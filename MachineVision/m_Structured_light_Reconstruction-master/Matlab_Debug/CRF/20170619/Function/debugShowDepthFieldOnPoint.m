function debugShowDepthFieldOnPoint(beliefField, x, y)
    tmp_vec = -0.4:0.02:0.4;
    x_value = reshape(tmp_vec, [41, 1]);
    y_value = reshape(beliefField{y, x}, [41, 1]);
    figure, plot(x_value, y_value, '.', 'MarkerSize', 20);
end
