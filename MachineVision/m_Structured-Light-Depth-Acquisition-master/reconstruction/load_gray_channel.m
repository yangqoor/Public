% function used to convert input colored image set into gray image sequence
function [img_seq] = load_gray_channel(folder, img_name, first, img_num, format)
    first_img = imread([folder,'/',img_name,num2str(first),'.',format]);
    first_img = im2double(rgb2gray(first_img));
    [height,width] = size(first_img);
    img_seq = zeros(height,width,img_num);
    img_seq(:,:,1) = first_img;
    
    count = 1;
    for i=first+1:first+img_num-1
        count=count+1;
        file_name = [folder, '/', img_name, num2str(i), '.', format];
        img_seq(:,:,count) = im2double(rgb2gray(imread(file_name)));
    end
end