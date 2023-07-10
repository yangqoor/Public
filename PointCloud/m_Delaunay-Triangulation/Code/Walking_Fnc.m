function Triangle=Walking_Fnc(x,y,DataStructure,mat)
a=[x y];
i=1;b=true;
if isnan(x) | isnan(y)
    Triangle=0;
else
while b==true && i~=-1
    v1=DataStructure(i,2);
    v2=DataStructure(i,3);
    v3=DataStructure(i,4);
    d(1,1)=det([mat(v2,2:3) 1;mat(v3,2:3) 1;a 1]);
    d(1,2)=det([mat(v3,2:3) 1;mat(v1,2:3) 1;a 1]);
    d(1,3)=det([mat(v1,2:3) 1;mat(v2,2:3) 1;a 1]);
    f=find(d<0);
    if length(f)==2
        i=DataStructure(i,f(1,1)+4);
    end
    if length(f)==1
        i=DataStructure(i,f+4);
    end
    if length(f)==3 | length(f)==0
        b=false;
        Triangle=i;
    end
end
end
if i==-1
    Triangle=0;
end
