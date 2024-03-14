function [result, t0_rough] = pyramid_dehazing_w_A(RGB0, I0, I1, I2, A, gamma)

%     r1 =[360 640];
%     r0 = [720 1280];

    r = 16;
    rr = 1;
    hei = 36;
    wid = 64;

    N = boxfilter(ones(hei,wid), r);
    NN = boxfilter(ones(hei, wid), rr); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.
    
    %% Estimation of T
    max_I = max(I2(:));
    min_I = min(I2(:));
    
    q = gamma * (I2 - min_I) / (max_I - min_I)  .* I2;
    
    if min_I < 0.1
        J2 = q + min_I;
    elseif min_I >= 0.1 && min_I < 0.2
        J2 = q + min_I/2;
    elseif min_I >= 0.2 && min_I < 0.3
        J2 = q + min_I/4;
    elseif min_I >= 0.3
        J2 = q + min_I/8;
    end
    
    % Level 2
    J2 = min(J2, max_I);
    t2 = (A - I2)./ (A - J2);
    t2 = abs(t2);

    
    t2_refine = t2;
    t2_refine(I2 >= A) = 1 / max(t2(:)) * t2(I2 >= A);
    t2 = t2_refine;

%     t2 = max(t2, 0.05);

%     t2 = t2.^0.9;
%     t2 = sqrt(t2);
    
    [m,n,~] = size(t2);
    r1 = [m * 2 n * 2];
    % Level 1
    t1_raw = imresize(t2, r1 ,'bilinear');
    t1_final = fast_gradient_1(I1, t1_raw, N, NN);
    t1_final = max(t1_final, 0.05);
    
    [m,n,~] = size(t1_final);
    r0 = [m * 2 n * 2];
    % Level 0
    t0_raw = imresize(t1_final, r0 ,'bilinear');
    t0_rough = t0_raw ;
    
    t0 = fast_gradient_2(I0, t0_raw, N, NN);
    t0 = max(t0, 0.05);
    
    %% haze-free image
    result = (RGB0 - A) ./ t0 + A;  

end