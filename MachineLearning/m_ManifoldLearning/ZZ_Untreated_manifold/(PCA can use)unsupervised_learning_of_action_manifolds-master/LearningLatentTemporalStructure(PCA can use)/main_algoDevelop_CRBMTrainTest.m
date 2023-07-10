% Training of CRBM development, Generation of test sequence and visualization of generated sequence
%Load the Features and set variables and the trained autoencoders
load SAE_Workspace;
[num_of_actions,num_sequences] = size(Features_train);
num_manifold_steps = 2000;

%Set the options for the training of CRBM parameters
%For now, considering only 
opts_crbm.n{1} = 5;
opts_crbm.n{2} = 5;
opts_crbm.sizes = [200 200]; % originally 150
opts_crbm.gsd = 1;
opts_crbm.nt = 5; % number of previous frames used for computing weights in the current frame
opts_crbm.batchsize = 100;
opts_crbm.epsilon_w = 1e-5; % changed to 10^-4 because 10^-3 wasn't converging
opts_crbm.epsilon_bi = 1e-5;
opts_crbm.epsilon_bj = 1e-5;
opts_crbm.epsilon_A = 1e-5;
opts_crbm.epsilon_B = 1e-5;
opts_crbm.w_decay = 0.0002;
opts_crbm.momentum = 0.9;
opts_crbm.num_epochs = 500; % 2000 iterations not required as error is same at 500 iterations
opts_crbm.numGibbs = 200;
opts_crbm.dropRate = 1;

% cell array holding structures for the trained crbm model
crbm = cell(num_of_actions,1);
clusters = cell(num_of_actions,1);
cluster_sigmas = cell(num_of_actions,1);
cluster_weights = cell(num_of_actions,1);
% 
% Iterate through each action
for act_num = 4:1:num_of_actions
    
%     get the stacked auto-encoder
    st = sae{act_num};
    
%     get all the training vectors for action class 'act_num'
    TrainingData = Features_train(act_num,:);
    Size = cellfun(fun_s,TrainingData);

%     flip the matrices in each cell
    for ce = 1:1:length(TrainingData)
        if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
            TrainingData{ce} = [];
        end
        TrainingData{ce} = TrainingData{ce}';
    end
    Inputs = cell2mat(TrainingData);
    Inputs = Inputs';
    
%     compute the outputs from the auto-encoder of class 'act_num'
    [Inputs_out,a_inputs_out] = sae_nn_ff(st,Inputs);
    
% %     % % Perform clustering to get suitable approximation of manifold
% %     % [C,I] = yael_kmeans(single(a_inputs_out'),num_manifold_steps,'init',0,'redo',10,'niter',100);
% %     % C = double(C');
% %     
% %     [w_C, C,sigma_C] = yael_gmm(single(a_inputs_out'),num_manifold_steps,'redo',10,'niter',100);
% %     C = double(C');
% %     
% %     fprintf('*** Finished computing clusters. Now for CRBM Training ******\n');
% %     
% %     clusters{act_num} = C;
% %     cluster_sigmas{act_num} = sigma_C;
% %     cluster_weights{act_num} = w_C;
    
%     For each sequence, find the closest codeword to each frame feature vector, note the
%     index and replace the frame feature vector with the codeword vector
    a_crbm_train_inputs = [];
    for ce = 1:1:length(TrainingData)
        if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
            TrainingData{ce} = [];
        end
        TrainingData{ce} = TrainingData{ce}';
        
%         the above commands flips each matrix back to original dimensions 
        X_seq = TrainingData{ce};
        if(isempty(X_seq))
            continue;
        end
        
%         apply the auto-encoder to each action class
        [X_seq_rec,a_X_seq] = sae_nn_ff(st,X_seq);
        
        % find the nearest codeword to the cluster
        [ids,dis] = yael_nn(single(C'),single(a_X_seq'));
        num_frames = size(a_X_seq,1);
        
        % Replace each frame with the codeword
        a_X_seq_clusters = zeros(num_frames,size(a_X_seq,2));
        for k = 1:1:num_frames
            a_X_seq_clusters(k,:) = C(ids(k),:);
        end
        
        % Remove consecutive duplicate codewords in the sequences
        last_codeword_encoun = a_X_seq_clusters(1,:);
        dup_ids = zeros(num_frames,1);
        for k = 2:1:num_frames
            sum_dist = sum(sum((last_codeword_encoun - a_X_seq_clusters(k,:)).^2));
            if(sum_dist == 0) % duplicate : no change in last_codeword seen
                dup_ids(k) = 1;
            else % if no duplicate
                last_codeword_encoun = a_X_seq_clusters(k,:);
            end
        end
        non_dup_ids = (~dup_ids);
        rel_ids = find(non_dup_ids ~= 0);
        a_X_seq_clusters = a_X_seq_clusters(rel_ids,:);
        
        a_crbm_train_inputs = [a_crbm_train_inputs ; a_X_seq_clusters];
        Size(ce) = size(a_X_seq_clusters,1);
        
        a_crbm_train_inputs = [a_crbm_train_inputs ; a_X_seq(1:opts_crbm.dropRate:end,:)];
        Size(ce) = size(a_X_seq(1:opts_crbm.dropRate:end,:),1);
        
    end
    
%     Training the CRBM network
    opts_crbm.seq_lengths = Size;
    
%     training to model transitions from codeword to the next
    crbm_local = trainCRBM(a_crbm_train_inputs,opts_crbm);
    crbm{act_num} = crbm_local;
    
    fprintf('\n\n************************** COMPLETED CRBM TRAINING FOR ACTION CLASS %d **********************************\n\n',act_num);
end

%%
% Find the global codewords
            %%%%% Instead of finding the nearest codeword only from a
            %%%%% specific action class, we can accumulate the codewords
            %%%%% from all classes and find the nearest one. Finding the
            %%%%% codeword of only a specific class will remove the effect
            %%%%% of test sequence and obtain a random noise vector from
            %%%%% that action class. 
            %%%%% So, when codewords of all action classes are used, then
            %%%%% the test vector coming from a certain distribution will
            %%%%% have most of its frame locking on codewords from that
            %%%%% distribution only. If some codewords from another
            %%%%% distribution get fired, 
global_C = [];
global_C_indices = [];
for act_num = 1:1:num_of_actions
    C = clusters{act_num};
    st = sae{act_num};
    
    % project the clusters back into the input space
    C_input = sae_ff_nn_decoder(st,C);
    
    global_C = [global_C ; C_input];
    
    if(act_num == 1)
        global_C_indices = 1:1:num_manifold_steps;
    else
        global_C_indices = [global_C_indices  (global_C_indices(end) + 1: global_C_indices(end) + num_manifold_steps)];
    end
end
%%

% %%
% 
% % Testing the trained CRBM models for each test sequence
% % Generate the sequence after a few frame initialization
% % Compare the test sequence with the self-generated sequence 
% % Find the action class with the least distance
% 
% Test_CRBM = zeros(num_of_actions,num_of_actions);
% Test_AutoEncoder = zeros(num_of_actions,num_of_actions);
% dist_of_action_from_all = [];
% 
% for seq_row = 1:1:size(Features_test,1)
%     for seq_num = 1:1:size(Features_test,2)
%         
%         % get the test sequence
%         test_seq = Features_test{seq_row,seq_num};
%         dist_to_action_crbm = zeros(num_of_actions,1);
%         dist_to_action_autoencoder = zeros(num_of_actions,1);
%         
%         % Find the nearest neighbors of the test sequence among the set of
%         % codewords
%         [ids,dis] = yael_nn(single(global_C'),single(test_seq'));
%         num_test_frames = size(test_seq,1);
%         
%         % Replace each frame with the codeword
%         X_test = zeros(num_test_frames,size(test_seq,2));
%         for k = 1:1:num_test_frames
%             X_test(k,:) = global_C(ids(k),:);
%         end
% 
%         % Remove consecutive duplicate codewords in the sequences
%         last_codeword_encoun = X_test(1,:);
%         dup_ids = zeros(num_test_frames,1);
%         for k = 2:1:num_test_frames
%             sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
%             if(sum_dist == 0) % duplicate : no change in last_codeword seen
%                 dup_ids(k) = 1;
%             else % if no duplicate
%                 last_codeword_encoun = X_test(k,:);
%             end
%         end
%         non_dup_ids = (~dup_ids);
%         rel_ids = find(non_dup_ids ~= 0);
%         
%         X_test = X_test(rel_ids,:);
%         num_frames_gen = size(X_test,1);
% 
%         for act_num = 1:1:num_of_actions    
%             close all;
%             st = sae{act_num};
%             crbm_local = crbm{act_num};
% 
%             % sample the sequence
%             %test_seq = test_seq(1:crbm_local.dropRate:end,:);
% 
%             % apply the auto-encoder
%             [X_test_out,a_X_test_out] = sae_nn_ff(st,X_test);
%             
%             % Finding the distance of the reconstructed clusters and true
%             % clusters 
%             dist_to_action_autoencoder(act_num) = sqrt(sum(sum( (X_test - X_test_out).^2 )))/size(X_test,1);
% 
%             % Normalizing the data to pass it to CRBM
%             a_X_test_out_norm = (a_X_test_out - repmat(crbm_local.data_mean,num_frames_gen,1))./(repmat(crbm_local.data_std,num_frames_gen,1));
% 
%             start_fr_num = 1;
% 
%             % apply the crbm
%             crbm_local.numGibbs = 1000;
%             [a_X_test_out_rec_norm,hidden1,hidden2] = testCRBM(crbm_local,num_frames_gen,a_X_test_out_norm,start_fr_num);
%             
%             % get the unnormalized version from the regenerated sequence
%             a_X_test_out_rec = (a_X_test_out_rec_norm .* repmat(crbm_local.data_std,num_frames_gen,1)) + repmat(crbm_local.data_mean,num_frames_gen,1);
%             
%             % apply the decoder
%             X_test_out_rec = sae_ff_nn_decoder(st,a_X_test_out_rec);
%             
%             % computing the distance between the reconstructed sequence and
%             % test sequence
% %             dist_to_man = 0;
% %             for k = 2*opts_crbm.nt+1:1:4*opts_crbm.nt  
% %                 
% %                 %x_vec = a_X_test_out_rec_norm(k,:);
% %                 %mean_vec = a_X_test_out_norm(k,:);
% %                 
% %                 %dist_to_man =  dist_to_man + (x_vec -mean_vec) * inv(cov_mat) * (x_vec - mean_vec)';
% %                 dist_to_man = dist_to_man + (x_vec -mean_vec) * (x_vec - mean_vec)';
% %                 
% %             end
% %             dist_to_action_crbm(act_num) = sqrt(dist_to_man)/(10);
%             
%             dist_to_action_crbm(act_num) = sqrt(sum(sum( (X_test - X_test_out_rec).^2 )))/size(X_test,1);
% 
%         end
%         
%         % determining the action class from the CRBM
%         %dist_to_action_combined = dist_to_action_autoencoder + dist_to_action_crbm
%         
%         [min_dist,min_I] = min(dist_to_action_crbm);
%         Test_CRBM(seq_row,min_I) = Test_CRBM(seq_row,min_I) + 1;
%         
%         [min_dist,min_I] = min(dist_to_action_autoencoder);
%         Test_AutoEncoder(seq_row,min_I) = Test_AutoEncoder(seq_row,min_I) + 1;
%         
%         dist_of_action_from_all = [dist_of_action_from_all dist_to_action_crbm];
%         
%     end
% 
% end
