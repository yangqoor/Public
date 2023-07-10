%Load_date
function [fre,data]=Load_data(filename)
fileID=fopen(filename);
f_string=fgetl(fileID);
fre=str2double(f_string(2:4))*1e+9;
%fre=str2double(mat2str(a(1,6:7)))*10e+9;
fgetl(fileID);
a=textscan(fileID,'%f64');
b=a{1,1};
[L,M]=size(b);
N=L/5;
data=reshape(b,5,N);
data=data';
end
