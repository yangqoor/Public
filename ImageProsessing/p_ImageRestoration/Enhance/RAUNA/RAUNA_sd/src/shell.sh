#!/bin/sh

nohup python main.py \
--loss=1*VGG22 \
--epochs=70 \
--lr=1e-5 \
--stage=17 \
--gam=0.1 \
--lr_re=1e-3 \
--no_finetune \
--pre_train_de=. \
--pre_train_re=. \
--patch_size=64 \
--batch_size=6 \
--test_every=2000 \
--ft_epochs=30 \
--adjust_brightness=4.8 \
--lr_alpha=5e-2 \
--alpha=0.85 \
--data_range=1-970/1-15 \
--num_L=29 \
--save_dir=1220_ours \




