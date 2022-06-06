#!/bin/bash

echo Running shell script that trains CostFourierVelModel network with balanced data with a given split.

# Define python version
EXE_PYTHON=python3

# Define environment variables

# Varibales to find code
PACKAGE_DIR=/data/datasets/mguamanc/learned_cost_map
BASE_DIR=/data/datasets/mguamanc/learned_cost_map/scripts/learned_cost_map/trainer

# Variables for trainer
PY_TRAIN=train.py
DATA_DIR=/project/learningphysics/tartancost_data
# TRAIN_SPLIT=/data/datasets/mguamanc/learned_cost_map/scripts/learned_cost_map/splits/train_uniform.txt
# VAL_SPLIT=/data/datasets/mguamanc/learned_cost_map/scripts/learned_cost_map/splits/val_uniform.txt
TRAIN_LC_DIR=lowcost_5k
TRAIN_HC_DIR=highcost_10k
VAL_LC_DIR=lowcost_val_1k
VAL_HC_DIR=highcost_val_2k
MODEL=CostFourierVelModel
RUN_NAME=train_${MODEL}_bal_aug_l2
NUM_EPOCHS=50
BATCH_SIZE=1024
SEQ_LENGTH=1
LEARNING_RATE=0.0003
WEIGHT_DECAY=0.0000001
GAMMA=0.95
EVAL_INTERVAL=1
SAVE_INTERVAL=1
NUM_WORKERS=10



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
    --log_dir $RUN_NAME \
    --balanced_loader \
    --train_lc_dir $TRAIN_LC_DIR \
    --train_hc_dir $TRAIN_HC_DIR \
    --val_lc_dir $VAL_LC_DIR \
    --val_hc_dir $VAL_HC_DIR \
    --num_epochs $NUM_EPOCHS \
    --batch_size $BATCH_SIZE \
    -lr $LEARNING_RATE \
    --gamma $GAMMA \
    --weight_decay $WEIGHT_DECAY \
    --eval_interval $EVAL_INTERVAL \
    --save_interval $SAVE_INTERVAL \
    --num_workers $NUM_WORKERS\
    --multiple_gpus \
    --augment_data 
    # --pretrained

echo Training CostFourierVelModel network shell script ends.