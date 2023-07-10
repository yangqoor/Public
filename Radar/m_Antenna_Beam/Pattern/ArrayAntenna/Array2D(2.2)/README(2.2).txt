README file for array codes (version 2.2, Sept. 2005, has Bayliss dist'n fixed):

The program array2d.m computes the array factor of two dimensional
arrays.  

GUI version for PCs (Matlab 6.5); nonGui version for any Matlab platform.

To execute from the command window, pwd to the folder where
array2d.m resides and type array2d.  Most data is entered interactively.
However, some of the sidelobe distribution parameters are "hardwired"
in the code.  Users can change them to suit their needs. 

The theory and operation of the program is described briefly
in the Microsoft Word document arraycodes.doc.  array2d.m requires 
the following functions:

sidelobe amplitude distributions:
taylor.m (tayl.m on later versions to avoid problems with Matlab's 
internal taylor function)
bayliss.m
cosine.m

phase shifter roundoff algorithms:
truncate.m
rro.m
rroff.m

plotting functions:
plotpatdata.m
polardb.m

plotpatdata.m can be run separately.  It reads file arraydat.m which is 
written by array2d (version > 2.1).  It contains the complex field values,
not just the dB values, from which the user can perform more complex
calculations

SEE THE ARRAY2D.PDF FILE FOR MORE DETAILS

Disclaimer:  The codes have been verified for basic test cases but
there is no guarantee of accuracy in all cases.

(25 June 2002)
