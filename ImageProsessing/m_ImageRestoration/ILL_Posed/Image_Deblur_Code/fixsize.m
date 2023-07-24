function nf=fixsize(f,n1,n2)
    [k1,k2]=size(f);
    while((k1~=n1)|(k2~=n2))
        if (k1>n1)
            s=sum(f,2);
            if (s(1)<s(end))
                f=f(2:end,:);
            else
                f=f(1:end-1,:);
            end
        end
        if (k1<n1)
            s=sum(f,2);
            if (s(1)<s(end))
                tf=zeros(k1+1,size(f,2));
                tf(1:k1,:)=f;
                f=tf;
            else
                tf=zeros(k1+1,size(f,2));
                tf(2:k1+1,:)=f;
                f=tf;
            end
        end
        if (k2>n2)
            s=sum(f,1);
            if (s(1)<s(end))
                f=f(:,2:end);
            else
                f=f(:,1:end-1);
            end
        end
        if (k2<n2)
            s=sum(f,1);
            if (s(1)<s(end))
                tf=zeros(size(f,1),k2+1);
                tf(:,1:k2)=f;
                f=tf;
            else
                tf=zeros(size(f,1),k2+1);
                tf(:,2:k2+1)=f;
                f=tf;
            end
        end
        [k1,k2]=size(f);
    end
    nf=f;
end