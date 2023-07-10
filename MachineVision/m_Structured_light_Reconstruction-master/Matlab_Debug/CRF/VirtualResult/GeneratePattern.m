patternMatrix = zeros(PROJECTOR_HEIGHT, PROJECTOR_WIDTH);
partRegion = zeros(100, 160);
for i = 1:2:100
    for j = 1:2:160
        rand_int = randi(4);
        partRegion(i:i+1, j:j+1) = double(rand_int - 1) / 3;
    end
end
for h = 1:100:PROJECTOR_HEIGHT
    for w = 1:160:PROJECTOR_WIDTH
        patternMatrix(h:h+100-1, w:w+160-1) = partRegion;
    end
end
imwrite(patternMatrix, '4RandDot0.png');