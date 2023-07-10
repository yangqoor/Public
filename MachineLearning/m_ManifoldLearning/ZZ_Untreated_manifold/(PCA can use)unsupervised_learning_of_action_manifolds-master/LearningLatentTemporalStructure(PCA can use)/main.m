%% Script file for training an auto-encoder for each action class
% What is required?
%       a) Set of features per action class
%       b) Function which takes in features per action class and outputs a
%          structure containing auto-encoder details
%       c) A set of options which is passed into the above function for
%          training the auto-encoder. These options are
%               (i) Learning rate of weights and biases: epsilon_w,
%               epsilon_vb, epsilon_vc or same rate "alpha"
%               (ii) initial/final momentum or same momentum
%               (iii) weight cost : cost of previous weight being taken off
%               (iv) Number of iterations or epochs 
%               (v) frames_per_seq : here, instead of updating weights by
%               taking a batch of 100 random samples, we update the weights
%               after providing frames of a single random sequence selected
%               for 1 epoch. After every epoch, the sequence are selected
%               again at random.
%               (vi) sizes : each element refers to the number of neurons in
%               the respective hidden layer. the number of element refers
%               to the number of neurons
% 需要什么？
% ％a）每个操作类的功能集
% ％b）根据每个操作类别输入特征的函数，并输出包含自动编码器细节的结构
% ％c）传递给上述函数的一组选项，用于训练自动编码器。这些选项是
% ％（i）权重和偏差的学习率：epsilon_w，epsilon_vb，epsilon_vc或相同的比率“alpha”
% （ii）初始/最终动力或相同动力
% ％（iii）重量成本：原重量的成本被取消
% ％（iv）迭代次数或时期
% ％（v）frames_per_seq：这里，而不是通过更新权重
% ％抽取一批100个随机样本，我们更新权重
% 在提供选择的单个随机序列的帧之后的％
% ％1个纪元。每个纪元后，序列被选中
% ％随机再次。
% ％（vi）大小：每个元素指的是神经元的数量
% ％相应的隐藏层。元素的数量指的是
% ％到神经元的数量

% % loading the features
% %load -mat ActionFeatures_KTH_EqualDiv_New_Ver8_WithVLBP
% %max_num_of_subseqs = 4;
num_manifold_steps = 100;
% win_size = 15;
% overlap = 14;
% %% Select an arbitrary train and test set
% testIndex = 2;
% % % get the training set
% Features_train = getFeaturesTrain(Features,testIndex);
% 
% % Training Autoencoder for each class
% %setting options
% opts.epsilon_w = 0.1;
% opts.epsilon_vb = 0.1;
% opts.epsilon_vc = 0.1;
% opts.momentum = 0.9;
% opts.weightcost = 0.0002;
% opts.numepochs = 50;
% opts.sizes = [300 100 30 3];
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
%     %sae{action} = stacked_autoencoder(Inputs,opts,true);
%     %[pc,net] = nlpca(Inputs,3); // Command takes super long time!!!
%     
%     fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED************************************\n',action); 
% end
%
%% Obtain outputs of training for the trained auto-encoders
% To show evidence set the opts.sizes - 
% vectors
color_code = {'b','r','g','k','c','m'};

% outputs of sequences obtained from their respect autoencoder
Clusters = cell(size(Features,1),1); % first index is the cluster index and the second is the index to which each data point belongs to
Sigmas = cell(size(Features,1),1);
Weights = cell(size(Features,1),1);

for k = 1:1:size(Features,1)
    % get the stacked auto-encoder
    st = sae{k};
    % get all the training vectors for action class k
    TrainingData = Features_train(k,:);
    Size = cellfun(fun_s,TrainingData);
    opts.seq_size = Size;

    % flip the matrices in each cell
    for ce = 1:1:length(TrainingData)
        if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
            TrainingData{ce} = [];
        end
        TrainingData{ce} = TrainingData{ce}';
    end
    Inputs = cell2mat(TrainingData);
    Inputs = Inputs';
    
    % Compute the clusters in the original space and find the mapping
    %[C_Inputs,I] = yael_kmeans(single(Inputs'),num_manifold_steps,'init',0,'redo',10);
    %C_Inputs = double(C_Inputs');
    %[C_Inputs_out,C] = sae_nn_ff(st,C_Inputs);
    
    % compute the ouputs from the auto-encoder from the clusters
    
    % compute the outputs from the auto-encoder
     [Inputs_out,a_inputs_out] = sae_nn_ff(st,Inputs);
%     
%     % finding the variables with the most variance
%     std_a_out = std(a_inputs_out);
%     [ma,in1] = max(std_a_out);
%     std_a_out(in1) = -1;
%     [ma,in2] = max(std_a_out);
%     std_a_out(in2) = -1;
%     [ma,in3] = max(std_a_out);
    
    % compute the set of manifold steps as clusters of kmeans
    
    %[C,I] = yael_kmeans(single(a_inputs_out'),num_manifold_steps,'init',0,'redo',10,'niter',100);
    [w_C, C,sigma_C] = yael_gmm(single(a_inputs_out'),num_manifold_steps,'redo',10,'niter',100); 
    %[I,C] = kmeanspp(a_inputs_out',num_manifold_steps);
    C = double(C'); % number of rows refers to number of observation N x D
    
    figure(k);
    scatter3(C(:,1),C(:,2),C(:,3),'r','filled');
    %hold on;
    %scatter3(a_inputs_out(:,1),a_inputs_out(:,2),a_inputs_out(:,3),'g*');
    %hold off;
    
    Clusters{k,1} = C;
    Sigmas{k,1} = double(sigma_C);
    Weights{k,1} = double(w_C);
    %Clusters{k,2} = I;
    
end
%%
% %% A sequence for all actions
% % outputs of sequences obtained from different auto-encoders
% % for each sequence
% seq_count = 0;
% color_code = {'b','r'}; % red means not belonging to that action class
% Train_Action_Accuracy = zeros(size(Features_train,1),size(Features_train,1));
% %bw_hist_action = cell(size(Features_train,2)/max_num_of_subseqs,size(Features_train,1));
% 
% for seq_num = 1:1:size(Features_train,2)
%     % projecting the data to different sub-spaces
%     for action = 1:1:size(Features_train,1)
%         seq_data_cell = Features_train(action,seq_num);
%         seq_data_cell{1} = seq_data_cell{1}';
%         
%         if(isempty(seq_data_cell{1}))
%             continue;
%         end
%         
%         % divide the sequence data into multiple sub-sequences
%         [seq_data_cell_subs,subset_size_seq] = SeperateFeatures(seq_data_cell,win_size,overlap);
%         delta = 5;
%         weight = 1;
%         % iterating through each sub-sequence
%                     %aviobj = avifile('mymovie.avi','fps',1);
%         myObj = VideoWriter('newfile.avi');
%         myObj.FrameRate = 5;
%         open(myObj);
%         set_of_feature_responses = cell(num_of_actions,1);
%         for k = 1:1:size(Features_train,1)
%             set_of_feature_responses{k} = zeros(subset_size_seq,num_manifold_steps);
%         end
%         for l = 1:1:subset_size_seq
%             seq_data = seq_data_cell_subs{l}';
%             Dist = zeros(size(Features_train,1),1);
%             
%             feature_responses = zeros(size(Features_train,1),num_manifold_steps);
% 
%             for k = 1:1:size(Features_train,1)
%                 % get the stacked auto-encoder for action class k
%                 st = sae{k}; 
%                 weights = Weights{k,1};
%                 sigmas = Sigmas{k,1};
%                 
%                 % apply the auto-encoder of action class k to the sequences
%                 [seq_data_out,a_out] = sae_nn_ff(st,seq_data);
% 
%                 % computing the distance to each cluster of the action
%                 C = Clusters{k,1};
%                 [ids,dis] = yael_nn(single(C'),single(a_out'),num_manifold_steps/10);
%                 
%                 val_acc = zeros(num_manifold_steps,1);
%                 % computing feature responses
%                 for p = 1:1:size(ids,2) % for each frame
%                     for q = 1:1:size(ids,1) % iterating through each neighbor
%                         weight = weights(ids(q,p));
%                         x_vec = a_out(p,:);
%                         mean_vec = C(ids(q,p),:);
%                         cov_mat = sigmas(:,ids(q,p));
%                         cov_mat = diag(cov_mat); % the covariance matrix of that gaussian
% 
%                         %val = exp(-1*(double(dis(id)))/delta.^2); % the delta and weight can be substituted for those obtained from GMM clustering
%                         val = exp(-1 * ( (x_vec -mean_vec) * cov_mat * (x_vec - mean_vec)'));
% 
%                         %feature_responses(k,ids(id)) = feature_responses(k,ids(id)) + weight*val;
%                         val_acc(ids(q,p)) = val_acc(ids(q,p)) + weight*val;
%                         % not weighted
%                         feature_responses(k,ids(q,p)) = feature_responses(k,ids(q,p)) + weight*val;
%                     end
%                 end
% 
%     %             for id = 1:1:length(ids)
%     %                 bw_hist(k,ids(id)) = bw_hist(k,ids(id)) + double(dis(id));
%     %             end
%     %             bw_hist(k,:) = bw_hist(k,:)./sum(bw_hist(k,:));
%                 %feature_responses(k,:) = feature_responses(k,:) / sum(feature_responses(k,:));
%                 
%                 set_of_feature_responses{k}(l,:) = feature_responses(k,:);
% 
%                 % error of input sequence and re-constructed sequence
%                 Dist(k) = sum(sum( (seq_data - seq_data_out).^2 ))/size(seq_data,1);
%             end
%             
%             %feature_responses = feature_responses ./ sum(feature_responses(:));
%             
%              % finding the class with the minimum error
%             [mi,class_est] = min(Dist);
% %             hf = figure(1);
% %             for k = 1:1:size(Features_train,1)
% %                 subplot(2,3,k); plot(feature_responses(k,:));
% %                 %set(h,'EraseMode','xor');
% %                 %axis([0 2000 0 1]);
% %                 s_title = sprintf('Action %d',k);
% %                 title(s_title);
% %                 xlabel('Clusters');
% %                 ylabel('Feature responses');
% %             end
% %             %set(hf,'EraseMode','xor');
% %             frame = getframe(hf);
% %             %aviobj = addframe(aviobj,frame);
% %             writeVideo(myObj,frame.cdata);
%              % row index : true action class; column index : estimated action
%             % class
%             Train_Action_Accuracy(action,class_est) = Train_Action_Accuracy(action,class_est) + 1;
%         end
%         
%         %aviobj = close(aviobj);
%         close(myObj);
% 
% 
%         %bw_hist = zeros(size(Features_train,1),num_manifold_steps); 
%         % applying to each au
%         
%         %bw_hist_action{seq_num,action} = bw_hist;
% 
%     end
%     
% end

%% For a single, show differences between sequences of same class and different action classes
% outputs of sequences obtained from different auto-encoders
% for each sequence
seq_count = 0;
color_code = {'b','r'}; % red means not belonging to that action class
Train_Action_Accuracy = zeros(size(Features_train,1),size(Features_train,1));
%bw_hist_action = cell(size(Features_train,2)/max_num_of_subseqs,size(Features_train,1));

for action = 1:1:size(Features_train,1)
    % projecting the data to different sub-spaces
    for seq_num = [1 10]%1:1:size(Features_train,2)
        seq_data_cell = Features_train(action,seq_num);
        seq_data_cell{1} = seq_data_cell{1}';
        
        if(isempty(seq_data_cell{1}))
            continue;
        end
        
        % divide the sequence data into multiple sub-sequences
        [seq_data_cell_subs,subset_size_seq] = SeperateFeatures(seq_data_cell,win_size,overlap);
        delta = 0.5;
        weight = 1;
        % iterating through each sub-sequence
                    %aviobj = avifile('mymovie.avi','fps',1);
        myObj = VideoWriter('newfile.avi');
        myObj.FrameRate = 5;
        open(myObj);
        set_of_feature_responses = cell(num_of_actions,1);
        for k = 1:1:size(Features_train,1)
            set_of_feature_responses{k} = zeros(subset_size_seq,num_manifold_steps);
        end
        for l = 1:1:subset_size_seq
            seq_data = seq_data_cell_subs{l}';
            Dist = zeros(size(Features_train,1),1);
            
            feature_responses = zeros(size(Features_train,1),num_manifold_steps);

            for k = 1:1:size(Features_train,1)
                % get the stacked auto-encoder for action class k
                st = sae{k}; 
                weights = Weights{k,1};
                sigmas = Sigmas{k,1};
                
                % apply the auto-encoder of action class k to the sequences
                [seq_data_out,a_out] = sae_nn_ff(st,seq_data);

                % computing the distance to each cluster of the action
                C = Clusters{k,1};
                [ids,dis] = yael_nn(single(C'),single(a_out'));
                
                val_acc = zeros(num_manifold_steps,1);
                % computing feature responses
                for p = 1:1:size(ids,2) % for each frame
                    for q = 1:1:size(ids,1) % iterating through each neighbor
                        %weight = weights(ids(q,p));
                        %x_vec = a_out(p,:);
                        %mean_vec = C(ids(q,p),:);
                        %cov_mat = sigmas(:,ids(q,p));
                        %cov_mat = diag(cov_mat); % the covariance matrix of that gaussian

                        %val = exp(-1*(double(dis(q,p)))/delta.^2); % the delta and weight can be substituted for those obtained from GMM clustering
                        val = double(dis(q,p));
                        %val = exp(-1 * ( (x_vec -mean_vec) * cov_mat * (x_vec - mean_vec)'));

                        %feature_responses(k,ids(q,p)) = feature_responses(k,ids(q,p)) + weight*val;
                        %val_acc(ids(q,p)) = val_acc(ids(q,p)) + weight*val;
                        % not weighted
                        feature_responses(k,ids(q,p)) = feature_responses(k,ids(q,p)) + val;
                    end
                end

    %             for id = 1:1:length(ids)
    %                 bw_hist(k,ids(id)) = bw_hist(k,ids(id)) + double(dis(id));
    %             end
    %             bw_hist(k,:) = bw_hist(k,:)./sum(bw_hist(k,:));
                feature_responses(k,:) = feature_responses(k,:) / sum(feature_responses(k,:));
                
                set_of_feature_responses{k}(l,:) = feature_responses(k,:);

                % error of input sequence and re-constructed sequence
                Dist(k) = sum(sum( (seq_data - seq_data_out).^2 ))/size(seq_data,1);
            end
            
            %feature_responses = feature_responses ./ sum(feature_responses(:));
            
             % finding the class with the minimum error
            [mi,class_est] = min(Dist);
%             hf = figure(1);
%             for k = 1:1:size(Features_train,1)
%                 subplot(2,3,k); plot(feature_responses(k,:));
%                 %set(h,'EraseMode','xor');
%                 axis([0 2000 0 1]);
%                 s_title = sprintf('Action %d',k);
%                 title(s_title);
%                 xlabel('Clusters');
%                 ylabel('Feature responses');
%             end
%             %set(hf,'EraseMode','xor');
%             frame = getframe(hf);
%             %aviobj = addframe(aviobj,frame);
%             writeVideo(myObj,frame.cdata);
             % row index : true action class; column index : estimated action
            % class
            Train_Action_Accuracy(action,class_est) = Train_Action_Accuracy(action,class_est) + 1;
        end
        
        %aviobj = close(aviobj);
        close(myObj);


        %bw_hist = zeros(size(Features_train,1),num_manifold_steps); 
        % applying to each au
        
        %bw_hist_action{seq_num,action} = bw_hist;

    end
    
end

% bw_hist_action can tell if sequences of same actions have similar
% responses to every action class with respect to the codewords of that
% action

% %% Computing the testing accuracy using only auto-encoders : Full Sequence
% % get the training set
% Test_Action_Accuracy = zeros(size(Features,1),size(Features,1));
% [num_of_actions,num_of_persons] = size(Features);
% [max_num_of_subseqs,num_of_sets] = size(Features{1,1});
% Features_train = {};
% Features_test = {};
% for testIndex = 1:1:num_of_persons
%     [Features_train,Features_test] = getFeaturesTrain(Features,testIndex);
% 
%     % Training Autoencoder for each class
%     %setting options
%     opts.epsilon_w = 0.1;
%     opts.epsilon_vb = 0.1;
%     opts.epsilon_vc = 0.1;
%     opts.momentum = 0.9;
%     opts.weightcost = 0.0002;
%     opts.numepochs = 50;
%     opts.sizes = [100 30];
% % 
%     % iterate through each action class
%     sae = cell(num_of_actions,1);
%     for action = 1:1:num_of_actions
%         % cumulate all features into one matrix with the sequence offsets
%         fun_s = @(x) size(x,1);
%         TrainingData = Features_train(action,:);
%         Size = cellfun(fun_s,TrainingData);
%         opts.seq_size = Size;
% 
%         % flip the matrices in each cell
%         for ce = 1:1:length(TrainingData)
%             if(sum(sum(isnan(TrainingData{ce}))) > 0) % if there is a NaN. ..ignore the sequence
%                 TrainingData{ce} = [];
%             end
%             TrainingData{ce} = TrainingData{ce}';
%         end
%         Inputs = cell2mat(TrainingData);
%         Inputs = Inputs';
% 
% 
%         sae{action} = stacked_autoencoder(Inputs,opts,true);
% 
%         fprintf('\n\t********************TRAINING AUTO-ENCODER FOR ACTION %d COMPLETED************************************\n',action); 
%     end
% 
%     for seq_num = 1:1:size(Features_test,2)
%         % projecting the data to different sub-spaces
%         for action = 1:1:size(Features_test,1)
%             seq_data = Features_test{action,seq_num};
% 
%             if(isempty(seq_data))
%                 continue;
%             end
% 
%             Dist = zeros(size(Features_test,1),1);
%             % applying to each auto-encoder
%             for k = 1:1:size(Features_test,1)
%                 % get the stacked auto-encoder for action class k
%                 st = sae{k}; 
% 
%                 % apply the auto-encoder of action class k to the sequences
%                 [seq_data_out,a_out] = sae_nn_ff(st,seq_data);
% 
%                 % error of input sequence and re-constructed sequence
%                 Dist(k) = sum(sum( (seq_data - seq_data_out).^2 ))/size(seq_data,1);
%             end
% 
%             % finding the class with the minimum error
%             [mi,class_est] = min(Dist);
% 
%             % row index : true action class; column index : estimated action
%             % class
%             Test_Action_Accuracy(action,class_est) = Test_Action_Accuracy(action,class_est) + 1;
% 
%         end
% 
%     end
%    
% % end of test index
% end
% 
% Acc = Test_Action_Accuracy*100./repmat(sum(Test_Action_Accuracy,2)',num_of_actions,1);