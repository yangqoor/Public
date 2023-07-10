function plot_mvdr(name)

eval(['load  ' name]);

% test vectors for spatially sampled response
W_H     = conj(W(Ndata, :));
st      = -1 : 0.025 : 1;
est     = exp(-j*pi*[0:(rp.p-1)]'*st);

S   = ones(81,1);
qq1 = pi*sin(st);

for n=[1 2 3 4], 
   S(:,n+1)=exp(-j*n*qq1'); 
end
plot(st,10*log10(abs(W_H*S').^2),rp.color)
xlabel('sin \theta')
ylabel('Amplitude response, dB')
