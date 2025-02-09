noise=0.001;
random1=rand(3,1);
random2=rand(3,1);
random3=rand(3,1);
focal_point1=6*random1/norm(random1);
focal_point2=6*random2/norm(random2);
focal_point3=6*random2/norm(random3);
A1=[eye(3) focal_point1];
A2=[eye(3) focal_point2];
A3=[eye(3) focal_point3];
twidleA1=twidleMatrix(A1);
twidleA2=twidleMatrix(A2);
twidleA3=twidleMatrix(A3);
A={twidleA1 twidleA2};
X=rand(4,1);
Y=rand(4,1);
M=X*Y'+Y*X'; M=M/M(4,4);
x1=A1*[X,Y]+normrnd(0,noise,3,2);
x2=A2*[X,Y]+normrnd(0,noise,3,2);
x3=A3*[X,Y]+normrnd(0,noise,3,2);
N1=x1(:,1)*x1(:,2)'+x1(:,2)*x1(:,1)'; vecN1 = N1(tril(true(size(N1))));
N2=x2(:,1)*x2(:,2)'+x2(:,2)*x2(:,1)'; vecN2 = N2(tril(true(size(N2))));
N3=x3(:,1)*x3(:,2)'+x3(:,2)*x3(:,1)'; vecN3 = N3(tril(true(size(N3))));
N=[vecN1 vecN2];
[kernelProjB, B]=svdTriangulation(A,N);
M0=[focal_point2;1]*[focal_point1;1]'+[focal_point1;1]*[focal_point2;1]'; M0=M0/M0(4,4);
M1=vecToSymmetric4x4Matrix(kernelProjB(:,1));
M2=vecToSymmetric4x4Matrix(kernelProjB(:,2));
alpha=eig(M2,M2-M1);


Mres1=alpha(1)*M1+(1-alpha(1))*M2; Mres1=Mres1/Mres1(4,4);
Mres2=alpha(2)*M1+(1-alpha(2))*M2; Mres2=Mres2/Mres2(4,4);
Mres3=alpha(3)*M1+(1-alpha(3))*M2;  Mres3=Mres3/Mres3(4,4);
Mres4=alpha(4)*M1+(1-alpha(4))*M2;  Mres4=Mres4/Mres4(4,4);

norm(M-Mres1,'fro')
norm(M-Mres2,'fro')
norm(M-Mres3,'fro')
norm(M-Mres4,'fro')
