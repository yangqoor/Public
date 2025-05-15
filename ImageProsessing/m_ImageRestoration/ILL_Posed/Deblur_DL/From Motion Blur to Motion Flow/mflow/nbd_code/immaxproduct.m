% max-product belief propagation on image lattice (2D matrix)
% This implementation contains no product. The compatibility function
% should be changed to exp{-E} where E is energy or error. Here E is the
% input. Output is the MAP estimation of the graph
% 
% This implementation is based on W.T. Freeman et al's IJCV paper
% http://www.merl.com/reports/docs/TR2000-05.pdf
%
% Input arguments:
%   CO: [nstates x height x width] -- energy function phi, connecting to
%                    the observation
%   CM_h: [nstates x nstates x height x (width-1)]--compatibility function 
%                    psi, connectiing horizontal neighbors. Each matrix is
%                       [index of left x index of right]
%   CM_v: [nstates x nstates x (height-1) x width]--compatibility function
%                    psi, connectiing vertical neighbors. Each matrix is
%                       [index of top x index of bottom]
%   nIerations: scalar-- the number of iterations in BP. The default value
%                    is max(height,width)/2
%   alpha: scalar-- It's better to smooth the message update in each
%                    iteration. Weight alpha is used to weight the new
%                    messages, and (1-alpha) is to weight the old ones.
%
% Output arguments:
%   IDX [height x width]-- Bayesian MAP estimation of the graph, each
%               element is an integer between 1 and nstates
%
% Ce Liu
% CSAIL,MIT, celiu@mit.edu
% Feb, 2006

function [IDX,En]=immaxproduct(CO,CM_h,CM_v,nIterations,alpha)
% get the dimension of the 
[nstates,height,width]=size(CO);

% sanity check for the dimensions
if size(CM_h)~=[nstates nstates height width-1] 
    error('The dimension of CM_h is incorrect!');
end
if size(CM_v)~=[nstates nstates height-1 width]
    error('The dimension of CM_v is incorrect!');
end

% default values for nIerations and alpha
if exist('nIterations','var')~=1
    nIterations=round(max(height,width)/2);
end
if exist('alpha','var')~=1
    alpha=0.6;
end

% compatibility function psi has to be permuted for bottom to top and right
% to left. 
CMtb=reshape(CM_v,nstates,nstates*(height-1)*width);
CMbt=reshape(permute(CM_v,[2,1,3,4]),nstates,nstates*(height-1)*width);
CMlr=reshape(CM_h,nstates,nstates*height*(width-1));
CMrl=reshape(permute(CM_h,[2,1,3,4]),nstates,nstates*height*(width-1));

% initialize messages
% Mtb: top to bottom
% Mbt: bottom to top
% Mlr: left to right
% Mrl: right to left
Mtb=zeros(nstates,(height-1),width);
Mbt=Mtb;
Mlr=zeros(nstates,height,width-1);
Mrl=Mlr;

[foo,IDX]=min(CO,[],1);
En(1)=imgraphen(IDX,CO,CM_h,CM_v);


for i=1:nIterations
    % update message from top to bottom
    Mtb1=zeros(nstates,height-1,width);
    Mtb1(:,2:end,:)=Mtb1(:,2:end,:)+Mtb(:,1:end-1,:);
    Mtb1(:,:,1:end-1)=Mtb1(:,:,1:width-1)+Mrl(:,1:end-1,:);
    Mtb1(:,:,2:end)=Mtb1(:,:,2:end)+Mlr(:,1:end-1,:);
    Mtb1=Mtb1+CO(:,1:end-1,:);
    Mtb1=kron(reshape(Mtb1,nstates,(height-1)*width),ones(1,nstates))+CMtb;
    Mtb1=reshape(min(Mtb1,[],1),[nstates,height-1,width]);
    
    % update message from bottom to top
    Mbt1=zeros(nstates,height-1,width);
    Mbt1(:,1:end-1,:)=Mbt1(:,1:end-1,:)+Mbt(:,2:end,:);
    Mbt1(:,:,1:end-1)=Mbt1(:,:,1:end-1)+Mrl(:,2:end,:);
    Mbt1(:,:,2:end)=Mbt1(:,:,2:end)+Mlr(:,2:end,:);
    Mbt1=Mbt1+CO(:,2:end,:);
    Mbt1=kron(reshape(Mbt1,nstates,(height-1)*width),ones(1,nstates))+CMbt;
    Mbt1=reshape(min(Mbt1,[],1),[nstates,height-1,width]);
    
    % update message from left to right
    Mlr1=zeros(nstates,height,width-1);
    Mlr1(:,:,2:end)=Mlr1(:,:,2:end)+Mlr(:,:,1:end-1);
    Mlr1(:,1:end-1,:)=Mlr1(:,1:end-1,:)+Mbt(:,:,1:end-1);
    Mlr1(:,2:end,:)=Mlr1(:,2:end,:)+Mtb(:,:,1:end-1);
    Mlr1=Mlr1+CO(:,:,1:end-1);
    Mlr1=kron(reshape(Mlr1,nstates,height*(width-1)),ones(1,nstates))+CMlr;
    Mlr1=reshape(min(Mlr1,[],1),[nstates,height,width-1]);
    
    % update message from right to left
    Mrl1=zeros(nstates,height,width-1);
    Mrl1(:,:,1:end-1)=Mrl1(:,:,1:end-1)+Mrl(:,:,2:end);
    Mrl1(:,1:end-1,:)=Mrl1(:,1:end-1,:)+Mbt(:,:,2:end);
    Mrl1(:,2:end,:)=Mrl1(:,2:end,:)+Mtb(:,:,2:end);
    Mrl1=Mrl1+CO(:,:,2:end);
    Mrl1=kron(reshape(Mrl1,nstates,height*(width-1)),ones(1,nstates))+CMrl;
    Mrl1=reshape(min(Mrl1,[],1),[nstates,height,width-1]);
    
    % reassign message
    Mtb=Mtb1*alpha+Mtb*(1-alpha);
    Mbt=Mbt1*alpha+Mbt*(1-alpha);
    Mlr=Mlr1*alpha+Mlr*(1-alpha);
    Mrl=Mrl1*alpha+Mrl*(1-alpha);
    
    % Bayesian MAP inference
    M=zeros(nstates,height,width);
    M(:,2:end,:)=M(:,2:end,:)+Mtb;
    M(:,1:end-1,:)=M(:,1:end-1,:)+Mbt;
    M(:,:,2:end)=M(:,:,2:end)+Mlr;
    M(:,:,1:end-1)=M(:,:,1:end-1)+Mrl;
    M=M+CO;
    [foo,IDX]=min(M,[],1);
    En(i+1)=imgraphen(IDX,CO,CM_h,CM_v);
    fprintf('BP: iteration %d \n', i);
end

%figure;plot(En);

% step 2. Bayesian MAP inference
M=zeros(nstates,height,width);
M(:,2:end,:)=M(:,2:end,:)+Mtb;
M(:,1:end-1,:)=M(:,1:end-1,:)+Mbt;
M(:,:,2:end)=M(:,:,2:end)+Mlr;
M(:,:,1:end-1)=M(:,:,1:end-1)+Mrl;
M=M+CO;
[foo,IDX]=min(M,[],1);
IDX=squeeze(IDX);