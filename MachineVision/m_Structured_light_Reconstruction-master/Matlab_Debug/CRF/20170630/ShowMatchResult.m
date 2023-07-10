h = 730;
w = 400;
i = 1;

cam_show = double(camera_image{i}(h-20:h+20, w-20:w+20)) / 255.0;
x = xpro_mats{i}(h, w);
y = ypro_mats{i}(h, w);
x = floor(x);
y = floor(y);
pro_show = pattern(y-20:y+20, x-20:x+20);

show_mat = [cam_show, pro_show];
imshow(show_mat);