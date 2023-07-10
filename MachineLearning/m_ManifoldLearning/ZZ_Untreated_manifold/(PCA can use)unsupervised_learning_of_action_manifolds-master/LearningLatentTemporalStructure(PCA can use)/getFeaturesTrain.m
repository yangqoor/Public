function [Features_train,Features_test,params] = getFeaturesTrain(Features,testIndex)

    [num_of_actions,num_of_persons] = size(Features);
    [max_num_of_subseqs,num_of_sets] = size(Features{1,1});
    Sets = 1:1:num_of_sets;
    
%     params.num_of_actions = num_of_actions;
%     params.num_of_persons = num_of_persons;
%     params.num_of_sets = num_of_sets;
%     params.max_num_of_subseqs = max_num_of_subseqs;
%     params.Sets = Sets;

    %Initialize the training Feature Set
    Features_train = Features(:,1:num_of_persons);
    Features_train(:,testIndex) = [];
    Features_HOF = cell(num_of_actions,size(Features_train,2)*num_of_sets*max_num_of_subseqs);
    Features_LBP = cell(num_of_actions,size(Features_train,2)*num_of_sets*max_num_of_subseqs);
    Features_RT = cell(num_of_actions,size(Features_train,2)*num_of_sets*max_num_of_subseqs);

    for k = 1:1:size(Features_train,1)
        for m = 1:1:size(Features_train,2) % iterating through sequence
            Features_per_set = Features_train{k,m};
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

    % NORMALIZATION OF HOF FEATURES
    Features_train = Features_HOF;
    Train_Data = [];
    [num_of_actions,num_of_videos2] = size(Features_train); % here videos2 = num_of_persons since the number of repetitions done by a person is 1
    for k = 1:1:num_of_videos2
        Tr = Features_train(:,k);
        Mr = cell2mat(Tr);
        Train_Data{k,1} = Mr;
    end
    CombinedActions = cell2mat(Train_Data);
    num_bins = 20;

    % decomposing into the three levels
    Level1_HOF = CombinedActions(:,1:num_bins);
    offset = num_bins;
    num_bins = num_bins / 2;
    Level2_HOF = CombinedActions(:,offset + 1: offset + num_bins*4);
    offset = offset + num_bins * 4;
    num_bins = num_bins / 2;
    Level3_HOF = CombinedActions(:,offset + 1: offset + num_bins*16);


    % add one more level if needed

    % finding the normalization factors for each level computed from all the
    % action sequences - I DO NOT UNDERSTAND THIS - SOMETHING WRONG
    NF_L1 = max(Level1_HOF(:)); % summing across the columns
    NF_L2 = max(Level2_HOF(:));
    NF_L3 = max(Level3_HOF(:));

    % creating the normalization vector to be divided by features at each frame
    % element by element
    num_bins = 20;
    %Norm_Factor_HOF = [NF_L1*ones(1,num_bins) NF_L2*ones(1,num_bins*2)];
    Norm_Factor_HOF = [NF_L1*ones(1,num_bins) NF_L2*ones(1,num_bins*2) NF_L3*ones(1,num_bins*4)];

    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_train{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_HOF,size(Data,1),1);
            Features_train{m,n} = Data;
        end
    end
    HOF_Flow = Features_train;

    % NORMALIZATION OF LBFP FEATURES
    Features_train = Features_LBP;
    Train_Data = [];
    [num_of_actions,num_of_videos2] = size(Features_train);
    for k = 1:1:num_of_videos2
        Tr = Features_train(:,k);
        Mr = cell2mat(Tr);
        Train_Data{k,1} = Mr;
    end
    CombinedActions = cell2mat(Train_Data);
    mapping = getmapping(8,'u2');
    num_bins = mapping.num-1;
    %mapping.table = 0:1:255;
    %mapping.num = 256;
    %num_bins = mapping.num;

    % decomposing into 2 levels
    Level1_LBP = CombinedActions(:,1:num_bins);
    offset = num_bins;
    Level2_LBP = CombinedActions(:,offset + 1: offset + num_bins*4);
    offset = offset + num_bins * 4;


    % finding the normalization factors for each level computed from all the
    % action sequences
    NF_L1 = max(Level1_LBP(:));
    NF_L2 = max(Level2_LBP(:));

    % creating the normalization vector to be divided by features at each frame
    % element by element
    Norm_Factor_LBP = [NF_L1*ones(1,num_bins) NF_L2*ones(1,num_bins*4)];

    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_train{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_LBP,size(Data,1),1);
            Features_train{m,n} = Data;
        end
    end
    LBP_Flow = Features_train;

    % NORMALIZATION OF RT
    Features_train = Features_RT;
    Train_Data = [];
    [num_of_actions,num_of_videos2] = size(Features_train);
    for k = 1:1:num_of_videos2
        Tr = Features_train(:,k);
        Mr = cell2mat(Tr);
        Train_Data{k,1} = Mr;
    end

    CombinedActions = cell2mat(Train_Data);
    num_bins = 36;

    % decomposing into the three levels
    Level1_RT = CombinedActions(:,1:num_bins);
    offset = num_bins;
    Level2_RT = CombinedActions(:,offset+1:offset + num_bins*4);
    offset = offset + num_bins * 4;
    %Level3_RT = CombinedActions(:,offset + 1: offset + num_bins*16);

    % finding the normalization factors for each level computed from all the
    % action sequences - I DO NOT UNDERSTAND THIS - SOMETHING WRONG
    NF_L1 = max(Level1_RT(:)); % summing across the columns
    NF_L2 = max(Level2_RT(:));
    %NF_L3 = max(Level3_RT(:));

    % creating the normalization vector to be divided by features at each frame
    % element by element
    num_bins = 36;
    %Norm_Factor_RT = [NF_L1*ones(1,num_bins)];
    Norm_Factor_RT = [NF_L1*ones(1,num_bins) NF_L2*ones(1,num_bins*4)]; %NF_L3*ones(1,num_bins*16)];

    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_train{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_RT,size(Data,1),1);
            Features_train{m,n} = Data;
        end
    end
    RT_Flow = Features_train;
    
    % Obtain the final features

    Features_train = CombineFeatures(HOF_Flow,LBP_Flow); % Motion CUES
    Features_train = CombineFeatures(Features_train,RT_Flow);
    
    % Initialize the Test feature set
    Features_test = Features(:,testIndex);
    Features_HOF_test = cell(num_of_actions,size(Features_test,2)*num_of_sets*max_num_of_subseqs);
    Features_LBP_test = cell(num_of_actions,size(Features_test,2)*num_of_sets*max_num_of_subseqs);
    Features_RT_test = cell(num_of_actions,size(Features_test,2)*num_of_sets*max_num_of_subseqs);


    for k = 1:1:size(Features_test,1)
        for m = 1:1:size(Features_test,2) % iterating through sequence
            Features_per_set = Features_test{k,m};
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
                Features_HOF_test{k,max_num_of_subseqs*num_of_sets*(m-1)+l} = HOF_temp;
                Features_LBP_test{k,max_num_of_subseqs*num_of_sets*(m-1)+l} = LBP_temp;
                Features_RT_test{k,max_num_of_subseqs*num_of_sets*(m-1)+l} = RT_temp;
            end
        end 
    end
    
    % Normalize the test features
        % NORMALIZATION OF HOF FEATURES
    Features_test = Features_HOF_test;
    [num_of_actions,num_of_videos2] = size(Features_test);
   
    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_test{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_HOF,size(Data,1),1);
            Features_test{m,n} = Data;
        end
    end
    HOF_Flow_test = Features_test;

    % NORMALIZATION OF LBFP FEATURES
    Features_test = Features_LBP_test;
    [num_of_actions,num_of_videos2] = size(Features_test);
    
    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_test{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_LBP,size(Data,1),1);
            Features_test{m,n} = Data;
        end
    end
    LBP_Flow_test = Features_test;

    % NORMALIZATION OF RT
    Features_test = Features_RT_test;
    [num_of_actions,num_of_videos2] = size(Features_test);
    
    %Normalize the features
    for m = 1:1:num_of_actions
        for n = 1:1:num_of_videos2
            Data = Features_test{m,n};
            if(length(Data) == 0)
                continue;
            end
            Data = Data ./ repmat(Norm_Factor_RT,size(Data,1),1);
            Features_test{m,n} = Data;
        end
    end
    RT_Flow_test = Features_test;
    
    Features_test = CombineFeatures(HOF_Flow_test,LBP_Flow_test); % Motion CUES
    Features_test = CombineFeatures(Features_test,RT_Flow_test);
    
    params.factor_HOF = Norm_Factor_HOF;
    params.factor_LBP = Norm_Factor_LBP;
    params.factor_RT = Norm_Factor_RT;

end

