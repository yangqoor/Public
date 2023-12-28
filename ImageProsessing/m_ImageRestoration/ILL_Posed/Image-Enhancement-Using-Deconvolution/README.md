# Image-Enhancement-Using-Deconvolution
Implemented 3 different methods of Deconvolution for the enhancement of a degraded image namely </br>
1. 'Inverse Filtering'(to start with) </br> 
2. 'Wiener Filtering'  </br>
3. 'Richardson Lucy Algorithm'. </br>
Tested the system on medical as well as non-medical images. </br>

INVERSE FILTERING </br>
inverse.m does inverse filtering. </br>
</br>
WIENER FILTERING </br>
wienergray.m , wienerrgb.m do wiener filtering on gray scale and rgb images respectively. </br>
wiener_pois.m , wiener_spec.m try removing poisson noise and speckle noise respectively. </br>
addgngray.m , addgncolor.m try removing gaussian noise in gray scale and color images respectively. </br>
wiegraymed2.m does wiener filtering on gray scale medical images. </br>
</br>
RL ALGORITHM </br>
RLpois.m , RLgauss.m try removing poisson noise and gaussian noise respectively using richardson lucy algorithm. 


