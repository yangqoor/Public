load mnist_all
xtrain = [train0; train1; train2;train3;train4;train5;train6;train7;train8;train9];
ytrain = [ones(size(train0,1),1);
    2*ones(size(train1,1),1);
    3*ones(size(train2,1),1);
    4*ones(size(train3,1),1);
    5*ones(size(train4,1),1);
    6*ones(size(train5,1),1);
    7*ones(size(train6,1),1);
    8*ones(size(train7,1),1);
    9*ones(size(train8,1),1);
    10*ones(size(train9,1),1)];
xtest = [test0; test1; test2;test3;test4;test5;test6;test7;test8;test9];
ytest = [ones(size(test0,1),1);
    2*ones(size(test1,1),1);
    3*ones(size(test2,1),1);
    4*ones(size(test3,1),1);
    5*ones(size(test4,1),1);
    6*ones(size(test5,1),1);
    7*ones(size(test6,1),1);
    8*ones(size(test7,1),1);
    9*ones(size(test8,1),1);
    10*ones(size(test9,1),1)];

xtrain = double(xtrain)/255;
xtest = double(xtest)/255;

% Make a random permutation mask
p = randperm(size(xtrain, 1));
% Shuffle the training dataset
xtrain = xtrain(p, :);
ytrain = ytrain(p, :);

% Shuffle the test dataset too
p = randperm(size(xtest, 1));
xtest = xtest(p, :);
ytest = ytest(p, :);

% Take part from training dataset for validation
% Using cross validation to optimize net parameters is expensive although..
m_validate = 10000;
xvalidate = xtrain(1:m_validate, :);
yvalidate = ytrain(1:m_validate, :);
xtrain = xtrain(m_validate + 1:end, :);
ytrain = ytrain(m_validate + 1:end, :);
m_train = size(xtrain, 1);
m_test = size(xtest, 1);

xtrain = xtrain';
ytrain = ytrain';
xvalidate = xvalidate';
yvalidate = yvalidate';
xtest = xtest';
ytest = ytest';