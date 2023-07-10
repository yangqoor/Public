/**********************************************************************
* FileName:        iir_demo.c
* FileVersion      x.xx
* 
* Architecture:    _
* IDE:             _
* Compiller:       _
*
* Design in:       SAL
* Design by:
* Feedback:
* 
* Licence:         MIT
*
* Project:         matlab TK
* ProjectVersion:  _
* Date:            _
**********************************************************************/
#include <stdlib.h>
#include <stdio.h>

#include "fsaver.h"

const float iirdata[] = {
#include "iir.dat"
};

int main()
{
    const float* ret_data = NULL;
    fsaver_result fsr = no_error;

    unsigned int i = 0;
    
    printf("saveIIR() demo:\n");
    
    for(i = 0; i < 2; i++)
    {
    	ret_data = iir_get_float(iirdata, i, &fsr);
		if(fsr)
			printf("Error with index : %d\n", (unsigned int)(fsr));
		else
        {
			printf("iirb coefs %d : %f, %f, %f, %f, %f\n", 
                    i, ret_data[0],ret_data[1],ret_data[2],ret_data[3],ret_data[4]);
            printf("iira coefs %d : %f, %f, %f, %f, %f\n", 
                    i, ret_data[5],ret_data[6],ret_data[7],ret_data[8],ret_data[9]);
        }
    }

    return 0;
}
