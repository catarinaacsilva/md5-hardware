/******************************************************************************
 *
 * Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "platform.h"
#include "xparameters.h"
#include "fsl.h"
#include "xtmrctr_l.h"
#include "xil_printf.h"

// Define the output of the MD5 algorithm (4 words of 32 bits - a single hash of 128)
struct word128 {
  uint32_t A;
  uint32_t B;
  uint32_t C;
  uint32_t D;
};

#define N	4

#define LEFTROTATE(x, c) (((x) << (c)) | ((x) >> (32 - (c))))

// computes the MD5 hash from the input
struct word128 md5(unsigned char* initial_msg, unsigned long initial_len)
{
  uint32_t h0, h1, h2, h3;

  // Message (to prepare)
  uint8_t *msg = NULL;

  // Note: All variables are unsigned 32 bit and wrap modulo 2^32 when calculating

  // r specifies the per-round shift amounts

  uint32_t r[] = {7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

  // Use binary integer part of the sines of integers (in radians) as constants// Initialize variables:
  uint32_t k[] = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};

  h0 = 0x67452301;
  h1 = 0xefcdab89;
  h2 = 0x98badcfe;
  h3 = 0x10325476;

  // Pre-processing: adding a single 1 bit
  //append "1" bit to message
  /* Notice: the input bytes are considered as bits strings,
     where the first bit is the most significant bit of the byte.[37] */

  // Pre-processing: padding with zeros
  //append "0" bit until message length in bit = 448 (mod 512)
  //append length mod (2 pow 64) to message

  uint32_t new_len = ((((initial_len + 8) / 64) + 1) * 64) - 8;

  msg = calloc(new_len + 64, 1); // also appends "0" bits
  // (we alloc also 64 extra bytes...)
  memcpy(msg, initial_msg, initial_len);
  msg[initial_len] = 128; // write the "1" bit

  uint32_t bits_len = 8*initial_len; // note, we append the len
  memcpy(msg + new_len, &bits_len, 4);           // in bits at the end of the buffer

  // Process the message in successive 512-bit chunks:
  //for each 512-bit chunk of message:
  for(uint32_t offset = 0; offset < new_len; offset += (512/8)) {

    // break chunk into sixteen 32-bit words w[j], 0 <= j <= 15
    uint32_t *w = (uint32_t *) (msg + offset);

    // Initialize hash value for this chunk:
    uint32_t a = h0;
    uint32_t b = h1;
    uint32_t c = h2;
    uint32_t d = h3;

    // Main loop:
    for(uint32_t i = 0; i < 64; i++) {

      uint32_t f, g;

      if (i < 16) {
        f = (b & c) | ((~b) & d);
        g = i;
      } else if (i < 32) {
        f = (d & b) | ((~d) & c);
        g = (5*i + 1) % 16;
      } else if (i < 48) {
        f = b ^ c ^ d;
        g = (3*i + 5) % 16;
      } else {
        f = c ^ (b | (~d));
        g = (7*i) % 16;
      }

      uint32_t temp = d;
      d = c;
      c = b;
      b = b + LEFTROTATE((a + f + k[i] + w[g]), r[i]);
      a = temp;

    }

    // Add this chunks hash to result so far:
    h0 += a;
    h1 += b;
    h2 += c;
    h3 += d;
  }

  struct word128 w = {h0, h1, h2, h3};

  // cleanup
  free(msg);

  return w;
}

// Send the words to the md5 function and combines the result
void Md5Sw(struct word128 pDst, uint32_t* pSrc, unsigned int size)
{
  uint32_t* p;

  for (p = pSrc; p < pSrc + size; p++)
  {
    struct word128 w = md5((unsigned char*)p, sizeof(*p));

    uint8_t *p0, *p1, *p2, *p3;

    p0=(uint8_t *)&w.A;
    p1=(uint8_t *)&w.B;
    p2=(uint8_t *)&w.C;
    p3=(uint8_t *)&w.D;

    pDst.A = ((p0[0] << 24) | (p0[1] << 16) | (p0[2] << 8) | p0[3]);
    pDst.B = ((p1[0] << 24) | (p1[1] << 16) | (p1[2] << 8) | p1[3]);
    pDst.C = ((p2[0] << 24) | (p2[1] << 16) | (p2[2] << 8) | p2[3]);
    pDst.D = ((p3[0] << 24) | (p3[1] << 16) | (p3[2] << 8) | p3[3]);
  }
}

// Print the array
void PrintDataArray(uint32_t* pData, uint32_t size)
{
  uint32_t* p;

  xil_printf("\n\r[");
  for (p = pData; p < pData + size; p++)
  {
    xil_printf("%08x  ", *p);
  }
  xil_printf("]");
}

// Print the hash
void PrintDataArray128(struct word128 pData, unsigned int size)
{
  xil_printf("\n\r");
  xil_printf("%08x%08x%08x%08x  ", pData.A, pData.B, pData.C, pData.D);
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

uint32_t GetPerformanceTimer()
{
  return XTmrCtr_GetTimerCounterReg(XPAR_TMRCTR_0_BASEADDR, 0);
}

uint32_t StopAndGetPerformanceTimer()
{
  XTmrCtr_Disable(XPAR_TMRCTR_0_BASEADDR, 0);
  return GetPerformanceTimer();
}

int main()
{
  uint32_t srcData[N];
  struct word128 dstData;
  uint32_t timeElapsed;

  init_platform();
  xil_printf("\n\rSoftware Only MD5 Demonstration\n\r");

  RestartPerformanceTimer();
  srand(0);
  for (int i = 0; i < N; i++)
  {
    srcData[i] = rand() + rand();
  }
  timeElapsed = StopAndGetPerformanceTimer();
  xil_printf("\n\rArray initialization time: %d microseconds\n\r", timeElapsed / (XPAR_CPU_M_AXI_DP_FREQ_HZ / 1000000));
  PrintDataArray(srcData, N);
  xil_printf("\n\r");

  // Software only
  RestartPerformanceTimer();
  Md5Sw(dstData, srcData, N);
  timeElapsed = StopAndGetPerformanceTimer();
  xil_printf("\n\rSoftware only MD5 time: %d microseconds", timeElapsed / (XPAR_CPU_M_AXI_DP_FREQ_HZ / 1000000));
  PrintDataArray128(dstData, N);
  xil_printf("\n\r");

  cleanup_platform();

  return 0;
}
