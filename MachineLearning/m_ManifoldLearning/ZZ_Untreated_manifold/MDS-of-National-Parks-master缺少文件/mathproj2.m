clear all 
close all
clc

%% Import Data 

n = 56;
tic
for j = 1:n
    filename = sprintf('park%d.xlsx',j);
    A = importdata(filename);
    name(1,j) = A(2,1);
    spec = A(2:end, 7)';
    total_spec(j,1:length(spec)) = str2double(spec);
    dimensions = size(spec);
    num_spec(j) = dimensions(2);
end

%% Distance Matrix
% want 56 x 56 matrix. Dist along diag = 0.

dist = zeros(56);
for j = 1:n
    for k = 1:n
        for l = 1:length(total_spec(k,:))
            if total_spec(k,l) == 0
                l = length(total_spec(k,:));
            elseif any(total_spec(j,:) == total_spec(k,l))
                dist(j,k) = dist(j,k) + 1;
            end
        end
    end
end

%% Inverse relation between dist and similarity
% dist = 1./dist; 
% [nRows,nCols] = size(dist);
% dist(1:(nRows+1):nRows*nCols) = 0; %since 1/'0' = Inf, set diag = 0. 

for j = 1:n
    for k = 1:n 
        dist(j,k) = (1-(2*dist(j,k))/(num_spec(j)+num_spec(k)))^4;
    end
end
toc

%% Saving files
save('dist_mat.dat', 'dist','-ASCII');
dlmwrite('dist_mattxt.txt',dist,'delimiter','\t','precision',10);
name = name';
dlmwrite('names.txt',name,'delimiter','');

