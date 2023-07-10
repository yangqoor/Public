function plotcol (points, ppm, colors)

M = length(colors);
figure;
hold on;
cumppm = cumsum(ppm);
cumppm = [0 cumppm(:)'];
for m = 1:M
    a = cumppm(m)+1;
    b = cumppm(m+1);
    if (size (points,2) == 2)
      plot ( points(a:b,1), points(a:b,2), [ colors(m) 'o' ] );
    elseif (size (points,2) == 3)
      plot3 ( points(a:b,1), points(a:b,2),points(a:b,3), [ colors(m) 'o' ] );
    end
end
hold off;

