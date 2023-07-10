for i = 1:49
    Img = imread(['./dyna/dyna_mat', num2str(i), '.png']);
    hBegin = 450;
    hEnd = 650;
    wBegin = 700;
    wEnd = 900;
    
    Img(hBegin:hEnd, wBegin:wEnd) = 255;
    
    imshow(Img);
    
end