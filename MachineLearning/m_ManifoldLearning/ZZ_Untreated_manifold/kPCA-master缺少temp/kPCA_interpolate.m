%interpolate = 55; %interpolatae value of temperature in Celcius
function [p_new] = kPCA_interpolate(interpolate)
load q4_data
%load data from main kPCA file
width = 100;
    K_new = zeros(width,1);
    temperature = temp;
    for row = 1:width
        expression = ((temperature(row) - interpolate).^2)/(2*sigma_n.^2);
        K_new(row) = exp(-expression);
    %New Kernel is Built!
    end
    K_new;
    p_new = B*(eigvec(:,1:noofeig)'*K_new) + mean(psat(:,1));
    %Find out new p_sat after iunterpolation and adding mean
    
    


    