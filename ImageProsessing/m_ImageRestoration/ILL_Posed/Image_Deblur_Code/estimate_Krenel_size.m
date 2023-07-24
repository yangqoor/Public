function [psfsize] = estimate_Krenel_size(S)
    dx = [-1 0 1; -2 0 2;-1 0 1];
    dy = dx';
    dS = conv2(S, dy, 'valid');
    ft = fft(dS);
    ft = fftshift((abs(ft)));
    [m,n] = size(S);
    lf = log(1+abs(ft));
    ff = fftshift(real(fft(lf.^5)));

    k = find(ff>0);
    ff(k) = 0;
    [m,n] = size(ff);
    ff1 = sum(ff');

    MINY = zeros(1,30);
    MINYT = zeros(1,30);
    MINYY = min(ff1)/10;
    ii = 1;
    for i = 20:m/2-8
        if(ff1(i) == min(ff1(1,i-8:i+8))&&ff1(i)<MINYY)
            MINY(1,ii) = ff1(i);
            MINYT(1,ii) = i;
            ii = ii+1;
        end
    end

    MINYY = 0;
    MINYYT = 0;
    for i = 1:30
        if(MINYY>MINY(1,i))
            MINYY = MINY(1,i);
            MINYYT = MINYT(1,i);
        end
    end

    sizeY = floor(m/2-MINYYT);
    if(sizeY>m/4)
        sizeY = 16;
    end

    S = S';
    dS = conv2(S, dy, 'valid');
    ft = fft(dS);
    ft = fftshift((abs(ft)));
    [m,n] = size(S);
    lf = log(1+abs(ft));
    ff = fftshift(real(fft(lf.^5)));

    k = find(ff>0);
    ff(k) = 0;
    [m,n] = size(ff);
    ff2 = sum(ff');

    MINX = zeros(1,30);
    MINXT = zeros(1,30);
    MINXX = min(ff2)/10;
    ii = 1;
    for i = 20:m/2-8
        if(ff2(i) == min(ff2(1,i-8:i+8))&&ff2(i)<MINXX)
            MINX(1,ii) = ff2(i);
            MINXT(1,ii) = i;
            ii = ii+1;
        end
    end

    MINXX = 0;
    MINXXT = 0;
    for i = 1:30
        if(MINXX>MINX(1,i))
            MINXX = MINX(1,i);
            MINXXT = MINXT(1,i);
        end
    end

    sizeX = floor(m/2-MINXXT);
    if(sizeX>m/4)
        sizeX = 16;
    end

    sizeX = floor(sizeX);
    sizeY = floor(sizeY);
    psfsize = 0;
    if(max(sizeX,sizeY)<=20)
        psfsize = 1;
    end
end