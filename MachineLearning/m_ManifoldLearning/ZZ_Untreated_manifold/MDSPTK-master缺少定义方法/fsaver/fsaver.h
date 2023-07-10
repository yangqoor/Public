/**********************************************************************
* FileName:        fsaver.h
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

#ifndef F_SAVER_H
#define F_SAVER_H

#ifndef NULL
#define NULL ((void *)0)
#endif

#define PLANE_DATA_HEADER_LENGTH (3)
#define FIR_HEADER_LENGTH        (3)
#define IIR_HEADER_LENGTH        (3)
#define SOS_HEADER_LENGTH        (3)

//Data types ID's
typedef enum {
        plane_data_id = 101,
        fir_id        = 102,
        iir_id        = 103,
        sos_id        = 104,
	} fsaver_data_type; 

//Errors handling
typedef enum {	
	no_error,                //Ok
	incorrect_data_provided, //Incorrect ID
	integrity_error,         //Data corrupted
	set_out_of_range         //Set not exist
	} fsaver_result;

/*
	Plane data, data file structure (matlab : fsaver.savePlaneData()): 101 (type ID), 
	number of sets, number of coefficients in set (header ends here), ...set1..., ...set2..., ...setN..., 
	integrity checking coefficient (number of sets * number of coefficients in set).  
*/
#define fsaver_plane_data_declare(DATA_TYPE) \
const DATA_TYPE *plane_data_get_##DATA_TYPE(const DATA_TYPE *input_data, unsigned int set_number, fsaver_result* fsr){ \
	unsigned int iterator = set_number*input_data[2] + PLANE_DATA_HEADER_LENGTH; \
	if(set_number > input_data[1] - 1) {*fsr = set_out_of_range; return NULL;} \
	return &input_data[iterator]; \
}

/*
	FIR, data file structure (matlab : fsaver.saveFIR()): 102 (FIR type ID), 
	number of sets, filter order = number of coefficients in set - 1 (header ends here), 
	...set1..., ...set2..., ...setN..., 
	integrity checking coefficient (number of sets * (order + 1)).
	Set structure: b0, b1, b2, ..., bN...
*/
#define fsaver_fir_declare(DATA_TYPE) \
const DATA_TYPE *fir_get_##DATA_TYPE(const DATA_TYPE *input_data, unsigned int set_number, fsaver_result* fsr){ \
	unsigned int iterator = set_number*(input_data[2] + 1) + FIR_HEADER_LENGTH; \
	if(set_number > input_data[1] - 1) {*fsr = set_out_of_range; return NULL;} \
	return &input_data[iterator]; \
}

/*
	IIR, data file structure (matlab : fsaver.saveIIR()): 103 (IIR type ID), 
	number of sets, filter order (header ends here), ...set1..., ...set2..., ...setN..., 
	integrity checking coefficient (number of sets * 2 * (order + 1)).
	Set structure : b0, b1, b2, ..., bN, a0, a1, a2, ..., aN. Where a0 always equals 1.
*/
#define fsaver_iir_declare(DATA_TYPE) \
const DATA_TYPE *iir_get_##DATA_TYPE(const DATA_TYPE *input_data, unsigned int set_number, fsaver_result* fsr){ \
	unsigned int iterator = 2*set_number*(input_data[2] + 1) + IIR_HEADER_LENGTH; \
	if(set_number > input_data[1] - 1) {*fsr = set_out_of_range; return NULL;} \
	return &input_data[iterator]; \
}

/* 
	SOS, data file structure (matlab : fsaver.saveSOS()) : 104 (SOS type ID),
	number of sets, number of coefs in set (header ends here), ...set1..., ...set2..., ...setN...,
	integrity checking coefficient (number of sets * number of coefs in set). 
	Set structure: gain coefficient, b01, b11, b21, a01, a11, a21, b02, b12, b22, a02, a12, a22, b03, b13, b23, a03 ...	
*/
#define fsaver_sos_declare(DATA_TYPE) \
const DATA_TYPE *sos_get_##DATA_TYPE(const DATA_TYPE *input_data, unsigned int set_number, fsaver_result* fsr){ \
    unsigned int iterator = set_number*input_data[2] + SOS_HEADER_LENGTH; \
    if(set_number > input_data[1] - 1) {*fsr = set_out_of_range; return NULL;} \
    return &input_data[iterator]; \
}

//Data checking functions

/*
	fsaver data type -> header length
*/
unsigned int get_header_length_from_data_id(fsaver_data_type dsr_type)
{
    switch(dsr_type)
    {
        case(plane_data_id):
            return PLANE_DATA_HEADER_LENGTH;
        case(fir_id):
            return FIR_HEADER_LENGTH;
        case(iir_id):
            return IIR_HEADER_LENGTH;
        case(sos_id):
            return SOS_HEADER_LENGTH;
        default:
            return 0xFFFFFFF; //error
    }
}

/*
	Checking function: checks data files and returns error indexes.
*/
#define fsaver_check_data_declare(DATA_TYPE) \
fsaver_result fsaver_check_data_##DATA_TYPE(const DATA_TYPE *input_data, fsaver_data_type fsr_type){ \
	if(input_data[0] != fsr_type) {return incorrect_data_provided;} \
    if(fsr_type == plane_data_id || fsr_type == fir_id) \
	/* Check PD and FIR */ \
	{if(input_data[1]*input_data[2] != input_data[(unsigned int)(input_data[1]*input_data[2]) + get_header_length_from_data_id(fsr_type)]) \
		{return integrity_error;}} \
    else if(fsr_type == iir_id) \
	/* Check IIR */ \
	{if(2*input_data[1]*(input_data[2] + 1) != input_data[(unsigned int)(2*input_data[1]*(input_data[2] + 1)) + IIR_HEADER_LENGTH]) \
		{return integrity_error;}} \
        /* Check SOS */ \
    else if(fsr_type == sos_id) \
	        {if(input_data[1]*input_data[2] != input_data[(unsigned int)(input_data[1]*input_data[2] + SOS_HEADER_LENGTH)]) \
		        {return integrity_error;}} \
    /* Check incorrect id */ \
    if(plane_data_id < fsr_type || fsr_type > sos_id) \
        return incorrect_data_provided; \
    return no_error; \
}

//Functions declarations for base data types
fsaver_plane_data_declare(int)
fsaver_plane_data_declare(float)

fsaver_fir_declare(int)
fsaver_fir_declare(float)

fsaver_iir_declare(int)
fsaver_iir_declare(float)

fsaver_sos_declare(int)
fsaver_sos_declare(float)

fsaver_check_data_declare(int)
fsaver_check_data_declare(float)

#endif //F_SAVER_H
