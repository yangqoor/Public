function [x_p, y_p] = GetCoordinateByDepth(x_c, y_c, depth, pattern)
    % inner parameters
    cameraMatrix = [ 2400.0, 0.0, 640.0;
        0.0, 2400.0, 512.0;
        0.0, 0.0, 1.0];
    projectorMatrix = [ 2400.0, 0.0, 640.0;
        0.0, 2400.0, 400.0;
        0.0, 0.0, 1.0];
    rotationMatrix = [1.0, 0.0, 0.0;
        0.0, 1.0, 0.0;
        0.0, 0.0, 1.0];
    transportVector = [5.0;
        0.0;
        0.0];

    % camera -> world
    point_camera = [x_c; y_c; 1];
    fx = cameraMatrix(1, 1); dx = cameraMatrix(1, 3);
    fy = cameraMatrix(2, 2); dy = cameraMatrix(2, 3);
    point_world = [depth * (x_c - dx) / fx;
        depth * (y_c - dy) / fy;
        depth;
        1];

    % world -> projector
    point_projector = projectorMatrix ...
        * [rotationMatrix, transportVector] * point_world;
    x_p = point_projector(1) / point_projector(3);
    y_p = point_projector(2) / point_projector(3);

    % Get color value
    color = GetColorByCoordinate(x_p, y_p, pattern);
end
