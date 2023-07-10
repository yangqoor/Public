grey_img = imread(['./dyna/dyna_mat', num2str(34), '.png']);
bin_img = grey_img;

H = fspecial('average', 10);
filter_img = filter2(H, grey_img);

[size_h, size_w] = size(grey_img);

for h = 1:size_h
    for w = 1:size_w
        if grey_img(h, w) < filter_img(h, w)
            bin_img(h, w) = 0;
        else
            bin_img(h, w) = 255;
        end
    end
end

h_begin = 660;
w_begin = 560;
h_end = 850;
w_end = 730;
imshow([grey_img(h_begin:h_end, w_begin:w_end),bin_img(h_begin:h_end, w_begin:w_end)]);