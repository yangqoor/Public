%Script to build predicted values of kPCA depeding on no of eigne vectors
%we choose
AIC = zeros(6,1);
for noofeig = 3:3
    kPCA_main;
    %Run kPCA main script to initialize Regression matrix
psat_predicted = zeros(100,1)
for i=1:100
    psat_predicted(i,1) = kPCA_interpolate(temperature(i,1));
    %Interpolate values
end
errormat = psat_predicted - psat;
%error value consolidator
RSS = (errormat'*errormat)/100;
AIC(noofeig,1) = log (RSS) + (2*noofeig)/100;
%AIC matrix
end

