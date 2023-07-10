% function to use the trained CRBM to generate a sequence given a set of
% initial frames
% Currently written for only two layer CRBM
function [gen_X,gen_X_hidden1,gen_X_hidden2] = testCRBM(crbm,num_frames_gen,X_initialdata,start_fr)

% num_frames_gen : number of frames to generate

% set parameters for testing
numGibbs = crbm.numGibbs;
n1 = crbm.rbm{1}.nt; % order of layer 1
n2 = crbm.rbm{2}.nt; % order of layer 2

% getting out the weights of layer 1
A1 = crbm.rbm{1}.A;
B1 = crbm.rbm{1}.B;
w1 = crbm.rbm{1}.w;
gsd = crbm.rbm{1}.gsd;
bj1 = crbm.rbm{1}.bj;   
bi1 = crbm.rbm{1}.bi;
num_hid1 = crbm.rbm{1}.num_hid;

% getting out the weights of layer 1
A2 = crbm.rbm{2}.A;
B2 = crbm.rbm{2}.B;
w2 = crbm.rbm{2}.w;
bj2 = crbm.rbm{2}.bj;
bi2 = crbm.rbm{2}.bi;
num_hid2 = crbm.rbm{2}.num_hid;

% re-shape A and B : this is for mulitplying with the past values which are
% unrolled.
A2_flat = reshape(A2,num_hid1,n2 * num_hid1);
B2_flat = reshape(B2,num_hid2, n2 * num_hid1);

max_clamped = n1 + n2;

% number of hidden units to generate
num_cases = n2; 

% initialize visible data
num_dims = size(X_initialdata,2);
visible = zeros(num_frames_gen,num_dims);

% starting frame used : start_fr. Use the first frame of X_initialdata
visible(1:max_clamped,:) = X_initialdata(start_fr:start_fr + max_clamped-1,:);     
    
data = zeros(num_cases,num_dims,n1 + 1);
dataindex = n1+1:max_clamped;

data(:,:,1) = visible(dataindex,:); % current frames
% store delayed data : storing the various states 
for hh = 1:1:n1
    data(:,:,hh+1) = visible(dataindex-hh,:);
end

% calculates the contributions from directed visible-to-hidden
% connections
bj_star = zeros(num_hid1,num_cases);
for hh = 1:1:n1
    bj_star = bj_star + B1(:,:,hh) * data(:,:,hh+1)';
end

% calculate the posterior probability 
eta = w1* (data(:,:,1)./gsd)' + repmat(bj1,1,num_cases) + bj_star; % data at frames 4,5,6 ; bj_star accumulated from state(t-1) = {3,4,5}; state(t-2) = {2,3,4}; state(t-3) = {1,2,3}
hposteriors = 1./(1+exp(-eta));
    
% Initialize hidden layer 1 with those obtained from the initial data
hidden1 = ones(num_frames_gen,num_hid1);
hidden1(n1+1 : n1+n2,:) = hposteriors';  %  generating hidden nodes for frame {4,5,6} from visible {1,2,3,4,5,6}

% intialize second layer ( first n1+n2 frames padded)
    
% keep the recent past in vector form : arrange the hidden nodes at three
% frames(4,5,6) as one long vector ( 150 * 3,1); Tehen in every new frame,
% 150 elements are shifted down/right in the vector
past = reshape(hidden1(max_clamped:-1:max_clamped+1-n2,:)',num_hid1*n2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First generate a hidden sequence (top layer)
%Then go down through the first CRBM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fprintf('Generating hidden states\n');

if(max_clamped+1 >= num_frames_gen)
    visible = zeros(num_frames_gen,num_dims);
    hidden1 = ones(num_frames_gen,num_hid1);
    hidden2 = ones(num_frames_gen,num_hid2);
    gen_X = visible;
    gen_X_hidden1 = hidden1;
    gen_X_hidden2 = hidden2;
    return
end

for tt = max_clamped+1:num_frames_gen
    % the current hidden layer frame is initialized with previous frame
    hidden1(tt,:) = hidden1(tt-1,:); 
    
    % Dynamic biases not recalcuated for alternating gibbs
    bi_star = A2_flat * past; % biases computed more quickly using past data
    bj_star = B2_flat * past;
    
    for gg = 1:numGibbs
        % calculate posterior probability 
        bottomup = w2 * hidden1(tt,:)'; % here hidden1 is the input data of layer 2
        eta = bottomup + bj2 + bj_star;
        
        hposteriors = 1./(1+exp(-eta));
        
        % compute hidden2(tt,:). Here this is the postive phase of layer 2
        hidden2(tt,:) = double(hposteriors' > rand(1,num_hid2));
        
        % Downward pass; visibles are binary logistic units : starting
        % negative phase
        topdown = hidden2(tt,:)*w2;
        
        eta = topdown+ bi2' + bi_star';
        
        hidden1(tt,:) = 1./(1+exp(-eta));  
    end
    
    % end Gibbs phenomenon
    % Do mean field update
    topdown = hposteriors' * w2; % in the loop, its binary units mulitplied while here, its the probability
    
    eta = topdown + bi2' + bi_star';
    hidden1(tt,:) = 1./(1+exp(-eta));
    
    % update the past ( shift to the right/down)
    % eg: shifted the first 300 (1:300 / 450) to the locations (151:450)
    past(num_hid1+1:end) = past(1:end-num_hid1); % shift older history down
    past(1:num_hid1) = hidden1(tt,:); % the new updates are the first 150 (num_hid1) elements
    
    if mod(tt,10)==0
        fprintf('Finished frame %d\n',tt);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now that we've decided on the "filtering distribution", generate visible
%data through CRBM 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for tt = max_clamped+1:num_frames_gen
    % connections from autoregressive
    bi_star = zeros(num_dims,1);
    for hh = 1:1:n1
        bi_star = bi_star + A1(:,:,hh)*visible(tt-hh,:)';
    end
    
    % Mean-field approx
    topdown = gsd.*(hidden1(tt,:)*w1);
    visible(tt,:) = topdown + bi1' + bi_star';
end

% send back the computed visible weights
gen_X = visible;
gen_X_hidden2 = hidden2;
gen_X_hidden1 = hidden1;


end