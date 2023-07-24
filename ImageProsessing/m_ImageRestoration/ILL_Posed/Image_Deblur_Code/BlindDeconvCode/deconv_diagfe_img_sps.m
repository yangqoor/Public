function [k,ex,ssde]=deconv_diagfe_img_sps(y,k_sz1,k_sz2,x,sig_noise,bmp_outname,dispOn,edges_w)
%function [k,ex,ssde]=deconv_diagfe_img_sps(y,k_sz1,k_sz2,x,sig_noise,bmp_outname,dispOn,edges_w)
%blind deconvolution on an image, assuming a sparse MOG prior on the
%derivatives
%This function solves for the image directly (not for the derivatives)
%To approximate the covariance we use the free-energy update rules,
%and construct a diagonal covariance.    
%
%input arguments:
% y- blurred image
% k_sz1,k_sz2- desired kernel size
% x- (optional) original sharp image, for error evaluation. Note: error
%     is computed up to a small spatial shift since kernel
%     reconstruction is invariant to shift.
% sig_noise- (optional) noise std parameter. default 0.01.
% bmp_outname- (optional) output name to write temporary results at
%     different pyramid levels.   
% dispOn- (optional) should display temporary results to screen?
% edges_w- (optional) edges weighting for the *final* deconvolution
%     process.
%
%output: 
% k-estimated kernel
% ex- estimated latent image  
% ssde - error between estimated image and sharp reference. error
%     is computed after searching for the best shift.
%
%Writen by: Anat Levin, anat.levin@weizmann.ac.il (c)
    
    if ~exist('sig_noise','var')
        sig_noise=0.01;
    end
    if ~exist('bmp_outname','var')
        bmp_outname=[];
    end
    
    if ~exist('dispOn','var')
        dispOn=0;
    end
    if ~exist('x','var')
        x=[];
    end
    if ~exist('edges_w','var')
       edges_w=0.0068;
    end

    
 


%set the parameters of our deconvolution problem
%(see readme file for description)

sig_noise_v=sig_noise*(1.15.^[10:-1:0]); 


load MOGparams

prob.prior_ivar=ivars/30*1.5;


prob.prior_pi=pis;

prob.filts(:,:,1)=[-1 1; 0 0];
prob.filts(:,:,2)=[-1 0; 1 0];
ret=0.5^0.5;


prob.cycconv=0;
prob.covtype='diag';   
prob.update_x='conjgrad';
prob.filt_space=0;
prob.init_x_every_itr=1;
prob.k_prior_ivar=0.01;
prob.unconst_k=0; 
prob.eval_freeeng=0;




%make sure kernel size is odd
k_sz1=floor(k_sz1/2)*2+1; 
k_sz2=floor(k_sz2/2)*2+1; 

prob.k_sz1=k_sz1;
prob.k_sz2=k_sz2;
tf=zeros(k_sz1,k_sz2);
tf(ceil(k_sz1/2),ceil(k_sz2/2))=1;
tf(ceil(k_sz1/2),ceil(k_sz2/2)+1)=1;
tf=tf/sum(tf(:));
prob.k=tf;     
prob.y=y;

%here we call the main deconvolution routine, in a coarse to fine scheme     
[prob1,kListItr]=multires_deconv(prob,ret,sig_noise_v,dispOn,bmp_outname);
k=prob1.k;
k=k/sum(k(:));
   
%final non blind deconvolution with the estimated kernel 
[ex]=deconvSps(y,k,edges_w,70);
if ~isempty(x)
   % compute error between estimated image and sharp reference.
   % error is computed after finding the best shift.
   [ssde]=comp_upto_shift(ex,x);
else
    ssde=[];
end

















