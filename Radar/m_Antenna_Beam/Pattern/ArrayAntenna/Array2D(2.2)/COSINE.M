function amp=cosine(nel,peddb,nexp)
% cosine on a pedestal distribution
% scale the number of elements to correspond to -1 through +1

ped=10^(-peddb/20.);
for n=1:nel
    xn=(n-1)/(nel-1)*2-1;
    amp(n)=(1.-ped)*abs(cos(xn*pi/2))^nexp+ped;
end
