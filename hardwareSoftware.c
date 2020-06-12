#include <stdlib.h>
#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "fsl.h"
#include "xtmrctr_l.h"
#include "xil_printf.h"


// #define N	4000

// DMA configuration
int DMAConfig(u16 dmaDeviceId, XAxiDma* pDMAInstDefs)
{
	XAxiDma_Config* dmaConf;
	int status;

	dmaConf = XAxiDma_LookupConfig(dmaDeviceId);
	if (!dmaConf) {
		xil_printf("No DMA configuration found for %d.\r\n", dmaDeviceId);
		return XST_FAILURE;
	}

	status = XAxiDma_CfgInitialize(pDMAInstDefs, dmaConf);
	if (status != XST_SUCCESS) {
		xil_printf("DMA Initialization failed %d.\r\n", status);
		return XST_FAILURE;
	}

	if (XAxiDma_HasSg(pDMAInstDefs)) {
		xil_printf("Device configured as SG mode.\r\n");
		return XST_FAILURE;
	}

	// Disable interrupts
	XAxiDma_IntrDisable(pDMAInstDefs, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(pDMAInstDefs, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	return XST_SUCCESS;
}


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


	// Configuring DMA
	xil_printf("\r\nConfiguring DMA...");
	status = DMAConfig(DMA_DEVICE_ID, &dmaInstDefs);
	if (status != XST_SUCCESS)
	{
		xil_printf("\r\nConfiguration failed.");
		return XST_FAILURE;
	}
	xil_printf("\r\nDMA running...");



	RestartPerformanceTimer();
	status = XAxiDma_SimpleTransfer(&dmaInstDefs,(UINTPTR) dstData, N * sizeof(int), XAXIDMA_DEVICE_TO_DMA);
	status = XAxiDma_SimpleTransfer(&dmaInstDefs,(UINTPTR) srcData, N * sizeof(int), XAXIDMA_DMA_TO_DEVICE);
	
	if (status != XST_SUCCESS)
	{
		xil_printf("\r\nDMA transfer failed.");
		return XST_FAILURE;
	}
	while ((XAxiDma_Busy(&dmaInstDefs, XAXIDMA_DEVICE_TO_DMA)) || (XAxiDma_Busy(&dmaInstDefs, XAXIDMA_DMA_TO_DEVICE)))
	{
		/* Wait */
	}
	timeElapsed = StopAndGetPerformanceTimer();
	xil_printf("\n\rDMA Hardware assisted reverse endianess time: %d microseconds",
			   timeElapsed / (XPAR_CPU_M_AXI_DP_FREQ_HZ / 1000000));
	PrintDataArray(dstData, min(8, N));
	xil_printf("\n\rChecking result: %s\n\r", CheckReversedEndianess(srcData, dstData, N) ? "OK" : "Error");


    // Hardware assisted
    RestartPerformanceTimer();
    md5Hw(dstData, srcData, N);
    timeElapsed = StopAndGetPerformanceTimer();
    xil_printf("\n\rHardware assisted reverse endianess time: %d microseconds", timeElapsed / (XPAR_CPU_M_AXI_DP_FREQ_HZ / 1000000));
    PrintDataArray(dstData, min(8, N));
   

    cleanup_platform();
    return 0;
}
