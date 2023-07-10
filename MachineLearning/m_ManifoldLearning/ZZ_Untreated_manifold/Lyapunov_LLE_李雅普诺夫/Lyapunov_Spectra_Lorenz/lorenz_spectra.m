function lorenz_spectra(T,dt)
% Usage: lorenz_spectra(T,dt)
% T is the total time and dt is the time step

% parameters defining canonical Lorenz attractor
sig=10.0;
rho=28;
bet=8/3;

% dt=0.01; %time step
N=T/dt; %number of time intervals

% calculate orbit at regular time steps on [0,T]
% using matlab's built-in ode45 runge-kutta integration routine

% begin with initial conditions (1,2,3)
x1=1; x2=2; x3=3;
% integrate forwards 10 units
[t,x] = ode45(@lorenz63,[0:1:10],[x1;x2;x3]);
n=length(t);
% begin at this point, hopefully near attractor!
x1=x(n,1); x2=x(n,2); x3=x(n,3);
[t,x] = ode45('lorenz63',[0:dt:T],[x1;x2;x3]);

e1=0;
e2=0;
e3=0;

% show trajectory being analyzed
plot3(x(:,1),x(:,2),x(:,3),'.','MarkerSize',2);
JN = eye(3);
w = eye(3);
J = eye(3);

for k=1:N
    % calculate next point on trajectory
    x1 = x(k,1);
    x2 = x(k,2);
    x3 = x(k,3);
    % calculate value of flow matrix at orbital point
    % remember it is I+Df(v0)*dt not Df(v0)
    J = (eye(3)+[-sig,sig,0;-x3+rho,-1,-x1;x2,x1,-bet]*dt);
    % calculate image of unit ball under J
    % remember, w is orthonormal ...
    w = ortho(J*w);
    % calculate stretching
    % should be e1=e1+log(norm(w(:,1)))/dt; but scale after summing
    e1=e1+log(norm(w(:,1)));
    e2=e2+log(norm(w(:,2)));
    e3=e3+log(norm(w(:,3)));
    % e1=e1+norm(w(:,1))-1;
    % e2=e2+norm(w(:,2))-1;
    % e3=e3+norm(w(:,3))-1;
    % renormalize into orthogonal vectors
    w(:,1) = w(:,1)/norm(w(:,1));
    w(:,2) = w(:,2)/norm(w(:,2));
    w(:,3) = w(:,3)/norm(w(:,3));
end

% exponent is given as average e1/(N*dt)=e1/T
e1=e1/T; % Lyapunov exponents
e2=e2/T;
e3=e3/T;
l1=exp(e1); % Lyapunov numbers
l2=exp(e2);
l3=exp(e3);
[e1,e2,e3]
trace=e1+e2+e3
[l1,l2,l3]