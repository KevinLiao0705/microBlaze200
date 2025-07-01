/*
 * 	program flash:
 * 		Xilinx->Program Device
 * 			bitstream/PDI:${project_loc:syncMain}/_ide/bitstream/design_1_wrapper.bit
 * 			microblaze_0:E:\kevin\myCode\microBlaze1\vitisJson\syncMain\Debug\syncMain.elf
 * 			program->
 * 		Xilinx->Program flash
 * 			image File:E:\kevin\myCode\microBlaze1\vitisJson\syncMain\_ide\bitstream\download.bit
 * 			flash type: mt25ql128-spi...
 *
 *
 *
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



void uart0TxIntPrg(void *CallBackRef, unsigned int EventData);
void uart0RxIntPrg(void *CallBackRef, unsigned int EventData);
void uart1RxIntPrg(void *CallBackRef, unsigned int EventData);
void uart1TxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart3RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart4RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart5RxIntPrg(void *CallBackRef, unsigned int EventData);
//void uart6RxIntPrg(void *CallBackRef, unsigned int EventData);
void intcDisconnect(u16 vecter);
void transBram(void);
void initBram(void);






/******************************************************************************/


#define txBufferSize_k 1024
#define rxBufferSize_k 1024
#define urxTmpMaxSize rxBufferSize_k*2

#define sspaMoniDatas_size 64
u16 myDeviceId = 25010;//deviceId
u16 mySerialId = 0x0000;//
u16 slotDeviceId = 0x2536;

typedef struct _myStream
{
	int inx;
	int spcChar_f;
	char name[32];
	unsigned char rdata[4096];
	int rdata_len;
	unsigned char rbuf[4096];
	int rbuf_len;
	//====================================
	// unsigned char tdata[4096];
	// unsigned char tbuf[4096];
	// int tdata_len = 0;
	int tbuf_len;
	int txStart_f;
	int txwait_tim;
	int txwait_tim_th;
	//====================================
	int reced_pack_f;
	int reced_clr_tim;
	int recon_tim;
	int err_cnt;
	int connect_f;
	int encType;
	int decType;
	int tx_nodata_f;
	int waitNorx_f;
	int rbuf_inx;
	int chksum0, chksum1;
	int noRxCnt;
	int noRxCnt_lim;
	void (*fptr)(struct _myStream *);
} MYSTM;

MYSTM msUart1;

typedef struct _uartDataSt
{
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
	u8 rxTmpPtr0;
	u8 rxTmpPtr1;
	u8 rxTmp[rxBufferSize_k * 2];
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


typedef struct radarSetSt
{
	u8 fpgaId;
	u16 paraSetSerId;
} RadarSetxx;
//
typedef struct radarDataSt
{
	//0:mast, 1:sub, 2:ctr, 3:drv, 4:meter
	u8 fpgaId;
	//==================================
	/*
			array 0:mast, 1:sub1, 2:sub2, 3:ctr1, 4:ctr2, 5:drv1a, 6:drv1b, 7:drv2a, 8:drv2b
			*** slotId[3:0] ==>
		 	 "none 				id=0;
		 	 "ＩＰＣ控制模組",     	id=1;
		 	 "ＦＰＧＡ控制模組",    	id=2;
		 	 "ＩＯ控制模組",       	id=3;
		 	 "邏輯分析模組",       	id=4;
		 	 "光纖傳輸模組",     	id=5;
		 	 "ＲＦ傳輸模組	",     	id=6;
		 	 "語音通信模組",   		id=7;
		 	 "SSPA驅動模組",   	id=8;
		 	 "METER MCU",   	id=9;
		  *** slotSerNo			7:4
		  *** slotStatus		9:8 ==> 0:none, 1:ready, 2:error 3:warn up
	      *** slotTestStatus 	11:10 ==> 0:none, 1:PreTest, 2:testing;
	      *** slotTestStatusId 	15:12 ==>
	      */
    u16 slotDataAA[12];
    /*=================================================
     mast mainStatus[1:0] 		==> 0:none, 1:warn up, 2:ready, 3:error
     sub1 mainStatus[3:2] 		==> 0:none, 1:warn up, 2:ready, 3:error
     sub2 mainStatus[5:4] 		==> 0:none, 1:warn up, 2:ready, 3:error
     ctr1 mainStatus[7:6] 		==> 0:none, 1:warn up, 2:ready, 3:error
     ctr2 mainStatus[9:8] 		==> 0:none, 1:warn up, 2:ready, 3:error
     drv1a mainStatus[11:10] 	==> 0:none, 1:warn up, 2:ready, 3:error
     drv1b mainStatus[13:12] 	==> 0:none, 1:warn up, 2:ready, 3:error
     drv2a mainStatus[15:14] 	==> 0:none, 1:warn up, 2:ready, 3:error
     drv2b mainStatus[17:16] 	==> 0:none, 1:warn up, 2:ready, 3:error
     ctr1Meter mainStatus[19:18] 	==> 0:none, 1:warn up, 2:ready, 3:error
     ctr2Meter mainStatus[21:20] 	==> 0:none, 1:warn up, 2:ready, 3:error




     //===
     ctr1 rfPulse detect flag[22]       ==> 0:none  1:OK
     ctr1 電源啟動[23] 						==> 0:停止 1:啟動
     ctr1 SSPA致能[24] 					==> 0:停止 1:啟動
     ctr1 輻射[25] 						==> 0:停止 1:啟動
     ctr1 緊急停止[26] 						==> 0:備便 1:停止
     //===
     ctr2 rfPulse detect flag[27] 		==> 0:none  1:OK
     ctr2 電源啟動[28] 						==> 0:停止 1:啟動
     ctr2 SSPA致能[29] 					==> 0:停止 1:啟動
     ctr2 輻射[30] 						==> 0:停止 1:啟動
     ctr2 緊急停止[31] 						==> 0:備便 1:停止
     */

    u32 systemStatus0;
    /*=================================================
    sub1 光纖連線狀態[0]		==> 0:未連線, 1:已連線
    sub1 RF連線狀態[1]     ==> 0:未連線, 1:已連線
    sub2 光纖連線狀態[2] 	==> 0:未連線, 1:已連線
    sub2 RF連線狀態[3]    ==> 0:未連線, 1:已連線
    ctr1 遠端遙控[4]      ==> 0:關閉, 1:開啟
    ctr2 遠端遙控[5]      ==> 0:關閉, 1:開啟
    mast spPulseExist[6]			==  0:none 1:exist
    ctr1 allSspaEnviSlatus[7] 		==> 0:OK, 1:Error
    ctr1 allSspaPowerSlatus[8] 		==> 0:OK, 1:Error
    ctr1 allSspaModuleSlatus[9] 	==> 0:OK, 1:Error
    ctr1 overWidth[10] 				==> 0:OK, 1:Error
    ctr1 overDuty[11] 				==> 0:OK, 1:Error
    ctr2 allSspaEnviSlatus[12] 		==> 0:OK, 1:Error
    ctr2 allSspaPowerSlatus[13] 	==> 0:OK, 1:Error
    ctr2 allSspaModuleSlatus[14] 	==> 0:OK, 1:Error
    ctr2 overWidth[15] 				==> 0:OK, 1:Error
    ctr2 overDuty[16] 				==> 0:OK, 1:Error
    ctr1 meterSlatus[17] 			==> 0:OK, 1:Error
    ctr2 meterSlatus[18] 			==> 0:OK, 1:Error
    mast spPulseEnable[19]			==  0:none 1:enable
    ctr1 txDummyLoad[20]      		==> 0:none, 1:connect
    ctr1 txAntLoad[21]      		==> 0:none, 1:connect
    ctr1 connected[22]      		==> 0:disconnected, 1:connected
    ctr2 connected[23]      		==> 0:disconnected, 1:connected
    sub1 mastPulseExist[24]			==  0:none 1:exist
    sub2 mastPulseExist[25]			==  0:none 1:exist



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
    u16 meterStatusAA[6];
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
     0:connect, 1:致能, 2 保護觸發, 3:工作比過高, 4:脈寬過高, 5:溫度過高, 6:反射過高,
     */
    u8 sspaModuleStatusAA[36];
    u16 sspaModuleRfOutAA[36];
    u16 sspaModuleTemprAA[36];
    //=============================================
    u8 gpsDataAA[3][16];//0:mast, 1sub1, 2sub2
    u16 adjTimeOf1588A[2];
    u16 commPackageCntA[2];
    u16 commOkRateA[2];
    u16 rfRxPowerA[4];//mast rx1,mast rx2,sub1 rx sub2 rx
    //==============================================




    /*=============================================================================
    emulate 信號模擬[1:0] ==> 0:no ,1:syncSet emulate, 2:vitis emulate.
    //
    ctr1 遠端遙控[2] ==> 0:disable 1:enable
    ctr2 遠端遙控[3] ==> 0:disable 1:enable
    //
    mast 脈波來源[4] ==> 0:SP脈波, 1:本機脈波
    sub 脈波來源[5] ==> 0:主控脈波, 1:本機脈波
    ctr 脈波來源[6] ==> 0:同步脈波, 1:本機脈波
    ctr 戰備短路[7] ==> 0:關閉, 1:開啟
    ctr 輸出裝置[8] ==> 0:假負載,1:天線,
    meter sp4tCnt[9] ==>  0:輸入功率,1:前置放大器輸出功率,2:驅動放大器輸出功率,3:順向輸出功率
    //
   	mast 與副控1連線方式[14:13] ==> 0: 光纖, 1: 無線, 2: 自動
   	mast 與副控2連線方式[16:15] ==> 0: 光纖, 1: 無線, 2: 自動
   	//
   	mast 與副控1通道[17] ==> 0:關閉, 1:開啟
   	mast 與副控2通道[18] ==> 0:關閉, 1:開啟:
   	//
    sub1 與主控連線方式 [20:19] ==> 0: 光纖, 1:無線, 2:自動
    sub2 與主控連線方式 [22:21] ==> 0: 光纖, 1:無線, 2:自動
    //
    sub1 主控與副控1同步模式 [23] ==> 0: 固定時間延時, 1:1588同步追蹤
    sub2 主控與副控2同步模式 [24] ==> 0: 固定時間延時, 1:1588同步追蹤

   	mast 副控1語音頻道[25] ==> 0:關閉, 1:開啟
   	mast 副控2語音頻道[26] ==> 0:關閉, 1:開啟

   	SSPA module protect flag[27] ==> 0:off, 1:on:

   	fpgaId[31:28] ==> :
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
	u8 hdfo;
	//=============================
	u8 pulseGenCh;
	u8 pulseGenDatasA[8*32];
	//================================
	u16 ioAd[5];
	u16 ioLdfi;
	u8 io;
	u8 ioLdlo;
	u8 ioLdfo;
	u8 fiberPointBuf[4][64];

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
UartData udUart[4];

u32 nowTime=0;
u32 timerBuf = 0;
u32 timerFlag = 0;
int bramAddr = 0;
int intBramAddr = 0;
int shTime=0;
u8 revData;

u32 bramBuf0;
u32 uartRestTime = 0;
u32 rs485RestTime = 0;
u32 ud485_endTime = 0;

RadarData radarData;

u16 rs485_tx_slotId=1;
u16 rs485_tx_para0;
u16 rs485_tx_para1;
u16 rs485_tx_para2;
u16 rs485_tx_para3;

u16 rs485_cmd = 0;
u16 rs485_cmd_para0 = 0;
u16 rs485_cmd_para1 = 0;
u16 rs485_cmd_para2 = 0;
u16 rs485_cmd_para3 = 0;


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
u16 no485RxTimeA[12];
u8 slotAdr=0;
u8 selfTest_f=1;
u16 selfTestCnt=0;
u8 transBram_f=0;
u8 flash_f=0;
u8 ledStatus=0;
//===========================
u8 radiationOn_f=0;
u8 localPreDataGateOn_f=0;
u8 emuSpPreDataGateOn_f=0;
u8 syncRxOn_f=0;
u32 memSaveBuf=0x12345678;
//============================
u16 noMeterMcuTime=0;
u16 noMeterFpgaTime=0;

u8 drvDataClrBuf[36];
u32 hdfoBuf=0;
u32 hdfoCnt=0;

u16 nextCmd=0;
u16 nextCmdPara0=0;
u16 nextCmdPara1=0;
u16 nextCmdPara2=0;
u16 nextCmdPara3=0;

void simple_delay(int simple_delay);
void encmst(UartData *ud, u8 uch, int enc);
void encmstW(UartData *ud, u16 uw);
void enc_mystm(UartData *ud);
void txUart2(UartData *ud);
void txUart0(UartData *ud);
void loadTickIpc();
void encUartTx(UartData *udp);
void loadTickCtr(UartData *udp);
void memTxPrg(UartData *udp);
void memRxPrg1(void);
void loadTickDrv();
void loadTickMeter();




void timerPrg0();
void timerPrg1();
void timerPrg2();
void timerPrg3();
void writeBram32(int data);
int readBram32();
int testBram(int addr, int len);
void initRadar();
int uartRxPrg(UartData *udp, u32 baseAddr);
int uartTxPrg(UartData *udp, u32 baseAddr);
int uartTxPrgTest(UartData *udp, u32 baseAddr);

void rs485TxLoadRequest(UartData *udp);
int chkUartTxEmpty(u32 baseAddr);
void uartByteDec(UartData *udp,u8 revData);
void uartRxChk(UartData *udp);
void timer0InterruptPrg(void *CallbackRef);
void udUartRxPrg0(UartData *udp);
void udUartRxPrg1(UartData *udp);
void udUartRxPrg2(UartData *udp);
void udUartRxPrg3(UartData *udp);
void udUartRxPrg(UartData *udp,u8 inx);


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

u8 getBufferByte(int *inxp, u8 *buf)
{
	int inx = *inxp;
	u8 sbuf = buf[inx];
	*inxp += 1;
	return sbuf;
}


void ud485RxPrg(UartData *udp)
{

	int inx = 0;
	u16 ibuf=0;
	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	if (deviceId != slotDeviceId)
		return;
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	u16 groupId = getBufferWord(&inx, udp->rxBuffer);
	u16 len = getBufferWord(&inx, udp->rxBuffer);
	u16 cmd = getBufferWord(&inx, udp->rxBuffer);
	u16 para0 = getBufferWord(&inx, udp->rxBuffer);
	u16 para1 = getBufferWord(&inx, udp->rxBuffer);
	u16 para2 = getBufferWord(&inx, udp->rxBuffer);
	u16 para3 = getBufferWord(&inx, udp->rxBuffer);
	if(serialId>=12)
		return;
	if(groupId!=0xac00)
		return;
	if(cmd==0x1000){
		radarData.slotDataAA[serialId]=para0;//slotStatus
		no485RxTimeA[serialId]=0;
		if((para0&15)==4){//La
			int kkk=serialId;
			return;
		}
		if((para0&15)==3){//io
			radarData.ioAd[0] = getBufferWord(&inx, udp->rxBuffer);
			radarData.ioAd[1] = getBufferWord(&inx, udp->rxBuffer);
			radarData.ioAd[2] = getBufferWord(&inx, udp->rxBuffer);
			radarData.ioAd[3] = getBufferWord(&inx, udp->rxBuffer);
			radarData.ioAd[4] = getBufferWord(&inx, udp->rxBuffer);
			radarData.ioLdfi=getBufferWord(&inx, udp->rxBuffer);
			hdfoBuf&=0xfffffcff;
			if(radarData.ioAd[1]>0x200)
				hdfoBuf|=0x00000100;
			if(radarData.ioAd[2]>0x200)
				hdfoBuf|=0x00000200;
			bramAddr = 17*4;
			writeBram32(hdfoBuf);

			return;
		}


		if((para0&15)==5){//fiber
			return;
		}
		if((para0&15)==6){//RF
			if(para3){
				radarData.gpsDataLen[0]=para3*2;
				for(int i=0;i<para3;i++){
					radarData.gpsDataA[0][i*2]=getBufferByte(&inx, udp->rxBuffer);
					radarData.gpsDataA[0][i*2+1]=getBufferByte(&inx, udp->rxBuffer);
				}
			}
			return;
		}
		if((para0&15)==8){//sspaDriver
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
		if((para0&15)==15){//meter
			if(para0&0x0001)//dummyLoadActIn
				radarData.systemStatus1|=(1<<20);
			else
				radarData.systemStatus1&=(1<<20)^0xffffffff;
			if(para0&0x0002)//dummyLoadActIn
				radarData.systemStatus1|=(1<<21);
			else
				radarData.systemStatus1&=(1<<21)^0xffffffff;
			radarData.meterStatusAA[0]=getBufferWord(&inx, udp->rxBuffer);
			radarData.meterStatusAA[2]=getBufferWord(&inx, udp->rxBuffer);
			radarData.meterStatusAA[3]=getBufferWord(&inx, udp->rxBuffer);
			radarData.meterStatusAA[4]=getBufferWord(&inx, udp->rxBuffer);
			radarData.meterStatusAA[5]=getBufferWord(&inx, udp->rxBuffer);
			noMeterMcuTime=0;

		}
	}

}

void udUartRxPrg0(UartData *udp){
	udUartRxPrg(udp,0);
}
void udUartRxPrg1(UartData *udp){
	udUartRxPrg(udp,1);
}
void udUartRxPrg2(UartData *udp){
	udUartRxPrg(udp,2);
}
void udUartRxPrg3(UartData *udp){
	udUartRxPrg(udp,3);
}


void udUartRxPrg(UartData *udp,u8 ser)
{
	u32 ibuf;
	u8 i8;
	int inx = 0;
	u16 deviceId = getBufferWord(&inx, udp->rxBuffer);
	u16 serialId = getBufferWord(&inx, udp->rxBuffer);
	u16 groupId = getBufferWord(&inx, udp->rxBuffer);



	if (deviceId != myDeviceId || serialId != mySerialId)
		return;
	if(groupId!=0xab00)
		return;
	u16 cmdLen = getBufferWord(&inx, udp->rxBuffer);
	u16 cmd = getBufferWord(&inx, udp->rxBuffer);
	u16 para0 = getBufferWord(&inx, udp->rxBuffer);
	u16 para1 = getBufferWord(&inx, udp->rxBuffer);
	u16 para2 = getBufferWord(&inx, udp->rxBuffer);
	u16 para3 = getBufferWord(&inx, udp->rxBuffer);



	if(para0==0x0002){
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
			rs485_cmd=i16;
			rs485_cmd_para0=getBufferWord(&inx, udp->rxBuffer);
			rs485_cmd_para1=getBufferWord(&inx, udp->rxBuffer);
			rs485_cmd_para2=getBufferWord(&inx, udp->rxBuffer);
			rs485_cmd_para3=getBufferWord(&inx, udp->rxBuffer);
			rs485_tx_slotId=0;
		}
		else{
			i16=getBufferWord(&inx, udp->rxBuffer);
			i16=getBufferWord(&inx, udp->rxBuffer);
			i16=getBufferWord(&inx, udp->rxBuffer);
			i16=getBufferWord(&inx, udp->rxBuffer);
		}
		ibuf=getBufferWord(&inx, udp->rxBuffer);
		if(ibuf==0xabcd)
			ibuf+=1;
		ibuf=radarData.systemStatus0&0xc6000000;
		ibuf+=radarData.laGroupCh;
		i8=(radarData.systemFlag0>>4)&255;
		ibuf+=i8<<8;
		if(ibuf!=bramBuf0){
			bramBuf0=ibuf;
			transBram_f=1;
		}

	}
	if(para0==0x0003){
		u8 adr=0;
		//slotInf
		for(int i=0;i<12;i++){
			radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
			radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		}
		//systemStatus0~1
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		radarData.fiberPointBuf[ser][adr++]=getBufferByte(&inx, udp->rxBuffer);
		//


		i8=getBufferByte(&inx, udp->rxBuffer);
		if(i8 != 0xab)
			return;




		i8=getBufferByte(&inx, udp->rxBuffer);
		if(i8>=36)
			return;
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



		i8=getBufferByte(&inx, udp->rxBuffer);
		if(i8==0xcd)
			i8+=1;

		hdfoBuf^=0x00000400;
		bramAddr = 17*4;
		writeBram32(hdfoBuf);

		return;

	}

	if(para0==0x000f){
		ibuf=getBufferDword(&inx, udp->rxBuffer);//systemStatus0
		ibuf=getBufferDword(&inx, udp->rxBuffer);//systemStatus1
		ibuf=radarData.systemStatus1^ibuf;
		ibuf&=3<<20;
		radarData.systemStatus1^=ibuf;
		ibuf=getBufferWord(&inx, udp->rxBuffer);
		if(ibuf!=0x0caa)
			return;
		radarData.meterStatusAA[0]=getBufferWord(&inx, udp->rxBuffer);
		radarData.meterStatusAA[1]=getBufferWord(&inx, udp->rxBuffer);
		radarData.meterStatusAA[2]=getBufferWord(&inx, udp->rxBuffer);
		radarData.meterStatusAA[3]=getBufferWord(&inx, udp->rxBuffer);
		radarData.meterStatusAA[4]=getBufferWord(&inx, udp->rxBuffer);
		radarData.meterStatusAA[5]=getBufferWord(&inx, udp->rxBuffer);
		noMeterFpgaTime=0;

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
				radarData.sspaPowerV32OnDly = getBufferByte(&inx, udp->rxBuffer);
				radarData.sspaPowerV50OffDly = getBufferByte(&inx, udp->rxBuffer);
				radarData.attenuator = getBufferByte(&inx, udp->rxBuffer);
				for(int i=0;i<5;i++)
					radarData.sspaPowerExistAA[i] = getBufferByte(&inx, udp->rxBuffer);
				for(int i=0;i<5;i++)
					radarData.sspaModuleExistAA[i] = getBufferByte(&inx, udp->rxBuffer);
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

				//==============================================
				//getBufferByte(&inx, udp->rxBuffer);
				//==============================================

				ibuf=getBufferByte(&inx, udp->rxBuffer);//altPackId
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
				i32=radarData.systemStatus0&0xc6000000;
				i32+=radarData.laGroupCh;
				u8 i8=(radarData.systemFlag0>>4)&255;
				i32+=i8<<8;
				if(i32!=bramBuf0){
					bramBuf0=i32;
					transBram_f=1;
				}



				if(para2==0x2008){//selfTestStartAll
					rs485_cmd=para2;
					rs485_tx_slotId=0;
					radarData.slotDataAA[slotAdr] &= (0xf3ff);
					radarData.slotDataAA[slotAdr]|=0x0400;
					ledStatus=4;
					nextCmd=rs485_cmd;
					return;
				}

				if(para2==0x2009){//selfTestStopAll
					rs485_cmd=para2;
					rs485_tx_slotId=0;
					radarData.slotDataAA[slotAdr] &= 0xf3ff;
					ledStatus=2;
					nextCmd=rs485_cmd;
					return;
				}
				if(para2==0x200a){//selfTestSlot
					rs485_cmd=para2;
					rs485_cmd_para0=para3;
					rs485_tx_slotId=0;
					if(para3==slotAdr){
						radarData.slotDataAA[slotAdr] &= (0xf3ff);
						radarData.slotDataAA[slotAdr] |= (0x0800);
						selfTest_f=1;
						selfTestCnt=0;
						ledStatus=5;
					}
					nextCmd=rs485_cmd;
					nextCmdPara0=rs485_cmd_para0;
					return;
				}


				if(fpgaId==0){
					if(para2==0x200b){//mastPulseEnable
						radarData.systemStatus1|=1<<19;
						return;
					}
					if(para2==0x200c){//mastPulseDisable
						radarData.systemStatus1&=(1<<19)^0xffffffff;
						return;
					}
				}

				if(fpgaId==1){
					if(para2!=0){
						fiber_cmd=para2;
						fiber_cmd_para0=para3;
						return;
					}
				}

				if(fpgaId==2 || fpgaId==3  ){
					u16 ia[3]={0,0,0};
					if(para2==0x2000){//sspaPowerOn
						u8* bufA=radarData.sspaPowerExistAA;
						for(int i=start;i<end;i++){
							int exist=bufA[i/8]&(1<<(i%8));
							if(exist)
								ia[i/16]|=1<<(i%16);

						}
						rs485_cmd=para2;
						rs485_cmd_para0=ia[0];
						rs485_cmd_para1=ia[1];
						rs485_cmd_para2=ia[2];
						rs485_cmd_para3=radarData.sspaPowerV32OnDly;
						rs485_tx_slotId=0;
						nextCmd=rs485_cmd;
						nextCmdPara0=rs485_cmd_para0;
						nextCmdPara1=rs485_cmd_para1;
						nextCmdPara2=rs485_cmd_para2;
						nextCmdPara3=rs485_cmd_para3;
						return;
					}
					if(para2==0x2001){//sspaPowerOff
						for(int i=start;i<end;i++){
							ia[i/16]|=1<<(i%16);
						}
						rs485_cmd=para2;
						rs485_cmd_para0=ia[0];
						rs485_cmd_para1=ia[1];
						rs485_cmd_para2=ia[2];
						rs485_cmd_para3=radarData.sspaPowerV50OffDly;
						rs485_tx_slotId=0;
						nextCmd=rs485_cmd;
						nextCmdPara0=rs485_cmd_para0;
						nextCmdPara1=rs485_cmd_para1;
						nextCmdPara2=rs485_cmd_para2;
						nextCmdPara3=rs485_cmd_para3;
						return;
					}
					if(para2==0x2002){//sspaModuleOn
						u8* bufA=radarData.sspaModuleExistAA;
						for(int i=start;i<end;i++){
							int exist=bufA[i/8]&(1<<(i%8));
							if(exist)
								ia[i/16]|=1<<(i%16);
						}
						rs485_cmd=para2;
						rs485_cmd_para0=ia[0];
						rs485_cmd_para1=ia[1];
						rs485_cmd_para2=ia[2];
						rs485_tx_slotId=0;
						nextCmd=rs485_cmd;
						nextCmdPara0=rs485_cmd_para0;
						nextCmdPara1=rs485_cmd_para1;
						nextCmdPara2=rs485_cmd_para2;
						return;
					}
					if(para2==0x2003){//sspaModuleOff
						for(int i=start;i<end;i++){
							ia[i/16]|=1<<(i%16);
						}
						rs485_cmd=para2;
						rs485_cmd_para0=ia[0];
						rs485_cmd_para1=ia[1];
						rs485_cmd_para2=ia[2];
						rs485_tx_slotId=0;
						nextCmd=rs485_cmd;
						nextCmdPara0=rs485_cmd_para0;
						nextCmdPara1=rs485_cmd_para1;
						nextCmdPara2=rs485_cmd_para2;
						nextCmdPara3=rs485_cmd_para3;
						return;
					}
				}

				if(para2==0x2004){//radiation on
					radarData.systemStatus0 |= 1<<25;
					radarData.pulseGenCh=para3&255;
					radiationOn_f=1;
					localPreDataGateOn_f=1;
					emuSpPreDataGateOn_f=0;
					syncRxOn_f=1;
					transBram();
					//==============================
					u8 freq;
					if(radarData.pulseGenCh<32){
						freq=radarData.pulseGenDatasA[8*radarData.pulseGenCh+6];
					}
					else{
						freq=40;
					}
					rs485_cmd=para2;
					rs485_cmd_para0=freq;
					rs485_cmd_para1=radarData.attenuator;
					rs485_tx_slotId=0;
					radarData.wgFreqCh=freq;
					nextCmd=rs485_cmd;
					nextCmdPara0=rs485_cmd_para0;
					nextCmdPara1=rs485_cmd_para1;
					return;
				}
				if(para2==0x2005){//radiation off
					radarData.systemStatus0 &= (1<<25)^0xffffffff;
					radiationOn_f=0;
					localPreDataGateOn_f=0;
					emuSpPreDataGateOn_f=0;
					syncRxOn_f=0;
					transBram();
					rs485_cmd=para2;
					rs485_tx_slotId=0;
					nextCmd=rs485_cmd;
					return;
				}
				if(para2==0x2006){//emergency on
					radarData.systemStatus0 |= 1<<26;
					for(int i=0;i<36;i++){
						radarData.sspaPowerStatusAA[i] &= 0xef;
					}
					for(int i=0;i<36;i++){
						radarData.sspaModuleStatusAA[i] &= 0xfd;
					}
					radarData.systemStatus0 &= (1<<25)^0xffffffff;
					rs485_cmd=para2;
					rs485_tx_slotId=0;

					radiationOn_f=0;
					localPreDataGateOn_f=0;
					emuSpPreDataGateOn_f=0;
					syncRxOn_f=0;
					transBram();

					nextCmd=rs485_cmd;

					return;
				}
				if(para2==0x2007){//emergency off
					radarData.systemStatus0 &= (1<<26)^0xffffffff;
					rs485_cmd=para2;
					rs485_tx_slotId=0;
					nextCmd=rs485_cmd;
					return;
				}
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
			rs485_cmd = 0x1500;
			rs485_cmd_para0 = para0;
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

	ibuf=radarData.commTestPacks;
	ibuf+=radarData.laGroupCh<<16;
	writeBram32(ibuf);//mem[5]
	ibuf=radarData.vgTimeDelay;//hostVgTimeDelay
	ibuf+=radarData.chTimeFineTune<<20;
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
	u8 pusleSourceFrom=1	;//0=sp, 1:local 2:emuSp
	if(radarData.pulseGenCh==254)
		pusleSourceFrom=0;
	if(radarData.pulseGenCh==253)
		pusleSourceFrom=2;

	u8 syncTxMode=1;		;//0 host 1:sync:2:ctr:3:endPoint
	u8 s1RxFrom=1;			;//0:rf 1:fiber 2:emu, 3:meter
	if(radarData.fpgaId==2){
		i8=(radarData.systemFlag0>>6)&1;//1:local
		if(i8){
			syncTxMode=3;
			s1RxFrom=2;
		}
		else{
			syncTxMode=2;
			s1RxFrom=1;
		}

	}

	if(radarData.fpgaId==3){
		syncTxMode=3;
		s1RxFrom=1;
	}

	if(radarData.fpgaId==15){
		syncTxMode=3;
		s1RxFrom=3;
	}



	u8 hostS1RxFrom=2;		;//0:rf 1:fiber 2:emu:
	u8 hostS2RxFrom=2;		;//0:rf 1:fiber 2:emu:
	u8 emuDelay=0;			;//
	u8 txCon_f=1;

	ibuf=radiationOn_f<<0;
	ibuf+=localPreDataGateOn_f<<1;
	ibuf+=emuSpPreDataGateOn_f<<2;
	ibuf+=syncRxOn_f<<3;
	ibuf+=pusleSourceFrom<<4;
	ibuf+=syncTxMode<<6;
	ibuf+=hostS1RxFrom<<8;
	ibuf+=hostS2RxFrom<<10;
	ibuf+=s1RxFrom<<12;
	ibuf+=emuDelay<<14;
	ibuf+=txCon_f<<16;


	ibuf+=0<<29;//emuRxBufByte
	ibuf+=0<<24;//emuRxBufBit
	writeBram32(ibuf);//13 setFlag


	ibuf=0x002b0001;
	writeBram32(ibuf);//14 sp emu txcode0
	ibuf=0x00002710;
	writeBram32(ibuf);//15 sp emu txcode1

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


void slotInfPrg(){
	if (ud485.txStart_f)
	{
		rs485RestTime=0;
		if (ud485.endTxFifo_f)
		{
			if (chkUartTxEmpty(XPAR_UARTLITE_1_BASEADDR))
			{
				ud485_endTime = XTmrCtr_GetValue(&timer0Obj, 1);
				ud485.endTx_f = 1;
				ud485.endTxFifo_f = 0;
			}
		}
		else
		{
			if (ud485.endTx_f)
			{
				if ((nowTime - ud485_endTime) > 10 * 200)
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
			rs485RestTime++;
		if (rs485RestTime > 40)
		{
			rs485RestTime = 0;
			rs485TxLoadRequest(&ud485);
			outFlag |= 0x08;
			XGpio_DiscreteWrite(&gpOutAObj, 1, outFlag);
			rs485_cmd = 0;
			rs485_cmd_para0 = 0;
			rs485_cmd_para1 = 0;
			rs485_cmd_para2 = 0;
			rs485_cmd_para3 = 0;

			rs485_tx_slotId++;
			if(rs485_tx_slotId>=13){
				rs485_tx_slotId=1;
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
    XTmrCtr_SetHandler(&timer0Obj, (XTmrCtr_Handler)timer0InterruptPrg,(void*)TIMER0_BASEADDR);
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
	//XUartLite_SetSendHandler(&uart0Obj, uart0TxIntPrg,&uart0Obj);
	XUartLite_SetRecvHandler(&uart0Obj, uart0RxIntPrg,&uart0Obj);
	//==========
	status = XUartLite_Initialize(&uart1Obj, uart1DeviceId);
	if(status)
		errorPrg("uart1Obj Initial Error",status);
	status = XUartLite_SelfTest(&uart1Obj);
	if(status)
		errorPrg("uart1Obj Test Error",status);
	XUartLite_EnableInterrupt(&uart1Obj);
	//XUartLite_SetSendHandler(&uart1Obj, uart1TxIntPrg,&uart1Obj);
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
	udUart[0].fptr = udUartRxPrg0;
	udUart[1].fptr = udUartRxPrg1;
	udUart[2].fptr = udUartRxPrg2;
	udUart[3].fptr = udUartRxPrg3;

	initBram();
	radiationOn_f=0;
	localPreDataGateOn_f=0;
	emuSpPreDataGateOn_f=0;
	syncRxOn_f=0;
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

		uartTxPrg(&udIpc, XPAR_UARTLITE_0_BASEADDR);
		uartRxChk(&udIpc);
		//=======================
		slotInfPrg();
		uartTxPrg(&ud485, XPAR_UARTLITE_1_BASEADDR);
		uartRxChk(&ud485);
		//=======================
		memTxPrg(&udUart[0]);
		memRxPrg1();
		uartRxChk(&udUart[0]);
		//=======================
		if(transBram_f)
			transBram();


		continue;
	}
	cleanup_platform();
	return 0;
}

u32 memTxDoneBuf=0;
u32 memTxStartBuf=0;
u8 memTxTime=0;
void memTxPrg(UartData *udp){
	u32 ibuf;
	u8 data[8];

	//========================================
	if (timerFlag & 0x00004000) // 102
		if(memTxTime<99)
			memTxTime++;
	if (!udp->txLen)
		return 0;
	//========================================
	bramAddr=32*4;
	ibuf=readBram32();
	if(ibuf==memTxDoneBuf){
		if(memTxTime<10)
			return;
	}
	memTxDoneBuf=ibuf;
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
	bramAddr=96*4;
	ibuf=(data[3]<<24)+(data[2]<<16)+(data[1]<<8)+data[0];
	writeBram32(ibuf);
	ibuf=(data[7]<<24)+(data[6]<<16)+(data[5]<<8)+data[4];
	writeBram32(ibuf);
	memTxStartBuf++;
	writeBram32(memTxStartBuf);
	memTxTime=0;
}


u32 memRxDoneBuf=0;
void memRxPrg1(void){
	u32 ibuf;
	u32 data[2];
	bramAddr=36*4;
	ibuf=readBram32();


	bramAddr=33*4;
	ibuf=readBram32();
	if(ibuf==memRxDoneBuf){
		return;
	}
	data[0]=readBram32();
	data[1]=readBram32();
	memRxDoneBuf=ibuf;
	for(int i=0;i<8;i++){
		int sh=(i&3)*8;
		int inx=i/4;
		udUart[0].rxTmp[udUart[0].rxTmpPtr0] = data[inx]>>sh;
		udUart[0].rxTmpPtr0++;
		if(udUart[0].rxTmpPtr0>=2048)
			udUart[0].rxTmpPtr0=0;
	}


}




void uartRxChk(UartData *udp){
	while(udp->rxTmpPtr1!=udp->rxTmpPtr0){
		revData=udp->rxTmp[udp->rxTmpPtr1];
		uartByteDec(udp,revData);
		udp->rxTmpPtr1++;
		if(udp->rxTmpPtr1>=2048)
			udp->rxTmpPtr1=0;
	}
}





void uartByteDec(UartData *udp,u8 revData){

	int j;
	int len;
	int chksum0, chksum1;
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
int uartRxPrg(UartData *udp, u32 baseAddr)
{
	u8 revData;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return 0;
	revData = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	uartByteDec(udp,revData);
	return 1;
}

//========================================================
int uartTxPrg(UartData *udp, u32 baseAddr)
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


int uartTxPrgTest(UartData *udp, u32 baseAddr)
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
		slotAdr=(inFlag>>4)&15;
		//slotAdr=11;//<<debug
		//buf=15;//<<debug
		radarData.fpgaId=buf;


		radarData.systemStatus0 &= 0xfffffffc;
		if(warnUpTime==0)
			radarData.systemStatus0 |= 2;
		else
			radarData.systemStatus0 |= 1;


		if(slotAdr<12){
			radarData.slotDataAA[slotAdr]&=0xfc00;
			radarData.slotDataAA[slotAdr]|=0x0202;
			no485RxTimeA[slotAdr]=0;
		}
		return;
	}


	if(shTime==1){
		if(udIpc.txLen)
			tickFatherTime=0;
		tickFatherTime++;
		if(tickFatherTime<50)
			return;
		tickFatherTime=0;
		loadTickIpc();
	}


	if(shTime==2){
		encUartTx(&udIpc);
	}
	if(shTime==3){
		for(int i=0;i<12;i++){
			no485RxTimeA[i]=no485RxTimeA[i]+1;
			if(no485RxTimeA[i]>500)
				radarData.slotDataAA[i]=0;

		}
	}
	if(shTime==4){
		if(radarData.fpgaId==2)
			loadTickCtr(&udUart[0]);
		if(radarData.fpgaId==3)
			loadTickDrv(&udUart[0]);
		if(radarData.fpgaId==15)
			loadTickMeter(&udUart[0]);

		encUartTx(&udUart[0]);
	}





}

// 250mhx 1.048ms
void timerPrg1()
{
}

// 104ms
void timerPrg2()
{
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
		if(radarData.fpgaId==15){
			noMeterMcuTime++;
			if(noMeterMcuTime>=10){
				radarData.meterStatusAA[0]=0xffff;
				radarData.meterStatusAA[1]=0xffff;
				radarData.meterStatusAA[2]=0xffff;
				radarData.meterStatusAA[3]=0xffff;
				radarData.meterStatusAA[4]=0xffff;
				radarData.meterStatusAA[5]=0xffff;
				radarData.systemStatus1&=(3<<20)^0xffffffff;
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
				radarData.systemStatus1&=(3<<20)^0xffffffff;
				noMeterFpgaTime=0;
			}
		}


}

// 250mhx 67.108ms

//outFlag.0 ledR
//outFlag.1 ledG
//outFlag.2 ledB
//outFlag.3 rs485De
//outFlag.7 rs485De
//ledStatus=0 none,1: warmup, 2:ok, 3:err, 4:preTest,5:testing


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
			radiationOn_f=0;
			localPreDataGateOn_f=0;
			emuSpPreDataGateOn_f=0;
			syncRxOn_f=0;
			transBram();
		}
	}
	for(u8 i=0;i<36;i++){
		drvDataClrBuf[i]++;
		if(drvDataClrBuf[i]>=20)
			radarData.sspaPowerStatusAA[i]&=0xfe;

	}
	hdfoCnt++;
	if(hdfoCnt>=10){
		hdfoCnt=0;
		hdfoBuf^=0x7f;
		bramAddr = 17*4;
		writeBram32(hdfoBuf);//mem[0]
	}


}

void simple_delay(int simple_delay)
{
	volatile int i = 0;
	for (i = 0; i < simple_delay; i++)
		;
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

void txUart2(UartData *udp)
{
	if (XUartLite_IsTransmitFull(XPAR_UARTLITE_1_BASEADDR))
		return;
	enc_mystm(udp);
	for (int i = 0; i < udp->txLen; i++)
		XUartLite_SendByte(XPAR_UARTLITE_1_BASEADDR, udp->txTmp[i]);
}

void txUart0(UartData *udp)
{
	if (XUartLite_IsTransmitFull(XPAR_UARTLITE_0_BASEADDR))
		return;
	enc_mystm(udp);
	for (int i = 0; i < udp->txLen; i++)
		XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, udp->txTmp[i]);
}


void loadUtxBufferB(UartData *udp, u8 byte)
{
	udp->txBuffer[udp->txBufferLen] = byte;
	udp->txBufferLen++;
}
void loadUtxBufferW(UartData *udp, u16 word)
{
	loadUtxBufferB(udp, word & 255);
	loadUtxBufferB(udp, (word >> 8) & 255);
}
void loadUtxBufferL(UartData *udp, u32 dword)
{
	loadUtxBufferB(udp, dword & 255);
	loadUtxBufferB(udp, (dword >> 8) & 255);
	loadUtxBufferB(udp, (dword >> 16) & 255);
	loadUtxBufferB(udp, (dword >> 24) & 255);
}




void loadTickDrv(){
	int ibuf;
	int fpgaId=radarData.fpgaId;
	udUart[0].txSerialCnt++;
	udUart[0].txDeiceId = myDeviceId;
	udUart[0].txSerialId = mySerialId;
	udUart[0].txGroupId=0xab00;
	udUart[0].txCmd = 0x1000;	//tick
	udUart[0].txPara0 =fpgaId;
	udUart[0].txPara1 = udUart[0].txSerialCnt;
	udUart[0].txPara2 = 0;
	udUart[0].txPara3 = 0;
	udUart[0].txBufferLen = 0;
	//
	int inx=0;
	for(int i=0;i<12;i++){
		udUart[0].txBuffer[inx++]=radarData.slotDataAA[i]&255;
		udUart[0].txBuffer[inx++]=radarData.slotDataAA[i]>>8;
	}
	//
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udUart[0].txBuffer[inx++]=(radarData.systemStatus1)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus1>>24)&255;


	if(udUart[0].txPackItemCnt0>=36)
		udUart[0].txPackItemCnt0=0;
	u8 itemCnt=udUart[0].txPackItemCnt0;
	u8 sta=radarData.sspaPowerStatusAA[itemCnt];
	if(sta&1){
		udUart[0].txBuffer[inx++]=0xab;
		udUart[0].txBuffer[inx++]=udUart[0].txPackItemCnt0;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerStatusAA[itemCnt];
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV50vAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV50vAA[itemCnt]>>8;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV50iAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV50iAA[itemCnt]>>8;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV50tAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV50tAA[itemCnt]>>8;

		udUart[0].txBuffer[inx++]=radarData.sspaPowerV32vAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV32vAA[itemCnt]>>8;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV32iAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV32iAA[itemCnt]>>8;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV32tAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaPowerV32tAA[itemCnt]>>8;

		udUart[0].txBuffer[inx++]=radarData.sspaModuleStatusAA[itemCnt];
		udUart[0].txBuffer[inx++]=radarData.sspaModuleRfOutAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaModuleRfOutAA[itemCnt]>>8;
		udUart[0].txBuffer[inx++]=radarData.sspaModuleTemprAA[itemCnt]&255;
		udUart[0].txBuffer[inx++]=radarData.sspaModuleTemprAA[itemCnt]>>8;
	}
	udUart[0].txPackItemCnt0++;
	//===================================
	udUart[0].txBuffer[inx++]=0xcd;//check end
	udUart[0].txBufferLen = inx;
}



void loadTickMeter(){
	int ibuf;
	int fpgaId=radarData.fpgaId;
	udUart[0].txSerialCnt++;
	udUart[0].txDeiceId = myDeviceId;
	udUart[0].txSerialId = mySerialId;
	udUart[0].txGroupId=0xab00;
	udUart[0].txCmd = 0x1000;	//tick
	udUart[0].txPara0 =fpgaId;
	udUart[0].txPara1 = udUart[0].txSerialCnt;
	udUart[0].txPara2 = 0;
	udUart[0].txPara3 = 0;
	udUart[0].txBufferLen = 0;
	//
	int inx=0;
	//
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udUart[0].txBuffer[inx++]=(radarData.systemStatus1)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udUart[0].txBuffer[inx++]=(radarData.systemStatus1>>24)&255;


	//=============================================
	udUart[0].txBuffer[inx++]=0xaa;
	udUart[0].txBuffer[inx++]=12;
	for(int i=0;i<6;i++){
		udUart[0].txBuffer[inx++]=radarData.meterStatusAA[i]&255;
		udUart[0].txBuffer[inx++]=radarData.meterStatusAA[i]>>8;
	}
	//==============================================
	udUart[0].txBuffer[inx++]=0xcd;//check end
	udUart[0].txBufferLen = inx;
}


void loadTickCtr(UartData *udp){
	int fpgaId=radarData.fpgaId;
	udp->txSerialCnt++;
	udp->txDeiceId = myDeviceId;
	udp->txSerialId = mySerialId;
	udp->txGroupId=0xab00;
	udp->txCmd = 0x1000;	//tick
	udp->txPara0 =fpgaId;
	udp->txPara1 = udp->txSerialCnt;
	udp->txPara2 = 0;
	udp->txPara3 = 0;
	int inx=0;
	udp->txBuffer[inx++]=(radarData.systemStatus0)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus0>>24)&255;

	udp->txBuffer[inx++]=(radarData.systemStatus1)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemStatus1>>24)&255;

	udp->txBuffer[inx++]=(radarData.systemFlag0)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag0>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag0>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag0>>24)&255;

	udp->txBuffer[inx++]=(radarData.systemFlag1)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag1>>8)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag1>>16)&255;
	udp->txBuffer[inx++]=(radarData.systemFlag1>>24)&255;
	//==================
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
	//==================
	udp->txBuffer[inx++]=(radarData.chFiberDelay)&255;
	udp->txBuffer[inx++]=(radarData.chFiberDelay>>8)&255;
	udp->txBuffer[inx++]=(radarData.chRfDelay)&255;
	udp->txBuffer[inx++]=(radarData.chRfDelay>>8)&255;
	//==================
	udp->txBuffer[inx++]=radarData.meterChDelay;
	udp->txBuffer[inx++]=radarData.drvChDelay;
	udp->txBuffer[inx++]=radarData.ctrChDelay;
	udp->txBuffer[inx++]=radarData.subChDelay;
	udp->txBuffer[inx++]=radarData.wgFreqCh;
	udp->txBuffer[inx++]=radarData.attenuator;
	//==================
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
	//==================
	udp->txBuffer[inx++]=0xcd;
	udp->txBuffer[inx++]=0xab;
	udp->txBufferLen = inx;


}

void loadTickIpc(){
	int ibuf;
	int fpgaId=radarData.fpgaId;
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


	if(fpgaId==0){
		//gps data
		for(int i=0;i<3;i++){
			if(radarData.gpsDataLen[i]){
				udp->txBuffer[inx++]=i+0xad;
				udp->txBuffer[inx++]=radarData.gpsDataLen[i];
				for(int j=0;j<radarData.gpsDataLen[i];j++){
					udp->txBuffer[inx++]=radarData.gpsDataA[i][j];
				}
			}
			udp->txBuffer[inx++]=0;
		}
		//view datas
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
		udp->txBufferLen = inx;
		return;
	}


	if(fpgaId==1){
		//gps data
		if(radarData.gpsDataLen[0]){
			udp->txBuffer[inx++]=fpgaId+0xad;
			udp->txBuffer[inx++]=radarData.gpsDataLen[0];
			for(int j=0;j<radarData.gpsDataLen[0];j++){
				udp->txBuffer[inx++]=radarData.gpsDataA[0][j];
			}
		}
		udp->txBuffer[inx++]=0;
		//====================================
		//view datas
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
		bramAddr=37*4;
		u32 pcnt=readBram32();
		u32 lowPeriod=readBram32();
		u32 highPeriod=readBram32();
		u32 freqCh=readBram32();

		udp->txBuffer[inx++]=0xb0;
		int lenInx=inx;
		udp->txBuffer[inx++]=0;
		int ddd=0;
		for(;;){
			int ichg=(prePulseCnt^pcnt)&15;
			if(ichg==0)
				break;
			bramAddr=((prePulseCnt&15)+48)*4;
			ibuf = readBram32();
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
			udp->txBuffer[lenInx]=udp->txBuffer[lenInx]+1;
			prePulseCnt++;
			ddd++;
		}


		/*
		udp->txBuffer[inx++]=0xb0;
		udp->txBuffer[inx++]=2;
		for(int i=0;i<1;i++){
			ibuf = 125000*2+1;
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
			ibuf = 900000*2+0;
			udp->txBuffer[inx++]=ibuf&255;
			udp->txBuffer[inx++]=(ibuf>>8)&255;
			udp->txBuffer[inx++]=(ibuf>>16)&255;
			udp->txBuffer[inx++]=(ibuf>>24)&255;
		}
		*/



		udp->txPackItemCnt1++;
		//====================================
		udp->txBuffer[inx++]=0xcd;//check end
		//====================================
		udp->txBufferLen = inx;

	}


	if(fpgaId==3){
		//=============================================
		if(udp->txPackItemCnt0>=36)
			udp->txPackItemCnt0=0;
		u8 status=radarData.sspaPowerStatusAA[udp->txPackItemCnt0];
		if(status&1){//connect_f
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
		}
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


void encUartTx(UartData *udp){
	if(udp->txBufferLen==0)
		return;
	enc_mystm(udp);
	udp->txStart_f = 1;
	udp->endTxFifo_f = 0;
	udp->txBufferLen=0;
}



void rs485TxLoadRequest(UartData *udp)
{
	udp->txDeiceId = slotDeviceId;
	if(rs485_tx_slotId==0){
		udp->txSerialId=0xffff;
		udp->txCmd = rs485_cmd;
		udp->txPara0 = rs485_cmd_para0;
		udp->txPara1 = rs485_cmd_para1;
		udp->txPara2 = rs485_cmd_para2;
		udp->txPara3 = rs485_cmd_para3;
		udp->txBufferLen = 0;
	}
	else{
		udp->txSerialId=rs485_tx_slotId-1;
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
		udp->txBufferLen = inx;
	}
	udp->txGroupId = 0xab00;
	enc_mystm(udp);
	udp->txStart_f = 1;
	udp->endTxFifo_f = 0;
}
















void intcDisconnect(u16 vecter)
{
	XIntc_Disconnect(&intc0Obj, vecter);

}

void uart0RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_0_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	udIpc.rxTmp[udIpc.rxTmpPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	udIpc.rxTmpPtr0++;
	if(udIpc.rxTmpPtr0>=2048)
		udIpc.rxTmpPtr0=0;

}


void uart0TxIntPrg(void *CallBackRef, unsigned int EventData)
{

}



void uart1RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_1_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	rs485RestTime=0;
	ud485.rxTmp[ud485.rxTmpPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	ud485.rxTmpPtr0++;
	if(ud485.rxTmpPtr0>=2048)
		ud485.rxTmpPtr0=0;

}
void uart1TxIntPrg(void *CallBackRef, unsigned int EventData)
{

}



/*
void uart3RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_3_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	udUart[0].rxTmp[udUart[0].rxTmpPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	udUart[0].rxTmpPtr0++;
	if(udUart[0].rxTmpPtr0>=2048)
		udUart[0].rxTmpPtr0=0;

}
void uart4RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_4_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	udUart[1].rxTmp[udUart[1].rxTmpPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	udUart[1].rxTmpPtr0++;
	if(udUart[1].rxTmpPtr0>=2048)
		udUart[1].rxTmpPtr0=0;

}
void uart5RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_5_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	udUart[2].rxTmp[udUart[2].rxTmpPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	udUart[2].rxTmpPtr0++;
	if(udUart[2].rxTmpPtr0>=2048)
		udUart[2].rxTmpPtr0=0;

}

void uart6RxIntPrg(void *CallBackRef, unsigned int EventData)
{
	u32 baseAddr=XPAR_UARTLITE_6_BASEADDR;
	if (XUartLite_IsReceiveEmpty(baseAddr))
		return;
	udUart[3].rxTmp[udUart[3].rxTmpPtr0] = (u8)XUartLite_ReadReg(baseAddr, XUL_RX_FIFO_OFFSET);
	udUart[3].rxTmpPtr0++;
	if(udUart[3].rxTmpPtr0>=2048)
		udUart[3].rxTmpPtr0=0;

}

*/








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
