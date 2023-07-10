
/**************************************************************************
 *  文件名：TemplateTrans.cpp
 *
 *  图像模板变换API函数库：
 *
 *  Template()			- 图像模板变换，通过改变模板，可以用它实现图像的平滑、锐化、边缘识别等操作。
*************************************************************************/

#include "stdafx.h"
#include "TemplateTrans.h"
#include "DIBAPI.h"

#include <math.h>
#include <direct.h>

/*************************************************************************
 *
 * 函数名称：
 *   Template()
 *
 * 参数:
 *   LPSTR lpDIBBits    - 指向源DIB图像指针
 *   LONG  lWidth       - 源图像宽度（象素数）
 *   LONG  lHeight      - 源图像高度（象素数）
 *   int   iTempH		- 模板的高度
 *   int   iTempW		- 模板的宽度
 *   int   iTempMX		- 模板的中心元素X坐标 ( < iTempW - 1)
 *   int   iTempMY		- 模板的中心元素Y坐标 ( < iTempH - 1)
 *	 FLOAT * fpArray	- 指向模板数组的指针
 *	 FLOAT fCoef		- 模板系数
 *
 * 返回值:
 *   BOOL               - 成功返回TRUE，否则返回FALSE。
 *
 * 说明:
 *   该函数用指定的模板（任意大小）来对图像进行操作，参数iTempH指定模板
 * 的高度，参数iTempW指定模板的宽度，参数iTempMX和iTempMY指定模板的中心
 * 元素坐标，参数fpArray指定模板元素，fCoef指定系数。
 *
 ************************************************************************/

BOOL WINAPI Template(LPSTR lpDIBBits, LONG lWidth, LONG lHeight, 
					 int iTempH, int iTempW, 
					 int iTempMX, int iTempMY,
					 FLOAT * fpArray, FLOAT fCoef)
{
	// 指向复制图像的指针
	LPSTR	lpNewDIBBits;
	HLOCAL	hNewDIBBits;
	
	// 指向源图像的指针
	unsigned char*	lpSrc;
	
	// 指向要复制区域的指针
	unsigned char*	lpDst;
	
	// 循环变量
	LONG	i;
	LONG	j;
	LONG	k;
	LONG	l;
	
	// 计算结果
	FLOAT	fResult;
	
	// 图像每行的字节数
	LONG lLineBytes;
	
	// 计算图像每行的字节数
	lLineBytes = WIDTHBYTES(lWidth * 8);
	
	// 暂时分配内存，以保存新图像
	hNewDIBBits = LocalAlloc(LHND, lLineBytes * lHeight);
	
	// 判断是否内存分配失败
	if (hNewDIBBits == NULL)
	{
		// 分配内存失败
		return FALSE;
	}
	
	// 锁定内存
	lpNewDIBBits = (char * )LocalLock(hNewDIBBits);
	
	// 初始化图像为原始图像
	memcpy(lpNewDIBBits, lpDIBBits, lLineBytes * lHeight);
	
	// 行(除去边缘几行)
	for(i = iTempMY; i < lHeight - iTempH + iTempMY + 1; i++)
	{
		// 列(除去边缘几列)
		for(j = iTempMX; j < lWidth - iTempW + iTempMX + 1; j++)
		{
			// 指向新DIB第i行，第j个象素的指针
			lpDst = (unsigned char*)lpNewDIBBits + lLineBytes * (lHeight - 1 - i) + j;
			
			fResult = 0;
			
			// 计算
			for (k = 0; k < iTempH; k++)
			{
				for (l = 0; l < iTempW; l++)
				{
					// 指向DIB第i - iTempMY + k行，第j - iTempMX + l个象素的指针
					lpSrc = (unsigned char*)lpDIBBits + lLineBytes * (lHeight - 1 - i + iTempMY - k)
						+ j - iTempMX + l;
					
					// 保存象素值
					fResult += (* lpSrc) * fpArray[k * iTempW + l];
				}
			}
			
			// 乘上系数
			fResult *= fCoef;
			
			// 取绝对值
			fResult = (FLOAT ) fabs(fResult);
			
			// 判断是否超过255
			if(fResult > 255)
			{
				// 直接赋值为255
				* lpDst = 255;
			}
			else
			{
				// 赋值
				* lpDst = (unsigned char) (fResult + 0.5);
			}
			
		}
	}
	
	// 复制变换后的图像
	memcpy(lpDIBBits, lpNewDIBBits, lLineBytes * lHeight);
	
	// 释放内存
	LocalUnlock(hNewDIBBits);
	LocalFree(hNewDIBBits);
	
	// 返回
	return TRUE;

}
