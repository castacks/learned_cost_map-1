from collections import OrderedDict
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from learned_cost_map.trainer.model import CostModel

from learned_cost_map.trainer.utils import *

import wandb

USE_WANDB = True

def traversability_cost_loss(model, x, y):
    pred_cost = model(x)
    criterion = nn.MSELoss(reduction="sum")
    pred_cost = pred_cost.squeeze()
    # Get loss averaged accross batch
    loss = criterion(pred_cost, y)/pred_cost.shape[0]

    return loss, OrderedDict(loss=loss)

def run_train_epoch(model, train_loader, optimizer, grad_clip = None):
    model.train()
    all_metrics = []
    for i, data_dict in enumerate(train_loader):
        print(f"Training batch {1}")
        x, y = preprocess_data(data_dict)

        loss, _metric = traversability_cost_loss(model, x, y)
        print(f"Loss: {loss}")
        all_metrics.append(_metric)
        optimizer.zero_grad()
        loss.backward()
        
        if grad_clip:
            torch.nn.utils.clip_grad_norm_(model.parameters(), grad_clip)
        optimizer.step()

    return avg_dict(all_metrics)

def get_val_metrics(model, val_loader):
    model.eval()
    all_metrics = []
    with torch.no_grad():
        for data_dict in val_loader:
            x, y = preprocess_data(data_dict    )
            loss, _metric = traversability_cost_loss(model, x, y)
            all_metrics.append(_metric)

    return avg_dict(all_metrics)


def main(log_dir, num_epochs = 20, batch_size = 256, seq_length = 10,
         grad_clip=None, lr = 1e-3, eval_interval = 5):

    # os.makedirs('data/'+ log_dir, exist_ok = True)
    train_loader, val_loader = get_dataloaders(batch_size, seq_length)

    model = CostModel(input_channels=8, output_size=1).cuda()
    optimizer = optim.Adam(model.parameters(), lr=lr)


    if USE_WANDB:
        config = {
            'batch_size': batch_size,
            'seq_length': seq_length,
            'lr': lr,
            'grad_clip': grad_clip,
            'num_epochs': num_epochs,
            'eval_interval': eval_interval
        }
        wandb.init(project="SARA", reinit=True, config=config)


    for epoch in range(num_epochs):
        print(f'Epoch: {epoch}')
        train_metrics = run_train_epoch(model, train_loader, optimizer, grad_clip)
        val_metrics = get_val_metrics(model, val_loader)

        #TODO : add plotting code for metrics (required for multiple parts)
        if USE_WANDB:
            train_metrics['epoch'] = epoch
            val_metrics['epoch'] = epoch
            train_metrics = {"train/"+k:v for k,v in train_metrics.items()}
            val_metrics = {"validation/"+k:v for k,v in val_metrics.items()}
            wandb.log(data=train_metrics, step=epoch)
            wandb.log(data=val_metrics, step=epoch)

        if (epoch+1)%eval_interval == 0:
            print(epoch, train_metrics)
            print(epoch, val_metrics)




if __name__ == '__main__':
    # Run training loop
    main('test_run', num_epochs = 20, batch_size = 1, seq_length = 10,
         grad_clip=None, lr = 1e-3, eval_interval = 1)