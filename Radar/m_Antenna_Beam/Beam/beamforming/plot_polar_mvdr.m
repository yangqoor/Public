function plot_polar_mvdr(name)

eval(['load  ' name]);

% test vectors for spatially sampled response
W_H     = conj(W(Ndata, :));
st      = -1 : 0.025 : 1;
st_angle=-pi/2:0.0392:pi/2;
est     = exp(-j*pi*[0:(rp.p-1)]'*st);

S   = ones(81,1);
qq1 = pi*sin(st);

for n=[1 2 3 4], 
   S(:,n+1)=exp(-j*n*qq1'); 
end

polar(st_angle,abs(W_H*S').^2)