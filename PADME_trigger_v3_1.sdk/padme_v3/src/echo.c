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

// PADME LIB
#include "padme_shared.h"
// IIC Device Instance
XIicPs Iic0;
XIicPs Iic1;
// XADC Instance
XAdcPs XAdcInst;

#ifndef PADME_SHARED_H
#include <stdio.h>
#include <string.h>
#include <xil_io.h>
#include <sleep.h>
#endif

#include "lwip/err.h"
#include "lwip/tcp.h"
#if defined (__arm__) || defined (__aarch64__)
#include "xil_printf.h"
#endif

#include "xparameters.h"


int transfer_data() {
	return 0;
}

void print_app_header()
{
	xil_printf("\n\r\n\r-----lwIP TCP server ------\n\r");
	//xil_printf("TCP packets sent to port 6001 will be echoed back\n\r");
}

err_t poll_callback (void *arg,struct tcp_pcb *tpcb)
{

/*
    u32 tx_pload[2047];
    u16 rx_addr=0x78;
    int i=2;

    // Check if FIFO is not empty
    tx_pload[i+1]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr));
	tx_pload[i]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr)+4);
	if (tx_pload[i]>>24 !=0)
		return ERR_OK;

	// Set Header
    tx_pload[0]=0xB0F0B0F0;
    tx_pload[1]=0x0B0F0B0F;

    while (1) {
    	i=i+2;
    	tx_pload[i+1]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr));
    	tx_pload[i]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr)+4);
    	if (tx_pload[i]>>24 !=0)
    		// Check if FIFO is empty
    		break;

    }

    // Set footer
    tx_pload[i]  =0xE0F0E0F0;
	tx_pload[i+1]=0x0E0F0E0F;

	// Send DATA
    u16 pl_len=(i+2)*4; // 32bit words*4
    for (i=0;i<pl_len;i++) {
    	tx_pload[i]=Xil_EndianSwap32(tx_pload[i]);
    }
    //pl_len=1;
    //tx_pload[0]=0x12345678;
	if (tcp_sndbuf(tpcb) > pl_len) {
		tcp_write(tpcb, tx_pload, pl_len, 1);
		xil_printf("Polling ...\n\r");
	} else
		xil_printf("no space in tcp_sndbuf\n\r");
	return ERR_OK;
	*/
}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	/* do not read the packet if we are not in ESTABLISHED state */
	if (!p) {
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}

	int verbose=1;

	//u32 r;
	/*int i=0;
	while (i<5) {
	  r=Xil_In32(XPAR_M00_AXI_0_BASEADDR+0x80+i*4);
	  xil_printf("AXI read: %08x \n\r",r);
	  i++;
	}
	 */

	/* indicate that the packet has been received */
	tcp_recved(tpcb, p->len);

	if (p->len <1) {
		xil_printf("No data received\n\r");
		return ERR_OK;
	} else if (p->len <2){
		xil_printf("Address not specified\n\r");
		return ERR_OK;
	}


	u8_t *rx_data;
	if (verbose==1) {
		rx_data = (u8_t *)p->payload;
		// Print payload received from Ethernet
		xil_printf("Recieved Packet Length = %d \r\n 0x", p->len);
		for( int i=0; i<(p->len); i++ ) {
		  xil_printf(" %02x", *(rx_data++));
		}
		xil_printf("\n\r");
	}


	u8_t rx_cmd= *(u8_t *) p->payload;
	//xil_printf("\nReceived command: %02x\n\r", rx_cmd);
	if (verbose==1)
		xil_printf("\tReceived command: 0x%02x\n\r", rx_cmd);

	u8_t rx_addr= *(u8_t *) (p->payload+1);
	//xil_printf("Received address: %02x\n\r", rx_addr);
	if (verbose==1)
		xil_printf("\tReceived address: 0x%02x\n\r", rx_addr);

	//xil_printf("Received pload: ");
	u32 *rx_pload;
	u16 pl_len;
	u16 tx_len;
	if (p->len>2) {
		rx_pload = (u32 *) (p->payload+2); // Note: rx_pload must be endian swapped
		pl_len=(p->len-2)/4;  //// Note: truncation
		//for (int i=0;i<pl_len;i++)
		//	rx_pload[i]=Xil_EndianSwap32(*(rx_pload+i));
		//xil_printf("Done\n\r");
	} else {
		rx_pload[0]=1;
		pl_len=0;
	}

	if (verbose==1) {
		xil_printf("\tRecieved Payload Length = %d \r\n", pl_len);
		xil_printf("\tReceived Payload:\n\r\t0x");
		for( int i=0; i<pl_len; i++ ) {
		  xil_printf("%08x ",Xil_EndianSwap32(*(rx_pload+i))); //// Note: Printed with swapped endian
		}
		xil_printf("\n\r\n");
	}


	//u32 tx_pload[(u8_t) *(rx_pload)];
	u32 tx_pload[TCP_SND_BUF/4];

	// IIC Buffers
	u8 SendBuffer[IIC_BUFFER_SIZE];    /**< Buffer for Transmitting Data */
	u8 RecvBuffer[IIC_BUFFER_SIZE];    /**< Buffer for Receiving Data */

	int Status;


	switch(rx_cmd){
	case 0x0:
		if (verbose==1)
			xil_printf("Reading...\n\r");
		if (*(rx_pload)>255)
			xil_printf("Maximum number of consecutive readable register is 255.");
		// Read from reg.
		for (int i=0; i<(u8_t)(*(rx_pload)); i++){
			xil_printf("AXI read ");
			tx_pload[i]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr+i)*4);
			xil_printf("@ %02X: %08X\n\r",rx_addr+i,tx_pload[i]);
			//tx_pload=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr+i)*4);
			//xil_printf("AXI read @ %02X: %08X\n\r",rx_addr+i,tx_pload);
			tx_pload[i]=Xil_EndianSwap32(tx_pload[i]);
		}
		if (tcp_sndbuf(tpcb) > pl_len) {
			err = tcp_write(tpcb, tx_pload, *(rx_pload)*4, 1);
		} else
		    xil_printf("no space in tcp_sndbuf\n\r");
		break;
	case 0x1:
		if (verbose==1)
			xil_printf("Writing...\n\r");
		// Write from reg.
		for (int i=0; i<pl_len; i++){
			xil_printf("AXI write @ %02X: %08X\n\r",rx_addr+i,Xil_EndianSwap32(*(rx_pload+i)));
			//xil_printf("AXI write @ %02x: ",rx_addr+i);
			//xil_printf("0x%08X\n\r",Xil_EndianSwap32(*(rx_pload+i)));
			Xil_Out32(XPAR_M00_AXI_0_BASEADDR+((u32)rx_addr+i)*4, Xil_EndianSwap32(*(rx_pload+i)));
		}
		break;
	case 0x2:
		// Read Data
		rx_addr=0x78;
		int i=1;
		int j=0;
		u16 pl_len=0;
		/*
		// Check if FIFO is not empty
		tx_pload[i+1]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr));
		tx_pload[i]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr)+4);
		if (tx_pload[i]>>24 !=0)
			break;
		 */

		// Set Header
		tx_pload[0]=0xB0F0B0F0;
		//tx_pload[1]=0x0B0F0B0F;


		while ( i < (tcp_sndbuf(tpcb)/4-20) ) {
			tx_pload[i+1]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr));
			tx_pload[i]=Xil_In32(XPAR_M00_AXI_0_BASEADDR+((u32) rx_addr)+4);
			if ( ((tx_pload[i]>>24)&1) !=0 )
				// Check if FIFO is empty
				break; /*
			i++;
			if ( i >= (tcp_sndbuf(tpcb)/8-1) ) {
				pl_len=(i+1)*4; // 32bit words*4
				for (j=0;j<pl_len/4;j++) {
					tx_pload[j]=Xil_EndianSwap32(tx_pload[j]);
				}
				err = tcp_write(tpcb, tx_pload, pl_len, 1);
				tcp_output(tpcb);
				// free the received pbuf
				//pbuf_free(p);
				i=0;
			} else
				i++;
			*/
			i=i+2;
		}

		// Set footer
		tx_pload[i]  =0xE0F0E0F0;
		//tx_pload[i+1]=0x0E0F0E0F;

		// Send DATA
		pl_len=(i+1)*4; // 32bit words*4
		for (j=0;j<pl_len/4;j++) {
			tx_pload[j]=Xil_EndianSwap32(tx_pload[j]);
		}
		if (tcp_sndbuf(tpcb) > pl_len) {
			err = tcp_write(tpcb, tx_pload, pl_len, 1);
			//xil_printf("\ttcp_sndbuf:%04X\n\r", tcp_sndbuf(tpcb));
			//xil_printf("\tpl_len:%04X\n\r", pl_len);
		} else {
			xil_printf("no space in tcp_sndbuf\n\r");
			xil_printf("\ttcp_sndbuf:%04X\n\r", tcp_sndbuf(tpcb));
			xil_printf("\tpl_len:%04X\n\r", pl_len);
		}
		break;
	//case 0x3:
		// Write reg. file.
		//break;
	case 0x4:
		// Read I2C Device Temperature
		if (rx_addr==0x0) {
		//STS21 on CPU Board
			Status = STS21_read(&Iic0, SendBuffer, RecvBuffer, verbose);
			if (Status==XST_FAILURE){
				xil_printf("Cannot Read STS21\n\r");
				break;
			}
			pl_len=4;
			// Convert the data
			tx_pload[0] = Xil_EndianSwap32 (  ( ((u32) RecvBuffer[0]) * 256) + ((u32) RecvBuffer[1] )  );
		} else if (rx_addr==0x1) {
		// Zynq XADC
			XADC_read (tx_pload, verbose);
			pl_len=12*4;
			for (int i=0; i<(u8_t)(*(rx_pload)); i++){
				tx_pload[i]=Xil_EndianSwap32(tx_pload[i]);
			}
		} else if ((rx_addr>>4)==1) {
		//STS21 through MUX0
			u8 lsnibble=B2LSN(rx_addr);
			if (lsnibble>8) {
				xil_printf("Invalid IIC channel");
				break;
			}
			SendBuffer[0]=((u8)1)<<lsnibble;
			Status = PCA9548A_Ch_Select(IIC_PCA9548A_MUX0, SendBuffer, RecvBuffer, verbose);
			if (Status==XST_FAILURE){
				break;
			}
			Status = STS21_read(&Iic1, SendBuffer, RecvBuffer, verbose);
			if (Status==XST_FAILURE){
				xil_printf("Cannot Read STS21\n\r");
				break;
			}
			pl_len=4;
			// Convert the data
			tx_pload[0] = Xil_EndianSwap32(  ( ((u32) RecvBuffer[0]) * 256) + ((u32) RecvBuffer[1] )  );
		} else if ((rx_addr>>4)==2) {
		//STS21 through MUX1
			u8 lsnibble=B2LSN(rx_addr);
			if (lsnibble>8) {
				xil_printf("Invalid IIC channel");
				break;
			}
			SendBuffer[0]=((u8)1)<<lsnibble;
			Status = PCA9548A_Ch_Select(IIC_PCA9548A_MUX1, SendBuffer, RecvBuffer, verbose);
			if (Status==XST_FAILURE){
				break;
			}
			Status = STS21_read(&Iic1, SendBuffer, RecvBuffer, verbose);
			if (Status==XST_FAILURE){
				xil_printf("Cannot Read STS21\n\r");
				break;
			}
			pl_len=4;
			// Convert the data
			tx_pload[0] = Xil_EndianSwap32(  ( ((u32) RecvBuffer[0]) * 256) + ((u32) RecvBuffer[1] )  );
		} else {
			xil_printf("Unrecognized address!!!\n\r");
			break;
		}

		if (tcp_sndbuf(tpcb) > pl_len) {
					err = tcp_write(tpcb, tx_pload, pl_len, 1);
				    //xil_printf("\ttcp_sndbuf:%04X\n\r", tcp_sndbuf(tpcb));
				    //xil_printf("\tpl_len:%04X\n\r", pl_len);
				} else {
				    xil_printf("no space in tcp_sndbuf\n\r");
				    xil_printf("\ttcp_sndbuf:%04X\n\r", tcp_sndbuf(tpcb));
				    xil_printf("\tpl_len:%04X\n\r", pl_len);
				}
		break;
	default:
		// Unknown command.
		xil_printf("Unrecognized command!!!\n\r");
		break;
	}


	/* We assume that the payload is < TCP_SND_BUF */
	//if (tcp_sndbuf(tpcb) > p->len) {
		//err = tcp_write(tpcb, p->payload, p->len, 1);
	/*if (tcp_sndbuf(tpcb) > pl_len) {
		err = tcp_write(tpcb, rx_pload, pl_len*4, 1);
	} else
		xil_printf("no space in tcp_sndbuf\n\r");
	 */

	/* free the received pbuf */
	pbuf_free(p);

	return ERR_OK;
}

err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)
{
	static int connection = 1;

	//if (connection==2) {
		/* set tcp_poll callback function for newpcb */
		//tcp_poll(newpcb, poll_callback, 1);
	//} else {
		/* set the receive callback for this connection */
		tcp_recv(newpcb, recv_callback);
	//}



	/* just use an integer number indicating the connection id as the
	   callback argument */
	tcp_arg(newpcb, (void*)(UINTPTR)connection);

	/* increment for subsequent accepted connections */
	connection++;

	return ERR_OK;
}


int start_application()
{
	struct tcp_pcb *pcb;
	err_t err;
	unsigned port = 7;

	/* create new TCP PCB structure */
	pcb = tcp_new();
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = tcp_bind(pcb, IP_ADDR_ANY, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(pcb, NULL);

	/* listen for connections */
	pcb = tcp_listen(pcb);
	if (!pcb) {
		xil_printf("Out of memory while tcp_listen\n\r");
		return -3;
	}

	/* specify callback to use for incoming connections */
	tcp_accept(pcb, accept_callback);

	xil_printf("TCP server started @ port %d\n\r", port);

	return 0;
}
