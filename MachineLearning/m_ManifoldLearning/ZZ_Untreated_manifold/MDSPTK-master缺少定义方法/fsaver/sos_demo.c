/**********************************************************************
* FileName:        sos_demo.c
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

const float sosdata[] = {
#include "sos.dat"
};

int main()
{
    const float* ret_data = NULL;
    fsaver_result fsr = no_error;

    printf("saveSOS() demo:\n");

    ret_data = sos_get_float(sosdata, 1, &fsr);

    if(ret_data == NULL)
    {
    	printf("PTR error");
    	return 1;
    }

    printf("Set 2:\n");
    printf("gain = %f\n",ret_data[0]);
    printf("SOS1 : %f, %f, %f, %f, %f, %f\n",
	ret_data[1],ret_data[2],ret_data[3],ret_data[4],ret_data[5],ret_data[6]);
    printf("SOS2 : %f, %f, %f, %f, %f, %f\n",
	ret_data[7],ret_data[8],ret_data[9],ret_data[10],ret_data[11],ret_data[12]);

    return 0;
}

