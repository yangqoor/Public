function Features_train_bg = getFeaturesTrain_bg(Features,testIndex,params)

    [num_of_actions,num_of_persons] = size(Features);
    [max_num_of_subseqs,num_of_sets] = size(Features{1,1});
    Sets = 1:1:num_of_sets;
    
%     num_of_actions = params.num_of_actions;
%     num_of_persons = params.num_of_persons;
%     num_of_sets = params.num_of_sets;
%     max_num_of_subseqs = params.max_num_of_subseqs;
%     Sets = params.Sets;

    %Initialize the training Feature Set
    Features_train_bg = Features(:,1:num_of_persons);
    Features_train_bg(:,testIndex) = [];
    Features_HOF = cell(num_of_actions,size(Features_train_bg,2)*num_of_sets*max_num_of_subseqs);
    Features_LBP = cell(num_of_actions,size(Features_train_bg,2)*num_of_sets*max_num_of_subseqs);
    Features_RT = cell(num_of_actions,size(Features_train_bg,2)*num_of_sets*max_num_of_subseqs);

    for k = 1:1:size(Features_train_bg,1)
        for m = 1:1:size(Features_train_bg,2) % iterating through sequence
            Features_per_set = Features_train_bg{k,m};
            % removing the last set
            Features_per_set = Features_per_set(:,Sets);
            Features_per_set = reshape(Features_per_set,length(Features_per_set(:)),1);
            % Iterating for a specific set
            set = 1;
            for l = 1:1:size(Features_per_set,1) % iterating through subsequence
                Features_per_subseq = Features_per_set{l,set};
                try
                    HOF_temp = Features_per_subseq{1};
                    LBP_temp = Features_per_subseq{2};
                    RT_temp = Features_per_subseq{3};
                catch exception
                    disp(exception)
                    HOF_temp = [];
                    LBP_temp = [];
                    RT_temp = [];
                end
                Features_HOF{k,max_num_of_subseqs*num_of_sets*(m-1)+l} = HOF_temp;
                Features_LBP{k,max_num_of_subseqs*num_of_sets*(m-1)+l} = LBP_temp;
                Features_RT{k,max_num_of_subseqs*num_of_sets*(m-1)+l} = RT_temp;
            end
        end 
    end

    Norm_Factor_HOF = params.factor_HOF;
    Norm_Factor_LBP = params.factor_LBP;
    Norm_Factor_RT = params.factor_RT;
    
    % Normalize the test features
    % NORMALIZATION OF HOF FEATURES
    Features_train_bg = Features_HOF;
    [num_of_actions,num_of_videos2] = size(Features_train_bg);
   
    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_train_bg{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_HOF,size(Data,1),1);
            Features_train_bg{m,n} = Data;
        end
    end
    HOF_Flow = Features_train_bg;

    % NORMALIZATION OF LBFP FEATURES
    Features_train_bg = Features_LBP;
    [num_of_actions,num_of_videos2] = size(Features_train_bg);
    
    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_train_bg{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_LBP,size(Data,1),1);
            Features_train_bg{m,n} = Data;
        end
    end
    LBP_Flow = Features_train_bg;

    % NORMALIZATION OF RT
    Features_train_bg = Features_RT;
    [num_of_actions,num_of_videos2] = size(Features_train_bg);
    
    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_train_bg{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_RT,size(Data,1),1);
            Features_train_bg{m,n} = Data;
        end
    end
    RT_Flow = Features_train_bg;
    
    Features_train_bg = CombineFeatures(HOF_Flow,LBP_Flow); % Motion CUES
    Features_train_bg = CombineFeatures(Features_train_bg,RT_Flow);

end

