% Set parameters
warning('off');
clear;
load ParaEpi.mat

color_vecs = cell(total_frame_num,1);
for frame_idx = 0:total_frame_num-1
    fprintf('Iter%d:\n', frame_idx);
    Gene_ColorTable;
    color_vecs{frame_idx+1,1} = ParaTable.color;
end

color_vec = zeros(size(color_vecs{1,1}));
for frame_idx = 1:total_frame_num
    color_vec = color_vec + color_vecs{frame_idx,1} / total_frame_num;
end
ParaTable.color = color_vec;
save('ColorPara.mat', 'ParaTable');