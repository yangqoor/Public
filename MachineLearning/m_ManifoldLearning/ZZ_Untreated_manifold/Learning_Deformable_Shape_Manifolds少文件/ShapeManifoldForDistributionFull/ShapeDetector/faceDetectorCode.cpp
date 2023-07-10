// VJDetector.cpp : Defines the entry point for the console application.
//

#include <iostream>
#include "cv.h"
#include <highgui.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <time.h>
#include <ctype.h>
#include <fstream>


using namespace std;
//using namespace cv;

static CvMemStorage* storage = 0;
static CvHaarClassifierCascade* cascade = 0;
int use_nested_cascade = 0;
const char* cascade_name = "/usr/local/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml";
const char* nested_cascade_name = NULL;
double scale = 1;
bool showIt = false;


void detect_and_draw( IplImage* image , char* safeFile);


int main( int argc, char** argv )
{
	
    IplImage *image = 0;
	//char* textFile = "/Users/stunna/Desktop/helloWorldXCODE/temp.txt";
	
	
	storage = cvCreateMemStorage(0);
	cascade = (CvHaarClassifierCascade*)cvLoad( cascade_name, 0, 0, 0 );
	
	if( showIt ){
		cvNamedWindow( "result", CV_WINDOW_AUTOSIZE );
	}
	
	//check input arguments, make sure right amount
	if(argc<3){
		printf("Usage: detectFace <inputImage> <outputTextFile>\n\7");
		image = cvLoadImage("/Users/stunna/Desktop/helloWorldXCODE/build/Debug/3.bmp");
		//exit(0);
	}
	else {
		// load an image 
		image = cvLoadImage(argv[1]);
	}
	
	
	if(!image){
		printf("Could not load image file: %s\n",argv[1]);
		exit(0);
	}
	
	
	detect_and_draw( image, argv[2] );
	
	if( showIt ){
		printf( "saving result in %s\n", argv[2]);
		cv::imshow("result", image);
		cv::waitKey(1500);
	}
	
	return 0;
	
}

void detect_and_draw( IplImage* img, char* saveFile )
{
	
    IplImage *gray, *small_img;
    int i;
	
    gray = cvCreateImage( cvSize(img->width,img->height), 8, 1 );
    small_img = cvCreateImage( cvSize( cvRound (img->width/scale),
									  cvRound (img->height/scale)), 8, 1 );
	
    cvCvtColor( img, gray, CV_BGR2GRAY );
    cvResize( gray, small_img, CV_INTER_LINEAR );
    cvEqualizeHist( small_img, small_img );
    cvClearMemStorage( storage );
	
	
	
    if( cascade )
    {
		
		ofstream outFile;
		outFile.open( saveFile, ios::out ); //saveFile
		
		
        double t = (double)cvGetTickCount();
		
        CvSeq* faces = cvHaarDetectObjects( small_img, cascade, storage,
										   1.1, 3, 
										   CV_HAAR_DO_CANNY_PRUNING, cvSize(50, 50)); 
		//const CvArr* image,
		//CvHaarClassifierCascade* cascade,
		//CvMemStorage* storage, double scale_factor CV_DEFAULT(1.1),
		//int min_neighbors CV_DEFAULT(3), int flags CV_DEFAULT(0),
		//CvSize min_size CV_DEFAULT(cvSize(0,0)));
		
		
		t = (double)cvGetTickCount() - t;
		
		//printf( "detection time = %gms\n", t/((double)cvGetTickFrequency()*1000.) );
        for( i = 0; i < (faces ? faces->total : 0); i++ )
        {
            CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
			
			//CvPoint x( r->x, r->y);
			//CvPoint y( r->x+r->height, r->y + r->height);
			//cvRectangle( small_img, x, y, 1, 1, 0 , 0)
			//, CvScalar color, int thickness=1, int lineType=8, int shift=0 );
			
			cvRectangle( img,  cvPoint(r->x, r->y), 
						cvPoint( r->x + r->width, r->y + r->height ), 
						cvScalar( 0, 0, 255, 0 ), 1, 0, 0 );
			
			//output
			//cout << r->y << "\t" << r->x << "\t" << r->height <<"\t" << r->width << endl;
			outFile << r->y << "\t" << r->x << "\t" << r->height << "\t" << r->width << endl; 
			
			//<<(t/((double)cvGetTickFrequency()*1000.))/1000 
        }
		
		outFile.close();
		
    }
	
    // if you want to display the image...
    //cvShowImage( "result", img );
	//cvWaitKey(0);  //this is the one that pops up when detected
    //cvReleaseImage( &gray );
    //cvReleaseImage( &small_img );
	
}


