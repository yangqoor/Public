function [ws]=makeBasis(Kwhiten,shift)

ws=[];

bigK=Kwhiten;
    
    
    for dx=[-shift:shift]
        for dy=[-shift:shift]
            zeroIm=zeros(2*shift+1);
            zeroIm(shift+1+dx,shift+1+dy)=1;
            newK=conv2(bigK,zeroIm,'same');
            ws=[ws newK(:)];
        end
    end
end