function depth = xpro2depth(x_c, y_c, x_p)
    cameraMatrix = [ 2321.35, 0.0, 639.50;
    0.0, 2326.22, 511.50;
    0.0, 0.0, 1.0];
    projectorMatrix = [ 1986.02, 0.0, 598.16;
        0.0, 1983.35, 856.85;
        0.0, 0.0, 1.0];
    rotationMatrix = [0.9945, 0.02305, -0.1020;
        -0.03917, 0.9865, -0.03917;
        0.09694, 0.1621, 0.9820];
    transportVector = [10.31;
        -2.8678;
        7.8434];
    
    camMat = [cameraMatrix, zeros(3, 1)];
    proMat = projectorMatrix * [rotationMatrix, transportVector];
    
    paraA = camMat(1, 1) * camMat(2, 2) * proMat(1, 4);
    paraB = camMat(1, 1) * camMat(2, 2) * proMat(3, 4);
    paraC = (x_c - camMat(1, 3)) * camMat(2, 2) * proMat(1, 1) ...
        + (y_c - camMat(2, 3)) * camMat(1, 1) * proMat(1, 2) ...
        + camMat(1, 1) * camMat(2, 2) * proMat(1, 3);
    paraD = (x_c - camMat(1, 3)) * camMat(2, 2) * proMat(3, 1) ...
        + (y_c - camMat(2, 3)) * camMat(1, 1) * proMat(3, 2) ...
        + camMat(1, 1) * camMat(2, 2) * proMat(3, 3);
    
    depth = - (paraA - paraB * x_p) / (paraC - paraD * x_p);
end