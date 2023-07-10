function [T,subsets_size] = SeperateFeatures(Features,win_size,overlap)
%Frames is the cell array whose each input is another cell array which consists of the respective frames
% It breaks the video sequences into space time cubes of size height x width x win_size(time) 
%  but with an overlap 
[r,c] = size(Features);
T = {};
subsets_size = [];

for m = 1:1:r
  total_subsets = 0;
  S = [];
  for n = 1:1:c
    temp = Features{m,n}; %getting the first video sequence
    [len_im,num_of_frames] = size(temp);
    %finding the number of subsets
    shift = win_size - overlap;
    sum = win_size;
    num_of_subsets = 1;
    while(sum <= num_of_frames)
      sum = win_size + shift*num_of_subsets;
      num_of_subsets = num_of_subsets+1;
    end
    num_of_subsets = num_of_subsets - 1;
    S = [S num_of_subsets];
   
    for k = 1:1:num_of_subsets
	B = temp(:,shift*(k-1) + 1 : shift*(k-1) + win_size);
	T{ m, total_subsets + k } = B;
    end
    total_subsets = total_subsets + num_of_subsets;
    %s = sprintf('Sequence A%d-P%d seperated',m,n);
    %disp(s);
  end
  subsets_size = [subsets_size ; S];
end

end