% visualize the data set
n=1;
load_mnist_all

img = xtrain(:, n); % the n-th sample as a 1D vector
img = reshape(img, 28, 28);
figure,
imshow(img') %otherwisse the iamge would be rotated by 90 degrees
ytrain(n)