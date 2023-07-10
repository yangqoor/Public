projector_pattern = zeros(800, 1280);
color_set = [0, 180, 255];

for h = 9:6:800
    for w = 33:6:1280
        projector_pattern(h:h+2, w:w+2) = color_set(1);
        projector_pattern(h:h+2, w+3:w+5) = color_set(3);
%         projector_pattern(h:h+2, w+6:w+8) = color_set(1);
        projector_pattern(h+3:h+5, w:w+2) = color_set(3);
        projector_pattern(h+3:h+5, w+3:w+5) = color_set(1);
%         projector_pattern(h+3:h+5, w+6:w+8) = color_set(3);
%         projector_pattern(h+6:h+8, w:w+2) = color_set(1);
%         projector_pattern(h+6:h+8, w+3:w+5) = color_set(3);
%         projector_pattern(h+6:h+8, w+6:w+8) = color_set(2);
    end
end

imshow(projector_pattern, []);
imwrite(uint8(projector_pattern), 'pattern_optflow.png');