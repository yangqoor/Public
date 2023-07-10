function y_p = xpro2ypro(x_c, y_c, x_p, lineA, lineB)
    paraA = lineA(y_c, x_c);
    paraB = lineB(y_c, x_c);
    paraC = - 1;

    y_p = - (paraA / paraB) * x_p - (paraC / paraB);
end

