function [Kernel opts] = estimate_Kernel(yg,opts)
%%
%%   Parameters: 
%%   Input:
%     @yg: Input blurred image.
%     @opts: Input parameters.
%%   Output:
%     @Kernel: Estimated blur kernel.
%     @opts: Input parameters.
%%
    [Kernel opts.kernel_size opts.kernal_size2]= estimate_Ceps(yg);

    [m,n] = size(Kernel);
    psfsize = estimate_Krenel_size(yg);
    m = floor((m-1)/2);
    n = floor((n-1)/2);

    if(psfsize == 1)
        psfsize = 15;
        psfsize1 = psfsize;
        psfsize2 = psfsize;

        if(psfsize1>m)
            psfsize1 = m;
        end
        if(psfsize2>n)
            psfsize2 = n;
        end

        opts.kernel_size = psfsize1;
        opts.kernal_size2 = psfsize2;
        Kernel1 = Kernel;
        Kernel = zeros(2*psfsize1+1,2*psfsize2+1)
        Kernel = Kernel1(m-psfsize1+1:m+psfsize1+1,n-psfsize2+1:n+psfsize2+1);
    end
end