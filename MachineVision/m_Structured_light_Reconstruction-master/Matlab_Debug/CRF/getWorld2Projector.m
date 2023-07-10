function [ projector_point ] = getWorld2Projector( world_point )
    % GETWORLD2PROJECTOR transfer world_point 2 projector
    
    % Set parameters
    projectorMatrix = [1986.023, 0.0, 598.155;
        0.0, 1983.349, 856.845;
        0.0, 0.0, 1.0];
    rotationMatrix = [0.99452, 0.023053, -0.10198;
        -0.039173, 0.98650, -0.15901;
        0.096938, 0.16214, 0.98200];
    transportVector = [10.3084;
        -2.8678;
        7.8434];
    proMat = projectorMatrix * [rotationMatrix, transportVector];
    
    projector_point = proMat * world_point;
    projector_point = projector_point / projector_point(3);
end

