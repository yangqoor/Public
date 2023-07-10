width = 30;
AIC = zeros(71,1);
%AIC criteria initialized to check for width compatibility
for width = 30:100

kPCA_main;
psat_predicted = zeros(width,1);
for i=1:width
    psat_predicted(i,1) = kPCA_interpolate(temperature(i,1));
end
errormat = psat_predicted - psat;
RSS = (errormat'*errormat)/100;
AIC(width,1) = log (RSS) + (2*noofeig)/100;
end
