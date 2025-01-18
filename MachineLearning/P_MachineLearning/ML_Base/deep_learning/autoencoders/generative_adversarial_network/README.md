# Generative Adversarial Networks (GAN)
`Generative Adversarial Networks` takes up a game-theoretic approach, unlike a conventional neural network. The network learns to generate from a training distribution through a 2-player game. The two entities are Generator and Discriminator. These two adversaries are in constant battle throughout the training process. Since an adversarial learning method is adopted, we need not care about approximating intractable density functions.

As you can identify from their names, a generator is used to generate real-looking images and the discriminator’s job is to identify which one is a fake. The entities/adversaries are in constant battle as one(generator) tries to fool the other(discriminator), while the other tries not to be fooled. To generate the best images you will need a very good generator and a discriminator. This is because if your generator is not good enough, it will never be able to fool the discriminator and the model will never converge. If the discriminator is bad, then images which make no sense will also be classified as real and hence your model never trains and in turn you never produces the desired output. The input, random noise can be a Gaussian distribution and values can be sampled from this distribution and fed into the generator network and an image is generated. This generated image is compared with a real image by the discriminator and it tries to identify if the given image is fake or real.

## code 
[`python3 sample_keras.py`](./sample_keras.py)  
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
[`python3 sample_scratch.py`](./sample_scratch.py)  

<p align="center">
  <img src="https://miro.medium.com/max/875/1*XKanAdkjQbg1eDDMF2-4ow.png" width="500px">
</p>
<p align="center">
  <img src="https://paperswithcode.com/media/methods/unetgan_BmLpRoq.png" width="500px">
</p>
<p align="center">
  <img src="https://miro.medium.com/max/7680/1*UMg_hfitiq_XlMJUn_fzFw.jpeg" width="500px">
</p>

## Usefull Resources:
+ https://machinelearningmastery.com/what-are-generative-adversarial-networks-gans/
+ https://towardsdatascience.com/understanding-generative-adversarial-networks-gans-cd6e4651a29
+ https://towardsdatascience.com/explained-a-style-based-generator-architecture-for-gans-generating-and-tuning-realistic-6cb2be0f431
+ https://towardsdatascience.com/generative-adversarial-networks-explained-34472718707a
+ https://towardsdatascience.com/a-new-way-to-look-at-gans-7c6b6e6e9737 (use incognito)
+ https://arxiv.org/pdf/1701.04722.pdf