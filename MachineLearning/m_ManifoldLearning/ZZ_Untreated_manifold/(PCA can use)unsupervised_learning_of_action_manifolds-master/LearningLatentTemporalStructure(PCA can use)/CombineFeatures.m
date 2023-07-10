% Combining the features
function C = CombineFeatures(Features1,Features2)
% Features1 and Features2 
[num_of_actions,num_of_persons] = size(Features1);
C = cell(num_of_actions,num_of_persons);

for m = 1:1:num_of_actions
    for n = 1:1:num_of_persons
        F1 = Features1{m,n};
        F2 = Features2{m,n};
        [num_of_frames,dims1] = size(F1);
        [num_of_frames,dims2] = size(F2);
        if(dims1 == 0)
            continue;
        end
        %F1 = reshape(F1,rows1*cols1,num_of_frames);
        %F2 = reshape(F2,rows2*cols2,num_of_frames);
        
        % normalize F1 and F2 before image fusion
        
        
        F3 = [F1 F2];
        %F3 = reshape(F3,rows1,cols1+cols2,num_of_frames);
        C{m,n} = F3;
    end
end


end