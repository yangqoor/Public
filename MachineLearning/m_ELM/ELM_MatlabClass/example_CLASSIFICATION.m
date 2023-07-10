% EXAMPLE FOR USING ELM_MatlabCalss in binary CLASSIFICATION problems
% 在二进制分类问题中使用ELM_MatlabCalss的例子
%
% Refer to README.md and ELM_MatlabClass for further details.  
% 有关更多详细信息，请参阅README.md和ELM_MatlabClass。
%
% Copyright 2015 Riccardo Taormina  
% riccardo.taormina@gmail.com 
%
%
% This file is part of ELM_MatlabClass.
%
%     ELM_MatlabClass is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     ELM_MatlabClass is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with ELM_MatlabClass.  If not, see <http://www.gnu.org/licenses/>.
%%
clear all;
clc;
close all;
format compact
%% data loading and preprocessing
% load data (skip 1st column, ID)
data = csvread('breast-cancer-wisconsin.data',0,1);

% load 'F://My_Study//MATlab//data_processing//features900_6d.mat'
% data = features;

% remove rows with NaNs;删除行
ixToRemove = sum(isnan(data),2) > 0;
data(ixToRemove,:) = [];

% get number of inputs and patterns
[nPatterns, nInputs] = size(data);
nInputs = nInputs - 1; % last column is target data

% normalize inputs data between -1 and 1
for i = 1 : nInputs
    data(:,i) = -1 + 2.*(data(:,i) - min(data(:,i)))./(max(data(:,i)) - min(data(:,i)));
end

% normalize target data (2 classes identified by 0 and 1)规范化目标数据（由0和1标识的2个类）
if numel(unique(data(:,end))) > 2
    error('Not a binary classification problem!');
else
    classLabels = unique(data(:,end));
    data(data(:,end) == classLabels(1),end) = 0;
    data(data(:,end) == classLabels(2),end) = 1;
end

% divide datasets
percTraining = 0.6; % 0.6 == use 60% data for training
endTraining  = ceil(percTraining * nPatterns);

trainData = data(1:endTraining,:); 
validData = data(endTraining+1:end,:);

%% creation and training of ELM model
% defined number of hidden neurons to use隐含层数
nHidden = 10;

% create ELM for classification
ELM = ELM_MatlabClass('CLASSIFICATION',nInputs,nHidden);

% train ELM on the training dataset训练
ELM = train(ELM,trainData);

% compute and report accuracy on training dataset
Yhat = predict(ELM,trainData(:,1:end-1));
fprintf('TRAINING ACCURACY = %3.2f %%\n',computeAccuracy(trainData(:,end),Yhat)*100);


%% validation of ELM model验证
Yhat = predict(ELM,validData(:,1:end-1));
fprintf('VALIDATION ACCURACY = %3.2f %%\n',computeAccuracy(validData(:,end),Yhat)*100);

%% sensitivity analysis on number of hidden neurons隐含神经元敏感性分析
nHidden    = [10, 50, 100, 200];
trainACC   = zeros(size(nHidden));
validACC   = zeros(size(nHidden));
for i = 1 : numel(nHidden)
    % create ELM for classification
    ELM = ELM_MatlabClass('CLASSIFICATION',nInputs,nHidden(i));
    % train ELM on the training dataset
    ELM = train(ELM,trainData);
    Yhat = predict(ELM,trainData(:,1:end-1));
    trainACC(i) = computeAccuracy(trainData(:,end),Yhat)*100;
    % validation of ELM model
    Yhat = predict(ELM,validData(:,1:end-1));
    validACC(i) = computeAccuracy(validData(:,end),Yhat)*100;
end

% plot results
plot(nHidden,[trainACC;validACC],'-o');
xlabel('Number of Hidden Neurons');
ylabel('Accuracy');
legend({'training','validation'},'Location','northwest')



