function debugShowDeltaDepthOnPoint(delta_depth_mats, h, w, data_frame_num)
    x = 1:data_frame_num;
    y = zeros(size(x));
    for idx = 2:data_frame_num
        y(idx) = delta_depth_mats{idx, 1}(h, w);
    end
    figure, plot(x, y, 'MarkerSize', 20);
end