
%This file originally created by Jim Mutch, but Samuel Rivera has modified
%it to make it a part of his face shape detection algorithm

function [r c lib] = calcC1( modelFile, imageFile )
warning off all

% FHDemo - Demo script illustrating basic usage of the FH library.
%
% FHDemo, by itself, performs the following steps:
%
%    - sets up a configuration (five filters: image, s1, c1, s2, c2),
%    - learns a small feature dictionary (for s2) from two training images,
%    - computes a stream (all levels) for a test image,
%    - extracts a response vector from level c2, and
%    - shows the bounding boxes of a few c2 features in the test image.
%
% See also: FHDemo_CVPR06_Cal101, FHHelp.

%***********************************************************************************************************************

% Copyright (C) 2007  Jim Mutch  (www.jimmutch.com)
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program.  If not, see
% <http://www.gnu.org/licenses/>.

%***********************************************************************************************************************

if exist( modelFile, 'file' )
    load( modelFile )
else

%     clc;
%     fprintf('\n');
%     while true
%         ans = lower(strtrim(input('All variables will be cleared.  Is this okay (y/n) ? ', 's')));
%         if isempty(ans), continue; end
%         if ans(1) == 'y', break; end
%         if ans(1) == 'n', return; end
%     end    
% 
%     fprintf('\n');
% 
%     clear;

    %***********************************************************************************************************************

    %basePath = fullfile(fileparts(mfilename('fullpath')), 'data');
    %for making it work on super computer
%     if exist( '/media/Data', 'dir')
%         basePath = '/media/Data/matlab/cotexLikeFeatures/FHLib/FH/data';
%         
%     elseif exist( '/media/SAMSUNG/CBCS03/cotexLikeFeatures/FHLib/FH/data', 'dir')
%          basePath = '/media/SAMSUNG/CBCS03/cotexLikeFeatures/FHLib/FH/data';
%          
%     else
%         basePath = '~/matlab/cotexLikeFeatures/FHLib/FH/data';
%     end
%     
%     imagePath1 = fullfile(basePath, 'ketch_0010.jpg');
%     imagePath2 = fullfile(basePath, 'ketch_0011.jpg');
%     imagePath3 = fullfile(basePath, 'ketch_0012.jpg');

    clear basePath;

    %***********************************************************************************************************************

%     fprintf('Configuring filters....\n');

    % Note: this is the same configuration as that returned by FHConfig_CVPR06.  Refer to the other FHConfig_* functions
    % for additional standard configurations.

    c.filters{1}.sizeMode   = 'short';
    c.filters{1}.size       = 140;
    c.filters{1}.scaleCount = 10;
    c.filters{1}.scaleBase  = 2;
    c.filters{1}.scaleRoot  = 4;

    c.filters{2}.name      = 's1';
    c.filters{2}.class     = 'ndp';
    c.filters{2}.func      = 'gabor';
    c.filters{2}.params    = [0.3 5.6410 4.5128];
    c.filters{2}.xySize    = 11;
    c.filters{2}.typeCount = 12;
    c.filters{2}.inhibit   = 0.5;

    c.filters{3}.name      = 'c1';
    c.filters{3}.class     = 'max';
    c.filters{3}.xySize    = 10;
    c.filters{3}.xyStep    = 5;
    c.filters{3}.scaleSize = 2;
    c.filters{3}.scaleStep = 1;
    c.filters{3}.inhibit   = 0.5;
% 
%     c.filters{4}.name    = 's2';
%     c.filters{4}.class   = 'grbf';
%     c.filters{4}.sigma   = 1;
%     c.filters{4}.xySizes = [4 8 12 16];
% 
%     c.filters{5}.name     = 'c2';
%     c.filters{5}.class    = 'gmax';
%     c.filters{5}.xyTol    = 0.05;
%     c.filters{5}.scaleTol = 1;

    c = FHSetupConfig(c);

%     fprintf('\n');

%     FHDispConfig(c);

    %***********************************************************************************************************************

%     fprintf('Creating empty feature library....\n');

    lib = FHSetupLibrary(c);

    %***********************************************************************************************************************

%     fprintf('Sampling 100 s2 features from two training images....\n');

%   GLInitRand;  %skip this if using your own randomization

%     dict1 = FHSampleFeatures(c, lib, imagePath1, 's2', 50, 1, 3);
%     dict2 = FHSampleFeatures(c, lib, imagePath2, 's2', 50, 1, 3);
% 
%     dict = FHCombineDicts(c, 's2', dict1, dict2);
% 
%     dict = FHSparsifyDict(c, lib, 's2', dict, true, 'best*', 1/12, 1);
% 
%     lib = FHSetDict(c, lib, 's2', dict);
% 
%     clear dict1 dict2 dict;

    %***********************************************************************************************************************

%     fprintf('Computing stream (all levels) for a test image....\n');
% 
%     
    %***********************************************************************************************************************

end

s = FHCreateStream(c, lib,  imageFile, 'all');
% fprintf('Extracting a response vector from level c1....\n');

r = FHGetResponses(c, lib, s, 'c1');

% size(r)

% %***********************************************************************************************************************
% 
% fprintf('Finding bounding boxes for a few c2 features....\n');
% 
% types = 1 : 5;
% 
% windows = FHTraceGlobalUnits(c, lib, s, 'c2', types);
% 
% image3 = FHReadImage(c, imagePath3);
% 
% image3 = GLMarkupGray(image3, windows);
% 
% GLShowGray(image3);
% 
% %***********************************************************************************************************************
% 
% fprintf('\n');
% 
% whos;

warning on all
