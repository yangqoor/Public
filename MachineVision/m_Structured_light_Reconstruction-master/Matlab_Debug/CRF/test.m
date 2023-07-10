pattern = zeros(800, 1280);
sub_pattern = zeros(100, 160);
for h = 1:2:100
    for w = 1:2:160
        sub_pattern(h:h+1, w:w+1) = double(randi(8) - 1) / 7;
    end
end

for h = 1:8
    for w = 1:8
        pattern((h-1)*100+1:h*100, (w-1)*160+1:w*160) = sub_pattern;
    end
end

imshow(pattern);
imwrite(pattern, '8RandDot0.png');