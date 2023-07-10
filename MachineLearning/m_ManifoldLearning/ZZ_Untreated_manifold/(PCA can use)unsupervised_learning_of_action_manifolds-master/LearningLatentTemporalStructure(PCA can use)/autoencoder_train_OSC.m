% Auto-Encoder Training OSC file
parfor act_num = 1:num_of_actions
    sae{act_num} = stacked_autoencoder(Inputs_per_action{act_num},opts_auto_per_action{act_num},true);
    fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED RUN: %d ************************************\n',act_num,rr);
end