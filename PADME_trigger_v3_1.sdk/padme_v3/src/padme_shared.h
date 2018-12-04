#ifndef PADME_SHARED_H
#define PADME_SHARED_H

// IIC LIB
#include "xiicps.h"
// XADC Lib
#include "xadcps.h"



// IIC DEVICES
#define IIC0_DEVICE_ID		XPAR_XIICPS_0_DEVICE_ID
#define IIC1_DEVICE_ID		XPAR_XIICPS_1_DEVICE_ID
#define IIC_SCLK_RATE		100000
// IIC Device Instance
extern XIicPs Iic0;
extern XIicPs Iic1;

// IIC MAX BUF SIZE
#define IIC_BUFFER_SIZE	132
// IIC0 Slaves
#define IIC_STS21			0x4A
// IIC1 Slaves
#define IIC_PCA9548A_MUX0	0x70
#define IIC_PCA9548A_MUX1	0x71

/*
Converts STS21 raw data to temperature [centigrades]
Synopsys: float STS21_RawToTemperature(u32 AdcData);
*/
#define STS21_RawToTemperature(AdcData)		\
  ((((float)(AdcData))*175.72f/65536.0f)-46.85f)

/*
Get Least Significant Nibble of a Byte
Synopsys: u8 B2LSN(u8 Data);
*/
#define B2LSN(Data)							\
	(((u8)(Data))-((((u8)(Data))>>4)<<4))

// XADC DEVICE
#define XADC_DEVICE_ID 		XPAR_XADCPS_0_DEVICE_ID
// XADC Instance
extern  XAdcPs XAdcInst;



// Function Prototype
// Float Fractional Part to Integer
int FractToInt(float FloatNum);
// I2C Mux PCA9548A Select Channel
int PCA9548A_Ch_Select(u8 DeviceAddress, u8 *SendBuffer, u8 *RecvBuffer, int verbose);
// I2C Temperature read
int STS21_read(XIicPs *InstancePtr, u8 *SendBuffer, u8 *RecvBuffer, int verbose);
// XADC Read
int XADC_read (u32 *read_buf, int verbose);

#endif
