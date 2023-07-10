function D = floyd_warshall(D_0)
    D = D_0;
    N = size(D,1);
    for k = 1:N
        disp(k);
        D = min(D,repmat(D(:,k),[1,N])+repmat(D(k,:),[N,1]));
    end
end