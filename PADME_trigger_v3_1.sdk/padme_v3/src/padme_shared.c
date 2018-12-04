/*
 * padme_shared.c
 *
 *  Created on: Apr 23, 2018
 *      Author: alp
 */

#include <stdio.h>
#include <string.h>
#include <xil_io.h>
#include <sleep.h>

//#include "xparameters.h"

// PADME LIB
#include "padme_shared.h"


// IIC Device Instance
XIicPs Iic0;
XIicPs Iic1;
// XADC Instance
XAdcPs XAdcInst;

XAdcPs XAdcInst;

#include "netif/xadapter.h"

#include "platform.h"
#include "platform_config.h"
#if defined (__arm__) || defined(__aarch64__)
#include "xil_printf.h"
#endif

int PCA9548A_Ch_Select(u8 DeviceAddress, u8 *SendBuffer, u8 *RecvBuffer, int verbose) {

	int Status;

	if (verbose==1)
		xil_printf("Setting PCA9548A Control Register to %02X...", SendBuffer[0]);
	Status = XIicPs_MasterSendPolled(&Iic1, SendBuffer,
				 1, DeviceAddress);
	while (XIicPs_BusIsBusy(&Iic0)) {
		/* NOP */
	}
	if (Status != XST_SUCCESS) {
		xil_printf("Cannot set IIC Mux0\n\r");
		return XST_FAILURE;
			}
	if (verbose==1) {
		xil_printf("Reading back CR: ");
		usleep(200000);
		xil_printf("\tReading temperature\n\r");
		Status = XIicPs_MasterRecvPolled(&Iic1, RecvBuffer,
				  1, DeviceAddress);
		if (Status != XST_SUCCESS) {
			xil_printf("Cannot read back IIC Mux0\n\r");
			return XST_FAILURE;
		}
		xil_printf("%02X\n\r", RecvBuffer[0]);
	}


	return XST_SUCCESS;

}

int STS21_read(XIicPs *InstancePtr, u8 *SendBuffer, u8 *RecvBuffer, int verbose) {

	int Status;

	// CPU Board Temperature Device
	if (verbose==1)
		xil_printf("\tSend read temperature command\n\r");
	SendBuffer[0]=0xF3;
	Status = XIicPs_MasterSendPolled(InstancePtr, SendBuffer,
			 1, IIC_STS21);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(&Iic0)) {
		/* NOP */
	}

	usleep(200000);
	if (verbose==1)
		xil_printf("\tReading temperature\n\r");
	Status = XIicPs_MasterRecvPolled(InstancePtr, RecvBuffer,
			  2, IIC_STS21);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	if (verbose==1)
		xil_printf("\tDone\n\r");

	//Output data to screen
	if (verbose==1) {
		// Convert the data
		u32 temperature = ( ((u32) RecvBuffer[0]) * 256) + ((u32) RecvBuffer[1] );
		//float Temp_c = -46.85 + (175.72 * temperature) / 65536.0;
		//int intp, fractp;
		//intp=Temp_c;
		//fractp=(Temp_c-intp)*1000;
		//xil_printf("\tTemperature in Celsius is : %.2f C\n", Temp_c);
		//xil_printf("\tTemperature in Celsius is : %02d.%d C\n\r", intp, fractp);
		float Temp_c= STS21_RawToTemperature(temperature);
		xil_printf("\tTemperature in Celsius is : %02d.%d C\n\r", (int) Temp_c, FractToInt(Temp_c));
		xil_printf("\tSent Temperature value: %08X.\n\n\r", temperature);
	}

	return 0;
}

int FractToInt(float FloatNum)
{
	float Temp;

	Temp = FloatNum;
	if (FloatNum < 0) {
		Temp = -(FloatNum);
	}

	return( ((int)((Temp -(float)((int)Temp)) * (1000.0f))));
}

int XADC_read (u32 *read_buf, int verbose) {

	u32 TempRawData;
	u32 VccPintRawData;
	u32 VccPauxRawData;
	u32 VccPdroRawData;
	float TempData;
	float VccPintData;
	float VccPauxData;
	float MaxData;
	float MinData;

	// XADC Instance
	XAdcPs *XAdcInstPtr = &XAdcInst;

	TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
	TempData = XAdcPs_RawToTemperature(TempRawData);
	read_buf[0]=TempRawData;
	if (verbose==1)
	xil_printf("\r\nThe Current Temperature is %0d.%03d Centigrades.\r\n",
				(int)(TempData), FractToInt(TempData));


	TempRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr, XADCPS_MAX_TEMP);
	MaxData = XAdcPs_RawToTemperature(TempRawData);
	read_buf[1]=TempRawData;
		if (verbose==1)
	xil_printf("The Maximum Temperature is %0d.%03d Centigrades. \r\n",
				(int)(MaxData), FractToInt(MaxData));

	TempRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr, XADCPS_MIN_TEMP);
	MinData = XAdcPs_RawToTemperature(TempRawData & 0xFFF0);
	read_buf[2]=TempRawData;
	if (verbose==1)
		xil_printf("The Minimum Temperature is %0d.%03d Centigrades. \r\n",
				(int)(MinData), FractToInt(MinData));

	/*
	 * Read the VccPint Votage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccPintRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_VCCPINT);
	VccPintData = XAdcPs_RawToVoltage(VccPintRawData);
	read_buf[3]=VccPintRawData;
	if (verbose==1)
		xil_printf("\r\nThe Current VCCPINT is %0d.%03d Volts. \r\n",
				(int)(VccPintData), FractToInt(VccPintData));

	VccPintRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr,
							XADCPS_MAX_VCCPINT);
	MaxData = XAdcPs_RawToVoltage(VccPintRawData);
	read_buf[4]=VccPintRawData;
	if (verbose==1)
		xil_printf("The Maximum VCCPINT is %0d.%03d Volts. \r\n",
			(int)(MaxData), FractToInt(MaxData));

	VccPintRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr,
							XADCPS_MIN_VCCPINT);
	MinData = XAdcPs_RawToVoltage(VccPintRawData);
	read_buf[5]=VccPintRawData;
	if (verbose==1)
		xil_printf("The Minimum VCCPINT is %0d.%03d Volts. \r\n",
			(int)(MinData), FractToInt(MinData));

	/*
	 * Read the VccPaux Voltage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccPauxRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_VCCPAUX);
	VccPauxData = XAdcPs_RawToVoltage(VccPauxRawData);
	read_buf[6]=VccPauxRawData;
	if (verbose==1)
		xil_printf("\r\nThe Current VCCPAUX is %0d.%03d Volts. \r\n",
			(int)(VccPauxData), FractToInt(VccPauxData));

	VccPauxRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr,
								XADCPS_MAX_VCCPAUX);
	MaxData = XAdcPs_RawToVoltage(VccPauxRawData);
	read_buf[7]=VccPauxRawData;
	if (verbose==1)
		xil_printf("The Maximum VCCPAUX is %0d.%03d Volts. \r\n",
				(int)(MaxData), FractToInt(MaxData));


	VccPauxRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr,
								XADCPS_MIN_VCCPAUX);
	MinData = XAdcPs_RawToVoltage(VccPauxRawData);
	read_buf[8]=VccPauxRawData;
	if (verbose==1)
		xil_printf("The Minimum VCCPAUX is %0d.%03d Volts. \r\n\r\n",
				(int)(MinData), FractToInt(MinData));


	/*
	 * Read the VccPdro Voltage Data (Current/Maximum/Minimum) from the
	 * ADC data registers.
	 */
	VccPdroRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_VCCPDRO);
	VccPintData = XAdcPs_RawToVoltage(VccPdroRawData);
	read_buf[9]=VccPdroRawData;
	if (verbose==1)
		xil_printf("\r\nThe Current VCCPDDRO is %0d.%03d Volts. \r\n",
			(int)(VccPintData), FractToInt(VccPintData));

	VccPdroRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr,
							XADCPS_MAX_VCCPDRO);
	MaxData = XAdcPs_RawToVoltage(VccPdroRawData);
	read_buf[10]=VccPdroRawData;
	if (verbose==1)
		xil_printf("The Maximum VCCPDDRO is %0d.%03d Volts. \r\n",
			(int)(MaxData), FractToInt(MaxData));

	VccPdroRawData = XAdcPs_GetMinMaxMeasurement(XAdcInstPtr,
							XADCPS_MIN_VCCPDRO);
	MinData = XAdcPs_RawToVoltage(VccPdroRawData);
	read_buf[11]=VccPdroRawData;
	if (verbose==1)
		xil_printf("The Minimum VCCPDDRO is %0d.%03d Volts. \r\n",
			(int)(MinData), FractToInt(MinData));


	return 0;
}
