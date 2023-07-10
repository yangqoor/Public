classdef ELM_MatlabClass
% Extreme Learning Machine (ELM) class for regression and binary classification.
% 极限学习机（ELM）类用于回归和二元分类。
%   
%   ELM = ELM_MatlabClass(type,nInputs,nHidden,varargin)
%
%   where:
%           type        -> 'CLASSIFICATION' or 'REGRESSION'
%           nInputs     -> number of inputs in the dataset (single output) 
%           nHidden     -> number of hidden neurons of the ELM 
%           varargin{1} -> ridge regression constant C for faster more stable
%                          solution, see 
%                           Huang, Guang-Bin, et al. "Extreme learning machine for 
%                           regression and multiclass classification." 
%                           Systems, Man, and Cybernetics, Part B: Cybernetics, 
%                           IEEE Transactions on 42.2 (2012): 513-529.
%           varargin{2} -> types of activation function (those with *
%                          may require MATLAB nnet toolbox); the user can
%                          also enter a function handle to use custom
%                          activation functions
%
%                          Options:
%                          'tanh'      hyperbolic tangent (default),
%                          'logsig'    log-sigmoid,
%                          'linear'    linear transfer function, 
%                          'sine'      sine transfer function,
%                          'harlim' *  positive hard limit transfer function
%                          'tribas' *  triangular basis transfer function
%                          'radbas' *  radial basis transfer function *,
%                          
% 
% Refer to example_REGRESSION and example_CLASSIFICATION for usage.  
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

    
    properties (GetAccess = private)
        nInputs         % number of inputs
        nHidden         % number of hidden nodes                
        C           % C constant系数
        actFun          % activation function 激活函数    
        
        IW              % input weights
        OW              % output weights
        bias            % bias 偏置               
        type            % regression = 0, classification = 1
    end
    
    properties (Constant, GetAccess = private)
        nOutputs = 1;   % fixed to 1 
    end
    
    
    % public methods
    methods
       
    % constructor
    function self = ELM_MatlabClass(type,nInputs,nHidden,varargin)
        % type of ELM
        if strcmp(type,'REGRESSION')
            self.type = 0;
        elseif strcmp(type,'CLASSIFICATION')
            self.type = 1;
        else
            error('ELM type not recognized!');
        end
        % # inputs and hidden neurons
        self.nInputs = nInputs;
        self.nHidden = nHidden;
        % check for additional arguments
        if nargin == 3
            self.C   = 0;
            self.actFun  = @(x) (1-2./(exp(2*x)+1));
        elseif nargin == 4
            % C
            if varargin{1} >= 0
                self.C   = varargin{1};
            else
                error('C parameter has to be >= 0');
            end
            % act fun
            self.actFun  = @(x) (1-2./(exp(2*x)+1));
        elseif nargin == 5
            % C
            if varargin{1} >= 0
                self.C   = varargin{1};
            else
                error('C parameter has to be >= 0');
            end
            % act fun
            actFunString = varargin{2};
            switch actFunString
                case 'tanh'
                    self.actFun = @(x) (1-2./(exp(2*x)+1));
                case 'logsig'
                    self.actFun = @(x)(1./(1+exp(-x)));
                case 'linear'
                    self.actFun = @(x) (x);
                case 'radbas'
                    self.actFun = @radbas;
                case 'sine'
                    self.actFun = @sin;
                case 'hardlim'
                    self.actFun = @(x) (double(hardlim(x)));
                case 'tribas'
                    self.actFun = @tribas;
                otherwise
                    self.actFun = actFunString;   % custom activation fucntion
            end
        end
    end
    
    % return weights and biases
    function [IW,OW,bias] = getWeights(self)
        IW = self.IW; OW = self.OW; bias = self.bias;
    end
    
    % train the ELM
    function self = train(self,train_data)
        % get output and inputs and number of patterns n
        X = train_data(:,1:end-1)';
        Y = train_data(:,end)';        
        [~,n] = size(X);
        % check and transform output if CLASSIFICATION
        if self.type == 1
            Y = self.preprocessClassificationTargets(Y);
        end        
        
        % initialize inputs and bias between -1 and 1
        self.IW   = 2*rand(self.nHidden,self.nInputs) - 1;
        self.bias = 2*rand(self.nHidden,1) - 1;
        % compute activation field F
        F = self.IW * X + repmat(self.bias,1,n);    
        % compute H
        H = self.actFun(F);
        % find OW from matrix H pseudo-inversion
        if self.C == 0
            % basic version of training
            Hinv    = pinv(H');
            self.OW = Hinv * Y';
        else
            % advanced version of training (ridge regression)            
            Hinv = (eye(size(H,1))/self.C + H*H') \ H;
            self.OW = Hinv* Y';
        end                            
    end    
    
    % predict using ELM
    function Yhat = predict(self,X)
        % get length of test dataset
        X = X';
        [~,n] = size(X);
        % compute activation field F
        F = self.IW * X + repmat(self.bias,1,n);
        % compute H
        H = self.actFun(F);
        % compute output
        Yhat = (H' * self.OW)';
        % check if we are doing classification
        if self.type == 1           
            [~,temp] = max(Yhat);
            Yhat = temp - 1;  
        end
        Yhat = Yhat';
    end
    end
    
    % private methods
    methods (Access = private)
    
    % check and preprocess classification target data
    function Y_ = preprocessClassificationTargets(self,Y)
        % get number of outputs
        n = numel(Y);
        % check
        if any(~ismember(Y,[0,1])) 
            error('Binary CLASSIFICATION targets are only 0 and 1!');
        end
        % prepare
        Y_ = zeros(2,n);
        Y_(2,:) = 2*Y-1;
        Y_(1,:) = -Y_(2,:);        
    end   
    end 
end
