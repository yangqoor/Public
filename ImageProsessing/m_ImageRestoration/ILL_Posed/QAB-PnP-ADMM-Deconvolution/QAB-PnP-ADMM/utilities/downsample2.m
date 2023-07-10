function y = downsample2(x,K)
y = downsample(downsample(x,K)',K)';
