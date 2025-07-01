# Photon Limited Non-Blind Deblurring Using Algorithm Unrolling
Pytorch code for [Photon Limited Non-Blind Deblurring Using Algorithm Unrolling](https://arxiv.org/abs/2110.15314) - published at Transactions on Computational Imaging

<img src="https://user-images.githubusercontent.com/20774419/177593608-9b5ccba2-ca3d-485a-9542-5f08df8e081a.png" width="800">

Pretrained model [here](https://drive.google.com/file/d/1SimYIMDOijOBV_MTepM9k6xAZQHWIafo/view?usp=sharing)


## Instructions
1. Create a local copy of repository using the following commands
      ```console
      foor@bar:~$ git clone https://github.com/sanghviyashiitb/poisson-deblurring.git
      foor@bar:~$ cd poisson-deblurring
      foor@bar:~/poisson-deblurring$ 
      
      ```
3. Download the pretrained model into ```model_zoo``` from the link [here](https://drive.google.com/file/d/1SimYIMDOijOBV_MTepM9k6xAZQHWIafo/view?usp=sharing)
4. To test the network using synthetic data, run the file
      ```console
      foo@bar:~/poisson-deblurring$ python3 demo_synthetic.py  
      ```
      
      ### Output:
      
    <img src="results/demo_synthetic.png" alt="demo_synthetic" width="400"/>

4. Download the zip file containing [real dataset](https://drive.google.com/file/d/1WUKuG-2Oddn8PmWac490mCNi5If4XqVg/view?usp=sharing) into the main directory and unzip using the following command:
      ```console
      foo@bar:~/poisson-deblurring$ unzip real_data.zip -d data/ 
      ```
      
5. To test the network using real data, run the file 
      ```console
      foo@bar:~/poisson-deblurring$ python3 demo_synthetic.py  --idx=11
      ```
      (Variable ```idx``` represents the file index and can be any integer from [0,29] )

      ![demo_real](results/demo_real.png)
      
      ##### Output: PSNR: 29.08, SSIM: 0.696

 ### Training
 Before running ```train.py```, add clean images (for example Flickr2K) in the ```data/training``` and ```data/val``` folders.
      
 ### Citation
 
 ```
@ARTICLE{9903556,
  author={Sanghvi, Yash and Gnanasambandam, Abhiram and Chan, Stanley H.},
  journal={IEEE Transactions on Computational Imaging}, 
  title={Photon Limited Non-Blind Deblurring Using Algorithm Unrolling}, 
  year={2022},
  volume={8},
  number={},
  pages={851-864},
  doi={10.1109/TCI.2022.3209939}}
 ```

Feel free to ask your questions/share your feedback at sanghviyash95@gmail.com
