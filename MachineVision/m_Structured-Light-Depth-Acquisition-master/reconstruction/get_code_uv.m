% function used to get uv code for one gray image
function [output_code]=get_code_uv(gray_img)
    % get size of intput gray matrix
    [height,width,~,~]=size(gray_img);
    
    output_code = zeros(height,width,2);
    
    
    for i=1:height
        for j=1:width
            % current_code represents binary 1-10 order
            current_code = zeros(1,10);
            
            diff_sum = 0;
            idx = 1;
            for k=1:2:20
                int1 = gray_img(i,j,k);     
                int2 = gray_img(i,j,k+1);
                
                % if white is before black,set as 1; otherwise, set as 0
                if int1<=int2
                    current_code(idx) = 0;
                else
                    current_code(idx) = 1;
                end
                
                idx = idx+1;
                diff_sum = diff_sum + abs(int1-int2);
            end
            
            % convert binary to decimal
            output_code(i,j,1) = bi2de(current_code)+1;
            output_code(i,j,2) = diff_sum;
        end
    end
end