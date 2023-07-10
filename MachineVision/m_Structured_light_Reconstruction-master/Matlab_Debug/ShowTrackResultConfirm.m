hBegin = 450;
hEnd = 650;
wBegin = 700;
wEnd = 900;
warning('off');

fix_h0 = 609;
fix_w0 = 817;

for frameIdx = 2:49
    iH = load(['./result/trace/iH', num2str(frameIdx), '.txt']);
    iW = load(['./result/trace/iW', num2str(frameIdx), '.txt']);
    Img = imread(['./dyna/dyna_mat', num2str(frameIdx), '.png']);
    
    rgbImg = zeros(1024, 1280, 3);
    rgbImg(:,:,1) = double(Img) / 255.0;
    rgbImg(:,:,2) = double(Img) / 255.0;
    rgbImg(:,:,3) = double(Img) / 255.0;
    
    hLen = hEnd - hBegin;
    wLen = wEnd - wBegin;
    for i = 1:(hEnd-hBegin)
        for j = 1:(wEnd-wBegin)
            h0 = i + hBegin;
            w0 = j + wBegin;
            
            hk = iH(i, j) + 1;
            wk = iW(i, j) + 1;
            
            if h0 == fix_h0 && w0 == fix_w0
                rgbImg(hk, wk, 1) = 1.0;
                rgbImg(hk, wk, 2) = 1.0;
                rgbImg(hk, wk, 3) = 0.0;
                continue;
            end
            
            if (rgbImg(hk, wk, 3) == 1.0)
                %fprintf('%d,%d\n', h, w);
            end
            
            rgbImg(hk, wk, 1) = i / hLen;
            rgbImg(hk, wk, 2) = j / wLen;
            rgbImg(hk, wk, 3) = 1.0;
        end
    end
    
    imshow(rgbImg);
    % imwrite(rgbImg, ['TrackResults/rgbImg', num2str(frameIdx), '.png']);
    
    fprintf('%d frame.\n', frameIdx);
    
end