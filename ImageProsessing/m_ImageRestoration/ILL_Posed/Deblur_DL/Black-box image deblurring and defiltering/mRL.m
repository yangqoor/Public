function [S, E] = mRL(F, y, options)
% Derivative free variant of Lucy-Richardson

options.null = 0;
maxiter = getoptions(options, 'maxiter', 500);

S = y;

E = [];
e = img_norm(y - F(S));
E = [E; e];

for i=1:maxiter
    r1 = F(S)./(abs(y)+eps);
    r1 = r1(end:-1:1,end:-1:1,:);
    r2 = F(r1);
    r2 = r2(end:-1:1,end:-1:1,:);
    S = S./(abs(r2)+eps);
    
    r1 = y./(abs(F(S))+eps);
    r1 = r1(end:-1:1,end:-1:1,:);
    r2 = F(r1);
    r2 = r2(end:-1:1,end:-1:1,:);
    S = S.*r2;
    
    e = img_norm(y - F(S));
    E = [E; e];
end

end
