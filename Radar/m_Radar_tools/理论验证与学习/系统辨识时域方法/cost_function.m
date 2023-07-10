function [cost] = cost_function(half_w,sig_ref,sig_cali)
half_w = half_w(:);
w = [flipud(half_w(2:end));half_w];
sig = conv(w,sig_ref);
cost = sum(abs(sig-sig_cali));
end