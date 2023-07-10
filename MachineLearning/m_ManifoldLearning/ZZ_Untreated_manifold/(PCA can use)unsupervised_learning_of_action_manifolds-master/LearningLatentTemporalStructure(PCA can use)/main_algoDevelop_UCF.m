% %% sample script for algorithm development
num_manifold_steps = 100;
% % loading the features
% load -mat ActionFeatures_KTH_EqualDiv_New_Ver8_WithVLBP
% max_num_of_subseqs = 4;
% % Select an arbitrary train and test set
% tic;
% testIndex = 2;
% % % get the training set
%  [Features_train,Features_test] = getFeaturesTrain(Features,testIndex);
% toc;
% % Training Autoencoder for each class
% % setting options
% tic;
% opts.epsilon_w = 0.1;
% opts.epsilon_vb = 0.1;
% opts.epsilon_vc = 0.1;
% opts.momentum = 0.9;
% opts.weightcost = 0.0002;
% opts.numepochs = 50;
% opts.sizes = [100 30];
% 
% % iterate through each action class
% sae = cell(num_of_actions,1);
% for action = 1:1:num_of_actions
%     % cumulate all features into one matrix with the sequence offsets
%     fun_s = @(x) size(x,1);
%     TrainingData = Features_train(action,:);
%     Size = cellfun(fun_s,TrainingData);
%     opts.seq_size = Size;
% 
%     % flip the matrices in each cell
%     for ce = 1:1:length(TrainingData)
%         if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
%             TrainingData{ce} = [];
%         end
%         TrainingData{ce} = TrainingData{ce}';
%     end
%     Inputs = cell2mat(TrainingData);
%     Inputs = Inputs';
%     
%     
%     sae{action} = stacked_autoencoder(Inputs,opts,true);
%     %[pc,net] = nlpca(Inputs,3); // Command takes super long time!!!
%     
%     fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED************************************\n',action); 
% end
% toc;
% % save the workspace 
% save('SAE_Workspace.mat');

% Obtain outputs of training for the trained auto-encoders
% To show evidence set the opts.sizes - [100 30 3]; three dimensional
% vectors
color_code = {'b','r','g','k','c','m'};
% h2 = figure(2);
% h3 = figure(3);
% outputs of sequences obtained from their respect autoencoder
for k = 4:1:size(Features_train,1)
 
    % get the stacked auto-encoder for action class k
    st = sae{k};
    
    % get all the training vectors for action class k
    TrainingData = Features_train(k,:);
    %Size = cellfun(fun_s,TrainingData);
    %opts.seq_size = Size;

    % flip the matrices in each cell
    for ce = 1:1:length(TrainingData)
        if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
            TrainingData{ce} = [];
        end
        TrainingData{ce} = TrainingData{ce}';
    end
    Inputs = cell2mat(TrainingData);
    Inputs = Inputs';
    
    % compute the outputs from the auto-encoder
    [Inputs_out,a_inputs_out] = sae_nn_ff(st,Inputs);
    
    % finding the variables with the most variance
    std_a_out = std(a_inputs_out);
    [ma,in1] = max(std_a_out);
    std_a_out(in1) = -1;
    [ma,in2] = max(std_a_out);
    std_a_out(in2) = -1;
    [ma,in3] = max(std_a_out);
    
    % compute the set of manifold steps as clusters of kmeans
    
    %[C,I] = yael_kmeans(single(a_inputs_out'),num_manifold_steps,'init',0,'redo',10);
    [w_C, C,sigma_C] = yael_gmm(single(a_inputs_out'),num_manifold_steps,'redo',10,'niter',100); 
    %[I,C] = kmeanspp(a_inputs_out',num_manifold_steps);
    C = double(C'); % number of rows refers to number of observation N x D
    figure(k);
    scatter3(C(:,1),C(:,2),C(:,3),'r','filled');
    figure(k+10);
    scatter3(a_inputs_out(:,1),a_inputs_out(:,2),a_inputs_out(:,3),'g*');
    
    % 
    
    
    % compute the topological ordering
    % get the squared distance of each cluster and sort it with accordance
    % to distance
    cluster_sqr_err = sum(C.^2,2);
    
    % this confirms that there is no ordering of labels the clusters along the
    % manifold although the clusters falls along the manifold
%     figure(k+6);
%     scatter3(C(:,1),C(:,2),C(:,3),'r','filled');
%     labels_C = num2str(unique(I));
%     labels_C_cell = cellstr(labels_C);
%     dx = 0.1;dy = 0.1;dz = 0.1;
%     text(C(:,1)+dx,C(:,2)+dy,C(:,3)+dz,labels_C_cell);
% 
%    for seq_num = 1:1:size(Features_train,2);
%         
%         % get the sequence
%         seq_data = Features_train{k,seq_num};
%         if(isempty(seq_data))
%             continue;
%         end
%         
%         % apply the auto-encoder of action class k to the sequences
%         [seq_data_out,a_out] = sae_nn_ff(st,seq_data);
%         
%         % find the corresponding cluster
%         figure(k+6);
%         scatter3(C(:,in1),C(:,in2),C(:,in3),'r','filled');
%         hold on;
%         
%         % plot the data for each action class
%         % 3d figure
%         %scatter3(a_out(:,1),a_out(:,2),a_out(:,3),color_code{k});
%         scatter3(a_out(:,1),a_out(:,2),a_out(:,3),'b*');
%         I = [1:1:size(seq_data,1)]';
%         labels_C = num2str(unique(I));
%         labels_C_cell = cellstr(labels_C);
%         dx = 0.01;dy = 0.01;dz = 0.01;
%         text(a_out(:,1)+dx,a_out(:,2)+dy,a_out(:,3)+dz,labels_C_cell);
%         
%         hold off;
%         
%         % redisplaying only the data plot and cluster plot for next
%         % sequence
% 
%         %scatter3(a_inputs_out(:,1),a_inputs_out(:,2),a_inputs_out(:,3),'g*');
% 
%         %plot3(a_out(:,1),a_out(:,2),a_out(:,3));
%         %plot(a_out(:,2),a_out(:,3));
%         %plot(a_out(:,1));
% %         figure(h2);
% %         plot(a_out(:,2));
% %         hold on;
% %         
% %         figure(h3);
% %         plot(a_out(:,3));
% %         hold on;
%         
%         
%     end
end