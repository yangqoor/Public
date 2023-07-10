depth_mat = load(['./result/depth_mat/depth_mat5.txt']);
depth_mat(depth_mat<0) = 0;
h = 640:1280;
w = 512:1024;
[h, w] = meshgrid(h, w);

new_mat = imgaussfilt(depth_mat);

cam_mat = [2400.00, 0, 640;
    0, 2399, 512;
    0, 0, 1];

% ±£´æµãÔÆ
fid = fopen('point_cloud.txt', 'w+');
for h = 1:1024
    for w = 1:1280
        if depth_mat(h, w) ~= 0
            h_center = h - cam_mat(1, 3);
            w_center = w - cam_mat(2, 3);
            h_f = cam_mat(1, 1);
            w_f = cam_mat(2, 2);
            z = depth_mat(h, w);
            x = z * h_center / h_f;
            y = z * w_center / w_f;
            fprintf(fid, '%f %f %f\n', x, y, z);
        end
    end
end
fclose(fid);