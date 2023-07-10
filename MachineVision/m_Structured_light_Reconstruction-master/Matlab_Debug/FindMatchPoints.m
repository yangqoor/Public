function [ error ] = FindMatchPoints( Img0, Imgk, point0, pointk )
% Calculate match level
    winSize = 10;

    h0 = point0(1);
    w0 = point0(2);
    hk = pointk(1);
    wk = pointk(2);
    patch0 = double(Img0(h0-winSize:h0+winSize, w0-winSize:w0+winSize));
    patchk = double(Imgk(hk-winSize:hk+winSize, wk-winSize:wk+winSize));
    
    min_val = min(min(patch0));
    max_val = max(max(patch0));
    p0 = (patch0 - min_val) / (max_val - min_val);
    min_val = min(min(patchk));
    max_val = max(max(patchk));
    pk = (patchk - min_val) / (max_val - min_val);
    
    error_mat = (p0 - pk) * 255;
    error = sum(sum(error_mat.^2))/441;

    figure, imshow([p0;pk]);
end

