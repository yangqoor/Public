#include "CCalculation.h"

using namespace cv;
using namespace std;

int main()
{
	bool status = true;

	CCalculation myCalculation;

	if (status)
	{
		status = myCalculation.Init();
	}
	if (status)
	{
		status = myCalculation.FillDepthGroundTruth();
		status = myCalculation.FillJproGroundTruth();
		return 0;
	}
	if (status)
	{
		status = myCalculation.CalculateFirst();
	}
	if (status)
	{
		status = myCalculation.CalculateOther();
	}
	
	return 0;
}