% generate h = exp( sqrt(x^2 + y^2)/240 ) blur template

function  h = BlurTemplate(n)

x = -floor(n/2):floor(n/2);
y = -floor(n/2):floor(n/2);

for i = 1:size(x,2)
    for j = 1:size(y,2)
        h(i,j) = exp( sqrt( x(i)^2 + y(j)^2 ) / 240 );
    end
end

h = h./sum(sum(h));
