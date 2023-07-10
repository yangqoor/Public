function y = upsample2(x,K)
y = upsample(upsample(x,K)',K)';
