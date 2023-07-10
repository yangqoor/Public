function TF = stft(f,wd) 
cntr = length(f)/2; 
sigma = wd; 
fsz = length(f); 
z = exp(-([1:fsz]-fsz/2).^2/(2*sigma^2))/(sqrt(2*pi)*sigma); 
for m=1:fsz 
    mm = m-cntr+fsz/2; 
    if (mm <= fsz & mm >= 1) 
        gwin(m) = z(mm); 
    else 
        if (mm > fsz) 
           gwin(m) = z(rem(mm,fsz)); 
        else 
           if(mm < 1) 
              mm1 = mm+fsz; 
              gwin(m) = z(mm1); 
           end 
        end 
    end 
end 
winsz = length(gwin); 
x = zeros(1,fsz+winsz); % Zero Padding 
x(winsz/2+1:winsz/2+fsz) = f; 
for j = 1:fsz 
   for k = 1:winsz 
      X(k) = gwin(k)*x(j+k);   
   end              
   TF(:,j) = fft(X).'; 
end 
 