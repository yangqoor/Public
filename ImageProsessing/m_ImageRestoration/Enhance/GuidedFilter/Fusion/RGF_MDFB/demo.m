clear,clc;
warning off;
addpath(genpath(cd));
dbstop if error
IRDir = ('.\28ir\');
VISDir = ('.\28vis\');
result_folder=('.\results');
files = dir(IRDir);
filesize=length(files);
mkdir(result_folder);

sigma_s=3;             % the ¦Òs of joint  bilateral filtering
sigma_r =0.24;         % the ¦Òr of joint  bilateral filtering
iteration = 4;         % the iteration number of RGF 
k = 2;                 % the index of multi-direction decomposition
level = 3;             % the number of multi-scale decomposition level

for imagenumber_i = 1:1:(filesize-2) 
    [dire, name ,ext]=fileparts(strcat(IRDir,'\',files(imagenumber_i+2).name));
    image_input1 = imread(strcat(IRDir, name,ext));
    image_input2 = imread(strcat(VISDir, name,ext));
    if size(image_input1)~=size(image_input2)
        error('two images are not the same size.');
    end
    imgf = msmd(image_input1,image_input2,level,iteration,sigma_s,sigma_r,k);
    imwrite((imgf),strcat( result_folder, '\',name,ext));
end