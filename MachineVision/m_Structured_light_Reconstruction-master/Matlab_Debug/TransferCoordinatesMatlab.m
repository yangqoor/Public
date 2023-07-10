function [ h0, w0 ] = TransferCoordinatesMatlab(rgbImg, h, w)
    hBegin = 450;
    hEnd = 650;
    wBegin = 700;
    wEnd = 900;
    
    hLen = hEnd - hBegin;
    wLen = wEnd - wBegin;

    r_val = rgbImg(h, w, 1);
    g_val = rgbImg(h, w, 2);
    
    i = r_val * hLen;
    j = g_val * wLen;
    
    h0 = i + hBegin;
    w0 = j + wBegin;

end

