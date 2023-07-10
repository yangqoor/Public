% Training of CRBM development, Generation of test sequence and visualization of generated sequence
%Load the Features and set variables and the trained autoencoders
%load SAE_Workspace;
%load CRBM_Trained_Layers;

% get the number of sequences
[num_of_actions,num_of_test_seqs] = size(Features_test);
[~,num_of_train_seqs] = size(Features_train);

% Compute the global codewords from the training set
global_C = [];
global_C_indices = [];
for seq_row = 1:1:num_of_actions
    C = clusters{seq_row};
    st = sae{seq_row};
    
    % project the clusters back into the input space
    C_input = sae_ff_nn_decoder(st,C);
    
    global_C = [global_C ; C_input];
    
    if(seq_row == 1)
        global_C_indices = 1:1:num_manifold_steps;
    else
        global_C_indices = [global_C_indices  (global_C_indices(end) + 1: global_C_indices(end) + num_manifold_steps)];
    end
end

% Plot the cluster codewords and the points from the training set
for seq_row = 6:1:num_of_actions 
    for seq_num = 2:1:num_of_train_seqs
        % get the sequence
        train_seq = Features_train{seq_row,seq_num};
        if(isempty(train_seq))
            continue;
        end
        
        X_train = train_seq;
        num_train_frames =size(train_seq,1);
        
%         % compare it with the global codewords
         %[ids,dis] = yael_nn(single(global_C'),single(train_seq'));
%         num_train_frames = size(train_seq,1);
%         
%         % Replace each frame with the codeword
%         X_train = zeros(num_test_frames,size(train_seq,2));
%         for k = 1:1:num_train_frames
%             X_train(k,:) = global_C(ids(k),:);
%         end
% 
%         % Remove consecutive duplicate codewords in the sequences
%         last_codeword_encoun = X_train(1,:);
%         dup_ids = zeros(num_test_frames,1);
%         for k = 2:1:num_train_frames
%             sum_dist = sum(sum((last_codeword_encoun - X_train(k,:)).^2));
%             if(sum_dist == 0) % duplicate : no change in last_codeword seen
%                 dup_ids(k) = 1;
%             else % if no duplicate
%                 last_codeword_encoun = X_train(k,:);
%             end
%         end
%         non_dup_ids = (~dup_ids);
%         rel_ids = find(non_dup_ids ~= 0);
        
        for act_num = 6:1:num_of_actions
            
            myObj = VideoWriter('TraversalOfLatentTemporalStructure_walk_action_from_left_to_right.avi');
            myObj.FrameRate = 1;
            open(myObj);
        
            st = sae{act_num};
            C = clusters{act_num};
            
            [X_train_out,a_X_train_out] = sae_nn_ff(st,X_train);

            hf = figure(act_num);
            scatter3(C(:,1),C(:,2),C(:,3),'c');
            hold on;
            
            frame = getframe(hf);
            writeVideo(myObj,frame.cdata);
            
            I = [1:1:size(X_train,1)]';
            labels_C = num2str(unique(I));
            labels_C_cell = cellstr(labels_C);
            dx = 0.01;dy = 0.01;dz = 0.01;
            
            for fr_num = 1:1:num_train_frames
                scatter3(a_X_train_out(fr_num,1),a_X_train_out(fr_num,2),a_X_train_out(fr_num,3),'r','filled');
                text(a_X_train_out(fr_num,1)+dx,a_X_train_out(fr_num,2)+dy,a_X_train_out(fr_num,3)+dz,labels_C_cell{fr_num});
                hold on;
                frame = getframe(hf);
                writeVideo(myObj,frame.cdata);
                pause(1);
            end
            
            close(myObj)
        end
        
        
    end
end

%% Need to divide the codewords of an action class into three contiguous groups.
% The three groups refers to specific states of the action
% Unsupervised learning of these groups of codewords or ordering is
% desired.
% Then, the percentage and position of manifold covered will then
% correspond to the distances for each cluster. Each cluster will have a
% variance associated with it and a sphere of influence. The extent of the
% clusters combined with give the action cycle. This is suitable only for
% one of the symmetric pairs. So, depending on the group, the correct
% symmetric can also be determined by knowing which cluster a window of
% frames are associated with. 
% Maybe try GMM Clustering on the codewords of each action. Let there by 6
% groups. ( Clusters of Clusters)
% So, from a window of test frames, each frame is associated with a
% codeword. This codeword will have a label of the higher cluster it is
% associated with it. The variance of the higher cluster can somehow be
% transformed into the location in the manifold as well as the state of the
% individual. The same concept can be used to provide the next phase in the
% action cycle.
% cluster_of_clusters = cell(num_of_actions,3);
% for act_num = 1:1:num_of_actions
%     % get the corresponding clusters
%     
%     C = clusters{act_num};
%     
%     % apply GMM clustering
%     [w_C1, C1,sigma_C1] = yael_gmm(single(C'),6,'redo',10,'niter',100);
%     C1 = double(C1');
%     w_C1 = double(w_C1); % probability of that cluster happening in that distribution
%     sigma_C1 = double(sigma_C1); % covariance of the gaussian associated with each cluster
%     
%     cluster_of_clusters{act_num,1} = C1;
%     cluster_of_clusters{act_num,2} = w_C1;
%     cluster_of_clusters{act_num,3} = sigma_C1;
% end

% Iterating through each test sequence
for seq_row = 6:1:num_of_actions
    for seq_num = 1:1:num_of_test_seqs
        % get the test sequence
        test_seq = Features_test{seq_row,seq_num};
        if(isempty(test_seq))
            continue;
        end
        
        X_test = test_seq;
        num_test_frames =size(test_seq,1);
        
        % compare it with the global codewords
         [ids,dis] = yael_nn(single(global_C'),single(test_seq'));
        num_test_frames = size(test_seq,1);
        
        % Replace each frame with the codeword
        X_test = zeros(num_test_frames,size(test_seq,2));
        for k = 1:1:num_test_frames
            X_test(k,:) = global_C(ids(k),:);
        end

        % Remove consecutive duplicate codewords in the sequences
        last_codeword_encoun = X_test(1,:);
        dup_ids = zeros(num_test_frames,1);
        for k = 2:1:num_test_frames
            sum_dist = sum(sum((last_codeword_encoun - X_test(k,:)).^2));
            if(sum_dist == 0) % duplicate : no change in last_codeword seen
                dup_ids(k) = 1;
            else % if no duplicate
                last_codeword_encoun = X_test(k,:);
            end
        end
        non_dup_ids = (~dup_ids);
        rel_ids = find(non_dup_ids ~= 0);
        
        X_test = X_test(rel_ids,:);
        
        
        
        % To determine the position of a ( 3*nt) frame window on the
        % manifold ( How to do that ? )
        C1 = cluster_of_clusters{seq_row};
        C = clusters{seq_row};
        figure(1);
        scatter3(C1(:,1),C1(:,2),C1(:,3),'r','filled');
        hold on;
        scatter3(C(:,1),C(:,2),C(:,3),'b')
    end
end
