#include<iostream>    
#include <opencv2/opencv.hpp>    
#include<opencv2/core/core.hpp>      
#include<opencv2/highgui/highgui.hpp>   

using namespace std;
using namespace cv;

class VideoProcessor {

private:
	//Opencv��Ƶ��׽����  
	VideoCapture capture;
	//ÿ֡���õĻص�����  
	void(*process)(Mat&, Mat&);
	//ȷ���Ƿ���ûص�������bool����  
	bool callIt;
	//���봰�ڵ�����  
	string windowNameInput;
	string windowNameOutput;
	//�ӳ�  
	int delay;
	//�Ѵ����֡��  
	long fnumber;
	//�ڸ�֡��ֹͣ  
	long frameToStop;
	//�Ƿ�ֹͣ����  
	bool stop;
public:
	VideoProcessor() :callIt(true), delay(0), fnumber(0), stop(false), frameToStop(-1) {};

	//���ûص�����  
	void setFrameProcessor(
		void(*frameProcessingCallback)(Mat&, Mat&)) {
		process = frameProcessingCallback;
	}

	//������Ƶ�ļ�������  
	bool setInput(string filename) {
		fnumber = 0;
		//�ͷ�֮ǰ�򿪹�����Դ  
		capture.release();
		//����Ƶ�ļ�  
		return capture.open(filename);
	}

	//�������봰��  
	void displayInput(string wn) {
		windowNameInput = wn;
		namedWindow(windowNameInput);
	}

	//�����������  
	void displayOutput(string wn) {
		windowNameOutput = wn;
		namedWindow(windowNameOutput);
	}

	//������ʾ������֡  
	void dontDisplay() {
		destroyWindow(windowNameInput);
		destroyWindow(windowNameOutput);
		windowNameInput.clear();
		windowNameOutput.clear();
	}

	//��ȡ����������֡  
	void run() {
		//��ǰ֡  
		Mat frame;
		//���֡  
		Mat output;

		//��ʧ��ʱ  
		if (!isOpened())return;
		stop = false;
		while (!isStopped())
		{
			//��ȡ��һ֡  
			if (!readNextFrame(frame))break;
			//��ʾ���֡  
			if (windowNameInput.length() != 0)
				imshow(windowNameInput, frame);
			//���ô�����  
			if (callIt) {
				//����ǰ֡  
				process(frame, output);
				//����֡��  
				fnumber++;
			}
			else
			{
				output = frame;
			}

			//��ʾ���֡  
			if (windowNameOutput.length() != 0)
				imshow(windowNameOutput, output);
			//�����ӳ�  
			if (delay >= 0 && waitKey(delay) >= 0)
				stopIt();
			//����Ƿ���Ҫֹͣ����  
			if (frameToStop >= 0 && getFrameNumber() == frameToStop)
				stopIt();
		}

	}

	//ֹͣ����  
	void stopIt() {
		stop = true;
	}

	//�Ƿ���ֹͣ  
	bool isStopped() {
		return stop;
	}

	//�Ƿ�ʼ�˲����豸  
	bool isOpened() {
		return capture.isOpened();
	}

	//����֡����ӳ� 0��ζ����ÿ֡���ȴ��û����� ������ζ��û���ӳ�  
	void setDelay(int d) {
		delay = d;
	}

	//�õ���һ֡ ��������Ƶ�ļ�������ͷ  
	bool readNextFrame(Mat &frame) {
		return capture.read(frame);
	}

	//��Ҫ���ûص�����  
	void callProcess() {
		callIt = true;
	}

	//����Ҫ���ûص�����  
	void dontCallProcess() {
		callIt = false;
	}

	void stopAtFrameNo(long frame) {
		frameToStop = frame;
	}

	//������һ֡��֡��  
	long getFrameNumber() {
		//�õ������豸����Ϣ  
		long fnumber = static_cast<long>(capture.get(CV_CAP_PROP_POS_FRAMES));
		return fnumber;
	}

	int getFrameRate() {
		return capture.get(CV_CAP_PROP_FPS);
	}
};

void canny(Mat &img, Mat &out) {

	////�Ҷ�ת��  
	if (img.channels() == 3)
	{
		cvtColor(img, out, CV_BGR2GRAY);
	}
	//����Canny��Ե  
	Canny(out, out, 100, 200);
	//��תͼ��  
	threshold(out, out, 128, 255, THRESH_BINARY_INV);
}

int main() {

	//����ʵ��  
	VideoProcessor processor;
	//����Ƶ�ļ�  
	processor.setInput("F:\\fs laser\\plasma_wave.avi");
	//������ʾ����  
	processor.displayInput("Current Frame");
	processor.displayOutput("Output Frame");
	//��ԭʼ֡�ʲ�����Ƶ  
	processor.setDelay(1000. / processor.getFrameRate());
	//���ô���ص�����  
	processor.setFrameProcessor(canny);
	//��ʼ�������  
	processor.run();

	waitKey();
	return 0;
}