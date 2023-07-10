/*************************************************************************
 *
 * 函数名称：
 *   SobelDIB()
 *
 * 参数:
 *   LPSTR lpDIBBits    - 指向源DIB图像指针
 *   LONG  lWidth       - 源图像宽度（象素数，必须是4的倍数）
 *   LONG  lHeight      - 源图像高度（象素数）
 * 返回值:
 *   BOOL               - 边缘检测成功返回TRUE，否则返回FALSE。
 *
 * 说明:
 * 该函数用Sobel边缘检测算子对图像进行边缘检测运算。
 * 
 * 要求目标图像为灰度图像。
 ************************************************************************/

BOOL WINAPI SobelDIB(LPSTR lpDIBBits, LONG lWidth, LONG lHeight)
{
	
	// 指向缓存图像的指针
	LPSTR	lpDst1;
	LPSTR	lpDst2;
	
	// 指向缓存DIB图像的指针
	LPSTR	lpNewDIBBits1;
	HLOCAL	hNewDIBBits1;
	LPSTR	lpNewDIBBits2;
	HLOCAL	hNewDIBBits2;

	//循环变量
	long i;
	long j;

	// 模板高度
	int		iTempH;
	
	// 模板宽度
	int		iTempW;
	
	// 模板系数
	FLOAT	fTempC;
	
	// 模板中心元素X坐标
	int		iTempMX;
	
	// 模板中心元素Y坐标
	int		iTempMY;
	
	//模板数组
	FLOAT aTemplate[9];

	// 暂时分配内存，以保存新图像
	hNewDIBBits1 = LocalAlloc(LHND, lWidth * lHeight);

	if (hNewDIBBits1 == NULL)
	{
		// 分配内存失败
		return FALSE;
	}
	
	// 锁定内存
	lpNewDIBBits1 = (char * )LocalLock(hNewDIBBits1);

	// 暂时分配内存，以保存新图像
	hNewDIBBits2 = LocalAlloc(LHND, lWidth * lHeight);

	if (hNewDIBBits2 == NULL)
	{
		// 分配内存失败
		return FALSE;
	}
	
	// 锁定内存
	lpNewDIBBits2 = (char * )LocalLock(hNewDIBBits2);

	// 拷贝源图像到缓存图像中
	lpDst1 = (char *)lpNewDIBBits1;
	memcpy(lpNewDIBBits1, lpDIBBits, lWidth * lHeight);
	lpDst2 = (char *)lpNewDIBBits2;
	memcpy(lpNewDIBBits2, lpDIBBits, lWidth * lHeight);

	// 设置Sobel模板参数
	iTempW = 3;
	iTempH = 3;
	fTempC = 1.0;
	iTempMX = 1;
	iTempMY = 1;
	aTemplate[0] = -1.0;
	aTemplate[1] = -2.0;
	aTemplate[2] = -1.0;
	aTemplate[3] = 0.0;
	aTemplate[4] = 0.0;
	aTemplate[5] = 0.0;
	aTemplate[6] = 1.0;
	aTemplate[7] = 2.0;
	aTemplate[8] = 1.0;

	// 调用Template()函数
	if (!Template(lpNewDIBBits1, lWidth, lHeight, 
		iTempH, iTempW, iTempMX, iTempMY, aTemplate, fTempC))
	{
		return FALSE;
	}

	// 设置Sobel模板参数
	aTemplate[0] = -1.0;
	aTemplate[1] = 0.0;
	aTemplate[2] = 1.0;
	aTemplate[3] = -2.0;
	aTemplate[4] = 0.0;
	aTemplate[5] = 2.0;
	aTemplate[6] = -1.0;
	aTemplate[7] = 0.0;
	aTemplate[8] = 1.0;

	// 调用Template()函数
	if (!Template(lpNewDIBBits2, lWidth, lHeight, 
		iTempH, iTempW, iTempMX, iTempMY, aTemplate, fTempC))
	{
		return FALSE;
	}

	//求两幅缓存图像的最大值
	for(j = 0; j <lHeight; j++)
	{
		for(i = 0;i <lWidth-1; i++)
		{

			// 指向缓存图像1倒数第j行，第i个象素的指针			
			lpDst1 = (char *)lpNewDIBBits1 + lWidth * j + i;

			// 指向缓存图像2倒数第j行，第i个象素的指针			
			lpDst2 = (char *)lpNewDIBBits2 + lWidth * j + i;
			
			if(*lpDst2 > *lpDst1)
				*lpDst1 = *lpDst2;
		
		}
	}

	// 复制经过模板运算后的图像到源图像
	memcpy(lpDIBBits, lpNewDIBBits1, lWidth * lHeight);

	// 释放内存
	LocalUnlock(hNewDIBBits1);
	LocalFree(hNewDIBBits1);

	LocalUnlock(hNewDIBBits2);
	LocalFree(hNewDIBBits2);
	// 返回
	return TRUE;
}
