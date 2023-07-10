function DataStructure=DataStructure_Fnc(Table)
[row col]=size(Table);
Table(1:end,5:7)=-1;
for j=1:row
    v1=Table(j,2);
    v2=Table(j,3);
    v3=Table(j,4);
    for n=1:row
        c1=find(Table(n,2:4)==v1);
        c2=find(Table(n,2:4)==v2);
        c3=find(Table(n,2:4)==v3);
            if length(c2)==1 & length(c3)==1 & length(c1)==0
                Table(j,5)=n;
            end
            if length(c1)==1 & length(c3)==1 & length(c2)==0
                Table(j,6)=n;
            end
            if length(c1)==1 & length(c2)==1 & length(c3)==0
                Table(j,7)=n;
            end
    end
end
DataStructure=Table;