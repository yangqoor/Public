function [  ] = my_imshow( show_mat, viewportMatrix, norm )
    if norm
        imshow(show_mat(viewportMatrix(2,1):viewportMatrix(2,2), viewportMatrix(1,1):viewportMatrix(1,2)), []);
    else
        imshow(show_mat(viewportMatrix(2,1):viewportMatrix(2,2), viewportMatrix(1,1):viewportMatrix(1,2)));
    end
end

