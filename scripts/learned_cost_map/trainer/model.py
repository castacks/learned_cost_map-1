import numpy as np
import torch
import torch.nn as nn
import torchvision.models as models

class CostModel(nn.Module):
    def __init__(self, input_channels, output_size):
        super().__init__()
        self.model = models.resnet18()
        self.model.conv1 = nn.Conv2d(in_channels=input_channels, out_channels=64, kernel_size=(7,7), stride=(2,2), padding=(3,3), bias=False)
        self.model.fc = nn.Linear(in_features=512, out_features=output_size, bias=True)

        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        output = self.model(x)
        output = self.sigmoid(output)
        return output


class CostVelModel(nn.Module):
    def __init__(self, input_channels, embedding_size, output_size):
        super().__init__()
        self.model = models.resnet18()
        self.model.conv1 = nn.Conv2d(in_channels=input_channels, out_channels=64, kernel_size=(7,7), stride=(2,2), padding=(3,3), bias=False)
        self.model.fc = nn.Linear(in_features=512, out_features=embedding_size, bias=True)

        self.vel_mlp = nn.Sequential([
            nn.Linear(in_features=1, out_features=512),
            nn.ReLU(),
            nn.Linear(in_features=512, out_features=512),
            nn.ReLU(),
            nn.Linear(in_features=512, out_features=512),
            nn.ReLU()
        ])

        self.output_mlp = nn.Sequential([
            nn.Linear(in_features=1024, out_features=output_size)
        ])
        self.sigmoid = nn.Sigmoid()

    def forward(self, x, vel):
        processed_maps = self.model(x)
        processed_vel  = self.vel_mlp(vel)
        combined_features = torch.cat(processed_maps, processed_vel)
        output = self.output_mlp(combined_features)
        output = self.sigmoid(output)
        return output


class CostFourierVelModel(nn.Module):
    def __init__(self, input_channels, ff_size, embedding_size, output_size):
        super().__init__()
        self.model = models.resnet18()
        self.model.conv1 = nn.Conv2d(in_channels=input_channels, out_channels=64, kernel_size=(7,7), stride=(2,2), padding=(3,3), bias=False)
        self.model.fc = nn.Linear(in_features=512, out_features=embedding_size, bias=True)

        self.vel_mlp = nn.Sequential([
            nn.Linear(in_features=ff_size, out_features=512),
            nn.ReLU(),
            nn.Linear(in_features=512, out_features=512),
            nn.ReLU(),
            nn.Linear(in_features=512, out_features=512),
            nn.ReLU()
        ])

        self.output_mlp = nn.Sequential([
            nn.Linear(in_features=1024, out_features=output_size)
        ])
        self.sigmoid = nn.Sigmoid()

    def forward(self, x, vel):
        processed_maps = self.model(x)
        processed_vel  = self.vel_mlp(vel)
        combined_features = torch.cat(processed_maps, processed_vel)
        output = self.output_mlp(combined_features)
        output = self.sigmoid(output)
        return output


if __name__ == "__main__":
    model = CostModel(8, 1)
