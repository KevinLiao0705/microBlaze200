/*
 * 	program flash:
 * 		Xilinx->Program Device
 * 			bitstream/PDI:${project_loc:sync}/_ide/bitstream/design_1_wrapper.bit
 * 			microblaze_0:E:\kevin\myCode\microBlaze1\vitisJson\syncMain\Debug\syncMain.elf
 * 			program->
 * 		Xilinx->Program flash
 * 			image File:E:\kevin\myCode\microBlaze1\vitisJson\syncMain\_ide\bitstream\download.bit
 * 			flash type: mt25ql128-spi...
 *
 *
 *  drvPcb wg signal buffer about 50ns delay
 *
 *
 *
 *
 *
 *
 */


#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xil_exception.h"
#include "xbasic_types.h"
#include "xgpio.h"
#include "microblaze_sleep.h"
#include "xuartlite.h"
#include "xuartlite_l.h"
#include "xtmrctr.h"
#include "xintc.h"




/************************** Function Prototypes ******************************/



void uart0RxIntPrg(void *CallBackRef, unsigned int EventData);
void uart1RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart3RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart4RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart5RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart6RxIntPrg(void *CallBackRef, unsigned int EventData);
void transBram(void);
void initBram(void);






/******************************************************************************/


#define txBufferSize_k 512
#define rxBufferSize_k 512
#define rxStackBufferSize_k 256




#define sspaMoniDatas_size 64
u16 myDeviceId = 25010;//deviceId
u16 mySerialId = 0x0000;//
u16 slotDeviceId = 0x2536;


typedef struct _uartDataSt
{
	u8 id;
	u8 txEnCode;
	u8 txBuffer[txBufferSize_k];
	u8 txTmp[txBufferSize_k * 2];
	u16 txBufferLen;
	u8 txChksum0;
	u8 txChksum1;
	//===
	u16 txDeiceId;
	u16 txSerialId;
	u16 txGroupId;
	u16 txSerialCnt;
	//================
	//u8 txDataId;
	//u8 txFlags;
	int txLen;
	int txCnt;
	u16 txCmd;
	u16 txPara0;
	u16 txPara1;
	u16 txPara2;
	u16 txPara3;
	u8 txPackItemCnt0;
	u8 txPackItemCnt1;
	u8 txPackItemCnt2;
	u8 txPackItemCnt3;
	//===========================================
	u8 preCodeLen;
	u8 rxEnCode;
	u8 spcChar_f;
	u16 rxStackPtr0;
	u16 rxStackPtr1;
	u8 rxStack[rxStackBufferSize_k];



	//===========================================
	u8 rxBuffer[rxBufferSize_k];
	u16 rxBufferLen;
	u16 rxBufferCnt;
	//===
	u16 rxDeiceId;
	u16 rxSerialId;
	u16 rxGroupId;
	u16 rxSerialCnt;
	u16 rxFlag;
	u16 rxLen;
	u16 rxCmd;
	u16 rxPara0;
	u16 rxPara1;
	u16 rxPara2;
	u16 rxPara3;
	u8 endTxFifo_f;
	u8 endTx_f;
	u8 txStart_f;


	void (*fptr)(struct _uartDataSt *);

} UartData;


typedef struct radarDataSt
{
	//0:mast, 1:sub, 2:ctr, 3:drva, 4:drvb 15:meter
	u8 fpgaId;
	//==================================
	/*
			array 0:mast, 1:sub1, 2:sub2, 3:ctr1, 4:ctr2, 5:drv1a, 6:drv1b, 7:drv2a, 8:drv2b
			*** slotId[3:0] ==>
		 	 "none 				id=0;
		 	 "ipc",     	id=1;
		 	 "fpga",    	id=2;
		 	 "io",       	id=3;
		 	 "la",       	id=4;
		 	 "fiber",     	id=5;
		 	 "rf",     		id=6;
		 	 "speech",   	id=7;
		 	 "sspa", 	  	id=8;
		 	 "meter",  		id=9;
		  *** slotSerNo			7:4
		  *** slotStatus		9:8 ==> 0:none, 1:ready, 2:error 3:warn up
	      *** slotTestStatus 	11:10 ==> 0:none, 1:PreTest, 2:testing;
	      *** slotTestStatusId 	15:12 ==>
	      */
    u16 slotDataAA[12];
    /*=================================================
     mast mainStatus[1:0] 		==> 0:none, 1:warn up, 2:ready, 3:error ==>mast
     //sub1 mainStatus[3:2] 		==> 0:none, 1:warn up, 2:ready, 3:error	==>mast,sub
     //sub2 mainStatus[5:4] 		==> 0:none, 1:warn up, 2:ready, 3:error ==>mast
     //ctr1 mainStatus[7:6] 		==> 0:none, 1:warn up, 2:ready, 3:error ==>mast,sub,ctr
     //ctr2 mainStatus[9:8] 		==> 0:none, 1:warn up, 2:ready, 3:error ==>mast
     //drv1a mainStatus[11:10] 	==> 0:none, 1:warn up, 2:ready, 3:error ==>mast,sub,ctr,drva
     //drv1b mainStatus[13:12] 	==> 0:none, 1:warn up, 2:ready, 3:error ==>mast,sub,ctr,drvb
     //drv2a mainStatus[15:14] 	==> 0:none, 1:warn up, 2:ready, 3:error ==>mast
     //drv2b mainStatus[17:16] 	==> 0:none, 1:warn up, 2:ready, 3:error ==>mast
     //ctr1Meter mainStatus[19:18] 	==> 0:none, 1:warn up, 2:ready, 3:error ==>mast,sub,ctr,meter
     //ctr2Meter mainStatus[21:20] 	==> 0:none, 1:warn up, 2:ready, 3:error ==>mast
     //===
     ctr1 rfPulse detect flag[22]       ==> 0:none 1:OK			==>mats,sub,ctr
     ctr1 powerOnStatus[23] 			==> 0:Off 1:On			==>mats,sub,ctr
     ctr1 sspaEnableStatus[24] 			==> 0:disable 1:enable	==>mats,sub,ctr
     ctr1 pulseEnableStatus[25] 		==> 0:disable 1:enable	==>mats,sub,ctr
     ctr1 emergencyStopStatus[26] 		==> 0:nono 1:stop		==>mats,sub,ctr
     //===
     ctr2 rfPulse detect flag[27] 		==> 0:none  1:OK  		==>mast
     ctr2 powerOnStatus[28] 			==> 0:Off 1:On			==>mast
     ctr2 sspaEnableStatus[29] 			==> 0:disable 1:enable	==>mast
     ctr2 pulseEnableStatus[30] 		==> 0:disable 1:enable	==>mast
     ctr2 emergencyStopStatus[31] 		==> 0:nono 1:stop		==>mast
     */
    u32 systemStatus0;



    /*=================================================
    sub1 fiberConnectStatus[0]		==> 0:none, 1:connected		==>mats,sub,
    sub1 rfConnectStatus[1]     	==> 0:none, 1:connected		==>mats,sub,
    sub2 fiberConnectStatus[2] 		==> 0:none, 1:connected		==>mast
    sub2 rfConnectStatus[3]    		==> 0:none, 1:connected		==>mast

    ctr1 remoteControlEnable[4]		==> 0:none, 1:enable		==>mast,sub,ctr
    ctr2 remoteControlEnable[5]		==> 0:none, 1:enable		==>mast
    mast spPulseExist[6]			==  0:none 1:exist			==>mast
    ctr1 allSspaEnviSlatus[7] 		==> 0:OK, 1:Error			==>mast,sub,ctr,ctrIpc

    ctr1 allSspaPowerSlatus[8] 		==> 0:OK, 1:Error			==>mast,sub,ctr,ctrIpc
    ctr1 allSspaModuleSlatus[9] 	==> 0:OK, 1:Error			==>mast,sub,ctr,ctrIpc
    ctr1 overWidth[10] 				==> 0:OK, 1:Error			==>mast,sub,ctr,ctrIpc
    ctr1 overDuty[11] 				==> 0:OK, 1:Error			==>mast,sub,ctr,ctrIpc

    ctr2 allSspaEnviSlatus[12] 		==> 0:OK, 1:Error			==>mast
    ctr2 allSspaPowerSlatus[13] 	==> 0:OK, 1:Error			==>mast
    ctr2 allSspaModuleSlatus[14] 	==> 0:OK, 1:Error			==>mast
    ctr2 overWidth[15] 				==> 0:OK, 1:Error			==>mast

    ctr2 overDuty[16] 				==> 0:OK, 1:Error			==>mast
    /*=================================================
    ctr1 meterStatus[17] 			==> 0:OK, 1:Error			==>mast,sub,ctr,ctrIpc
    ctr2 meterStatus[18] 			==> 0:OK, 1:Error			==>mast
    mast spPulseExist[19]			==  0:none 1:exist			==>mast

    ctr1 loadType[20]      			==> 0:dummyLoad, 1:ant		==>mast,sub,ctr,meter
    ctr2 loadType[21]      			==> 0:dummyLoad, 1:ant		==>mast
    ctr1 battleShort[22]      		==> 0:Off, 1:On				==>mast,sub,ctr
    ctr2 battleShort[23]      		==> 0:Off, 1:On				==>mast

    sub1MastPulseExist[24]			==  0:none 1:exist			==>mast,sub
    sub2MastPulseExist[25]			==  0:none 1:exist			==>mast
    ctr1 pusleFrom[26]				==  0:remoute 1:local		==>mast,sub,ctr
    sub1 pulseFrom[27]				==  0:remoute 1:local		==>mast,sub

    ctr2 pusleFrom[28]				==  0:remoute 1:local		==>mast
    sub2 pulseFrom[29]				==  0:remoute 1:local		==>mast

    ctr1 remote enable[30]		    ==  1:remoute ctr sub mast
    ctr2 remote enable[31]		    ==  1:remoute mast



    */
    u32 systemStatus1;
    //=============================================















    /* enviStatus every item is 2 bit
     value 0:none, 1:ok, 2:error
     airFlow left
     airFlow middle
     airFlow right
     waterFlow 1
     waterFlow 2
     waterFlow 3
     waterFlow 4
     waterFlow 5
     waterFlow 6
     waterFlow temperature
     */
    u32 enviStatusA;
    //=============================================
    /*
     0:input rf power
     1:
     2:pre amp output rf power
     3:driver amp output rf power
     4:cw output rf power
     5:ccw output rf power
     */
    u16 meterStatusAA[8];
    //=============================================
    //0 connectFlag, 1 faultLed, 2:v50enLed, 3:v32enLed,4:powerOnSet;
    u8 	sspaPowerStatusAA[36];
    u16 sspaPowerV50vAA[36];
    u16 sspaPowerV50iAA[36];
    u16 sspaPowerV50tAA[36];
    u16 sspaPowerV32vAA[36];
    u16 sspaPowerV32iAA[36];
    u16 sspaPowerV32tAA[36];
    //=============================================
    /*
     0:connect, 1:enable, 2 protectTriged, 3:overDuty, 4:overPulseWidth, 5:overTemperaute, 6:overReflect,
     */
    u8 sspaModuleStatusAA[36];
    u16 sspaModuleRfOutAA[36];
    u16 sspaModuleTemprAA[36];
    //=============================================
    u16 adjTimeOf1588A[2];
    u16 commPackageCntA[2];
    u16 commOkRateA[2];
    u16 rfRxPowerA[4];//mast rx1,mast rx2,sub1 rx sub2 rx
    //==============================================




    /*=============================================================================
    emulate flag[1:0] ==> 0:no ,1:syncSet emulate, 2:vitis emulate  ==>all
    //
    ctr remote[2] ==> 0:disable 1:enable	==>ctr
    xxx[3] ==> 0:disable 1:enable
    //
    mast pulse source[4] ==> 0:SP, 1:local generate  ==>mast
    sub pulse source[5] ==> 0:from mast, 1:local generate ==>sub
    ctr pulseSource[6] ==> 0:from sub, 1:local generate	==>ctr
    ctr battle short[7] ==> 0:close, 1:open ==>ctr
    ctr txLoad[8] ==> 0:dummyLoad,1:ant ==>ctr
    meter sp4tCnt[9] ==>  0:input power, 1:driver poser, 2:cw power, 3:ccw power ==>ctr
    //
   	mastToSub1CommType[14:13] ==> 0: fiber, 1:rf, 2:auto, 3:none	==>mast
   	mastToSub2CommType[16:15] ==> 0: fiber, 1:rf, 2:auto, 3:none	==>mast
   	//
   	xxx[17] ==> 0:, 1:
   	xxx[18] ==> 0:, 1:
   	//
    subCommType[20:19] ==> 0: fiber, 1:rf, 2:auto, 3:none		==>sub
    xxx[22:21] ==> 0: fiber, 1:rf, 2:auto, 3:none
    //
    subChSyncType[23] ==> 0: fix delay, 1:1588	==>sub
    xxx[24] ==> 0: fix delay, 1:1588

   	mastToSub1SpeechEnable[25] ==> 0:disable, 1:enable ==>mast
   	mastToSub2SpeechEnable[26] ==> 0:disable, 1:enable ==>mast

   	SSPA module protect flag[27] ==> 0:off, 1:on: ==>ctr

   	fpgaId[31:28] ==> ==>all
    */
    u32 systemFlag0;
    /*
    [0]: microBlaze ready

    */
    u32 systemFlag1;
    //===============================
    u8 sspaPowerV32OnDly;
    u8 sspaPowerV50OffDly;
    u8 wgFreqCh;
	u8 attenuator;
	u8 sspaPowerExistAA[5];
	u8 sspaModuleExistAA[5];
	u8 gpsDataLen[3];
	u8 gpsDataA[3][64];

	/*
	 []no use
	 //ctr Use
	 0-3 subA->ctrA,subB->ctrB,xxx,ctrB->subB
	 4-7 ctrA->drvaA,ctrA->drvaB,xxx,devaB->ctrB
	 8-12 ctrA->drvbA,ctrA->drvbB,xxx,devbB->ctrB
	 12-15 ctrA->meterA,ctrB->meterB,xxx,meterB->ctrB
	 16-19 xxx,xxx,[s1RxPackCnt],xxx
	 //20-23 hostS1FiberRx,,hostS1RfRx,hostS2FiberRx,,hostS2RfRx,
	 24-27 [uart0,uart1],xx,xx

	 //sub Use
	 0-3 mstA->subA,xxx,subA->mstA,xxx
	 4-7 subA->ctrA,subB->ctrB,xxx,ctrA->subB
	 16-19 ,s1SyncRfRx,s1SyncFiberRx,[s1SyncRxPackCnt],xxx
	 //20-23 hostS1FiberRx,,hostS1RfRx,hostS2FiberRx,,hostS2RfRx,
	 24-27 [uart0,uart1],xx,xx
	 //mast Use
	 0-3 sub1A->mast,xxx,sub2A->mstA,xxx
	 16-19 ,s1SyncRfRx,s1SyncFiberRx,[s1SyncRxPackCnt],xxx
	 24-27 [uart0,uart1],xx,xx
	*/


	u8 conRxCntA[28];

	u16 preTrigTime;
	u8 preRfOutTime;
	u8 afterTrigTime;
	//=============================
	u16 commTestPacks;
	u16 vgTimeDelay;//unit 0.1
	u16 chTimeFineTune;
	u16 chFiberDelay;
	u16 chRfDelay;
	u8 chRfTxChA[2];
	u8 chRfRxChA[2];
	u8 laGroupCh;
	u8 subChDelay;
	u8 ctrChDelay;
	u8 drvChDelay;
	u8 meterChDelay;
	u8 mastChDelay;
	u16 commChDelay;
	u8 hdfo;
	//=============================
	u8 pulseGenCh;
	u8 pulseGenDatasA[8*32];
	//================================
	u16 ioInA[6];
	u8 io;
	u8 ioLdlo;
	u8 ioLdfo;
	u8 fiberPointBuf[4][64];
	u32 subStatusA[2];
	u16 iZeroTh;
	u8 iSumShift;
	u16 i32Th;
	u16 i50Th;



} RadarData;

#define gpOutADeviceId	 		XPAR_AXI_GPIO_0_DEVICE_ID
#define OUTPUTA_BASEADDR 		XPAR_AXI_GPIO_0_BASEADDR
//===
#define gpInADeviceId	 		XPAR_AXI_GPIO_1_DEVICE_ID
#define INPUTA_BASEADDR 		XPAR_AXI_GPIO_1_BASEADDR
//===
#define timer0DeviceId	 		XPAR_AXI_TIMER_0_DEVICE_ID
#define TIMER0_BASEADDR 		XPAR_AXI_TIMER_0_BASEADDR
//===
#define uart0DeviceId	 		XPAR_AXI_UARTLITE_0_DEVICE_ID
#define uart0BaseAddr	 		XPAR_AXI_UARTLITE_0_BASEADDR
//===
#define uart1DeviceId	 		XPAR_AXI_UARTLITE_1_DEVICE_ID
#define uart1BaseAddr	 		XPAR_AXI_UARTLITE_1_BASEADDR
//===
#define uart2DeviceId	 		XPAR_AXI_UARTLITE_2_DEVICE_ID
#define uart2BaseAddr	 		XPAR_AXI_UARTLITE_2_BASEADDR
//===
//#define uart3DeviceId	 		XPAR_AXI_UARTLITE_3_DEVICE_ID
//#define uart3BaseAddr	 		XPAR_AXI_UARTLITE_3_BASEADDR
//===
//#define uart4DeviceId	 		XPAR_AXI_UARTLITE_4_DEVICE_ID
//#define uart4BaseAddr	 		XPAR_AXI_UARTLITE_4_BASEADDR
//===
//#define uart5DeviceId	 		XPAR_AXI_UARTLITE_5_DEVICE_ID
//#define uart5BaseAddr	 		XPAR_AXI_UARTLITE_5_BASEADDR
//===
//#define uart6DeviceId	 		XPAR_AXI_UARTLITE_6_DEVICE_ID
//#define uart6BaseAddr	 		XPAR_AXI_UARTLITE_6_BASEADDR
//===
#define intc0DeviceId 			XPAR_INTC_0_DEVICE_ID
#define intc0BaseAddr 			XPAR_INTC_0_BASEADDR





//==
#define BRAM_CTR0_DEVICE_ID 	XPAR_AXI_BRAM_CTRL_0_DEVICE_ID
#define BRAM_CTR0_BASEADDR 		XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define uart0IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_0_INTERRUPT_INTR
#define uart1IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_1_INTERRUPT_INTR
#define uart2IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_2_INTERRUPT_INTR
//#define uart3IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_3_INTERRUPT_INTR
//#define uart4IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_4_INTERRUPT_INTR
//#define uart5IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_5_INTERRUPT_INTR
//#define uart6IntVecter 			XPAR_AXI_INTC_0_AXI_UARTLITE_6_INTERRUPT_INTR
#define timer0IntVecter			XPAR_AXI_INTC_0_AXI_TIMER_0_INTERRUPT_INTR










static XGpio gpInAObj;
static XGpio gpOutAObj;
static XTmrCtr timer0Obj;
static XIntc intc0Obj;
static XUartLite uart0Obj;
static XUartLite uart1Obj;
//static XUartLite uart2Obj;
//static XUartLite uart3Obj;
//static XUartLite uart4Obj;
//static XUartLite uart5Obj;
//static XUartLite uart6Obj;











u32 prePulseCnt=0;
u32 outFlag = 0;
u32 inFlag = 0xffffffff;

UartData udIpc;
UartData ud485;
UartData udFib[4];

UartData udSxSync;
UartData udHostS1Sync;
UartData udHostS2Sync;



u8 noSyncConTime=0;

u32 nowTime=0;
u32 timerBuf = 0;
u32 timerFlag = 0;
int bramAddr = 0;
int intBramAddr = 0;
int shTime=0;
u8 revData;

u32 bramBuf0;
u32 bramBuf1;
u32 uartRestTime = 0;
u32 rsRestTime = 0;
u32 ud_endTime = 0;

RadarData radarData;

u16 rs_tx_slotId=1;
u16 rs_tx_para0;
u16 rs_tx_para1;
u16 rs_tx_para2;
u16 rs_tx_para3;

u16 rs_cmd = 0;
u16 rs_cmd_para0 = 0;
u16 rs_cmd_para1 = 0;
u16 rs_cmd_para2 = 0;
u16 rs_cmd_para3 = 0;


u16 fiber_cmd = 0;
u16 fiber_cmd_para0 = 0;
u16 fiber_cmd_para1 = 0;
u16 fiber_cmd_para2 = 0;
u16 fiber_cmd_para3 = 0;


u32 preLoopTime=0;
u32 maxLoopTime=0;
u32 debugCnt=0;
u32 debugBuf0=0;
u8 tickFatherTime=0;

u32 rmem[10];
u32 preRmem0;
u32 debugMem[16];
u8 debugMemCnt=0;
u16 noRxTimeA[12];
u8 slotAdr=0;
u8 selfTest_f=1;
u16 selfTestCnt=0;
u8 transBram_f=0;
u8 flash_f=0;
u8 ledStatus=0;
//===========================
u8 localPreDataGateOn_f=0;
u32 memSaveBuf=0x12345678;
//============================
u16 noMeterMcuTime=0;
u16 noMeterFpgaTime=0;

u8 drvDataClrBuf[36];
u32 hdfoBuf=0;
u32 hdfoCnt=0;

u16 nextCmd=0;
u8 nextCmdTimes=0;
u16 nextCmdPara0=0;
u16 nextCmdPara1=0;
u16 nextCmdPara2=0;
u16 nextCmdPara3=0;

u8 sspaPowerOn_f=0;
u8 sspaModuleOn_f=0;
u8 chkSspaCnt=0;


u16 ipcCmd=0;
u16 ipcCmdPara=0;

u32 s1TxStatusBuf;

u16 ctrConnectTime;


u8 rxTestBuf[64];
u8 rxTestBufCnt=0;
u8 debug_f=0;

u16 mastToSubCmd=0;
u16 mastToSubPara=0;
u16 mastToSubCmdPre=0;


void writeBram32(int data);
int readBram32();
void encmst(UartData *ud, u8 uch, int enc);
void encmstW(UartData *ud, u16 uw);
void enc_mystm(UartData *ud);
void encUartTx(UartData *udp);






void loadUdIpcTx();
void getSlotInfPrg(void);
void loadUd485Tx(UartData *udp);
int uartTxByte(UartData *udp, u32 baseAddr);
//==========================================
void loadSyncStatus(UartData *udp,int inx);
void syncMemTxPrg(UartData *udp,int inx);
void syncMemRxGet(UartData *udp,int inx);
void udSyncRxPrg(UartData *udp,int id);
//==========================================
void loadTickCtr(UartData *udp);
void loadTickDrv();
void loadTickMeter();
void loadTickSub();
void fibMemTxPrg(UartData *udp);
//=========
void fibMemRxGet(int inx);
void udFibRxPrg0(UartData *udp);
void udFibRxPrg1(UartData *udp);
void udFibRxPrg2(UartData *udp);
void udFibRxPrg3(UartData *udp);
void udFibRxPrg(UartData *udp,u8 inx);
//==========================================








void timerPrg0();
void timerPrg1();
void timerPrg2();
void timerPrg3();
int testBram(int addr, int len);
void initRadar();



int chkUartTxEmpty(u32 baseAddr);
void uartByteDec(UartData *udp,u8 revData);
void uartRxChk(UartData *udp);

void timer0InterruptPrg(void *CallbackRef);





void sspaAct(int para2,int start,int end);
void emergencyAct(int para2);
void radiationAct(int para2,int para3);
void cplLaCh15_3(void);


u32 getBufferDword(int *inxp, u8 *buf)
{
	int inx = *inxp;
	u32 sbuf = buf[inx] + buf[inx + 1] * 256;
	sbuf += buf[inx+2]*65536 + buf[inx + 3] * 256*65536;
	*inxp += 4;
	return sbuf;
}


u16 getBufferWord(int *inxp, u8 *buf)
{
	int inx = *inxp;
	u16 sbuf = buf[inx] + buf[inx + 1] * 256;
	*inxp += 2;
	return sbuf;
}

u32 getBufferInt(int *inxp, u8 *buf)
{
	int inx = *inxp;
	u32 sbuf = buf[inx];
	sbuf+=buf[inx+1]<<8;
	sbuf+=buf[inx+2]<<16;
	sbuf+=buf[inx+3]<<24;
	*inxp += 4;
	return sbuf;
}


u8 getBufferByte(int *inxp, u8 *buf)
{
	int inx = *inxp;
	u8 sbuf = buf[inx];
	*inxp += 1;
	return sbuf;
}

//485
int gpsDataClrTime=0;
void ud485RxPrg(UartData *udp)
{
	int inx = 0;
	u16 ibuf=0;

	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	u16 groupId = getBufferWord(&inx, udp->rxBuffer);
	u16 len = getBufferWord(&inx, udp->rxBuffer);
	u16 cmd = getBufferWord(&inx, udp->rxBuffer);
	u16 para0 = getBufferWord(&inx, udp->rxBuffer);
	u16 para1 = getBufferWord(&inx, udp->rxBuffer);
	u16 para2 = getBufferWord(&inx, udp->rxBuffer);
	u16 para3 = getBufferWord(&inx, udp->rxBuffer);



	if (deviceId != slotDeviceId)
		return;
	u8 devId=para0&15;
	if(serialId>=12)
		return;
	if(groupId!=0xac00)
		return;
	if(cmd==0x1000){
		radarData.slotDataAA[serialId]=para0;//slotStatus
		noRxTimeA[serialId]=0;
		if(devId==4){//La
			return;
		}
		if(devId==5){//fiber
			return;
		}
		if(devId==3){//io
			for(int i=0;i<6;i++)
				radarData.ioInA[i] = getBufferWord(&inx, udp->rxBuffer);
			return;
		}
		if(devId==6){//RF
			if(para3){
				radarData.gpsDataLen[0]=para3*2;
				for(int i=0;i<para3;i++){
					radarData.gpsDataA[0][i*2]=getBufferByte(&inx, udp->rxBuffer);
					radarData.gpsDataA[0][i*2+1]=getBufferByte(&inx, udp->rxBuffer);
				}
			}
			gpsDataClrTime=0;
			return;
		}
		if(devId==8){//sspaDriver
			u8 itemCnt=(para0>>4)&15;
			if(itemCnt>=10)
				return;
			u8 dataLen=4;
			if(itemCnt==0 || itemCnt ==9)
				dataLen=2;
			u8 adrStart=itemCnt*4-2;
			if(itemCnt==0)
				adrStart=0;
			u8 adrEnd=adrStart+dataLen;
			for(int i=adrStart;i<adrEnd;i++){
				if(i==0 || i==1 || i==35)
					inx+=20;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
		    	radarData.sspaPowerStatusAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV50vAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV50iAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV50tAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV32vAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV32iAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV32tAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaModuleStatusAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaModuleRfOutAA[i]=ibuf;
				ibuf = getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaModuleTemprAA[i]=ibuf;
				drvDataClrBuf[i]=0;
			}


		}
		if(devId==15){//meter
			for(int i=0;i<8;i++)
				radarData.meterStatusAA[i]=getBufferWord(&inx, udp->rxBuffer);
			noMeterMcuTime=0;

		}
	}

}



void udSxSyncRxPrg(UartData *udp){
	udSyncRxPrg(udp,0);
}
void udHostS1SyncRxPrg(UartData *udp){
	udSyncRxPrg(udp,1);
}
void udHostS2SyncRxPrg(UartData *udp){
	udSyncRxPrg(udp,2);
}

u8 syncDataPackCnt[3];
/*
 * id = 0 SX RX from syncDataPackage SX=>host:conRxCntA[0],host=>s1:conRxCntA[2]
 * id = 1 host RX from syncDataPackage of s1
 * id = 2 host RX from syncDataPackage of s2
 */


void udSyncRxPrg(UartData *udp,int id){
	u32 ibuf;
	u8 i8;
	int inx = 0;

	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	u16 groupId = getBufferWord(&inx, udp->rxBuffer);
	u16 cmdLen = getBufferWord(&inx, udp->rxBuffer);
	u16 cmd = getBufferWord(&inx, udp->rxBuffer);
	u16 para0 = getBufferWord(&inx, udp->rxBuffer);
	u16 para1 = getBufferWord(&inx, udp->rxBuffer);
	u16 para2 = getBufferWord(&inx, udp->rxBuffer);
	u16 para3 = getBufferWord(&inx, udp->rxBuffer);

	cplLaCh15_3();



	if (deviceId != myDeviceId || serialId != mySerialId)
		return;
	if(groupId!=0xab00)
		return;
	if((cmd>>8)!=0x30)
		return;
	if(radarData.fpgaId==0){
		if(para0!=1)
			return;
	}
	else{
		if(para0!=0)
			return;

	}


	syncDataPackCnt[id]+=1;
	if(id==0){//sx
		noSyncConTime=0;
		radarData.conRxCntA[0]=syncDataPackCnt[0];
		radarData.conRxCntA[2]=para2>>8;
		mastToSubCmd=getBufferWord(&inx, udp->rxBuffer);
		mastToSubPara=getBufferWord(&inx, udp->rxBuffer);
		if(mastToSubCmd!=0){
			if(mastToSubCmdPre!=mastToSubCmd){
				mastToSubCmdPre=mastToSubCmd;
				ipcCmd=mastToSubCmd;
				ipcCmdPara=mastToSubPara;
			}
		}else{
			mastToSubCmdPre=0;
		}

		radarData.commOkRateA[0]=getBufferWord(&inx, udp->rxBuffer);
		bramAddr=15*4;
		ibuf = readBram32();//
		if(radarData.fpgaId==1){
			radarData.conRxCntA[16]=ibuf;
			radarData.conRxCntA[17]=ibuf>>8;
		}
		return;

	}
	if(id==1){//hostS1
		radarData.conRxCntA[1]=syncDataPackCnt[1];
		radarData.subStatusA[0] = getBufferInt(&inx, udp->rxBuffer);



	}
	if(id==2){//hostS2
		radarData.conRxCntA[3]=syncDataPackCnt[2];
		radarData.subStatusA[1] = getBufferInt(&inx, udp->rxBuffer);
	}
	u8 ch=udp->rxBuffer[inx++];
	if(ch!=0xad)
		return;
	radarData.gpsDataLen[0]=udp->rxBuffer[inx++]&0x3f;
	for(int j=0;j<radarData.gpsDataLen[0];j++){
		radarData.gpsDataA[0][j]=udp->rxBuffer[inx++];
	}

}


void udFibRxPrg0(UartData *udp){
	udFibRxPrg(udp,0);
}
void udFibRxPrg1(UartData *udp){
	udFibRxPrg(udp,1);
}
void udFibRxPrg2(UartData *udp){
	udFibRxPrg(udp,2);
}
void udFibRxPrg3(UartData *udp){
	udFibRxPrg(udp,3);
}



void udFibRxPrg(UartData *udp,u8 ser)
{
	u32 ibuf;
	u8 i8;
	u8 packId;
	int inx = 0;



	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	u16 groupId = getBufferWord(&inx, udp->rxBuffer);
	u16 cmdLen = getBufferWord(&inx, udp->rxBuffer);
	u16 cmd = getBufferWord(&inx, udp->rxBuffer);
	u16 para0 = getBufferWord(&inx, udp->rxBuffer);
	u16 para1 = getBufferWord(&inx, udp->rxBuffer);
	u16 para2 = getBufferWord(&inx, udp->rxBuffer);
	u16 para3 = getBufferWord(&inx, udp->rxBuffer);



	if (deviceId != myDeviceId || serialId != mySerialId)
		return;
	if(groupId!=0xab00)
		return;


	if(para0==0x0001){
		if(radarData.fpgaId==2){ //sub => ctr
			radarData.conRxCntA[2]=para2&255;
			radarData.conRxCntA[3]=para2>>8;
			ibuf=getBufferDword(&inx, udp->rxBuffer);//systemStatus0
			ibuf=getBufferDword(&inx, udp->rxBuffer);//systemStatus1
			int fiberCmd=getBufferWord(&inx, udp->rxBuffer);
			int fiberCmdPara=getBufferWord(&inx, udp->rxBuffer);
			ibuf=getBufferWord(&inx, udp->rxBuffer);
			if(ibuf!=0xabcd)
				return;
			//cplLaCh15_3();
			radarData.conRxCntA[1]+=1;
			i8=(radarData.systemStatus1>>30)&1;//1:remote enable
			if(i8){
				if(fiberCmd!=0){
					if(fiberCmd==0x2004 || fiberCmd==0x2005){
						radiationAct(fiberCmd,252);
						return;
					}
					if(fiberCmd==0x2012 || fiberCmd==0x2013 || fiberCmd==0x2020){
						ipcCmd=fiberCmd;
						ipcCmdPara=fiberCmdPara;
						return;
					}

					sspaAct(fiberCmd,0,36);
					emergencyAct(fiberCmd);
				}
			}
		}

	}


	if(para0==0x0002){
		if(radarData.fpgaId==1){ //ctr => sub




			radarData.conRxCntA[4]=para2&255;
			radarData.conRxCntA[5]=para2>>8;
			//====================
			ibuf=getBufferDword(&inx, udp->rxBuffer);
			ibuf^=radarData.systemStatus0;
			//0000 0111 1100 1100 0011 1100 1100 0000
			ibuf&=0x07cc3cc0;
			radarData.systemStatus0^=ibuf;

			ibuf=getBufferDword(&inx, udp->rxBuffer);
			ibuf^=radarData.systemStatus1;
			//0000 0100 0101 0010 0000 1111 1001 0000
			ibuf&=0x44520f90;
			radarData.systemStatus1^=ibuf;
			inx+=37;
			ibuf=getBufferWord(&inx, udp->rxBuffer);
			if(ibuf==0xabcd){
				radarData.conRxCntA[7]+=1;
				ctrConnectTime=0;
			}
			return;
		}
		//fpgaId=3,4,15

		radarData.systemStatus0=getBufferDword(&inx, udp->rxBuffer);
		radarData.systemStatus1=getBufferDword(&inx, udp->rxBuffer);
		radarData.systemFlag0=getBufferDword(&inx, udp->rxBuffer);
		radarData.systemFlag1=getBufferDword(&inx, udp->rxBuffer);
		radarData.afterTrigTime=getBufferByte(&inx, udp->rxBuffer);
		radarData.preRfOutTime=getBufferByte(&inx, udp->rxBuffer);
		radarData.preTrigTime=getBufferWord(&inx, udp->rxBuffer);
		radarData.laGroupCh=getBufferByte(&inx, udp->rxBuffer);
		radarData.vgTimeDelay=getBufferWord(&inx, udp->rxBuffer);
		radarData.chTimeFineTune=getBufferWord(&inx, udp->rxBuffer);
		radarData.chFiberDelay=getBufferWord(&inx, udp->rxBuffer);
		radarData.chRfDelay=getBufferWord(&inx, udp->rxBuffer);
		radarData.meterChDelay=getBufferByte(&inx, udp->rxBuffer);
		radarData.drvChDelay=getBufferByte(&inx, udp->rxBuffer);
		radarData.ctrChDelay=getBufferByte(&inx, udp->rxBuffer);
		radarData.subChDelay=getBufferByte(&inx, udp->rxBuffer);
		radarData.wgFreqCh=getBufferByte(&inx, udp->rxBuffer);
		radarData.attenuator=getBufferByte(&inx, udp->rxBuffer);

		u16 i16=getBufferWord(&inx, udp->rxBuffer);
		if(i16!=0){
			rs_cmd=i16;
			rs_cmd_para0=getBufferWord(&inx, udp->rxBuffer);
			rs_cmd_para1=getBufferWord(&inx, udp->rxBuffer);
			rs_cmd_para2=getBufferWord(&inx, udp->rxBuffer);
			rs_cmd_para3=getBufferWord(&inx, udp->rxBuffer);
			rs_tx_slotId=0;
		}
		else{
			i16=getBufferWord(&inx, udp->rxBuffer);
			i16=getBufferWord(&inx, udp->rxBuffer);
			i16=getBufferWord(&inx, udp->rxBuffer);
			i16=getBufferWord(&inx, udp->rxBuffer);
		}
		ibuf=getBufferWord(&inx, udp->rxBuffer);
		if(ibuf==0xabcd){
			bramAddr=15*4;
			ibuf = readBram32();//
			if(radarData.fpgaId==3){
				radarData.conRxCntA[4]=ibuf>>8;
				radarData.conRxCntA[5]+=1;
			}
			if(radarData.fpgaId==4){
				radarData.conRxCntA[8]=ibuf>>8;
				radarData.conRxCntA[9]+=1;
			}
			if(radarData.fpgaId==15){
				radarData.conRxCntA[12]=ibuf>>8;
				radarData.conRxCntA[13]+=1;
			}
		}
		//===============================================
		ibuf=radarData.systemStatus0&0x07000000;//pulseEnableStatus & emergencyStopStatus
		ibuf+=radarData.laGroupCh;
		i8=(radarData.systemFlag0>>4)&1;
		ibuf+=i8<<8;
		if(ibuf!=bramBuf0){
			bramBuf0=ibuf;
			transBram_f=1;
		}
	}

	if(para0==0x0003 || para0==0x0004){//rx from dev
		if(radarData.fpgaId==2){ //ctr rx from dev
			int devCnt=0;
			if(para0==0x0003){
				radarData.conRxCntA[4]=para2&255;
				radarData.conRxCntA[5]=para2>>8;
				radarData.conRxCntA[7]+=1;
			}
			else{
				radarData.conRxCntA[8]=para2&255;
				radarData.conRxCntA[9]=para2>>8;
				radarData.conRxCntA[11]+=1;
				devCnt=1;
			}

			u8 adr=0;
            //slotInf 24byte systemStatus 8byte
			for(int i=0;i<32;i++){
				radarData.fiberPointBuf[devCnt][adr++]=getBufferByte(&inx, udp->rxBuffer);
			}
			//=====================================================================
			packId=getBufferByte(&inx, udp->rxBuffer);
			//=====================================================================
			if(packId == 0xab){
				i8=getBufferByte(&inx, udp->rxBuffer);
				if(i8>=36)
					return;
				if(para0==0x0003){
					if(i8>=18)
						return;
				}
				else{
					if(i8<18)
						return;
				}
				radarData.sspaPowerStatusAA[i8]=getBufferByte(&inx, udp->rxBuffer);
				radarData.sspaPowerV50vAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV50iAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV50tAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV32vAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV32iAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaPowerV32tAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaModuleStatusAA[i8]=getBufferByte(&inx, udp->rxBuffer);
				radarData.sspaModuleRfOutAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				radarData.sspaModuleTemprAA[i8]=getBufferWord(&inx, udp->rxBuffer);
				drvDataClrBuf[i8]=0;
				packId=getBufferByte(&inx, udp->rxBuffer);
			}
		//=====================================================================
			return;
		}

	}

	if(para0==0x000f){

		if(radarData.fpgaId==2){
			radarData.conRxCntA[12]=para2&255;
			radarData.conRxCntA[13]=para2>>8;

			ibuf=getBufferDword(&inx, udp->rxBuffer);//systemStatus0
			ibuf=radarData.systemStatus0^ibuf;
			//#0000 0000 0000 1100 0000 0000 0000 0000
			ibuf&=0x000c0000;
			radarData.systemStatus0^=ibuf;

			ibuf=getBufferDword(&inx, udp->rxBuffer);//systemStatus0
			ibuf=radarData.systemStatus1^ibuf;
			//#0000 0000 0001 0000 0000 0000 0000 0000
			ibuf&=0x00100000;
			radarData.systemStatus1^=ibuf;
			ibuf=getBufferWord(&inx, udp->rxBuffer);
			if(ibuf!=0x10aa)
				return;
			for(int i=0;i<8;i++)
				radarData.meterStatusAA[i]=getBufferWord(&inx, udp->rxBuffer);
			noMeterFpgaTime=0;
			radarData.conRxCntA[15]+=1;
		}

	}



}

void sspaAct(int para2,int start,int end){
	u16 ia[3]={0,0,0};
	if(para2==0x2000){//sspaPowerOn
		u8* bufA=radarData.sspaPowerExistAA;
		for(int i=start;i<end;i++){
			int exist=bufA[i/8]&(1<<(i%8));
			if(exist)
				ia[i/16]|=1<<(i%16);

		}
		rs_cmd=para2;
		rs_cmd_para0=ia[0];
		rs_cmd_para1=ia[1];
		rs_cmd_para2=ia[2];
		rs_cmd_para3=radarData.sspaPowerV32OnDly;
		rs_tx_slotId=0;
		nextCmd=rs_cmd;
		nextCmdPara0=rs_cmd_para0;
		nextCmdPara1=rs_cmd_para1;
		nextCmdPara2=rs_cmd_para2;
		nextCmdPara3=rs_cmd_para3;
		return;
	}
	if(para2==0x2001){//sspaPowerOff
		for(int i=start;i<end;i++){
			ia[i/16]|=1<<(i%16);
		}
		rs_cmd=para2;
		rs_cmd_para0=ia[0];
		rs_cmd_para1=ia[1];
		rs_cmd_para2=ia[2];
		rs_cmd_para3=radarData.sspaPowerV50OffDly;
		rs_tx_slotId=0;
		nextCmd=rs_cmd;
		nextCmdPara0=rs_cmd_para0;
		nextCmdPara1=rs_cmd_para1;
		nextCmdPara2=rs_cmd_para2;
		nextCmdPara3=rs_cmd_para3;
		return;
	}
	if(para2==0x2002){//sspaModuleOn
		radarData.systemStatus0|=0x01000000;
		u8* bufA=radarData.sspaModuleExistAA;
		for(int i=start;i<end;i++){
			int exist=bufA[i/8]&(1<<(i%8));
			if(exist)
				ia[i/16]|=1<<(i%16);
		}
		rs_cmd=para2;
		rs_cmd_para0=ia[0];
		rs_cmd_para1=ia[1];
		rs_cmd_para2=ia[2];
		rs_tx_slotId=0;
		nextCmd=rs_cmd;
		nextCmdPara0=rs_cmd_para0;
		nextCmdPara1=rs_cmd_para1;
		nextCmdPara2=rs_cmd_para2;
		return;
	}
	if(para2==0x2003){//sspaModuleOff
		radarData.systemStatus0&=0xfeffffff;
		for(int i=start;i<end;i++){
			ia[i/16]|=1<<(i%16);
		}
		rs_cmd=para2;
		rs_cmd_para0=ia[0];
		rs_cmd_para1=ia[1];
		rs_cmd_para2=ia[2];
		rs_tx_slotId=0;
		nextCmd=rs_cmd;
		nextCmdPara0=rs_cmd_para0;
		nextCmdPara1=rs_cmd_para1;
		nextCmdPara2=rs_cmd_para2;
		nextCmdPara3=rs_cmd_para3;
		return;
	}


}

void radiationAct(int para2,int para3){
	if(para2==0x2004){//radiation on
		if(para3==252){
			radarData.systemStatus0 |= 1<<25;
		}
		else if(para3==251){
			localPreDataGateOn_f=0;
		}
		else{
			radarData.pulseGenCh=para3&255;
			localPreDataGateOn_f=1;
		}
		transBram();
		//==============================
		u8 freq;
		if(radarData.pulseGenCh<32){
			freq=radarData.pulseGenDatasA[8*radarData.pulseGenCh+6];
		}
		else{
			freq=40;
		}
		rs_cmd=para2;
		rs_cmd_para0=freq;
		rs_cmd_para1=radarData.attenuator;
		rs_tx_slotId=0;
		radarData.wgFreqCh=freq;
		nextCmd=rs_cmd;
		nextCmdPara0=rs_cmd_para0;
		nextCmdPara1=rs_cmd_para1;
		return;
	}
	if(para2==0x2005){//radiation off
		radarData.systemStatus0 &= (1<<25)^0xffffffff;
		transBram();
		return;
	}


}

void emergencyAct(int para2){
	if(para2==0x2006){//emergency on
		radarData.systemStatus0 |= 1<<26;
		for(int i=0;i<36;i++){
			radarData.sspaPowerStatusAA[i] &= 0xef;
		}
		for(int i=0;i<36;i++){
			radarData.sspaModuleStatusAA[i] &= 0xfd;
		}
		radarData.systemStatus0 &= 0xfcffffff;
		rs_cmd=para2;
		rs_tx_slotId=0;

		localPreDataGateOn_f=0;
		transBram();

		nextCmd=rs_cmd;

		return;
	}
	if(para2==0x2007){//emergency off
		radarData.systemStatus0 &= (1<<26)^0xffffffff;
		rs_cmd=para2;
		rs_tx_slotId=0;
		nextCmd=rs_cmd;
		return;
	}


}


void udIpcRxPrg(UartData *udp)
{
	u8 ibuf;
	int inx = 0;
	u8 i8;

	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	u16 groupId = getBufferWord(&inx, udp->rxBuffer);
	if (deviceId != myDeviceId || serialId != mySerialId)
		return;


	if(groupId==0xac00){
		u16 cmdLen = getBufferWord(&inx, udp->rxBuffer);
		u16 cmd = getBufferWord(&inx, udp->rxBuffer);
		u16 para0 = getBufferWord(&inx, udp->rxBuffer);
		u16 para1 = getBufferWord(&inx, udp->rxBuffer);
		u16 para2 = getBufferWord(&inx, udp->rxBuffer);
		u16 para3 = getBufferWord(&inx, udp->rxBuffer);
		if(cmd!=udp->txCmd)
			return;
		int fpgaId=radarData.fpgaId;
		if(fpgaId!=para0)
			return;
		if(udp->txPara1==para1)
			tickFatherTime=250;
		if(fpgaId<99){
			if(cmd == 0x1000){//tickFather back
				radarData.systemFlag0 = getBufferDword(&inx, udp->rxBuffer);
				radarData.systemFlag1 = getBufferDword(&inx, udp->rxBuffer);
				if(fpgaId==2){
					radarData.systemStatus1&=0xbfffffff;
					if(radarData.systemFlag0&0x04)
						radarData.systemStatus1|=0x40000000;
				}


				//==============================================
				radarData.sspaPowerV32OnDly = getBufferByte(&inx, udp->rxBuffer);
				radarData.sspaPowerV50OffDly = getBufferByte(&inx, udp->rxBuffer);
				radarData.attenuator = getBufferByte(&inx, udp->rxBuffer);
				for(int i=0;i<5;i++)
					radarData.sspaPowerExistAA[i] = getBufferByte(&inx, udp->rxBuffer);
				for(int i=0;i<5;i++)
					radarData.sspaModuleExistAA[i] = getBufferByte(&inx, udp->rxBuffer);
				//==============================================
				radarData.preTrigTime = getBufferWord(&inx, udp->rxBuffer);
				radarData.preRfOutTime = getBufferByte(&inx, udp->rxBuffer);
				radarData.afterTrigTime = getBufferByte(&inx, udp->rxBuffer);
				//==============================================
				radarData.commTestPacks = getBufferWord(&inx, udp->rxBuffer);
				radarData.vgTimeDelay = getBufferWord(&inx, udp->rxBuffer);
				radarData.chTimeFineTune = getBufferWord(&inx, udp->rxBuffer);
				radarData.chFiberDelay = getBufferWord(&inx, udp->rxBuffer);
				radarData.chRfDelay = getBufferWord(&inx, udp->rxBuffer);
				radarData.chRfTxChA[0] = getBufferByte(&inx, udp->rxBuffer);
				radarData.chRfTxChA[1] = getBufferByte(&inx, udp->rxBuffer);
				radarData.chRfRxChA[0] = getBufferByte(&inx, udp->rxBuffer);
				radarData.chRfRxChA[1] = getBufferByte(&inx, udp->rxBuffer);

				radarData.laGroupCh = getBufferByte(&inx, udp->rxBuffer);
				radarData.subChDelay = getBufferByte(&inx, udp->rxBuffer);
				radarData.ctrChDelay = getBufferByte(&inx, udp->rxBuffer);
				radarData.drvChDelay = getBufferByte(&inx, udp->rxBuffer);
				radarData.meterChDelay = getBufferByte(&inx, udp->rxBuffer);


				ibuf=getBufferByte(&inx, udp->rxBuffer);//altPackId
				if(ibuf==0xb0){
					ibuf=getBufferByte(&inx, udp->rxBuffer);//len
					if(ibuf==8){
						radarData.iZeroTh = getBufferWord(&inx, udp->rxBuffer);
						radarData.iSumShift = getBufferWord(&inx, udp->rxBuffer);
						radarData.i32Th = getBufferWord(&inx, udp->rxBuffer);
						radarData.i50Th = getBufferWord(&inx, udp->rxBuffer);
					}
					ibuf=getBufferByte(&inx, udp->rxBuffer);//endPackId
				}
				if(ibuf==0xab){
					ibuf=getBufferByte(&inx, udp->rxBuffer);//altPackCnt
					if(ibuf >=32)
						return;
					int offset=8*ibuf;
					for(int i=0;i<8;i++){
						radarData.pulseGenDatasA[offset+i] = getBufferByte(&inx, udp->rxBuffer);
					}
					ibuf=getBufferByte(&inx, udp->rxBuffer);//endPackId
				}
				//
				int start = para3;
				int end=para3+1;
				if(para3==0xffff){
					start=0;
					end=36;
				}

				u32 i32;
				i32=radarData.systemStatus0&0xc7000000;//pulse on and emergency
				i32+=radarData.laGroupCh;
				u8 i8=(radarData.systemFlag0>>4)&255;
				i32+=i8<<8;
				i8=(radarData.systemFlag0>>13)&1;
				i32+=i8<<9;
				i8=(radarData.systemFlag0>>15)&1;
				i32+=i8<<10;
				i8=(radarData.systemFlag0>>17)&7;
				i32+=i8<<11;
				if(i32!=bramBuf0){
					bramBuf0=i32;
					transBram_f=1;
				}

				i32=radarData.preTrigTime;
				i32+=radarData.preRfOutTime;
				i32+=radarData.afterTrigTime;
				i32+=radarData.vgTimeDelay;
				i32+=radarData.chTimeFineTune;
				i32+=radarData.chFiberDelay;
				i32+=radarData.chRfDelay;
				i32+=radarData.subChDelay;
				i32+=radarData.ctrChDelay;
				i32+=radarData.drvChDelay;
				i32+=radarData.meterChDelay;

				if(i32!=bramBuf1){
					bramBuf1=i32;
					transBram_f=1;
				}


				if(para2==0)
					return;




				if(para2==0x2008){//selfTestStartAll
					rs_cmd=para2;
					rs_tx_slotId=0;
					radarData.slotDataAA[slotAdr] &= (0xf3ff);
					radarData.slotDataAA[slotAdr]|=0x0400;
					ledStatus=4;
					nextCmd=rs_cmd;
					return;
				}

				if(para2==0x2009){//selfTestStopAll
					rs_cmd=para2;
					rs_tx_slotId=0;
					radarData.slotDataAA[slotAdr] &= 0xf3ff;
					ledStatus=2;
					nextCmd=rs_cmd;
					return;
				}
				if(para2==0x200a){//selfTestSlot
					rs_cmd=para2;
					rs_cmd_para0=para3;
					rs_tx_slotId=0;
					if(para3==slotAdr){
						radarData.slotDataAA[slotAdr] &= (0xf3ff);
						radarData.slotDataAA[slotAdr] |= (0x0800);
						selfTest_f=1;
						selfTestCnt=0;
						ledStatus=5;
					}
					nextCmd=rs_cmd;
					nextCmdPara0=rs_cmd_para0;
					return;
				}


				if(fpgaId==0){
					if(para2==0x2004 || para2 == 0x2005){
						radiationAct(para2,para3);
						return;
					}
					if(para2==0x200b){//mastPulseEnable
						radarData.systemStatus1|=1<<19;
						return;
					}
					if(para2==0x200c){//mastPulseDisable
						radarData.systemStatus1&=(1<<19)^0xffffffff;
						return;
					}
					if(para2==0x2020){//mastSubRadarSet
						nextCmd=para2;
						nextCmdPara0=para3;
						nextCmdTimes=0;
						return;
					}
					if(para2==0x2021){//mastSubRadarCtr
						nextCmd=para2;
						nextCmdPara0=para3;
						nextCmdTimes=0;
						return;
					}
				}

				if(fpgaId==1){
					if(para2==0x2004 || para2 == 0x2005){
						radiationAct(para2,para3);
						return;
					}
					if(para2==0x2010){
						para2=0x2004;
					}
					if(para2==0x2011){
						para2=0x2005;
					}
					fiber_cmd=para2;
					fiber_cmd_para0=para3;
					return;
				}

				if(fpgaId==2 || fpgaId==3 || fpgaId==4){
					sspaAct(para2,start,end);
				}
				radiationAct(para2,para3);
				emergencyAct(para2);
				if(para2==0x2008){//preTest
					return;
				}
				if(para2==0x2009){//testStop
					return;
				}
				if(para2==0x200a){//testting
					return;
				}




			}
		}



	}


	return;

	/*
	int inx = 0;
	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	if (deviceId == myDeviceId && serialId == mySerialId)
	{
		u16 groupId = getBufferWord(&inx, udp->rxBuffer);
		u16 cmdLen = getBufferWord(&inx, udp->rxBuffer);
		u16 cmd = getBufferWord(&inx, udp->rxBuffer);
		u16 para0 = getBufferWord(&inx, udp->rxBuffer);
		u16 para1 = getBufferWord(&inx, udp->rxBuffer);
		u16 para2 = getBufferWord(&inx, udp->rxBuffer);
		u16 para3 = getBufferWord(&inx, udp->rxBuffer);
		if (cmd == 0x1100)
		{ // pulseGenStart
			int ibuf0;
			u16 trigAfterSetTime = para0;
			u8 rfAfterTrigTime = para1 & 255;
			u8 trigAfterRfTime = para1 >> 8;
			sspaData.systemflag |= (1 << 5);

			// b0=0:power off, 1: power On//no use
			// b1=0:sspaOn power on
			// b2=0:radiation ready
			// b3=pulseFrom 0:local 1:remote
			// b4=pulseType 1:fix 0:random
			// b5=local pulse start flag
			// b6=sspa protect on
			bramAddr = 0;
			writeBram32(sspaData.systemflag);
			ibuf0 = trigAfterSetTime * 65536 + rfAfterTrigTime * 256 + trigAfterRfTime;
			writeBram32(ibuf0);
			int sampleLen = 0;
			for (int i = 0; i < 30; i++)
			{
				u16 width = getBufferWord(&inx, udp->rxBuffer);
				u16 duty = getBufferWord(&inx, udp->rxBuffer);
				u16 buf16 = getBufferWord(&inx, udp->rxBuffer);
				u8 enable = buf16 & 255;
				u8 times = (buf16 >> 8) - 1;
				if (enable)
				{
					ibuf0 = (times << 24) + (sspaData.rfFreq << 16) + width;
					bramAddr = (32 + i) * 4;
					writeBram32(ibuf0);
					writeBram32(duty);
					sampleLen++;
				}
			}
			if (sampleLen)
			{
				bramAddr = 2 * 4;
				writeBram32(sampleLen - 1);
				bramAddr = 15 * 4;
				ibuf0 = readBram32();
				bramAddr = 15 * 4;
				writeBram32(ibuf0 + 1);
			}
		}

		if (cmd == 0x1200)
		{ // pulseGenStop
			bramAddr = 0;
			sspaData.systemflag &= ((1 << 5) ^ 0xffffffff);
			writeBram32(sspaData.systemflag);
			bramAddr = 15 * 4;
			int ibuf0 = readBram32();
			bramAddr = 15 * 4;
			writeBram32(ibuf0 + 1);
		}

		if (cmd == 0x1300)
		{ // setLocal
			bramAddr = 0;
			sspaData.systemflag &= ((1 << 3) ^ 0xffffffff);
			sspaData.systemflag &= ((1 << 5) ^ 0xffffffff);
			writeBram32(sspaData.systemflag);
			bramAddr = 15 * 4;
			int ibuf0 = readBram32();
			bramAddr = 15 * 4;
			writeBram32(ibuf0 + 1);
		}

		if (cmd == 0x1400)
		{ // setRemote
			bramAddr = 0;
			sspaData.systemflag |= (1 << 3);
			sspaData.systemflag &= ((1 << 5) ^ 0xffffffff);
			writeBram32(sspaData.systemflag);
			bramAddr = 15 * 4;
			int ibuf0 = readBram32();
			bramAddr = 15 * 4;
			writeBram32(ibuf0 + 1);
		}

		if (cmd == 0x1500)
		{ // powerSuplyOnOff
			rs_cmd = 0x1500;
			rs_cmd_para0 = para0;
		}
	}
	*/
}


void initBram(){
	radarData.systemStatus0=0;
	radarData.systemStatus1=0;
	radarData.systemFlag0=0;
	radarData.systemFlag1=0;
	radarData.afterTrigTime=10;
	radarData.preRfOutTime=10;
	radarData.preTrigTime=10;
	radarData.commTestPacks=4096;
	radarData.vgTimeDelay=0x2580;
	radarData.chTimeFineTune=0;
	radarData.chFiberDelay=0x100;
	radarData.chRfDelay=0x100;
	radarData.pulseGenCh=0;



	int ibuf=0;
	bramAddr = 0;
	writeBram32(0x00000000);//00 systemStatus0
	writeBram32(0x00000000);//01 systemStatus1
	writeBram32(0x00000010);//02 systemFlag0
	writeBram32(0x00000001);//03 systemFlag1
	writeBram32(0x000a0a0a);//04 16:8:8 ,preTrigTime,  preRfoutTime  afterTrigTime,
	writeBram32(0x00000000);//05 16:16, spare,commTestPacks
	ibuf=0x2580;
	writeBram32(ibuf);//06 12:20., chTimeFineTune,vgTimeDelay
	writeBram32(0x01000100);//07 16:16 chRfTimeDelay,chFiberTimeDelay
	writeBram32(0x00101000);//08 16:8:8 preDataGateWidth,fgaId,sample end


	writeBram32(0x00000191);//09 12:20 wgPulseTimeDelay(vg sub)
	ibuf=ibuf-0x1f16;
	writeBram32(ibuf);//10 12:20 xxx,s1VgTimeDelay
	writeBram32(0x3beb);//11 12:20 xxx,commBaseTime  3de8
	writeBram32(0x27103020);//12 16:16 hostAutoPreDataPri,hostAutoDelayTime
    /*
    wgRepeatEnd<=ibuf[0][31:24];
    wgRfFreq<=ibuf[0][23:16];
    wgPulseWidth<=ibuf[0][4:0];tblInx

    wgPulseFlag<=ibuf[1][31:24];
    wgPri<=ibuf[1][23:0];
    pulseGen datas addr 0x20 end 0x60
    */
	bramAddr = 32*4;
    for(int i=0;i<32;i++){
    	writeBram32(0x002b00c8);//
    	writeBram32(0x00002710);//
    }
	bramAddr = 96*4;
	ibuf=10*150;
    for(int i=0;i<32;i++){
    	writeBram32(ibuf);//low byte = local width, high byte = sync width;
    	ibuf+=100;
    }

}


void transBram(){
	u32 ibuf;
	u8 i8;
	int debug;
	bramAddr = 0;
	writeBram32(radarData.systemStatus0);//mem[0]
	writeBram32(radarData.systemStatus1);//mem[1]
	writeBram32(radarData.systemFlag0);//mem[2]
	writeBram32(radarData.systemFlag1);//mem[3]
	//==================
	ibuf=radarData.afterTrigTime;
	ibuf+=radarData.preRfOutTime<<8;
	ibuf+=radarData.preTrigTime<<16;
	writeBram32(ibuf);//mem[4]
	//===================
	//radarData.laGroupCh=14;//debug<<


	ibuf=radarData.commTestPacks;
	ibuf+=radarData.laGroupCh<<16;
	writeBram32(ibuf);//mem[5]
	ibuf=radarData.vgTimeDelay;//hostVgTimeDelay
	//ibuf+=radarData.chTimeFineTune<<20;
	ibuf+=(256)<<20;//localVgTimeDelay

	writeBram32(ibuf);//mem[6]
	ibuf=radarData.chFiberDelay;
	ibuf+=radarData.chRfDelay<<16;
	writeBram32(ibuf);//mem[7]
	//=================================
	int sampleLen = 0;
	int i=0;
	int endi=32;
	if(radarData.pulseGenCh<32){
		i=radarData.pulseGenCh;
		endi=i+1;
	}
	bramAddr = 32*4;
	for (; i < endi; i++)
	{
		u32 pri=radarData.pulseGenDatasA[8*i]+radarData.pulseGenDatasA[8*i+1]*256;
		pri+=radarData.pulseGenDatasA[8*i+2]*65536+radarData.pulseGenDatasA[8*i+3]*256*65536;
		//
		u16 width=radarData.pulseGenDatasA[8*i+4]+radarData.pulseGenDatasA[8*i+5]*256;
		u8 freq=radarData.pulseGenDatasA[8*i+6];
		u8 times=radarData.pulseGenDatasA[8*i+7]-1;
		//u8 times=0;
		//
		u8 flag = pri>>24;
		if (flag & 1)
		{
			ibuf = (times << 24) + (freq << 16) + width;
			writeBram32(ibuf);
			writeBram32(pri);
			sampleLen++;
		}
	}

	bramAddr = 8 * 4;
	ibuf=sampleLen - 1;
	if(ibuf>31)
		ibuf=0;
	ibuf+=radarData.fpgaId<<8;
	ibuf+=160<<16;//preDataGateWidth
	writeBram32(ibuf);
	//=========================================
	writeBram32(0x00000191);//09 12:20 wgPulseTimeDelay(vg sub)
	ibuf=radarData.vgTimeDelay-0x1f3e;
	writeBram32(ibuf);//10 12:20 xxx,s1VgTimeDelay
	//writeBram32(0x3beb3beb);//11 16:16 hostS2CommBaseTime,hostS1CommBaseTime
	writeBram32(0x3c3b3c3b);//11 16:16 hostS2CommBaseTime,hostS1CommBaseTime
	writeBram32(0x27102710);//12 16:16 hostAutoPreDataPri,hostAutoDelayTime
	//=========================================
	u8 pusleSourceFrom=2	;//0:none 1=sp, 2:local 3:emuSp(local)
	if(radarData.pulseGenCh==254)
		pusleSourceFrom=1;
	if(radarData.pulseGenCh==253)
		pusleSourceFrom=3;

	u8 hostSpType=0;		;//0:sp, 1:emuSp
	u8 syncTxMode=0;		;//0 host, 1:s1Return, 2:bypass, 3:local gen
	u8 wgRxFrom=0;		    ;//0:rf, 1:fiber, 2:local
	u8 subSyncRxFrom=(radarData.systemFlag0>>19)&1;//0:rf,1:fiber
	if(radarData.fpgaId==0){
		syncTxMode=0;
		wgRxFrom=2;
	}
	if(radarData.fpgaId==1){
		syncTxMode=1;
		if((radarData.systemFlag0>>5)&1)
			wgRxFrom=2;
		else
			wgRxFrom=subSyncRxFrom;
	}
	if(radarData.fpgaId==2){
		syncTxMode=2;
		if((radarData.systemFlag0>>6)&1){
			syncTxMode=3;
			wgRxFrom=2;
		}
		else{
			wgRxFrom=1;

		}
		subSyncRxFrom=1;
	}
	if(radarData.fpgaId==3){
		syncTxMode=2;
		wgRxFrom=1;
		subSyncRxFrom=1;

	}
	if(radarData.fpgaId==4){
		syncTxMode=2;
		wgRxFrom=1;
		subSyncRxFrom=1;

	}
	if(radarData.fpgaId==15){
		syncTxMode=2;
		wgRxFrom=1;
		subSyncRxFrom=1;

	}


	//u8 hostS1RxFrom=0;		;//0:rf 1:fiber 2:emu:
	//u8 hostS2RxFrom=0;		;//0:rf 1:fiber 2:emu:
	u8 hostS1RxFrom=(radarData.systemFlag0>>13)&1;
	u8 hostS2RxFrom=(radarData.systemFlag0>>15)&1;

	//u8 sub1ChCommSet=(radarData.systemFlag0>>17)&1;
	//u8 sub2ChCommSet=(radarData.systemFlag0>>18)&1;

	u8 sub1ChCommSet=1;
	u8 sub2ChCommSet=1;



	u8 subCommType=(radarData.systemFlag0>>19)&1;


	u8 emuDelay=0;			;//
	u8 txCon_f=1;
	u8 txSyncClkEn1_f = 0;
	u8 txSyncClkEn2_f = 0;
	//===================================
	/*
	  radiationOn_f:


	*/

	ibuf=(radarData.systemStatus0>>25)&1;
	ibuf+=localPreDataGateOn_f<<1;	//local pulse gen on
	//ibuf+=emuSpPreDataGateOn_f<<2;	//xx
	//ibuf+=syncRxOn_f<<3;			//noUset
	ibuf+=pusleSourceFrom<<4;//0:off 1=sp, 2:local 3:emuSp
	ibuf+=syncTxMode<<6;	//fiber and rf tx mode 0:mast,1:sub,2:ctr.3:endpoint
	ibuf+=hostS1RxFrom<<8;	//0:rf 1:fiber
	ibuf+=hostS2RxFrom<<10; //0:rf 1:fiber
	ibuf+=wgRxFrom<<12;		//0:rf 1:fiber 2:local
	ibuf+=emuDelay<<14;		//emu rx delay type
	ibuf+=txCon_f<<16;
	ibuf+=txSyncClkEn1_f<<17;//enable rf1 clko in
	ibuf+=txSyncClkEn2_f<<18;//enable rf2 clko in
	//ibuf+=subCommType<<19;////0:rf 1:fiber
	ibuf+=subSyncRxFrom<<21;//0:rf 1:fiber
	ibuf+=hostSpType<<22;////0:sp, 1:emuSp
	ibuf+=sub1ChCommSet<<23;
	ibuf+=sub2ChCommSet<<24;

	writeBram32(ibuf);//13 setFlag


	ibuf=0x002b0001;
	writeBram32(ibuf);//14 sp emu txcode0
	ibuf=0x00002710;
	writeBram32(ibuf);//15 sp emu txcode1

	radarData.ctrChDelay=0;//ddd

	ibuf=radarData.meterChDelay;
	ibuf=ibuf*256+radarData.drvChDelay;
	ibuf=ibuf*256+radarData.ctrChDelay;
	ibuf=ibuf*256+radarData.subChDelay;
	writeBram32(ibuf);//16

	ibuf=radarData.hdfo;
	writeBram32(ibuf);//17

	memSaveBuf++;
	bramAddr = 31 * 4;//ram change flag
	writeBram32(memSaveBuf);
	transBram_f=0;


}

void initRadar()
{
	radarData.fpgaId=255;
	radarData.systemStatus0=0;
	radarData.systemStatus1=0;
	for(int i=0;i<12;i++){
	}

	for(int i=0;i<36;i++){
		radarData.sspaPowerStatusAA[i] |= 0x00;
		radarData.sspaModuleStatusAA[i] |= 0x00;
	}


}

void emu_sspaData()
{
	/*
	// u32 ibuf;
	// u32 systemflag;
	// sspaData.systemflag=0x00000000;
	// u16 enviStatus;
	sspaData.enviStatus = 0x0000;

	// u16 fiberStatus;
	sspaData.fiberStatus = 0x0000;
	// u16 sspaCtrStatus;
	sspaData.sspaCtrStatus = 0x0000;

	// u8 attenuator;
	sspaData.attenuator = 31;
	// u8 testMode;
	sspaData.testMode = 0;
	// u8 testItem;
	sspaData.testItem = 0;
	// u8 testResult;
	sspaData.testResult = 0;

	// u16 readyTime;
	if (sspaData.readyTime)
	{
		sspaData.readyTime--;
	}

	//
	for (int i = 0; i < 6; i++)
	{
		sspaData.meterAd[i] += 1;
		if (sspaData.meterAd[i] > 999)
		{
			sspaData.meterAd[i] = 0;
		}
	}
	sspaData.sspaMoniDatasLen = 12;
	for (int i = 0; i < 36; i++)
	{
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 0;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 1;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 2;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 3;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 4;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 5;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 6;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 7;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 8;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 9;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 10;
		sspaData.sspaMoniDatas[i * sspaMoniDatas_size + 0] = 11;
	}
	*/
}


void getSlotInfPrg(){
	if (ud485.txStart_f)
	{
		rsRestTime=0;
		if (ud485.endTxFifo_f)
		{
			if (chkUartTxEmpty(XPAR_UARTLITE_1_BASEADDR))
			{
				ud_endTime = XTmrCtr_GetValue(&timer0Obj, 1);
				ud485.endTx_f = 1;
				ud485.endTxFifo_f = 0;
			}
		}
		else
		{
			if (ud485.endTx_f)
			{
				if ((nowTime - ud_endTime) > 10 * 200)
				{
					ud485.txStart_f = 0;
					ud485.endTx_f = 0;
					outFlag &= 0xfffffff7;
					XGpio_DiscreteWrite(&gpOutAObj, 1, outFlag);
				}
			}
		}
	}
	else
	{
		if (timerFlag & 0x00001000)
			rsRestTime++;
		if (rsRestTime > 40)
		{
			rsRestTime = 0;
			loadUd485Tx(&ud485);
			outFlag |= 0x08; //txEn
			XGpio_DiscreteWrite(&gpOutAObj, 1, outFlag);
			rs_cmd = 0;
			rs_cmd_para0 = 0;
			rs_cmd_para1 = 0;
			rs_cmd_para2 = 0;
			rs_cmd_para3 = 0;
			rs_tx_slotId++;
			if(rs_tx_slotId>=13){
				rs_tx_slotId=1;
			}
		}
	}



}

void interruptHandle(void* callback);
void errorPrg(char* str,int statis ){
	outFlag = 0x00000110;
	XGpio_DiscreteWrite(&gpOutAObj, 1, outFlag);
	while(1){

	}
}
u8 uart0TxBuffer[20];

u8 first_f=1;
u8 warnUpTime=10;


//$main
int main()
{

	int ibuf;
	int status=0;
	init_platform();
	initRadar();





	//if(testBram(1024,256))
	//	errorPrg("testBram Error",1);
	// initial GPIO =======================================
	status=XGpio_Initialize(&gpOutAObj, gpOutADeviceId);
	if(status)
		errorPrg("gpOutAObj Initial Error",status);
	outFlag = 0x00000111;
	XGpio_DiscreteWrite(&gpOutAObj, 1, outFlag);
	//======================================================
	status=XGpio_Initialize(&gpInAObj, gpInADeviceId);
	if(status)
		errorPrg("gpInAObj Initial Error",status);

	// initial timer ========================================
	/*
	status=XTmrCtr_Initialize(&timer0Obj, timer0DeviceId);
	if(status)
		errorPrg("timer0Obj Initial Error",status);
	XTmrCtr_SetOptions(&timer0Obj, 0, XTC_AUTO_RELOAD_OPTION); // enable auto load
	XTmrCtr_Start(&timer0Obj, 0);
	XTmrCtr_SetOptions(&timer0Obj, 1, XTC_AUTO_RELOAD_OPTION); // enable auto load
	XTmrCtr_Start(&timer0Obj, 1);
	*/
    //initial timer ========================================
	status=XTmrCtr_Initialize(&timer0Obj, timer0DeviceId);
	if(status)
		errorPrg("timer0Obj Initial Error",status);
    //set timer option
    XTmrCtr_SetOptions(&timer0Obj, 0,XTC_INT_MODE_OPTION |    //enable interrupt
                                     XTC_AUTO_RELOAD_OPTION | //enable auto load
                                     XTC_DOWN_COUNT_OPTION);  //dec counter
    //set timer value
    XTmrCtr_SetResetValue(&timer0Obj, 0, 8000);//200mhz-5ns
    //set callback process
    //XTmrCtr_SetHandler(&timer0Obj, (XTmrCtr_Handler)timer0InterruptPrg,(void*)TIMER0_BASEADDR);
    //start timer
    XTmrCtr_Start(&timer0Obj, 0);
    XTmrCtr_SetOptions(&timer0Obj, 1,XTC_AUTO_RELOAD_OPTION);//enable auto load
    XTmrCtr_Start(&timer0Obj, 1);

	// initial uart0 ========================================
	status = XUartLite_Initialize(&uart0Obj, uart0DeviceId);
	if(status)
		errorPrg("uart0Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart0Obj);
	if(status)
		errorPrg("uart0Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart0Obj);
	XUartLite_SetRecvHandler(&uart0Obj, uart0RxIntPrg,&uart0Obj);
	//==========
	status = XUartLite_Initialize(&uart1Obj, uart1DeviceId);
	if(status)
		errorPrg("uart1Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart1Obj);
	if(status)
		errorPrg("uart1Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart1Obj);
	XUartLite_SetRecvHandler(&uart1Obj, uart1RxIntPrg,&uart1Obj);
	//==========
	/*
	status = XUartLite_Initialize(&uart3Obj, uart3DeviceId);
	if(status)
		errorPrg("uart3Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart3Obj);
	if(status)
		errorPrg("uart3Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart3Obj);
	//XUartLite_SetSendHandler(&uart3Obj, uart3TxIntPrg,&uart3Obj);
	XUartLite_SetRecvHandler(&uart3Obj, uart3RxIntPrg,&uart3Obj);
	//==========
	status = XUartLite_Initialize(&uart4Obj, uart4DeviceId);
	if(status)
		errorPrg("uart4Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart4Obj);
	if(status)
		errorPrg("uart4Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart4Obj);
	//XUartLite_SetSendHandler(&uart4Obj, uart4TxIntPrg,&uart4Obj);
	XUartLite_SetRecvHandler(&uart4Obj, uart4RxIntPrg,&uart4Obj);
	//==========
	status = XUartLite_Initialize(&uart5Obj, uart5DeviceId);
	if(status)
		errorPrg("uart5Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart5Obj);
	if(status)
		errorPrg("uart5Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart5Obj);
	//XUartLite_SetSendHandler(&uart5Obj, uart5TxIntPrg,&uart5Obj);
	XUartLite_SetRecvHandler(&uart5Obj, uart5RxIntPrg,&uart5Obj);
	//==========
	status = XUartLite_Initialize(&uart6Obj, uart6DeviceId);
	if(status)
		errorPrg("uart6Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart6Obj);
	if(status)
		errorPrg("uart6Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart6Obj);
	//XUartLite_SetSendHandler(&uart6Obj, uart6TxIntPrg,&uart6Obj);
	XUartLite_SetRecvHandler(&uart6Obj, uart6RxIntPrg,&uart6Obj);
	//==========
	*/


	// initial intc0 ========================================
	status = XIntc_Initialize(&intc0Obj, intc0DeviceId);
	if(status)
		errorPrg("intc0Obj Initial Error",status);
	//==============
	status = XIntc_Connect(&intc0Obj, uart0IntVecter,(XInterruptHandler)XUartLite_InterruptHandler,
			       (void *)&uart0Obj);
	if(status)
		errorPrg("intc0Obj connect to uart0 Error",status);
	//==============
	status = XIntc_Connect(&intc0Obj, uart1IntVecter,(XInterruptHandler)XUartLite_InterruptHandler,
			       (void *)&uart1Obj);
	if(status)
		errorPrg("intc1Obj connect to uart1 Error",status);
	//==============================================================
	/*
	status = XIntc_Connect(&intc0Obj, uart3IntVecter,(XInterruptHandler)XUartLite_InterruptHandler,
			       (void *)&uart3Obj);
	if(status)
		errorPrg("intc1Obj connect to uart3 Error",status);
	//==============================================================
	status = XIntc_Connect(&intc0Obj, uart4IntVecter,(XInterruptHandler)XUartLite_InterruptHandler,
			       (void *)&uart4Obj);
	if(status)
		errorPrg("intc1Obj connect to uart4 Error",status);
	//==============================================================
	status = XIntc_Connect(&intc0Obj, uart5IntVecter,(XInterruptHandler)XUartLite_InterruptHandler,
			       (void *)&uart5Obj);
	if(status)
		errorPrg("intc1Obj connect to uart5 Error",status);
	//==============================================================
	status = XIntc_Connect(&intc0Obj, uart6IntVecter,(XInterruptHandler)XUartLite_InterruptHandler,
			       (void *)&uart6Obj);
	if(status)
		errorPrg("intc1Obj connect to uart6 Error",status);
	//==============================================================
	*/

	status = XIntc_Connect(&intc0Obj, timer0IntVecter,(XInterruptHandler)XTmrCtr_InterruptHandler,
			       (void *)&timer0Obj);
	if(status)
		errorPrg("intc1Obj connect to uart1 Error",status);
	//==============================================================



	XIntc_Enable(&intc0Obj, uart0IntVecter);
	XIntc_Enable(&intc0Obj, uart1IntVecter);
	//XIntc_Enable(&intc0Obj, uart3IntVecter);
	//XIntc_Enable(&intc0Obj, uart4IntVecter);
	//XIntc_Enable(&intc0Obj, uart5IntVecter);
	//XIntc_Enable(&intc0Obj, uart6IntVecter);
	XIntc_Enable(&intc0Obj, timer0IntVecter);

	status = XIntc_Start(&intc0Obj, XIN_REAL_MODE);
	if(status)
		errorPrg("intc0Obj start Error",status);

	// initial exception ========================================
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				     (Xil_ExceptionHandler)XIntc_InterruptHandler,&intc0Obj);
	Xil_ExceptionEnable();

	/*
	XIntc_Disconnect(&intc0Obj, uart0IntVecter);
	XIntc_Disconnect(&intc0Obj, uart1IntVecter);
	XIntc_Disconnect(&intc0Obj, uart3IntVecter);
	XIntc_Disconnect(&intc0Obj, uart4IntVecter);
	XIntc_Disconnect(&intc0Obj, uart5IntVecter);
	XIntc_Disconnect(&intc0Obj, uart6IntVecter);
	XIntc_Disconnect(&intc0Obj, timer0IntVecter);
	*/

	//XUartLite_Recv(&uart0Obj, uart0RxBuffer, 8);
	//XUartLite_Send(&uart0Obj, uart0TxBuffer, 8);


	udIpc.fptr = udIpcRxPrg;
	ud485.fptr = ud485RxPrg;
	udFib[0].fptr = udFibRxPrg0;
	udFib[1].fptr = udFibRxPrg1;
	udFib[2].fptr = udFibRxPrg2;
	udFib[3].fptr = udFibRxPrg3;

	udSxSync.fptr = udSxSyncRxPrg;
	udHostS1Sync.fptr = udHostS1SyncRxPrg;
	udHostS2Sync.fptr = udHostS2SyncRxPrg;

	udIpc.id=0;
	ud485.id=1;
	udFib[0].id=2;
	udFib[1].id=3;
	udFib[2].id=4;
	udFib[3].id=5;
	udSxSync.id=6;
	udHostS1Sync.id=7;
	udHostS2Sync.id=8;





	radarData.iZeroTh=10000;
	radarData.iSumShift=5;
	radarData.i32Th=0x6030;
	radarData.i50Th=0x6030;

	initBram();
	localPreDataGateOn_f=0;
	radarData.pulseGenCh=0;
	transBram();
	ledStatus=1;


//mainLoop
	while (1)
	{
		//6.25ns 160mhz
		nowTime = XTmrCtr_GetValue(&timer0Obj, 1);
		if(!first_f){
			u32 loopTime=nowTime-preLoopTime;
			if(loopTime>maxLoopTime)
				maxLoopTime=loopTime;
		}
		preLoopTime=nowTime;
		timerFlag = nowTime ^ timerBuf;
		timerBuf = nowTime;
		if (timerFlag & 0x00008000) // 204.8us
			timerPrg0();
		if (timerFlag & 0x01000000) // 104ms
			timerPrg2();
		if (timerFlag & 0x02000000) // 208ms
			timerPrg3();

		//=======================
		uartTxByte(&udIpc, XPAR_UARTLITE_0_BASEADDR);
		uartRxChk(&udIpc);
		//=======================
		getSlotInfPrg();
		uartTxByte(&ud485, XPAR_UARTLITE_1_BASEADDR);
		uartRxChk(&ud485);
		//=======================
		fibMemTxPrg(&udFib[0]);
		fibMemRxGet(0);
		uartRxChk(&udFib[0]);
		fibMemRxGet(1);
		uartRxChk(&udFib[1]);
		fibMemRxGet(2);
		uartRxChk(&udFib[2]);
		fibMemRxGet(3);
		uartRxChk(&udFib[3]);
		//=======================
		if(radarData.fpgaId==1){
			syncMemTxPrg(&udSxSync,0);
			syncMemRxGet(&udSxSync,0);
			uartRxChk(&udSxSync);
		}
		if(radarData.fpgaId==0){
			syncMemTxPrg(&udHostS1Sync,1);
			syncMemRxGet(&udHostS1Sync,1);
			uartRxChk(&udHostS1Sync);
			//syncMemTxPrg(&udHostS2Sync,2);
			//syncMemRxGet(&udHostS2Sync,2);
			//uartRxChk(&udHostS2Sync);
		}




		if(transBram_f)
			transBram();


		bramAddr=(41)*4;
		ibuf=readBram32();
		if(ibuf!=s1TxStatusBuf){
			s1TxStatusBuf=ibuf;
		}


		/*
		hdfoBuf^=0x00000800;
		bramAddr = 17*4;
		writeBram32(hdfoBuf);//to La 15:3
		*/



		continue;
	}
	cleanup_platform();
	return 0;
}

u32 fibMemTxDoneBuf=0;
u32 fibMemTxStartBuf=0;
u8 fibMemTxTime=0;
void fibMemTxPrg(UartData *udp){
	u32 ibuf;
	u8 data[8];

	//========================================
	if (timerFlag & 0x00004000) // 102 us
		if(fibMemTxTime<99)
			fibMemTxTime++;
	if (!udp->txLen)
		return;
	//========================================
	bramAddr=32*4;
	ibuf=readBram32();
	if(ibuf==fibMemTxDoneBuf){
		if(fibMemTxTime<10)
			return;
	}
	fibMemTxDoneBuf=ibuf;
	//========================================
	for(int i=0;i<8;i++){
		data[i] = udp->txTmp[udp->txCnt];
		udp->txCnt++;
		if (udp->txCnt >= udp->txLen)
		{
			udp->txLen = 0;
			udp->endTxFifo_f = 1;
			udp->endTx_f = 0;
			break;
		}
	}
	//cplLaCh15_3();
	bramAddr=96*4;
	ibuf=(data[3]<<24)+(data[2]<<16)+(data[1]<<8)+data[0];
	writeBram32(ibuf);
	ibuf=(data[7]<<24)+(data[6]<<16)+(data[5]<<8)+data[4];
	writeBram32(ibuf);
	fibMemTxStartBuf++;
	writeBram32(fibMemTxStartBuf);
	fibMemTxTime=0;
}




u32 syncMemTxDoneBuf=0;
u32 syncMemTxStartBuf=0;
u8 syncMemTxTime=0;


//inx 0=sxTx, 1:hostS1Tx and hostS2tx
void syncMemTxPrg(UartData *udp,int inx){
	u32 ibuf;
	u8 data;
	//========================================
	if (timerFlag & 0x00004000){ // 102 us
		if(syncMemTxTime<99)
			syncMemTxTime++;
	}
	if (!udp->txLen)
		return;
	//========================================
	bramAddr=(41+inx)*4;
	ibuf=readBram32();
	if(ibuf==syncMemTxDoneBuf){
		if(syncMemTxTime<10)
			return;
	}
	syncMemTxDoneBuf=ibuf;
	//========================================
	data = udp->txTmp[udp->txCnt];
	udp->txCnt++;
	if (udp->txCnt >= udp->txLen)
	{
		udp->txLen = 0;
		udp->endTxFifo_f = 1;
		udp->endTx_f = 0;
	}
	bramAddr=(100+inx)*4;
	syncMemTxStartBuf++;
	ibuf=data;
	ibuf+=syncMemTxStartBuf<<24;
	writeBram32(ibuf);
	syncMemTxTime=0;


}

void cplLaCh15_3(void){
	hdfoBuf^=0x00000800;
	bramAddr = 17*4;
	writeBram32(hdfoBuf);//to La 15:3
}

void cplLaCh15_2(void){
	hdfoBuf^=0x00000400;
	bramAddr = 17*4;
	writeBram32(hdfoBuf);//to La 15:3
}

void setLaCh15_2(u8 flag){
	if(flag==1)
		hdfoBuf|=0x00000400;
	else
		hdfoBuf&=0xfffffbff;
	bramAddr = 17*4;
	writeBram32(hdfoBuf);//to La 15:3
}


/*
 	udIpc.id=0;
	ud485.id=1;
	udFib[0].id=2;
	udFib[1].id=3;
	udFib[2].id=4;
	udFib[3].id=5;
	udSxSync.id=6;
	udHostS1Sync.id=7;
	udHostS2Sync.id=8;

 */


void uartRxChk(UartData *udp){
	int ddd=0;
	if(udp->id==6)
		ddd=6;
	while(udp->rxStackPtr1!=udp->rxStackPtr0){
		revData=udp->rxStack[udp->rxStackPtr1];
		uartByteDec(udp,revData);
		udp->rxStackPtr1++;
		if(udp->rxStackPtr1>=rxStackBufferSize_k)
			udp->rxStackPtr1=0;
	}
}





void uartByteDec(UartData *udp,u8 revData){

	int j;
	int len;
	int chksum0, chksum1;

	/*
	int ddd=0;
 	if(udp->id==3){
		ddd=1;
		cplLaCh15_3();

 	}
 	*/



	if (revData == 0xEA)
	{
		udp->rxBufferCnt = 0;
		udp->spcChar_f = 0;
		return;
	}
	if (revData == 0xEC)
	{
		udp->spcChar_f = 1;
		return;
	}
	if (revData != 0xEB)
	{
		if (udp->rxBufferCnt < sizeof(udp->rxBuffer))
		{
			if (udp->spcChar_f)
				udp->rxBuffer[udp->rxBufferCnt] = revData ^ 0xAB;
			else
				udp->rxBuffer[udp->rxBufferCnt] = revData;
			udp->spcChar_f = 0;
			udp->rxBufferCnt++;
		}
		return;
	}
	udp->spcChar_f = 0;
	len = udp->rxBufferCnt - 2;
	//==================================




	chksum0 = 0xab;
	chksum1 = 0;
	for (j = 0; j < len; j++)
	{
		chksum0 ^= udp->rxBuffer[j];
		chksum1 += udp->rxBuffer[j];
	}
	if ((chksum0 ^ udp->rxBuffer[j]) & 0xff)
		return;
	j++;
	if ((chksum1 ^ udp->rxBuffer[j]) & 0xff)
		return;



	udp->rxBufferLen = len;
	udp->fptr(udp);

}

//========================================================
int uartTxByte(UartData *udp, u32 baseAddr)
{
	if (!udp->txLen)
		return 0;
	if (XUartLite_IsTransmitFull(baseAddr))
		return 0;
	u8 data = udp->txTmp[udp->txCnt];
	XUartLite_WriteReg(baseAddr, XUL_TX_FIFO_OFFSET, data);
	udp->txCnt++;
	if (udp->txCnt >= udp->txLen)
	{
		udp->txLen = 0;
		udp->endTxFifo_f = 1;
		udp->endTx_f = 0;
	}
	return 1;
}



int chkUartTxEmpty(u32 baseAddr)
{
	u32 flag = XUartLite_GetStatusReg(baseAddr);
	return (flag & XUL_SR_TX_FIFO_EMPTY);
}



// 160mhx 203.83us
u8 test1Cnt=0;

void timerPrg0()
{
	u8 buf=0;
	shTime++;
	if(shTime>=6)
		shTime=0;
	if(shTime==0){
		inFlag=XGpio_DiscreteRead(&gpInAObj, 1);
		if(inFlag&0x04)
			buf |=0x01;
		if(inFlag&0x08)
			buf |=0x02;
		if(inFlag&0x100)
			buf |=0x04;
		if(inFlag&0x200)
			buf |=0x08;
		//buf=15;//<<debug
		//buf=4;//<<debug
		radarData.fpgaId=buf;

		if((ctrConnectTime&0x8000)==0)
			ctrConnectTime++;

		slotAdr=0;
		if(inFlag&0x80)
			slotAdr |=0x01;
		if(inFlag&0x40)
			slotAdr |=0x02;
		if(inFlag&0x20)
			slotAdr |=0x04;
		if(inFlag&0x10)
			slotAdr |=0x08;
		//slotAdr=11;//<<debug


		radarData.systemStatus0 &= 0xfffffffc;
		if(warnUpTime==0)
			radarData.systemStatus0 |= 2;
		else
			radarData.systemStatus0 |= 1;


		if(slotAdr<12){
			radarData.slotDataAA[slotAdr]&=0xfc00;
			radarData.slotDataAA[slotAdr]|=0x0202;
			noRxTimeA[slotAdr]=0;
		}
		return;
	}
	if(shTime==1){
		if(udIpc.txLen)
			tickFatherTime=0;
		tickFatherTime++;
		if(tickFatherTime<5)
			return;
		tickFatherTime=0;
		loadUdIpcTx();
	}
	if(shTime==2){
		encUartTx(&udIpc);
	}
	if(shTime==3){
		for(int i=0;i<12;i++){
			noRxTimeA[i]=noRxTimeA[i]+1;
			if(noRxTimeA[i]>500)
				radarData.slotDataAA[i]=0;

		}
	}
	if(shTime==4){
		if (udFib[0].txLen)
			return;
		if(radarData.fpgaId==1)
			loadTickSub(&udFib[0]);
		if(radarData.fpgaId==2)
			loadTickCtr(&udFib[0]);
		if(radarData.fpgaId==3)
			loadTickDrv(&udFib[0]);
		if(radarData.fpgaId==4)
			loadTickDrv(&udFib[0]);
		if(radarData.fpgaId==15)
			loadTickMeter(&udFib[0]);
		encUartTx(&udFib[0]);
	}

	if(shTime==5){

		if(radarData.fpgaId==1){
			if(udSxSync.txLen==0){
				loadSyncStatus(&udSxSync,0);
				encUartTx(&udSxSync);
				/*
				UartData *udp=&udSxSync;
				udp->txLen = 0;
				encmst(udp, 0x12, 0);
				encmst(udp, 0x34, 0);
				encmst(udp, 0x56, 0);
				encmst(udp, 0x78, 0);
				udp->txCnt = 0;
				*/




			}
		}
		if(radarData.fpgaId==0){
			if(udHostS1Sync.txLen==0){
				loadSyncStatus(&udHostS1Sync,1);//<<debug
				encUartTx(&udHostS1Sync);
				/*
				test1Cnt++;
				if(test1Cnt<10)
					return;
				test1Cnt=0;
				UartData *udp=&udHostS1Sync;
				udp->txLen = 0;
				encmst(udp, 0x12, 0);
				encmst(udp, 0x34, 0);
				encmst(udp, 0x56, 0);
				encmst(udp, 0x78, 0);
				udp->txCnt = 0;
				*/




			}
		}
	}




}

// 250mhx 1.048ms
void timerPrg1()
{
}

// 104ms
void timerPrg2()
{
	//ddd
		debugCnt++;
		if(debugCnt>10)
			first_f=0;
		if(selfTest_f){
			selfTestCnt++;
			if(selfTestCnt==20){
				radarData.slotDataAA[slotAdr] &= (0xf3ff);
				selfTest_f=0;
				ledStatus=2;
			}

		}

		if(radarData.fpgaId==1){
			noSyncConTime++;
			if(noSyncConTime>10)
				radarData.commOkRateA[0]=0;

		}
		if(radarData.fpgaId==15){
			noMeterMcuTime++;
			if(noMeterMcuTime>=10){
				radarData.meterStatusAA[0]=0xffff;
				radarData.meterStatusAA[1]=0xffff;
				radarData.meterStatusAA[2]=0xffff;
				radarData.meterStatusAA[3]=0xffff;
				radarData.meterStatusAA[4]=0xffff;
				radarData.meterStatusAA[5]=0xffff;
				//radarData.systemStatus1&=(3<<20)^0xffffffff;
				noMeterMcuTime=0;
			}
		}

		if(radarData.fpgaId==2){
			noMeterFpgaTime++;
			if(noMeterFpgaTime>=10){
				radarData.meterStatusAA[0]=0xffff;
				radarData.meterStatusAA[1]=0xffff;
				radarData.meterStatusAA[2]=0xffff;
				radarData.meterStatusAA[3]=0xffff;
				radarData.meterStatusAA[4]=0xffff;
				radarData.meterStatusAA[5]=0xffff;
				//radarData.systemStatus1&=(3<<20)^0xffffffff;
				noMeterFpgaTime=0;
			}
		}




}


//outFlag.0 ledR
//outFlag.1 ledG
//outFlag.2 ledB
//outFlag.3 rsDe
//outFlag.7 rsDe
//ledStatus=0 none,1: warmup, 2:ok, 3:err, 4:preTest,5:testing

//208ms
void timerPrg3()
{
	outFlag|=0x07;
	outFlag^=0x80;
	flash_f^=1;
	if(ledStatus==1){
		outFlag&=0xfd;
	}
	if(ledStatus==2){
		if(flash_f)
			outFlag&=0xfd;
	}
	if(ledStatus==3){
		outFlag&=0xfe;
	}
	if(ledStatus==4){
		outFlag&=0xfb;
	}
	if(ledStatus==5){
		if(flash_f)
			outFlag&=0xfb;
	}
	XGpio_DiscreteWrite(&gpOutAObj, 1, outFlag);
	//print("\ntimerPrg3");
	if(warnUpTime){
		warnUpTime--;
		if(warnUpTime==0){
			radarData.systemStatus0 &= 0xfffffffc;
			radarData.systemStatus0 |= 2;
			ledStatus=2;
			//===============
			radarData.pulseGenCh=0;
			localPreDataGateOn_f=0;
			transBram();
		}
	}
	for(u8 i=0;i<36;i++){
		drvDataClrBuf[i]++;
		if(drvDataClrBuf[i]>=10){
			radarData.sspaPowerStatusAA[i]=0x00;
		}

	}
	hdfoCnt++;
	if(hdfoCnt>=10){
		hdfoCnt=0;
		hdfoBuf^=0x7f;
		bramAddr = 17*4;
		writeBram32(hdfoBuf);//mem[0]
	}

	gpsDataClrTime++;
	if(gpsDataClrTime>=10){
		radarData.gpsDataA[0][0]=0;
	}





}




// return err_f;



int testBram(int addr, int len)
{
	int ibuf;
	int data;
	bramAddr = addr;
	data = 0x12345678;
	for (int i = 0; i < len; i++)
	{
		writeBram32(data);
		data += 0x11111111;
	}
	bramAddr = addr;
	data = 0x12345678;
	for (int i = 0; i < len; i++)
	{
		ibuf = readBram32();
		if (ibuf != data)
			return 1;
		data += 0x11111111;
	}
	return 0;
}










void loadTickDrv(){
	int fpgaId=radarData.fpgaId;
	udFib[0].txSerialCnt++;
	udFib[0].txDeiceId = myDeviceId;
	udFib[0].txSerialId = mySerialId;
	udFib[0].txGroupId=0xab00;
	udFib[0].txCmd = 0x1000;	//tick
	udFib[0].txPara0 =fpgaId;
	udFib[0].txPara1 = udFib[0].txSerialCnt;
	if(fpgaId==3)
		udFib[0].txPara2 = radarData.conRxCntA[5]*256+radarData.conRxCntA[4];
	else
		udFib[0].txPara2 = radarData.conRxCntA[9]*256+radarData.conRxCntA[8];
	udFib[0].txPara3 = 0;
	udFib[0].txBufferLen = 0;
	//
	int inx=0;
	for(int i=0;i<12;i++){
		udFib[0].txBuffer[inx++]=radarData.slotDataAA[i]&255;
		udFib[0].txBuffer[inx++]=radarData.slotDataAA[i]>>8;
	}
	//
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udFib[0].txBuffer[inx++]=(radarData.systemStatus1)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus1>>24)&255;

//%1
	if(udFib[0].txPackItemCnt0>=36)
		udFib[0].txPackItemCnt0=0;
	u8 itemCnt=udFib[0].txPackItemCnt0;
	u8 sta=radarData.sspaPowerStatusAA[itemCnt];

	if(itemCnt>=0 && itemCnt<36){
		sta=1;


	}
	if(sta&1){
		udFib[0].txBuffer[inx++]=0xab;
		udFib[0].txBuffer[inx++]=udFib[0].txPackItemCnt0;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerStatusAA[itemCnt];
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV50vAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV50vAA[itemCnt]>>8;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV50iAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV50iAA[itemCnt]>>8;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV50tAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV50tAA[itemCnt]>>8;

		udFib[0].txBuffer[inx++]=radarData.sspaPowerV32vAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV32vAA[itemCnt]>>8;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV32iAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV32iAA[itemCnt]>>8;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV32tAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaPowerV32tAA[itemCnt]>>8;

		udFib[0].txBuffer[inx++]=radarData.sspaModuleStatusAA[itemCnt];
		udFib[0].txBuffer[inx++]=radarData.sspaModuleRfOutAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaModuleRfOutAA[itemCnt]>>8;
		udFib[0].txBuffer[inx++]=radarData.sspaModuleTemprAA[itemCnt]&255;
		udFib[0].txBuffer[inx++]=radarData.sspaModuleTemprAA[itemCnt]>>8;

	}

	udFib[0].txPackItemCnt0++;
	//===================================
	udFib[0].txBuffer[inx++]=0xcd;//check end
	udFib[0].txBufferLen = inx;
}



void loadTickMeter(){
	int fpgaId=radarData.fpgaId;
	udFib[0].txSerialCnt++;
	udFib[0].txDeiceId = myDeviceId;
	udFib[0].txSerialId = mySerialId;
	udFib[0].txGroupId=0xab00;
	udFib[0].txCmd = 0x1000;	//tick
	udFib[0].txPara0 =	fpgaId;

	udFib[0].txPara1 = udFib[0].txSerialCnt;
	udFib[0].txPara2 = radarData.conRxCntA[13]*256+radarData.conRxCntA[12];
	udFib[0].txPara3 = 0;
	udFib[0].txBufferLen = 0;
	//
	int inx=0;
	//
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udFib[0].txBuffer[inx++]=(radarData.systemStatus1)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udFib[0].txBuffer[inx++]=(radarData.systemStatus1>>24)&255;


	//=============================================
	udFib[0].txBuffer[inx++]=0xaa;
	udFib[0].txBuffer[inx++]=16;
	for(int i=0;i<8;i++){
		udFib[0].txBuffer[inx++]=radarData.meterStatusAA[i]&255;
		udFib[0].txBuffer[inx++]=radarData.meterStatusAA[i]>>8;
	}
	//==============================================
	udFib[0].txBuffer[inx++]=0xcd;//check end
	udFib[0].txBufferLen = inx;
}




void loadTickSub(UartData *udp){
	int fpgaId=radarData.fpgaId;
	udp->txSerialCnt++;
	udp->txDeiceId = myDeviceId;
	udp->txSerialId = mySerialId;
	udp->txGroupId=0xab00;
	udp->txCmd = 0x1000;	//tick
	udp->txPara0 =fpgaId;
	udp->txPara1 = udp->txSerialCnt;
	udp->txPara2 = radarData.conRxCntA[7]*256+radarData.conRxCntA[6];
	udp->txPara3 = 0;
	int inx=0;//18
	udp->txBuffer[inx++]=(radarData.systemStatus0)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>24)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>24)&255;
	//==================
	udp->txBuffer[inx++]=(fiber_cmd)&255;
	udp->txBuffer[inx++]=(fiber_cmd>>8)&255;
	udp->txBuffer[inx++]=(fiber_cmd_para0)&255;
	udp->txBuffer[inx++]=(fiber_cmd_para0>>8)&255;
	fiber_cmd=0;
	//==================
	udp->txBuffer[inx++]=0xcd;
	udp->txBuffer[inx++]=0xab;
	udp->txBufferLen = inx;

}




//;id=0:sx, 1:host

void loadIntBytes(u8 *bytes,int inx,int vv){
	bytes[inx++]=vv&255;
	bytes[inx++]=(vv>>8)&255;
	bytes[inx++]=(vv>>16)&255;
	bytes[inx++]=(vv>>24)&255;
}
void loadShortBytes(u8 *bytes,int inx,int vv){
	bytes[inx++]=vv&255;
	bytes[inx++]=(vv>>8)&255;
}

void loadSyncStatus(UartData *udp,int id){
	int fpgaId=radarData.fpgaId;
	udp->txSerialCnt++;
	udp->txDeiceId = myDeviceId;
	udp->txSerialId = mySerialId;
	udp->txGroupId=0xab00;
	udp->txCmd = 0x3000;	//tick
	udp->txPara0 =fpgaId;
	udp->txPara1 = udp->txSerialCnt;
	udp->txPara2 = syncDataPackCnt[1]*256+syncDataPackCnt[0];
	udp->txPara3 = syncDataPackCnt[2];;//sub inx
	int inx=0;//18
	if(fpgaId==0){
		udp->txBuffer[inx++]=(nextCmd)&255;
		udp->txBuffer[inx++]=(nextCmd>>8)&255;
		udp->txBuffer[inx++]=(nextCmdPara0)&255;
		udp->txBuffer[inx++]=(nextCmdPara0>>8)&255;
		udp->txBuffer[inx++]=(radarData.commOkRateA[0])&255;
		udp->txBuffer[inx++]=(radarData.commOkRateA[0]>>8);
		udp->txBuffer[inx++]=(radarData.commOkRateA[1])&255;
		udp->txBuffer[inx++]=(radarData.commOkRateA[1]>>8)&255;
		if(udp->txPackItemCnt0>=3)
			udp->txPackItemCnt0=0;
		int ii=udp->txPackItemCnt0;
		udp->txBuffer[inx++]=ii+0xad;
		udp->txBuffer[inx++]=radarData.gpsDataLen[ii];
		for(int j=0;j<radarData.gpsDataLen[ii];j++){
			udp->txBuffer[inx++]=radarData.gpsDataA[ii][j];
		}
		udp->txPackItemCnt0++;
		nextCmdTimes++;
		if(nextCmdTimes>10){
			nextCmd=0;
		}
	}
	if(fpgaId==1){
		radarData.subStatusA[0]=0x2000;//connect flag
		if((radarData.systemFlag0>>19)&1)//connectType
			radarData.subStatusA[0]+=1<<5;
		if(radarData.systemStatus1&0x00000080)//all envi err
			radarData.subStatusA[0]|=0x0001;
		if(radarData.systemStatus1&0x00000100)//sspa power err
			radarData.subStatusA[0]|=0x0002;
		if(radarData.systemStatus1&0x00000200)//sspa module err
			radarData.subStatusA[0]|=0x0004;
		if(radarData.systemStatus1&0x00000c00)//over width and over duty
			radarData.subStatusA[0]|=0x0008;
		if(radarData.systemStatus1&0x00002000)//meter err
			radarData.subStatusA[0]|=0x0010;
		if(radarData.systemFlag0 &0x00080000)//connectType
			radarData.subStatusA[0]|=0x0020;

		if(radarData.systemFlag0&0x00000020)//pulse from
			radarData.subStatusA[0]|=0x0040;

		if(radarData.systemStatus1&0x00100000)//out type
			radarData.subStatusA[0]|=0x0080;
		if(radarData.systemStatus1&0x00400000)//bat short
			radarData.subStatusA[0]|=0x0100;
		if(radarData.systemStatus0&0x00800000)//sspa power
			radarData.subStatusA[0]|=0x0200;
		if(radarData.systemStatus0&0x01000000)//sspa module
			radarData.subStatusA[0]|=0x0400;
		if(radarData.systemStatus0&0x02000000)//pulse out en
			radarData.subStatusA[0]|=0x0800;
		if(radarData.systemStatus0&0x04000000)//emergency
			radarData.subStatusA[0]|=0x1000;
		if(radarData.systemStatus1&0x40000000)//ctr remote enable xxxx<<debug
			radarData.subStatusA[0]|=0x2000;
		if(ctrConnectTime<1000)
			radarData.subStatusA[0]|=0x8000;
		//============================================
		int subStatus=radarData.subStatusA[0];
		udp->txBuffer[inx++]=(subStatus)&255;
		udp->txBuffer[inx++]=(subStatus>>8)&255;
		udp->txBuffer[inx++]=(subStatus>>16)&255;
		udp->txBuffer[inx++]=(subStatus>>24)&255;
		udp->txBuffer[inx++]=0xad;
		udp->txBuffer[inx++]=radarData.gpsDataLen[0];
		for(int j=0;j<radarData.gpsDataLen[0];j++){
			udp->txBuffer[inx++]=radarData.gpsDataA[0][j];
		}
	}


	udp->txBuffer[inx++]=0xcd;
	udp->txBuffer[inx]=inx+18;
	inx++;
	udp->txBufferLen = inx;

}






void loadTickCtr(UartData *udp){
	int ibuf;
	int fpgaId=radarData.fpgaId;
	udp->txSerialCnt++;
	udp->txDeiceId = myDeviceId;
	udp->txSerialId = mySerialId;
	udp->txGroupId=0xab00;
	udp->txCmd = 0x1000;	//tick
	udp->txPara0 =fpgaId;
	udp->txPara1 = udp->txSerialCnt;
	udp->txPara2 = radarData.conRxCntA[1]*256+radarData.conRxCntA[0];
	udp->txPara3 = 0;
	int inx=0;//18
	udp->txBuffer[inx++]=(radarData.systemStatus0)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udp->txBuffer[inx++]=(radarData.systemStatus1)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>24)&255;
	//28
	udp->txBuffer[inx++]=(radarData.systemFlag0)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag0>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag0>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag0>>24)&255;

	udp->txBuffer[inx++]=(radarData.systemFlag1)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag1>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag1>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag1>>24)&255;
	//==================36
	udp->txBuffer[inx++]=(radarData.afterTrigTime)&255;
	udp->txBuffer[inx++]=(radarData.preRfOutTime)&255;
	udp->txBuffer[inx++]=(radarData.preTrigTime)&255;
	udp->txBuffer[inx++]=(radarData.preTrigTime>>8)&255;
	//==================
	udp->txBuffer[inx++]=(radarData.laGroupCh)&255;

	udp->txBuffer[inx++]=(radarData.vgTimeDelay)&255;
	udp->txBuffer[inx++]=(radarData.vgTimeDelay>>8)&255;
	udp->txBuffer[inx++]=(radarData.chTimeFineTune)&255;
	udp->txBuffer[inx++]=(radarData.chTimeFineTune>>8)&255;
	//==================45
	udp->txBuffer[inx++]=0x00;
	udp->txBuffer[inx++]=0x00;
	udp->txBuffer[inx++]=(radarData.commChDelay)&255;
	udp->txBuffer[inx++]=(radarData.commChDelay>>8)&255;
	//==================49
	udp->txBuffer[inx++]=radarData.meterChDelay;
	udp->txBuffer[inx++]=radarData.drvChDelay;
	udp->txBuffer[inx++]=radarData.ctrChDelay;
	udp->txBuffer[inx++]=radarData.subChDelay;
	udp->txBuffer[inx++]=radarData.wgFreqCh;
	udp->txBuffer[inx++]=radarData.attenuator;
	//==================55
	udp->txBuffer[inx++]=(nextCmd)&255;
	udp->txBuffer[inx++]=(nextCmd>>8)&255;
	udp->txBuffer[inx++]=(nextCmdPara0)&255;
	udp->txBuffer[inx++]=(nextCmdPara0>>8)&255;
	udp->txBuffer[inx++]=(nextCmdPara1)&255;
	udp->txBuffer[inx++]=(nextCmdPara1>>8)&255;
	udp->txBuffer[inx++]=(nextCmdPara2)&255;
	udp->txBuffer[inx++]=(nextCmdPara2>>8)&255;
	udp->txBuffer[inx++]=(nextCmdPara3)&255;
	udp->txBuffer[inx++]=(nextCmdPara3>>8)&255;
	nextCmd=0;
	//==================65
	udp->txBuffer[inx++]=0xcd;
	udp->txBuffer[inx++]=0xab;
	udp->txBufferLen = inx;

	chkSspaCnt++;
	if(chkSspaCnt>36)
		chkSspaCnt=0;
	if(chkSspaCnt==0){
		sspaPowerOn_f=0;
		sspaModuleOn_f=0;
		ibuf=(radarData.systemFlag0>>7)&1;//battleShort
		ibuf<<=22;
		ibuf=radarData.systemStatus1^ibuf;
		ibuf&=1<<22;
		radarData.systemStatus1^=ibuf;

		ibuf=(radarData.systemFlag0>>8)&1;//antLoad
		ibuf<<=20;
		ibuf=radarData.systemStatus1^ibuf;
		ibuf&=1<<20;
		radarData.systemStatus1^=ibuf;




	}
	if(radarData.sspaPowerStatusAA[chkSspaCnt]&0x10)
		sspaPowerOn_f=1;
	//if(radarData.sspaModuleStatusAA[chkSspaCnt]&0x2)
	//	sspaModuleOn_f=1;
	if(chkSspaCnt==35){
		ibuf=sspaPowerOn_f<<23;
		ibuf=radarData.systemStatus0^ibuf;
		ibuf&=1<<23;
		radarData.systemStatus0^=ibuf;
		//ibuf=sspaModuleOn_f<<24;
		//ibuf=radarData.systemStatus0^ibuf;
		//ibuf&=1<<24;
		//radarData.systemStatus0^=ibuf;
	}


}






















//====================================================================================
void uart0RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_0_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	udIpc.rxStack[udIpc.rxStackPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	udIpc.rxStackPtr0++;
	if(udIpc.rxStackPtr0>=rxStackBufferSize_k)
		udIpc.rxStackPtr0=0;

}

void uart1RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_1_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	rsRestTime=0;
	ud485.rxStack[ud485.rxStackPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	ud485.rxStackPtr0++;
	if(ud485.rxStackPtr0>=rxStackBufferSize_k)
		ud485.rxStackPtr0=0;

}



u32 syncMemRxCntp[3];
//inx 0=sxRxfromeHost, 1:hostRxFromS1, 1:hostRxFromS2
u32 preSxRxBuf;
void syncMemRxGet(UartData *udp,int inx){
	u32 ibuf;
	u32 data;
	bramAddr=(43+inx)*4;
	ibuf=readBram32();
	setLaCh15_2(ibuf&1);//<<debug
	syncMemRxCntp[inx]&=0x1f;	//stack is 32
	if(ibuf==syncMemRxCntp[inx]){
		return;
	}
	bramAddr=((160+inx*32)+syncMemRxCntp[inx])*4;
	data=readBram32();
	syncMemRxCntp[inx]+=1;

	if(data&0x100)//none data
		return;

	if(inx==0){
		ibuf=preSxRxBuf^data;
		ibuf&=0xc000;
		if(!ibuf){
			return;
		}
		preSxRxBuf=data;
	}

	/*
	rxTestBuf[rxTestBufCnt]=data;
	rxTestBufCnt++;
	if(rxTestBufCnt>=64)
		rxTestBufCnt=0;
	cplLaCh15_3();
	*/

	udp->rxStack[udp->rxStackPtr0] = data;
	udp->rxStackPtr0++;
	if(udp->rxStackPtr0>=rxStackBufferSize_k){
		udp->rxStackPtr0=0;
	}
	//cplLaCh15_2();



}



u32 fiberBRxDoneBuf[4];
u8  fiberBRxCntA[4];
void fibMemRxGet(int inx){
	u32 ibuf;
	u32 data[2];
	bramAddr=(16+inx*4)*4;
	ibuf=readBram32();
	fiberBRxCntA[inx]=ibuf;
	if(ibuf==fiberBRxDoneBuf[inx]){
		return;
	}
	data[0]=readBram32();
	data[1]=readBram32();
	fiberBRxDoneBuf[inx]=ibuf;
	for(int i=0;i<8;i++){
		int sh=(i&3)*8;
		int byteCnt=i/4;
		udFib[inx].rxStack[udFib[inx].rxStackPtr0] = data[byteCnt]>>sh;
		udFib[inx].rxStackPtr0++;
		if(udFib[inx].rxStackPtr0>=rxStackBufferSize_k)
			udFib[inx].rxStackPtr0=0;
	}
}
//====================================================================================










void loadUdIpcTx(){
	int ibuf;
	int fpgaId=radarData.fpgaId;

	//ddd


	UartData *udp;
	udp=&udIpc;

	udp->txSerialCnt++;
	udp->txDeiceId = myDeviceId;
	udp->txSerialId = mySerialId;
	udp->txGroupId=0xab00;
	udp->txCmd = 0x1000;	//tick
	udp->txPara0 =fpgaId;
	udp->txPara1 = udp->txSerialCnt;
	udp->txPara2 = 0;
	udp->txPara3 = 0;
	udp->txBufferLen = 0;
	//
	int inx=0;
	for(int i=0;i<12;i++){
		udp->txBuffer[inx++]=radarData.slotDataAA[i]&255;
		udp->txBuffer[inx++]=radarData.slotDataAA[i]>>8;
	}
	//
	udp->txBuffer[inx++]=(radarData.systemStatus0)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udp->txBuffer[inx++]=(radarData.systemStatus1)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>24)&255;

	udp->txBuffer[inx++]=(ipcCmd)&255;
	udp->txBuffer[inx++]=(ipcCmd>>8)&255;
	udp->txBuffer[inx++]=(ipcCmdPara)&255;
	udp->txBuffer[inx++]=(ipcCmdPara>>8)&255;
	ipcCmd=0;
	//=====================================================================
	if(fpgaId==0){
		//gps data
		if(udp->txPackItemCnt0>=3)
			udp->txPackItemCnt0=0;
		int ii=udp->txPackItemCnt0;
		udp->txBuffer[inx++]=ii+0xad;
		udp->txBuffer[inx++]=radarData.gpsDataLen[ii];
		for(int j=0;j<radarData.gpsDataLen[ii];j++){
			udp->txBuffer[inx++]=radarData.gpsDataA[ii][j];
		}
		udp->txPackItemCnt0++;
		//view datas
		if(udp->txPackItemCnt1>=6)
			udp->txPackItemCnt1=0;
		udp->txBuffer[inx++]=0xac;
		udp->txBuffer[inx++]=udp->txPackItemCnt1;
		bramAddr = udp->txPackItemCnt1*8*4;
		for(int i=0;i<8;i++){
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
		}
		udp->txPackItemCnt1++;
		//====================================

		bramAddr=37*4;
		u32 pcnt=readBram32();
		udp->txBuffer[inx++]=0xb0;
		int lenInx=inx;
		udp->txBuffer[inx++]=0;
		for(;;){
			int ichg=(prePulseCnt^pcnt)&31;
			if(ichg==0)
				break;
			bramAddr=((prePulseCnt&31)+128)*4;
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
			udp->txBuffer[lenInx]=udp->txBuffer[lenInx]+1;
			prePulseCnt++;
		}
		//===================================
		udp->txBuffer[inx++]=0xb1;
		udp->txBuffer[inx++]=10;
		bramAddr=38*4;
		ibuf = readBram32();//now wgRfoutPeriod low period time, unit 6.25ns
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		udp->txBuffer[inx++]=(ibuf>>16)&255;
		udp->txBuffer[inx++]=(ibuf>>24)&255;
		ibuf = readBram32();//now wgRfoutPeriod high period time, unit 6.25ns
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		udp->txBuffer[inx++]=(ibuf>>16)&255;
		udp->txBuffer[inx++]=(ibuf>>24)&255;
		ibuf = readBram32();//[5:0]:now wdRfoutFreq, 2.9G~3.49G, [15:8]s1rxPackCnt
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		//===================================

		bramAddr=6*4;
		ibuf = readBram32();//
		radarData.conRxCntA[0]=ibuf>>16;
		radarData.commOkRateA[0]=ibuf&0xffff;

		bramAddr=14*4;
		ibuf = readBram32();//
		radarData.conRxCntA[2]=ibuf>>16;
		radarData.commOkRateA[1]=ibuf&0xffff;



		//view rxCntA
		udp->txBuffer[inx++]=0xb2;
		udp->txBuffer[inx++]=10;
		udp->txBuffer[inx++]=radarData.conRxCntA[0];
		udp->txBuffer[inx++]=radarData.conRxCntA[1];
		udp->txBuffer[inx++]=radarData.conRxCntA[2];
		udp->txBuffer[inx++]=radarData.conRxCntA[3];
		udp->txBuffer[inx++]=radarData.conRxCntA[4];
		udp->txBuffer[inx++]=radarData.conRxCntA[5];
		udp->txBuffer[inx++]=radarData.conRxCntA[6];
		udp->txBuffer[inx++]=radarData.conRxCntA[7];
		udp->txBuffer[inx++]=radarData.conRxCntA[16];
		udp->txBuffer[inx++]=radarData.conRxCntA[17];

		//====================================
		udp->txBuffer[inx++]=0xb3;
		udp->txBuffer[inx++]=4;
		udp->txBuffer[inx++]=radarData.commOkRateA[0]&255;
		udp->txBuffer[inx++]=radarData.commOkRateA[0]>>8;
		udp->txBuffer[inx++]=radarData.commOkRateA[1]&255;
		udp->txBuffer[inx++]=radarData.commOkRateA[1]>>8;
		//==========================================

		udp->txBuffer[inx++]=0xb4;
		udp->txBuffer[inx++]=12;
		for(int i=0;i<6;i++){
			udp->txBuffer[inx++]=radarData.ioInA[i]&255;
			udp->txBuffer[inx++]=radarData.ioInA[i]>>8;
		}

		udp->txBuffer[inx++]=0xb5;
		udp->txBuffer[inx++]=8;
		for(int i=0;i<2;i++){
			udp->txBuffer[inx++]=radarData.subStatusA[i];
			udp->txBuffer[inx++]=radarData.subStatusA[i]>>8;
			udp->txBuffer[inx++]=radarData.subStatusA[i]>>16;
			udp->txBuffer[inx++]=radarData.subStatusA[i]>>32;
		}


		udp->txBuffer[inx++]=0xcd;//check end
		udp->txBufferLen = inx;
		return;
	}
	if(fpgaId==1){
		//gps data
		//if(radarData.gpsDataLen[0]){
		udp->txBuffer[inx++]=0xad;
		udp->txBuffer[inx++]=radarData.gpsDataLen[0];
		for(int j=0;j<radarData.gpsDataLen[0];j++){
			udp->txBuffer[inx++]=radarData.gpsDataA[0][j];
		}
		//}
		//====================================
		//view datas
		if(udp->txPackItemCnt1>=8)
			udp->txPackItemCnt1=0;
		udp->txBuffer[inx++]=0xac;
		udp->txBuffer[inx++]=udp->txPackItemCnt1;
		bramAddr = udp->txPackItemCnt1*8*4;
		for(int i=0;i<8;i++){
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
		}
		udp->txPackItemCnt1++;
		//====================================
		bramAddr=37*4;
		u32 pcnt=readBram32();
		udp->txBuffer[inx++]=0xb0;
		int lenInx=inx;
		udp->txBuffer[inx++]=0;
		for(;;){
			int ichg=(prePulseCnt^pcnt)&31;
			if(ichg==0)
				break;
			bramAddr=((prePulseCnt&31)+128)*4;
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
			udp->txBuffer[lenInx]=udp->txBuffer[lenInx]+1;
			prePulseCnt++;
		}
		//===================================
		udp->txBuffer[inx++]=0xb1;
		udp->txBuffer[inx++]=10;
		bramAddr=38*4;
		ibuf = readBram32();//now wgRfoutPeriod low period time, unit 6.25ns
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		udp->txBuffer[inx++]=(ibuf>>16)&255;
		udp->txBuffer[inx++]=(ibuf>>24)&255;
		ibuf = readBram32();//now wgRfoutPeriod high period time, unit 6.25ns
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		udp->txBuffer[inx++]=(ibuf>>16)&255;
		udp->txBuffer[inx++]=(ibuf>>24)&255;
		ibuf = readBram32();//[5:0]:now wdRfoutFreq, 2.9G~3.49G, [15:8]s1rxPackCnt
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		//===================================


		//view rxCntA
		udp->txBuffer[inx++]=0xb2;
		udp->txBuffer[inx++]=10;
		udp->txBuffer[inx++]=radarData.conRxCntA[0];
		udp->txBuffer[inx++]=radarData.conRxCntA[1];
		udp->txBuffer[inx++]=radarData.conRxCntA[2];
		udp->txBuffer[inx++]=radarData.conRxCntA[3];
		udp->txBuffer[inx++]=radarData.conRxCntA[4];
		udp->txBuffer[inx++]=radarData.conRxCntA[5];
		udp->txBuffer[inx++]=radarData.conRxCntA[6];
		udp->txBuffer[inx++]=radarData.conRxCntA[7];
		udp->txBuffer[inx++]=radarData.conRxCntA[16];
		udp->txBuffer[inx++]=radarData.conRxCntA[17];

		//====================================
		udp->txBuffer[inx++]=0xb3;
		udp->txBuffer[inx++]=4;
		udp->txBuffer[inx++]=radarData.commOkRateA[0]&255;
		udp->txBuffer[inx++]=radarData.commOkRateA[0]>>8;
		udp->txBuffer[inx++]=radarData.commOkRateA[1]&255;
		udp->txBuffer[inx++]=radarData.commOkRateA[1]>>8;
		//==========================================




		udp->txBuffer[inx++]=0xb4;
		udp->txBuffer[inx++]=12;
		for(int i=0;i<6;i++){
			udp->txBuffer[inx++]=radarData.ioInA[i]&255;
			udp->txBuffer[inx++]=radarData.ioInA[i]>>8;
		}



		udp->txBuffer[inx++]=0xcd;//check end
		udp->txBufferLen = inx;
		return;
	}


	if(fpgaId==2){
		//=============================================
		udp->txBuffer[inx++]=0xaa;
		udp->txBuffer[inx++]=16;
		udp->txBuffer[inx++]=(radarData.enviStatusA)&255;
		udp->txBuffer[inx++]=(radarData.enviStatusA>>8)&255;
		udp->txBuffer[inx++]=(radarData.enviStatusA>>16)&255;
		udp->txBuffer[inx++]=(radarData.enviStatusA>>24)&255;
		for(int i=0;i<6;i++){
			udp->txBuffer[inx++]=radarData.meterStatusAA[i]&255;
			udp->txBuffer[inx++]=radarData.meterStatusAA[i]>>8;
		}
		//==============================================
		if(udp->txPackItemCnt0>=36)
			udp->txPackItemCnt0=0;
		udp->txBuffer[inx++]=0xab;
		udp->txBuffer[inx++]=udp->txPackItemCnt0;
		udp->txBuffer[inx++]=radarData.sspaPowerStatusAA[udp->txPackItemCnt0];
		udp->txBuffer[inx++]=radarData.sspaPowerV50vAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV50vAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV50iAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV50iAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV50tAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV50tAA[udp->txPackItemCnt0]>>8;

		udp->txBuffer[inx++]=radarData.sspaPowerV32vAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV32vAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV32iAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV32iAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV32tAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV32tAA[udp->txPackItemCnt0]>>8;

		udp->txBuffer[inx++]=radarData.sspaModuleStatusAA[udp->txPackItemCnt0];
		udp->txBuffer[inx++]=radarData.sspaModuleRfOutAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaModuleRfOutAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaModuleTemprAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaModuleTemprAA[udp->txPackItemCnt0]>>8;
		udp->txPackItemCnt0++;

		//===================================
		if(udp->txPackItemCnt1>=8)
			udp->txPackItemCnt1=0;
		udp->txBuffer[inx++]=0xac;
		udp->txBuffer[inx++]=udp->txPackItemCnt1;
		bramAddr = udp->txPackItemCnt1*8*4;
		for(int i=0;i<8;i++){
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
		}
		udp->txPackItemCnt1++;
		//===================================
		bramAddr=37*4;
		u32 pcnt=readBram32();
		udp->txBuffer[inx++]=0xb0;
		int lenInx=inx;
		udp->txBuffer[inx++]=0;
		for(;;){
			int ichg=(prePulseCnt^pcnt)&31;
			if(ichg==0)
				break;
			bramAddr=((prePulseCnt&31)+128)*4;
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
			udp->txBuffer[lenInx]=udp->txBuffer[lenInx]+1;
			prePulseCnt++;
		}
		//===================================
		udp->txBuffer[inx++]=0xb1;
		udp->txBuffer[inx++]=10;
		bramAddr=38*4;
		ibuf = readBram32();//now wgRfoutPeriod low period time, unit 6.25ns
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		udp->txBuffer[inx++]=(ibuf>>16)&255;
		udp->txBuffer[inx++]=(ibuf>>24)&255;
		ibuf = readBram32();//now wgRfoutPeriod high period time, unit 6.25ns
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		udp->txBuffer[inx++]=(ibuf>>16)&255;
		udp->txBuffer[inx++]=(ibuf>>24)&255;
		ibuf = readBram32();//[5:0]:now wdRfoutFreq, 2.9G~3.49G, [15:8]s1rxPackCnt
		udp->txBuffer[inx++]=ibuf&255;
		udp->txBuffer[inx++]=(ibuf>>8)&255;
		//===================================

		bramAddr=15*4;
		ibuf = readBram32();//
		radarData.conRxCntA[0]=ibuf>>8;
		//view rxCntA
		udp->txBuffer[inx++]=0xb2;
		udp->txBuffer[inx++]=16;
		udp->txBuffer[inx++]=radarData.conRxCntA[0];
		udp->txBuffer[inx++]=radarData.conRxCntA[1];
		udp->txBuffer[inx++]=radarData.conRxCntA[2];
		udp->txBuffer[inx++]=radarData.conRxCntA[3];
		udp->txBuffer[inx++]=radarData.conRxCntA[4];
		udp->txBuffer[inx++]=radarData.conRxCntA[5];
		udp->txBuffer[inx++]=radarData.conRxCntA[6];
		udp->txBuffer[inx++]=radarData.conRxCntA[7];
		udp->txBuffer[inx++]=radarData.conRxCntA[8];
		udp->txBuffer[inx++]=radarData.conRxCntA[9];
		udp->txBuffer[inx++]=radarData.conRxCntA[10];
		udp->txBuffer[inx++]=radarData.conRxCntA[11];
		udp->txBuffer[inx++]=radarData.conRxCntA[12];
		udp->txBuffer[inx++]=radarData.conRxCntA[13];
		udp->txBuffer[inx++]=radarData.conRxCntA[14];
		udp->txBuffer[inx++]=radarData.conRxCntA[15];
		//====================================
		udp->txBuffer[inx++]=0xb4;
		udp->txBuffer[inx++]=12;
		for(int i=0;i<6;i++){
			udp->txBuffer[inx++]=radarData.ioInA[i]&255;
			udp->txBuffer[inx++]=radarData.ioInA[i]>>8;
		}
		udp->txBuffer[inx++]=0xcd;//check end
		//====================================
		udp->txBufferLen = inx;

	}


	if(fpgaId==3 || fpgaId == 4){
		//=============================================
		if(udp->txPackItemCnt0>=36)
			udp->txPackItemCnt0=0;
		u8 status=radarData.sspaPowerStatusAA[udp->txPackItemCnt0];
		udp->txBuffer[inx++]=0xab;
		udp->txBuffer[inx++]=udp->txPackItemCnt0;
		udp->txBuffer[inx++]=radarData.sspaPowerStatusAA[udp->txPackItemCnt0];
		udp->txBuffer[inx++]=radarData.sspaPowerV50vAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV50vAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV50iAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV50iAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV50tAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV50tAA[udp->txPackItemCnt0]>>8;

		udp->txBuffer[inx++]=radarData.sspaPowerV32vAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV32vAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV32iAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV32iAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaPowerV32tAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaPowerV32tAA[udp->txPackItemCnt0]>>8;

		udp->txBuffer[inx++]=radarData.sspaModuleStatusAA[udp->txPackItemCnt0];
		udp->txBuffer[inx++]=radarData.sspaModuleRfOutAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaModuleRfOutAA[udp->txPackItemCnt0]>>8;
		udp->txBuffer[inx++]=radarData.sspaModuleTemprAA[udp->txPackItemCnt0]&255;
		udp->txBuffer[inx++]=radarData.sspaModuleTemprAA[udp->txPackItemCnt0]>>8;
		udp->txPackItemCnt0++;

		//===================================
		if(udp->txPackItemCnt1>=1)
			udp->txPackItemCnt1=0;
		udp->txBuffer[inx++]=0xac;
		udp->txBuffer[inx++]=udp->txPackItemCnt1;
		bramAddr = udp->txPackItemCnt1*8*4;
		for(int i=0;i<8;i++){
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
		}
		udp->txPackItemCnt1++;
		//====================================
		udp->txBuffer[inx++]=0xcd;//check end
		//====================================
		udp->txBufferLen = inx;

	}



	if(fpgaId==15){
		//=============================================
		udp->txBuffer[inx++]=(radarData.systemFlag0)&255;
		udp->txBuffer[inx++]=(radarData.systemFlag0>>8)&255;
		udp->txBuffer[inx++]=(radarData.systemFlag0>>16)&255;
		udp->txBuffer[inx++]=(radarData.systemFlag0>>24)&255;

		udp->txBuffer[inx++]=(radarData.systemFlag1)&255;
		udp->txBuffer[inx++]=(radarData.systemFlag1>>8)&255;
		udp->txBuffer[inx++]=(radarData.systemFlag1>>16)&255;
		udp->txBuffer[inx++]=(radarData.systemFlag1>>24)&255;

		udp->txBuffer[inx++]=radarData.wgFreqCh;
		udp->txBuffer[inx++]=radarData.attenuator;


		udp->txBuffer[inx++]=0xcd;//check end
		//====================================
		udp->txBufferLen = inx;

	}

}



//485tx
void loadUd485Tx(UartData *udp)
{
	udp->txDeiceId = slotDeviceId;
	if(rs_tx_slotId==0){
		udp->txSerialId=0xffff;
		udp->txCmd = rs_cmd;
		udp->txPara0 = rs_cmd_para0;
		udp->txPara1 = rs_cmd_para1;
		udp->txPara2 = rs_cmd_para2;
		udp->txPara3 = rs_cmd_para3;
		udp->txBufferLen = 0;
	}
	else{
		udp->txSerialId=rs_tx_slotId-1;
		udp->txCmd = 0x1000;
		udp->txPara0 = radarData.systemStatus0&0xffff;
		udp->txPara1 = (radarData.systemStatus0>>16);
		udp->txPara2 = radarData.systemStatus1&0xffff;
		udp->txPara3 = radarData.systemStatus1>>16;
		u8 inx=0;
		udp->txBuffer[inx++]=radarData.systemFlag0&255;;
		udp->txBuffer[inx++]=(radarData.systemFlag0>>8)&255;;
		udp->txBuffer[inx++]=(radarData.systemFlag0>>16)&255;;
		udp->txBuffer[inx++]=(radarData.systemFlag0>>24)&255;;

		udp->txBuffer[inx++]=radarData.systemFlag1&255;;
		udp->txBuffer[inx++]=(radarData.systemFlag1>>8)&255;;
		udp->txBuffer[inx++]=(radarData.systemFlag1>>16)&255;;
		udp->txBuffer[inx++]=(radarData.systemFlag1>>24)&255;;

		udp->txBuffer[inx++]=radarData.wgFreqCh;
		udp->txBuffer[inx++]=radarData.attenuator;
		udp->txBuffer[inx++]=radarData.ioLdlo;
		udp->txBuffer[inx++]=radarData.ioLdfo;
		udp->txBuffer[inx++]=radarData.chRfTxChA[0];
		udp->txBuffer[inx++]=radarData.chRfTxChA[1];
		udp->txBuffer[inx++]=radarData.chRfRxChA[0];
		udp->txBuffer[inx++]=radarData.chRfRxChA[1];
		//==========================================
		udp->txBuffer[inx++]=0xB0;
		udp->txBuffer[inx++]=0x08;
		udp->txBuffer[inx++]=radarData.iZeroTh;
		udp->txBuffer[inx++]=radarData.iZeroTh>>8;
		udp->txBuffer[inx++]=radarData.iSumShift;
		udp->txBuffer[inx++]=0;
		udp->txBuffer[inx++]=radarData.i32Th;
		udp->txBuffer[inx++]=radarData.i32Th>>8;
		udp->txBuffer[inx++]=radarData.i50Th;
		udp->txBuffer[inx++]=radarData.i50Th>>8;






		udp->txBufferLen = inx;
	}
	udp->txGroupId = 0xab00;
	enc_mystm(udp);
	udp->txStart_f = 1;
	udp->endTxFifo_f = 0;
}



/*
void timer0InterruptPrg(void *CallbackRef){
	int ibuf;
	intBramAddr = 0*4;
	ibuf = intReadBram32();
	if(ibuf==preRmem0)
		return;
	preRmem0=ibuf;
	rmem[0]	=ibuf;
	rmem[1] = intReadBram32();
	rmem[2] = intReadBram32();
	rmem[3] = intReadBram32();
}
*/




void encmst(UartData *udp, u8 uch, int enc)
{
	if (enc == 1)
	{
		udp->txChksum0 ^= uch;
		udp->txChksum1 += uch;
	}
	if (enc != 0)
	{
		if (uch == 0xEA || uch == 0xEB || uch == 0xEC)
		{
			udp->txTmp[udp->txLen++] = 0xEC;
			udp->txTmp[udp->txLen++] = (uch ^ 0xAB);
			return;
		}
		udp->txTmp[udp->txLen++] = uch;
		return;
	}
	udp->txTmp[udp->txLen++] = uch;
}

void encmstW(UartData *udp, u16 uw)
{
	u8 uch;
	uch = uw & 255;
	encmst(udp, uch, 1);
	uch = uw >> 8;
	encmst(udp, uch, 1);
	return;
}

void enc_mystm(UartData *udp)
{
	udp->txLen = 0;
	udp->txChksum0 = 0xAB;
	udp->txChksum1 = 0;
	//===
	encmst(udp, 0xEA, 0);
	encmstW(udp, udp->txDeiceId);
	encmstW(udp, udp->txSerialId);
	encmstW(udp, udp->txGroupId);
	int cmdLen = udp->txBufferLen + 10;
	encmstW(udp, cmdLen);
	//================================
	encmstW(udp, udp->txCmd);
	encmstW(udp, udp->txPara0);
	encmstW(udp, udp->txPara1);
	encmstW(udp, udp->txPara2);
	encmstW(udp, udp->txPara3);
	for (int i = 0; i < udp->txBufferLen; i++)
	{
		encmst(udp, udp->txBuffer[i], 1);
	}
	encmst(udp, (udp->txChksum0 & 255), 2);
	encmst(udp, (udp->txChksum1 & 255), 2);
	encmst(udp, 0xEB, 0);

	udp->txCnt = 0;
}

void encUartTx(UartData *udp){
	if(udp->txBufferLen==0)
		return;
	enc_mystm(udp);
	udp->txStart_f = 1;
	udp->endTxFifo_f = 0;
	udp->txBufferLen=0;
}

void writeBram32(int data)
{
	Xil_Out32(BRAM_CTR0_BASEADDR + bramAddr, data);
	bramAddr += 4;
}

int readBram32()
{
	int data = Xil_In32(BRAM_CTR0_BASEADDR + bramAddr);
	bramAddr += 4;
	return data;
}
int intReadBram32()
{
	int data = Xil_In32(BRAM_CTR0_BASEADDR + intBramAddr);
	intBramAddr += 4;
	return data;
}

