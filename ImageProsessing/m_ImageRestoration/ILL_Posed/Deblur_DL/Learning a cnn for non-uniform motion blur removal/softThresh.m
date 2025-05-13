function z = softThresh(yout, beta)
z = sign(yout) .* max(abs(yout) - beta, 0);