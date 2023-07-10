function y_p = xpro2ypro(x_c, y_c, x_p, epi_para)
    paraA = epi_para.A(y_c, x_c);
    paraB = epi_para.B(y_c, x_c);
    paraC = - epi_para.C(y_c, x_c);

    y_p = - (paraA / paraB) * x_p - (paraC / paraB);
end

