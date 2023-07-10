# Convolutional-Neural-Network
### Built the CNN

### Used MINIST data set to test and train the network

Start with several observations by control experiments. Notice that because the training time of neural network is long (on the scale of hours), the observations are based on a few scattered points and thereby some can be far from conclusive.

- To take the advantage of fast matrix computation, miniBatch is applied to gradient descent process with suggested sizes the power of 2.
- The training time per sample per iteration with GDS is almost twice of that with miniBatch of sizes 8, 16 and 64.
- When minibatch size < 4, the loss function does not decrease after only a few iterations. By monitoring the histograms of the weight changes of units, it is found that most units become "dead" quickly. That's because when only a few images are used each time, the chance that the values of all dimensions are in the negative side of the ReLU function is considerable. Once it occurs, these units become dead and there would be no longer weight flow through.
- To optimize the speed of gradient descent converge, the miniBatch size has to be tuned together with the decaying learning rate. More specific, with a larger miniBatch, the gradient descent evolution trends to  travel down vertically and a larger learning rate is safe and preferred; whereas with a smaller miniBath, the gradient descent evolution is more random and a smaller learning rate can be better.
- The best test accuracy, 99.3% I got is a CNN with miniBatch size of 8 (my CPU is 64 bits). While the best test accuracy I got from the CNN with miniBatch size of 64 is 99.1%.
- All of the handwritten digits on the incorrectly classified test samples have unusual fashion. In fact, I feel many of them are mislabaled and the train CNN does give digits that look more similar to the hand writtings.
