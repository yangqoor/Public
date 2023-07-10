function out=Cal_Scene_Para(Scene,Carrier,Scan,receive_shift)
if nargin==3
    receive_shift=0;
end
out=[];
for k=1:numel(Scene.array)
    index_x=floor((k-1)/Scene.nr)+1;
    index_y=k-(index_x-1)*Scene.nr;
    sigma=Scene.array(index_x,index_y);
    if sigma==0
        continue;
    else
        x=Scene.R_ref+(index_y-(Scene.nr+1)/2)*Scene.Space;
        y=(index_x-(Scene.na+1)/2)*Scene.Space;
        
        r=sqrt((x-Carrier.x)^2+(y-(Carrier.y+receive_shift))^2);
        sita=angle((x-Carrier.x)+1j*(y-(Carrier.y+receive_shift)))*180/pi;
        
        temp_sita=angle((x-Carrier.x)+1j*(y-Carrier.y))*180/pi;
        if temp_sita>=Scan.CurrentDown && temp_sita<=Scan.CurrentUp
            TEMP.x=x;
            TEMP.y=y;
            TEMP.r=r;
            TEMP.sita=sita;
            TEMP.sigma=sigma;
            out=[out,TEMP];
        end
    end
    
    
    
    
end