function delta_depth = debugShowDepthFieldOnPoint(beliefField, x, y)
    tmp_vec = -0.8:0.04:0.8;
    x_value = reshape(tmp_vec, [41, 1]);
    y_value = reshape(beliefField{y, x}, [41, 1]);
    figure, plot(x_value, y_value, '.', 'MarkerSize', 20);
    
    [~, max_idx] = max(beliefField{y, x});
    delta_depth = (max_idx - 20 - 1) * 0.04;
end
