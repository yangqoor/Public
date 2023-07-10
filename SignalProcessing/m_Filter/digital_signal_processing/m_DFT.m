function Xk=m_DFT(xn)
N=size(xn,2);
K=N;
Xk=zeros(1,K);
for k=1:K
    for n=1:N
        Xk(k)=Xk(k)+xn(n)*exp(-1i*2*pi/N*(n-1)*(k-1));
    end
end