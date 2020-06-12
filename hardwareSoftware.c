#include <stdlib.h>
#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "fsl.h"
#include "xtmrctr_l.h"
#include "xil_printf.h"


// #define N	4000


void md5Hw(int* pDst, int* pSrc, unsigned int size)
{
	int* p;

	for (p = pSrc; p < pSrc + size; p++, pDst++)
	{
		putfslx(*p, 0, FSL_DEFAULT);
		getfslx(*pDst, 0, FSL_DEFAULT);
	}
}


void PrintDataArray(int* pData, unsigned int size)
{
	int* p;

	xil_printf("\n\r");
	for (p = pData; p < pData + size; p++)
	{
		xil_printf("%08x  ", *p);
	}
}

void ResetPerformanceTimer()
{
	XTmrCtr_Disable(XPAR_TMRCTR_0_BASEADDR, 0);
	XTmrCtr_SetLoadReg(XPAR_TMRCTR_0_BASEADDR, 0, 0x00000001);
	XTmrCtr_LoadTimerCounterReg(XPAR_TMRCTR_0_BASEADDR, 0);
	XTmrCtr_SetControlStatusReg(XPAR_TMRCTR_0_BASEADDR, 0, 0x00000000);
}

void RestartPerformanceTimer()
{
	ResetPerformanceTimer();
	XTmrCtr_Enable(XPAR_TMRCTR_0_BASEADDR, 0);
}

unsigned int GetPerformanceTimer()
{
	return XTmrCtr_GetTimerCounterReg(XPAR_TMRCTR_0_BASEADDR, 0);
}

unsigned int StopAndGetPerformanceTimer()
{
	XTmrCtr_Disable(XPAR_TMRCTR_0_BASEADDR, 0);
	return GetPerformanceTimer();
}


int main()
{
	int srcData[N], dstData[N];
	unsigned int timeElapsed;

    init_platform();

    
    RestartPerformanceTimer();
    srand(0);
    for (int i = 0; i < N; i++)
    {
    	srcData[i] = rand();
    }
    timeElapsed = StopAndGetPerformanceTimer();
    xil_printf("\n\rArray initialization time: %d microseconds\n\r",
    		   timeElapsed / (XPAR_CPU_M_AXI_DP_FREQ_HZ / 1000000));
    PrintDataArray(srcData, min(8, N));
    xil_printf("\n\r");



    // Hardware assisted
    RestartPerformanceTimer();
    md5Hw(dstData, srcData, N);
    timeElapsed = StopAndGetPerformanceTimer();
    xil_printf("\n\rHardware assisted reverse endianess time: %d microseconds", timeElapsed / (XPAR_CPU_M_AXI_DP_FREQ_HZ / 1000000));
    PrintDataArray(dstData, min(8, N));
   

    cleanup_platform();
    return 0;
}
