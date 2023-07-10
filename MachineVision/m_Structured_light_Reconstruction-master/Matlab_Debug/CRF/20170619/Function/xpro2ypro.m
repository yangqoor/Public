function y_p = xpro2ypro(x_c, y_c, x_p, lineA, lineB, lineC)
    paraA = lineA(y_c, x_c);
    paraB = lineB(y_c, x_c);
    paraC = - lineC(y_c, x_c);

    y_p = - (paraA / paraB) * x_p - (paraC / paraB);
end

