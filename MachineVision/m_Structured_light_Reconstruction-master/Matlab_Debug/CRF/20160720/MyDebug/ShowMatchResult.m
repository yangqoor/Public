h = 400;
w = 500;
x = xpro_mat(h, w);
y = ypro_mat(h, w);
i = 12;

cam_show = camera_image{i, 1}(h-20:h+20, w-20:w+20);
x = floor(x + 0.5);
y = floor(y + 0.5);
pro_show = pattern(y-20:y+20, x-20:x+20);

show_mat = [cam_show, pro_show];
fprintf('camera_image(%d, %d) = %f\n', h, w, camera_image{i, 1}(h, w));
fprintf('pattern(%f, %f) = %f\n', ypro_mat(h, w), xpro_mat(h, w), pattern(y, x));
imshow(show_mat);
