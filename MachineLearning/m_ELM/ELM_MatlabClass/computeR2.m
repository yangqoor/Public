function R2 = computeR2(Y,Yhat)
% Compute RSquared statistics.
%
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

% get total sum of squares
SStot = sum((Y-mean(Y)).^2);

% get the residual sum of squares
SSres = sum((Y-Yhat).^2);

% compute R2
R2 = 1 - SSres/SStot;