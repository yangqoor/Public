% [theta_ss,im_blur] = shake_camera(im_orig,Korig,dims_blur,Kblur,blur_type,synth_size)

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function [theta_ss,im_blur] = shake_camera(im_orig,Korig,dims_blur,Kblur,blur_type,synth_size,seed)

non_uniform = 1;

t = 0:0.01:0.1;
t_ss = linspace(min(t),max(t),250);
if strcmp(blur_type,'random')
    if exist('seed','var')
        randn('seed',seed);
    else        
        time = fix(clock)
        randn('seed',time(end));
    end
    d2thetaxdt2 = randn(size(t)); d2thetaxdt2(1) = 0;
    d2thetaydt2 = randn(size(t)); d2thetaydt2(1) = 0;
    d2thetazdt2 = randn(size(t)); d2thetazdt2(1) = 0;
    theta0 = 1/100*[(cumsum(d2thetaxdt2)); ...
        			(cumsum(d2thetaydt2)); ...
        			(cumsum(d2thetazdt2))];
    theta_ss = interp1(t,theta0',t_ss,'spline')';
	theta_ss = theta_ss - repmat(mean(theta_ss,2),[1 size(theta_ss,2)]); % center kernel
	theta_ss = theta_ss/max(sqrt(sum(theta_ss.^2,1)))*synth_size*pi/180/2;
    % theta_ss(3,:) = 0.5*theta_ss(3,:);
elseif strcmp(blur_type,'x')
    theta_ss = [linspace(-synth_size*pi/180/2,synth_size*pi/180/2,length(t_ss)); ...
		        zeros(size(t_ss)); ...
		        zeros(size(t_ss))];
elseif strcmp(blur_type,'y')
    theta_ss = [zeros(size(t_ss)); ...
		        linspace(-synth_size*pi/180/2,synth_size*pi/180/2,length(t_ss)); ...
		        zeros(size(t_ss))];
elseif strcmp(blur_type,'z')
    theta_ss = [zeros(size(t_ss)); ...
        		zeros(size(t_ss)); ...
        		linspace(-synth_size*pi/180/2,synth_size*pi/180/2,length(t_ss))];
end

if nargout > 1
	im_blur = zeros([dims_blur, size(im_orig,3)]);
	for c=1:size(im_orig,3)
		im_blur(:,:,c) = apply_blur_kernel_mex(im_orig(:,:,c),dims_blur,Korig,Kblur,-theta_ss,ones(size(theta_ss,2))/size(theta_ss,2),0,non_uniform,[0;0;0]);
	end
	im_blur = max(min(im_blur,1),0);
end


end %  function