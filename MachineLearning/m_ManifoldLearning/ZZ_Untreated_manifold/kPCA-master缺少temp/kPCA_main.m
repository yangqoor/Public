%Gaussian Kernel = K(x,y) = exp(-(x-y)^2/(sigma)^2)%
%Loading Temperature data as temperature%
%sigma is the standard deviation of the temperature values%
%的高斯核= k（x，y）= exp（-（X-Y）^ 2 /（∑）^ 2）%
%装载温度数据为温度%
%是温度值的标准偏差%。
noofeig = 3;
width = 100;
temperature =temp;
sigma_n = std(temperature((1:width),1));
sigma = sigma_n;

K = zeros(width,width);
for row = 1:width
    for column = 1: width
        expression = ((temperature(row) - temperature(column)).^2)/(2*sigma.^2);
        %Gaussian Kernel function
        K(row,column) = exp(-expression); %#ok<*IJCL>
    end
end
%K = K + K';
%for i = 1:size(temperature)
 %   K(i,i) = K(i,i)./2;
%end

one_matrix = ones(size(K))./width;
%Pseudo-centering of K must be done for kPCA to be applied
K = K - one_matrix*K - K*one_matrix + one_matrix*K*one_matrix;
%This centers K
[eigvec eigval] = eigs(K);
%Normalizing the Vectors in the lower dimensions

lambdamat = zeros(noofeig,noofeig);
for i = 1:noofeig
    lambdamat(i,i) = 1/sqrt(eigval(i,i));
end
for column = 1:noofeig
    eigvec(:,column) = eigvec(:,column)./(sqrt(eigval(column,column)));
    %Nrmalize Eigen vectors
end

Principal_components = eigvec(:,1:noofeig)'*K;
%saturation_pressure is the mean shifted saturation pressure%;
saturation_pressure(:,1) = psat(:,1) - mean(psat(:,1));
%Mean centering of pressure.
B = saturation_pressure'*Principal_components'*inv(Principal_components*Principal_components');
%Regression Matrix
save('q4_data');
%B'*(lambda)^-1/2*A*K_new

%lambda 
