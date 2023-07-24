function cx=convfun(x,k,cycconvv,convshape)
    if ~exist('convshape','var')
        convshape='valid';
    end
    
    if cycconvv
       cx=cycconv(x,k);
    else
       cx=conv2(x,k,convshape);
    end
    