function out = randpoisson(inarray,thresh);

% out=randpoisson(inarray,thresh);
%
% outputs an array of poisson-distributed numbers with mean equal to inarray
% For inarray values above the threshold thresh (default=32),
%  use a quick-and-dirty version of the gaussian method,
%  but with negatives clipped to zero
% J.R. Fienup 10/22/99


if nargin <  1, 
    error('Requires at least one input argument.'); 
end

if exist('thresh')~=1, thresh=32; end

out=inarray;

% High-count pixels - use Gaussian approach
gtthresh=find(inarray>thresh);
if length(gtthresh)>0,
        out(gtthresh)=inarray(gtthresh) + ...
sqrt(inarray(gtthresh)).*randn(size(inarray(gtthresh)));
        out(gtthresh)=round(max(0,out(gtthresh)));
end

% Low-count pixels - this goes into the counting-experiment method

ltthresh=find(inarray<=thresh);
if length(ltthresh)>0  % segregate low-value pixels to speed computation
        lamda=inarray(ltthresh); 
     % Now dealing with 1-D column vector to merge into n-D array out later on
     % Initialize r to zero.
        r = zeros(size(lamda));  % output array for ltthresh pixels
        p = zeros(size(lamda));
        done = ones(size(lamda));
        
        while any(done) ~= 0 % note, do repeatedly calculate over all of lamda
            p = p - log(rand(size(lamda)));  
            kc = [1:length(lamda)]';
            k = find(p < lamda); % Q: does this k index over 
            if any(k)
                r(k) = r(k) + 1;
            end
            kc(k) = [];
            done(kc) = zeros(size(kc));
        end
            
% Return NaN if lamda not positive -- to do this, un-comment what 
% follows (gives zero now).      
%       tmp = NaN;
%       if any(any(any(lamda <= 0)));
%           if prod(size(lamda) == 1),   % i.e., a single pixel?
%               r = tmp(ones(size(lamda)));
%           else
%               k = find(lamda <= 0);
%               r(k) = tmp(ones(size(k)));
%           end
%       end

% Merge low-value-pixel results with large-value-pixel results
        out(ltthresh)=r;  
        
end; % of if length(ltthresh)>0
