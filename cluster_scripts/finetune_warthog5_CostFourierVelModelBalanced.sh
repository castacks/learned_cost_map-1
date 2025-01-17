#!/bin/bash

echo Running shell script that fine-tunes CostFourierVelModel network with balanced Wanda data with a given split.

# Define python version
EXE_PYTHON=python3

# Define environment variables

# Varibales to find code
PACKAGE_DIR=/data/datasets/mguamanc/learned_cost_map
BASE_DIR=/data/datasets/mguamanc/learned_cost_map/scripts/learned_cost_map/trainer

# Variables for trainer
PY_TRAIN=train.py
DATA_DIR=/project/learningphysics/tartancost_arl_20220922
# TRAIN_SPLIT=/data/datasets/mguamanc/learned_cost_map/scripts/learned_cost_map/splits/train_uniform.txt
# VAL_SPLIT=/data/datasets/mguamanc/learned_cost_map/scripts/learned_cost_map/splits/val_uniform.txt
TRAIN_LC_DIR=lowcost_2500
TRAIN_HC_DIR=highcost_7000
VAL_LC_DIR=lowcost_val_500
VAL_HC_DIR=highcost_val_800
MODEL=CostFourierVelModel
FOURIER_SCALE=10.0
NUM_EPOCHS=50
BATCH_SIZE=1024
LEARNING_RATE=0.00003
WEIGHT_DECAY=0.0000001
GAMMA=0.99
EVAL_INTERVAL=1
SAVE_INTERVAL=1
NUM_WORKERS=10
EMBEDDING_SIZE=512
MLP_SIZE=512
NUM_FREQS=8
SAVED_MODEL=/data/datasets/mguamanc/learned_cost_map/models/train_CostFourierVelModel_MLP_512_freqs_8_moredata_1/epoch_50.pt
SAVED_FREQS=/data/datasets/mguamanc/learned_cost_map/models/train_CostFourierVelModel_MLP_512_freqs_8_moredata_1/fourier_freqs.pt
MODELS_DIR=/data/datasets/mguamanc/learned_cost_map/models
MAP_CONFIG=/data/datasets/mguamanc/learned_cost_map/configs/wanda_map_params.yaml
RUN_NAME=finetune_warthog5_${MODEL}_MLP_${MLP_SIZE}_lr_${LEARNING_RATE}_freqs_${NUM_FREQS}_betterData_0



# Install learned_cost_map package
cd $PACKAGE_DIR
sudo pip3 install -e .

# Login to Weights and Biases
wandb login b47938fa5bae1f5b435dfa32a2aa5552ceaad5c6
export WANDB_MODE=offline
wandb init -p SARA

# # Run split script
# ${EXE_PYTHON} $BASE_DIR/$PY_SPLIT \
#     --num_train $NUM_TRAIN \
#     --num_val $NUM_VAL \
#     --all_train_fp $ALL_TRAIN_FP \
#     --all_val_fp $ALL_VAL_FP \
#     --output_dir $OUTPUT_DIR

echo Running standard split

# Run trainer
${EXE_PYTHON} $BASE_DIR/$PY_TRAIN \
    --model $MODEL \
    --data_dir $DATA_DIR \
    --models_dir $MODELS_DIR \
    --log_dir $RUN_NAME \
    --map_config $MAP_CONFIG \
    --balanced_loader \
    --train_lc_dir $TRAIN_LC_DIR \
    --train_hc_dir $TRAIN_HC_DIR \
    --val_lc_dir $VAL_LC_DIR \
    --val_hc_dir $VAL_HC_DIR \
    --num_epochs $NUM_EPOCHS \
    --batch_size $BATCH_SIZE \
    --embedding_size $EMBEDDING_SIZE \
    --mlp_size $MLP_SIZE \
    --num_freqs $NUM_FREQS \
    -lr $LEARNING_RATE \
    --gamma $GAMMA \
    --weight_decay $WEIGHT_DECAY \
    --eval_interval $EVAL_INTERVAL \
    --save_interval $SAVE_INTERVAL \
    --num_workers $NUM_WORKERS\
    --multiple_gpus \
    --augment_data \
    --fourier_scale $FOURIER_SCALE \
    --fine_tune \
    --saved_model $SAVED_MODEL \
    --saved_freqs $SAVED_FREQS \
    --wanda
    # --pretrained

echo Fine-tuning Wanda CostFourierVelModelBalanced network shell script ends.