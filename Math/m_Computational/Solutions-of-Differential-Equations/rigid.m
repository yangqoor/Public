function dx = rigid(t,x)
dx = zeros(3,1);
A = [-21,19,-20;
     19,-21,20;
     40,-40,-40];
dx = A*[x(1);x(2);x(3)];




