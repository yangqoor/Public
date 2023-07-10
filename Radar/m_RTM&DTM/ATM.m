%% Simulation of Angle Time Map
time_cells = 32;
ATM1 = zeros(time_cells,181);
for i=1:time_cells
    %% Transceiving Signal Generation
    % Signal source directions
    az = [35+2*i;22+1*i;10+0.5*i]; % Azimuths
    el = zeros(size(az)); % Simple example: assume elevations zero
    M = length(az); % Number of sources
    % Transmitted signals
    L = 200; % Number of data snapshots recorded by receiver
    m = randn(M,L); % Example: normally distributed random signals
    % Wavenumber vectors (in units of wavelength/2)
    k = pi*[cosd(az).*cosd(el), sind(az).*cosd(el), sind(el)].';
    % Array geometry [rx,ry,rz]
    N = 10; % Number of antennas
    r = [(-(N-1)/2:(N-1)/2).',zeros(N,2)]; % Assume uniform linear array
    % Matrix of array response vectors
    A = exp(-1j*r*k);
    % Additive noise
    sigma2 = 0.01; % Noise variance
    n = sqrt(sigma2)*(randn(N,L) + 1j*randn(N,L))/sqrt(2);
    % Received signal
    x = A*m + n;

    %% MUSIC Calculation
    % Sample covariance matrix
    Rxx = x*x'/L;
    d = 0.5;% Distance between elements in Wavelenght
    [Q ,D]=eig(Rxx); %Compute eigendecomposition of covariance matrix
    [D,I]=sort(diag(D),1,'descend'); %Find r largest eigenvalues
    Q=Q (:,I); %Sort the eigenvectors to put signal eigenvectors first
    Qs=Q (:,1:M); %Get the signal eigenvectors
    Qn=Q(:,M+1:N); %Get the noise eigenvectors
    % MUSIC algorithm
    % Define angles at which MUSIC “spectrum” will be computed
    angles=(-90:1:90);
    for k=1:length(angles)
        a1(:,k)=exp(-1i*2*pi*(d*(0:N-1)'*sin([angles(k).']*pi/180)));
    end
    for k=1:length(angles)
        %Compute MUSIC “spectrum”
        music_spectrum(k)=(a1(:,k)'*a1(:,k))/(a1(:,k)'*(Qn*Qn')*a1(:,k));
    end
    ATM1(i,:)=music_spectrum;
    % plot(angles,abs(music_spectrum))
    % grid on
    % title('MUSIC Spectrum')
    % xlabel('Angle in degrees')
    % ylabel('Amplitude')
end
T=4;
imagesc([0,T],angles,abs(ATM1'));
xlabel('Time (s)');
ylabel('Angle (°)');
title('Angle-Time Map');
axis xy;
clim = get(gca,'CLim');
% set(gca,'CLim',clim(2) + [-45 0]);
colorbar;
drawnow;