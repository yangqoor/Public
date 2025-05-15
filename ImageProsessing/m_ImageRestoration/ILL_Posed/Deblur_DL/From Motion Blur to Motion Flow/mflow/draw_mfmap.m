% draw motion field over images
function im_mfmap = draw_mfmap(img, mag, ori)
% img: blurred image.
% [mag, ori]: motion flow in "magnitude + orientation" format.
[r,c,d] = size(img);
inte = 21;
if d > 1
    img = double((rgb2gray(uint8(img)))) / 255;
end
im_mfmap(:,:,1) = 0.7 * 1 + 0.4 * img;
im_mfmap(:,:,2) = 0.7 * 1 + 0.4 * img;
im_mfmap(:,:,3) = 0.7 * 1 + 0.4 * img;
ori = 90 - ori;
rec_wid = 1;
for i = inte : inte : r - inte
    for j = inte : inte : c - inte
        l = max(mag(i, j), 1);
        o = ori(i, j);

        ft = ((fspecial('motion', l, o)));
        kkk = fspecial('average', 2);
        ft = conv2(ft, kkk, 'same');
        
        
        ft = ft / max(ft(:));
        [w,h] = size(ft);
        
        [xs, ys] = find(ft > 0);
        ids_ker = sub2ind([w,h], xs, ys);
        xs = xs - (w+1) / 2;
        ys = ys - (h+1) / 2;
        ids_img = sub2ind([r,c], i + xs, j + ys);
        
        im_mfmap(ids_img) = 1 * ft(ids_ker) + (1 - ft(ids_ker)) .* im_mfmap(ids_img);
        im_mfmap(ids_img + r * c) = (1 - ft(ids_ker)) .* im_mfmap(ids_img + r * c);
        im_mfmap(ids_img + 2 * r * c) = (1 - ft(ids_ker)) .* im_mfmap(ids_img + 2 * r * c);
        
        % draw a rectangle around the centered pixel
        if(0)
            for pp = i - rec_wid : i +  rec_wid
                for qq = j - rec_wid : j + rec_wid
                    imMotion(pp, qq, 1) = 0;
                    imMotion(pp, qq, 2) = 0;
                    imMotion(pp, qq, 3) = 1;  
                end
            end
        end
        im_mfmap(i, j, 1) = 0;
        im_mfmap(i, j, 2) = 0.5;
        im_mfmap(i, j, 3) = 0;
    end
end


