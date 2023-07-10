% EXAMPLE FOR USING ELM_MatlabClass in REGRESSION problems
% 使用elm_matlabclass回归问题中的实现
%
% Refer to README.md and ELM_MatlabClass for further details.  
%
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

%% data loading and preprocessing
% load data (skip 1st row and 1st column, header)
data = csvread('data_akbilgic.csv',1,1);

% get number of inputs and patterns
[nPatterns, nInputs] = size(data);
nInputs = nInputs - 1; % last column is target data

% normalize data between -1 and 1
for i = 1 : (nInputs + 1)
    data(:,i) = -1 + 2.*(data(:,i) - min(data(:,i)))./(max(data(:,i)) - min(data(:,i)));
end

% divide datasets
percTraining = 0.6; % 0.6 == use 60% data for training
endTraining  = ceil(percTraining * nPatterns);

trainData = data(1:endTraining,:); 
validData = data(endTraining+1:end,:);

%% creation and training of ELM model
% defined number of hidden neurons to use
nHidden = 10;

% create ELM for classification
ELM = ELM_MatlabClass('REGRESSION',nInputs,nHidden);

% train ELM on the training dataset
ELM = train(ELM,trainData);

% compute and report accuracy on training dataset
Yhat = predict(ELM,trainData(:,1:end-1));
fprintf('TRAINING RSquared = %3.3f\n',computeR2(trainData(:,end),Yhat));


%% validation of ELM model
Yhat = predict(ELM,validData(:,1:end-1));
fprintf('VALIDATION RSquared = %3.3f\n',computeR2(validData(:,end),Yhat));

%% sensitivity analysis on number of hidden neurons
nHidden    = 1:100;
trainR2   = zeros(size(nHidden));
validR2   = zeros(size(nHidden));
for i = 1 : numel(nHidden)
    % create ELM for classification
    ELM = ELM_MatlabClass('REGRESSION',nInputs,nHidden(i));
    % train ELM on the training dataset
    ELM = train(ELM,trainData);
    Yhat = predict(ELM,trainData(:,1:end-1));
    trainR2(i) = computeR2(trainData(:,end),Yhat);
    % validation of ELM model
    Yhat = predict(ELM,validData(:,1:end-1));
    validR2(i) = computeR2(validData(:,end),Yhat);
end

% plot results
plot(nHidden,[trainR2;validR2],'-o');
xlabel('Number of Hidden Neurons');
ylabel('RSquared');
legend({'training','validation'},'Location','southeast')



