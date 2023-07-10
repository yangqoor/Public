#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
using namespace cv;
using namespace std;

ostringstream oss[36];
int main(int argc,char **argv)
{
	for(int k=0;k<35;k=k+2)
	{
		IplImage *img1=0;
	    IplImage *img2=0;
		float Pre_15Day_V=0;
    	float Pro_15Day_V=0.0;
		float P_V=0.0;


	    int count=0;
	    unsigned char* phtr=new unsigned char [3*(5616)*(3744)];
    	unsigned char* qhtr=new unsigned char [3*(5616)*(3744)];
   // 	unsigned char* phtr1=new unsigned char [3*(5616)*(3744)];
  // 	unsigned char* qhtr1=new unsigned char [3*(5616)*(3744)];
	    string str,str1,str2,s1,s2;
	
		str=".\\17\\PB";
		oss[k]<<k+157607;
		oss[k+1]<<k+1+157607;
		s1=oss[k].str(); 
		s2=oss[k+1].str();
		str1=str+s1;
		str2=str+s2;
		str1=str1+".JPG";
        str2=str2+".JPG";
		img1=cvLoadImage(str1.c_str(),-1);
		img2=cvLoadImage(str2.c_str(),-1);

		IplImage *imghsv1=cvCreateImage(cvGetSize(img1),8,3);           //全开
		IplImage *imghsv2=cvCreateImage(cvGetSize(img2),8,3);           //单开
		cvCvtColor(img1,imghsv1,CV_RGB2HSV);
		cvCvtColor(img2,imghsv2,CV_RGB2HSV);

		for(int y=0;y<img1->height;y++)
		{		  	
			for(int x=0;x<img1->width;x++)
			{
				int Index =y * (img1->width) + x;

				phtr[3*Index+1]=((uchar*)(imghsv1->imageData+y*imghsv1->widthStep))[x*imghsv1->nChannels+1];     //全开	亮度
				qhtr[3*Index+2]=((uchar*)(imghsv2->imageData+y*imghsv2->widthStep))[x*imghsv2->nChannels+2];     //单开 
            	qhtr[3*Index+1]=((uchar*)(imghsv2->imageData+y*imghsv2->widthStep))[x*imghsv2->nChannels+1];     //单开 饱和度

				Pre_15Day_V=Pre_15Day_V + phtr[3*Index+1];           //全开亮度
				Pro_15Day_V=Pro_15Day_V + qhtr[3*Index+1];          //单开饱和度
				P_V=P_V+qhtr[3*Index+2];			

			}	
		}
 		count=img1->width*img1->height;
 		cout<<(k/2)*15<<"  ";
        cout<<Pro_15Day_V/count<<" , ";                  //单开

		cout<<Pre_15Day_V/count<<" , ";                //全开
	
		cout<<((Pre_15Day_V/count)-(Pro_15Day_V/count))<<endl<<endl;
		delete phtr;
		delete qhtr;
		cvReleaseImage(&img1);
		cvReleaseImage(&img2);
		cvReleaseImage(&imghsv1);
		cvReleaseImage(&imghsv2);		
	}
	system("pause");
	return 0;
}