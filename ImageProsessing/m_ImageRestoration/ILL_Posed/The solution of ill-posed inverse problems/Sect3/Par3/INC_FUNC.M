function F=Inc_func(z,A,u,delta,hdelta)

H=hdelta*norm(A);
Delta=delta*norm(u);
F=norm(A*z-u)+Delta+H*norm(z);