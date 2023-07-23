     PSF  = fspecial('gaussian',13,1);
     OTF  = psf2otf(PSF,[31 31]);         % PSF --> OTF