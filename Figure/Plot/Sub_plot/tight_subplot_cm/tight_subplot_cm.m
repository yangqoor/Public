function [ha, hfig] = tight_subplot_cm(Nh, Nw, gap, marg_h, marg_w, h, w)

% tight_subplot creates "subplot" axes with adjustable gaps and margins
%
% [ha, pos] = tight_subplot_cm(Nh, Nw, gap, marg_h, marg_w)
%
%   in:  Nh      number of axes in height (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in cm 
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in cm
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in cm
%                   or [left right] for different left and right margins 
%
%  out:  ha      array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   subplot
%        hfig    handle for the figure
%
%  Example:
%  ========
%  ha = tight_subplot_cm(3,2,[.2 .2],[0.5 1],[.5 .5], 10, 10);
%  for ii = 1:6; 
%      axes(ha(ii)); plot(randn(10,ii)); 
%  end

% Pekka Kumpulainen 21.5.2012   @tut.fi
% Tampere University of Technology / Automation Science and Engineering
% 
% Auralius Manurung 13.7.2016   @ethz.ch
% ETH Zurich


if nargin<3; gap = .2; end
if nargin<4 || isempty(marg_h); marg_h = .5; end
if nargin<5; marg_w = .5; end
if nargin<6; h = 8; w = 8; end

if numel(gap)==1; 
    gap = [gap gap];
end
if numel(marg_w)==1; 
    marg_w = [marg_w marg_w];
end
if numel(marg_h)==1; 
    marg_h = [marg_h marg_h];
end

hfig = figure;
set(hfig,'Units', 'centimeters'); % set figure position to cm
set(hfig, 'Position', [0 0 w h]); % resize figure

axh = (h-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
axw = (w-sum(marg_w)-(Nw-1)*gap(2))/Nw;

py = h-marg_h(2)-axh; 

% ha = zeros(Nh*Nw,1);
ii = 0;
for ih = 1:Nh
    px = marg_w(1);
    
    for ix = 1:Nw
        ii = ii+1;
        ha(ii) = axes('Units','centimeters', ...
            'Position',[px py axw axh], ...
            'XTickLabel','', ...
            'YTickLabel','', ...
            'ZTickLabel','');
        px = px+axw+gap(2);
    end
    py = py-axh-gap(1);
end
