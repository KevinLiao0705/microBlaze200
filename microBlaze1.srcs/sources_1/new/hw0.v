`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/22 11:31:33
// Design Name: 
// Module Name: hw0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module hw0
    #(  parameter RamAddrWidth = 13,
        parameter RamDataWidth = 32,
        parameter RamDepth = 256 
    )
    ( 	  

        //ram use
   		//==========================================================================
        input 					    ramClk,
   		input [RamAddrWidth-1:0]	ramAddr,
   		input [RamDataWidth-1:0]	ramInData,
   		output [RamDataWidth-1:0]	ramOutData,
   		input [3:0]					ramWe,
   		input 					    ramEn,
   		input 					    ramRstp,
   		//==========================================================================
        input   wire                sysClk,     //System clock
        input   wire                clk160m,    //System clock 160m
        input   wire                resetN,
        //==========================================================================
        input wire gpsPps,
        //output  ledV1,         //output io

        output  ledV3,         //output io
        output  ledV4,         //output io





        /* 
                0: ledR
                1: ledG
                2:ledB  
                3: rs485De
            */
        //output [3:0] gpOutA,
        /*
                0:spare 
                1: spare
                2: sw1_0
                3: sw1_1
                4:slotSw0
                5:slotSw1
                6:slotSw2
                7:slotSw3
            */
        //input   wire    [7:0]       gpInA,
        
        // 0:aRfmaCko,  1:aRfmaDio1,  2:aRfmaD0,  3:aRfmbCko,  4:aRfmbDio1,  5:aRfmbD0,
        // 6:bRfmaCko,  7:bRfmaDio1,  8:bRfmaD0,  9:bRfmbCko,  10:bRfmbDio1,  11:bRfmbD0,
        input wire [11:0] rfInA,
        // 0:aRfmaDio2,  1:aRfmbDio2, 2:bRfmaDio2,  3:bRfmbDio2,
        output [3:0] rfOutA,
       
        output [3:0] fibTxA,    		
        input   wire [3:0] fibRxA,

        output fibTxB1,    		
        output fibTxB3,    		
        output fibTxB5,    		
        output fibTxB7,
        
        input wire fibRxB1,    		
        input wire fibRxB3,    		
        input wire fibRxB5,    		
        input wire fibRxB7,    		
            		
        
        input wire inpChk0,    		
        input wire inpChk1,    		
        input wire inpChk2,    		
        input wire inpChk3,    		
        
        input wire [7:0] inpChkA,

        output wgRfOut,
        output [7:0]         hdfoA,    		
        output [15:0]        laCh,
        //==================================================
        //[5:0]:spFreqCh[5:0], 6:spInhib, 7:spPreTrig, 8:spGate,[13:9]:spPulseWidthCh[4:0]   
        inout [19:0] hdfioA,
                
        
            		
        /*
                    0:. aSndRx, 1:bSndRx
                    2: spFreqCh0, 3: spFreqCh1,  4: spFreqCh2, 5: spFreqCh3, 6: spFreqCh4, 7: spFreqCh5hd
                    8: spzInhib, 9: spPreTrig   ,10: spGate,
                    [11:15]: spPulseWidthCh[0:4]
                  //   
        */
        input [15:0]    dfInP,
        input [15:0]    dfInN,
        
        // diff output
        // 0:wg_clk, 1:wg_data, 2:wg_trig, 3:wg_rfout, 4:a_snd_clk, 5:a_snd_tx, 6:b_snd_clk, 7:b_snd_tx           
        output  [7:0]       dfOutP    ,   //+   		
        output  [7:0]       dfOutN        //-
        
        
   		
    );
  
    reg[15:0] s1StatusData;
    reg[7:0] s1SoundData;
    reg[15:0] hostCommandData;
    reg[7:0] hostS1SoundData;
    reg[7:0] hostS2SoundData;
    reg[RamDataWidth-1:0]             mem[RamDepth-1:0];
    reg[RamDataWidth-1:0]             bmem[RamDepth-1:0];
    reg[RamDataWidth-1:0]             rmem[255:0];
    reg[RamDataWidth-1:0]             smem0[31:0];
    reg[RamDataWidth-1:0]             smem1[31:0];//s1RxStatck
    reg[RamDataWidth-1:0]             smem2[31:0];//host S1RxStack
    reg[RamDataWidth-1:0]             smem3[31:0];//host S2RxStack
    reg[15:0] wgMaxPulseWidth;
    reg[23:0] wgMinPri;
    //==========================
    wire s1SyncTxLoad_w;
    wire s1SyncTxData_w;
    wire s1SyncTxEnd_w;
    wire s1SyncTxDataClk_w;
    wire txSysData1_load_w;
    wire txSysData1_clk_w;
    wire txSysData1_data_w;
    reg[19:0] hdfioDirA;
    reg[19:0] hdfioOA;
    wire[19:0] hdfioIA;
    integer      i ;  
  

/*===========================================================
initialize
=============================================================*/
    reg txSyncClkEn1_f;
    reg txSyncClkEn2_f;
    initial begin
        ramOutDataR = 0;
        //===
        for(i=0;i<256;i=i+1)begin
            rmem[i]=0;
        end
        //rmem[33]=32'h1234_5678;//id
        //rmem[34]=32'habcd_1234;//id



        /*
        rmem[0]:    hostRxData from s1 of data[3~0]
        rmem[1]:    hostRxData from s1 of data[7~4]
        rmem[2]:    hostRx from s1 tx~responseRx time limit(16000:100us)
        rmem[3]:    rootCommTime=rmem[2]-commBaseTime
        rmem[4]:    hostRx from s1 tx~responseRx time
        rmem[5]:    the filter data of (rootCommTime-trnasTypeDelay)
        *rmem[6]:    15:0 hostS1RCnt when tx 1000 times,23:16 hostS1RxPackCnt 
        rmem[]:
        rmem[8]:    hostRxData from s1 of data[3~0]
        rmem[9]:    hostRxData from s1 of data[7~4]
        rmem[10]:   hostRx from s1 tx~responseRx time limit(16000:100us)
        rmem[11]:   rootCommTime=rmem[2]-commBaseTime
        rmem[12]:   hostRx from s1 tx~responseRx time
        rmem[13]:   the filter data of (rootCommTime-trnasTypeDelay)
        *rmem[14]:   15:0 hostS2RCnt when tx 1000 times, 23:16 hostS2RxPackCnt
        *rmem[15]:   8:8:8:8 xxx,xxx,s1SyncFibRxPackCnt,s1SyncRfRxPackCnt

        *rmem[16]:   fiberB1 rxPackCnt
        *rmem[17]:   fiberB1 rxData0
        *rmem[18]:   fiberB1 rxData1
        rmem[19]:
        *rmem[20]:   fiberB3 rxPackCnt
        *rmem[21]:   fiberB3 rxData0
        *rmem[22]:   fiberB3 rxData1
        rmem[23]:
        *rmem[24]:   fiberB5 rxPackCnt
        *rmem[25]:   fiberB5 rxData0
        *rmem[26]:   fiberB5 rxData1
        rmem[27]:
        *rmem[28]:   fiberB7 rxPackCnt
        *rmem[29]:   fiberB7 rxData0
        *rmem[30]:   fiberB7 rxData1
        rmem[31]:

        rmem[32]: sysData txDone checkCnt 
        rmem[33]: rmemId0
        rmem[34]: rmemId1  
        rmem[35]:
        rmem[36]: [3:0]:fpgaId
        *rmem[37]: xxx:5  xxx:wgRfoutPulseFormDatas end ptr
        *rmem[38]: now wgRfoutPeriod low period time, unit 6.25ns
        *rmem[39]: now wgRfoutPeriod high period time, unit 6.25ns
        *rmem[40]: [5:0]:now wdRfoutFreq, 2.9G~3.49G, [15:8]s1SyncRxPackCnt [23:16]s1WgRxPackCnt
        
        rmem[41]: s1TxSyncStatus txDone checkCnt 
        *rmem[42]<=hostSxTxStatusBufCnt txDone checkCnt;
        
        rmem[43]<=s1RxCommandDataCnt;
        *rmem[44]<=hostS1RxCommandDataCnt;
        *rmem[45]<=hostS2RxCommandDataCnt;
        rmem[46]<=hdfioIA[19:0];
        
        rmem[47]:    sxSyncRxData from s1 of data[3~0]
        rmem[48]:    sxSyncRxData from s1 of data[7~4]
        
        
        smem0:rmem[128:32]: wgRfoutPulseFormDatas, bit[0]:0:low 1:high, bit[31:29] periodTime
        smem1:rmem[160:32]: sxRxSyncFromHost commandData trans to vitis
        *smem2:rmem[192:32]: hostS1RxSyncFromHost commandData trans to vitis
        *smem3:rmem[224:32]: hostS2RxSyncFromHost commandData trans to vitis


        */
        //======================================        
        /*
        mem[0]=32'h0000_0000;//systemStatus0
        mem[1]=32'h0000_0000;//systemStatus1
        mem[2]=32'b00000000_00000000_00000000_00010000;//systemFlag0
        mem[3]=32'b00000000_00000000_00000000_00000001;//systemFlag1
        *mem[4]=32'h0014_0a0a;//16:8:8 ,preTrigTime,  preRfoutTime  afterTrigTime,
        mem[5]=32'h0000_1000;//8:8:16, spare,laGroupCh,commTestPacks
        *mem[6]=32'h1000_2580;//12:20, xxx,hostWgVideoGateDelayTime 
        mem[7]=32'h0100_0100;//16:16 chRfTimeDelay,chFiberTimeDelay
        *mem[8]=32'h000a_1000;//16:4:4:8 preDataGateWidth:xxx:fgaId:pulse gen sample end
        *mem[9]=32'h0000_0221;//12:20, xxx,wgTrigGateDelayTime-sub 
        mem[10]=32'h0000_05ed;//12:20, xxx,s1WgVideoGateDelayTime 
        mem[11]=32'h0000_3ce8;//12:20, xxx,baseCommTime//3de8
        *mem[12]=32'h0000_0000;//16:16 hostAutoPreDataPri,hostAutoDelayTime(minimun pri)


        *mem[14][23:16] emu sp freq
        *mem[14][4:0] emu sp pulse width table index
        *mem[15][31:24] spEmuWgFlag
        *mem[15][23:0] spEmuWgPriTime unit=0.1us

        *mem[31]=32'habcd_1234;//mem 0~95 block change flag

        *mem[96]     txData[3:0] from vitis
        *mem[97]     txData[7:4] fomr vits
        *mem[98]     changeValueCnt
        *mem[101]    hostSxTx sync staus data 8:15:1:8 txCnt,xxx,disableFlag,data



        */



        mem[0]=32'h0000_0000;//systemStatus0
        mem[1]=32'h0000_0000;//systemStatus1
        mem[2]=32'b00000000_00000000_00000000_00010000;//systemFlag0
        mem[3]=32'b00000000_00000000_00000000_00000001;//systemFlag1
        mem[4]=32'h0014_0a0a;//16:8:8 ,preTrigTime,  preRfoutTime  afterTrigTime,
        mem[5]=32'h0000_1000;//8:8:16, spare,laGroupCh,commTestPacks
        mem[6]=32'h1000_2580;//12:20, xxx,hostWgVideoGateDelayTime 
        mem[7]=32'h0100_0100;//16:16 chRfTimeDelay,chFiberTimeDelay
        mem[8]=32'h000a_1000;//16:8:8 preDataGateWidth:fgaId,sample end  0
        mem[9]=32'h0000_0221;//12:20, xxx,wgTrigGateDelayTime-sub 
        mem[10]=32'h0000_05ed;//12:20, xxx,s1WgVideoGateDelayTime 
        mem[11]=32'h0000_3ce8;//12:20, xxx,baseCommTime//3de8
        //mem[12]=32'h0000_0000;//16:16 xxx,emuTimeDelay
        mem[31]=32'habcd_1234;//  

        //======================================        
        /*
            wgRepeatEnd<=ibuf[0][31:24]
            wgRfFreq<=ibuf[0][23:16]        unit:0.1G, offset:2.9G, range:0~59
            wgPulseWidth<=ibuf[0][15:0]     unit=0.1us
            wgPulseFlag<=ibuf[1][31:24]
            wgPri<=ibuf[1][23:0]            unit:0.1us
            pulseGen datas 0x20<=addr<0x60
        */
        
        //mem[96]     txData[3:0] from vitis
        //mem[97]     txData[7:4] fomr vits
        //mem[98]     changeValueCnt
        
        
        //mem[100]     s1TxSyncStatusData from vitis
        
        for (i=0;i<32;i=i+1)begin
            mem[32+i*2]=(0*256+43)*65536+100*10;
            mem[33+i*2]=0*65536*256+1000*10;
        end
        //===
        mem[32]=(2*256+43)*65536+100*10;
        mem[33]=0*65536*256+1000*10;
        mem[34]=(4*256+43)*65536+50*10;
        mem[35]=0*65536*256+800*10;
        //===========================        
        localPreDataGateTimeCnt=32'hfff_0000;
        localWgPriTime<=160*1000*100;
        localWgRepeatCnt=0;
        localWgRepeatEnd=0;   
        localWgSampleCnt=0;
        localWgSampleEnd=0;
        wgActTimeCnt=24'hf0000;
        hostPreDataGate_f=1;                
        //===
        s1SyncWgPulseWidth=10*10;
        s1SyncPreDataGate_f=1;                
        s1WgGate_f=1;                
        s1WgGate_ff=1;                
        wgClk_f=0;
        wgDataBit_f=0;
        wgTrig_f=1;
        wgRfout_f=0;
        wgTimeClk=10*1000;
        //==================================
        hostVideoGateDelayTimeCnt=20'hfff00;
        localPreDataGate_f=1;
        hostVideoGate_f=0;
        //==================================
        s1VideoGateDelayTimeCnt=20'hfff00;
        s1SyncPreDataGate_f=1;
        s1VideoGate_f=0;
        s1SyncRespDelayTime=656;
        s1WgRespDelayTime=656;
        //===================================
        s1CommDelayTime=16;
        txSyncClkEn1_f=0;
        txSyncClkEn2_f=0;
        memSaveBuf1=0;
        hdfioDirA=0;
        hdfioOA=0;
        fpgaId=4'b1111;
        bmem[8][11:8]=4'b1111;
    end

/*===============================================================================================================
/*===============================================================================================================
/*===============================================================================================================
/*===============================================================================================================



/*===========================================================
purpose:
    generate hostS1RxPackCnt to rmem[6][23:16]
    save  hostS1Rx statusData  to smem2[0~31], stackPtr to rmem[44]
    generate hostS1Rx correctCnt per thousand to rmem[6][15:0];
input: 
    hostS1TxEnd_w
    hostS1RxPack_w
    hostS1RxData1_wb
output: 
    rmem[6][15:0] hostS1CommOkRate/1000
    rmem[6][23:16]<=hostS1RxPackCnt
    smem2[ptr:0~31]<=s1StatusData
    rmem[44]<=ptr
=============================================================*/
    reg hostS1TxEnd_ff;
    reg[15:0] hostS1TxCnt;
    reg hostS1RxPack_ff;
    reg[15:0] hostS1RxCnt;
    reg[7:0] hostS1RxPackCnt;
    reg[4:0] hostS1RxCommandDataCnt;
    always @(posedge clk160m) begin
        if(hostS1TxEnd_w)begin
            if(!hostS1TxEnd_ff)
                hostS1TxCnt<=hostS1TxCnt+1;
        end
        hostS1TxEnd_ff<=hostS1TxEnd_w;
        //
        if(hostS1RxPack_w)begin        
            if(!hostS1RxPack_ff)begin
                hostS1RxCnt<=hostS1RxCnt+1;
                hostS1RxPackCnt<=hostS1RxPackCnt+1;
                rmem[6][23:16]<=hostS1RxPackCnt;
                //===========================================
                if(!hostS1RxData1_wb[8:8])begin
                    smem2[hostS1RxCommandDataCnt]<=hostS1RxData1_wb;
                    rmem[7]<=hostS1RxData1_wb;
                    hostS1RxCommandDataCnt<=hostS1RxCommandDataCnt+1;
                    rmem[44]<=hostS1RxCommandDataCnt;
                end
            end    
        end
        hostS1RxPack_ff<=hostS1RxPack_w;
        //
        if(hostS1TxCnt==1000)begin
            hostS1TxCnt=1;
            rmem[6][15:0]<=hostS1RxCnt;
            hostS1RxCnt<=0;
        end    
    end
//=========================================================================================================





    

/*===========================================================
purpose:
    generate hostS2RxPackCnt to rmem[14][23:16]
    save  hostS2Rx statusData  to smem3[0~31], stackPtr to rmem[45]
    generate hostS2Rx correctCnt per thousand to rmem[6][15:0];
input: 
    hostS2TxEnd_w
    hostS2RxPack_w
    hostS2RxData1_wb
output: 
    rmem[14][15:0] hostS2CommOkRate/1000
    rmem[14][23:16]<=hostS2RxPackCnt
    smem3[ptr:0~31]<=s2StatusData
    rmem[45]<=ptr
=============================================================*/
    reg hostS2TxEnd_ff;
    reg[15:0] hostS2TxCnt;
    reg hostS2RxPack_ff;
    reg[15:0] hostS2RxCnt;
    reg[7:0] hostS2RxPackCnt;
    reg[4:0] hostS2RxCommandDataCnt;
    
    always @(posedge clk160m) begin
        if(hostS2TxEnd_w)begin
            if(!hostS2TxEnd_ff)
                hostS2TxCnt<=hostS2TxCnt+1;
        end
        hostS2TxEnd_ff<=hostS2TxEnd_w;
        if(hostS2RxPack_w)begin        
            if(!hostS2RxPack_ff)begin
                hostS2RxCnt<=hostS2RxCnt+1;
                hostS2RxPackCnt<=hostS2RxPackCnt+1;
                rmem[14][23:16]<=hostS2RxPackCnt;
                //===================================================
                if(!hostS2RxData1_wb[8:8])begin      
                    smem3[hostS2RxCommandDataCnt]<=hostS2RxData1_wb;
                    hostS2RxCommandDataCnt<=hostS2RxCommandDataCnt+1;
                    rmem[45]<=hostS2RxCommandDataCnt;
                end
            end    
        end
        hostS2RxPack_ff<=hostS2RxPack_w;
        if(hostS2TxCnt==1000)begin
            hostS2TxCnt=1;
            rmem[14][15:0]<=hostS2RxCnt;
            hostS2RxCnt<=0;
        end    
    end
//=========================================================================================================


    
    
/*===========================================================
purpose:
    generate txSysPreData_f and txDatas of vitisUserSetValue via fiberB to other device
input: 
    mem[96]     txData[3:0] from vitis
    mem[97]     txData[7:4] fomr vits
    mem[98]     changeValueCnt
output: 
    txSysPreData_f tx trig flag, low active 1 us
    txSysData[0:3] tx data 16bit *4
=============================================================*/
    reg[31:0] txSysDataChgBuf;
    reg[15:0] txSysData[3:0];
    reg txSysPreData_f;
    reg[15:0] txSysPreDataTimeCnt;
    always @(posedge clk160m) begin
        if(!txSysPreDataTimeCnt[15])
            txSysPreDataTimeCnt<=txSysPreDataTimeCnt+1;
        if(txSysPreDataTimeCnt==160)
            txSysPreData_f<=1;
        if(txSysPreDataTimeCnt==12800)
            rmem[32]<=txSysDataChgBuf;    
        txSysPreDataTimeCnt<=txSysPreDataTimeCnt+1;    
        if(mem[98]!=txSysDataChgBuf)begin
            txSysDataChgBuf<=mem[98];
            txSysData[0]<=mem[96][15:0];
            txSysData[1]<=mem[96][31:16];
            txSysData[2]<=mem[97][15:0];
            txSysData[3]<=mem[97][31:16];
            txSysPreData_f<=0;
            txSysPreDataTimeCnt<=0;
        end
    end

//=========================================================================================================






/*===========================================================
purpose:
    generate ch1:rxDatas for vitisUserStatusValue from fiberB of other device
input: 
    rxSysData1_pack_w       from rxModule, fiberB rxData tirg flag, high active
    rxSysData1_data0_wb     from rxModule, 16bit
    rxSysData1_data1_wb     from rxModule, 16bit
    rxSysData1_data2_wb     from rxModule, 16bit
    rxSysData1_data3_wb     from rxModule, 16bit
output: 
    rmem[16]    rxPackCnt
    rmem[17]    rxData0, 32bit
    rmem[18]    rxData1, 32bit
=============================================================*/
    reg rxSysData1_pack_ff;
    reg[31:0] rxSysData1_chg_buf;
    always @(posedge clk160m) begin
        if(rxSysData1_pack_w)begin
            if(!rxSysData1_pack_ff)begin
                rmem[16]<=rxSysData1_chg_buf;                   
                rmem[17][15:0]<=rxSysData1_data0_wb;                   
                rmem[17][31:16]<=rxSysData1_data1_wb;                   
                rmem[18][15:0]<=rxSysData1_data2_wb;                   
                rmem[18][31:16]<=rxSysData1_data3_wb;                   
                rxSysData1_chg_buf<=rxSysData1_chg_buf+1;
            end
        end                   
        rxSysData1_pack_ff<=rxSysData1_pack_w;                   
    end

/*===========================================================
purpose:
    generate ch2:rxDatas for vitisUserStatusValue from fiberB of other device
input: 
    rxSysData2_pack_w       from rxModule, fiberB rxData tirg flag, high active
    rxSysData2_data0_wb     from rxModule, 16bit
    rxSysData2_data1_wb     from rxModule, 16bit
    rxSysData2_data2_wb     from rxModule, 16bit
    rxSysData2_data3_wb     from rxModule, 16bit
output: 
    rmem[20]    rxPackCnt
    rmem[21]    rxData0, 32bit
    rmem[22]    rxData1, 32bit
=============================================================*/
    reg rxSysData2_pack_ff;
    reg[31:0] rxSysData2_chg_buf;
    always @(posedge clk160m) begin
        if(rxSysData2_pack_w)begin
            if(!rxSysData2_pack_ff)begin
                rmem[20]<=rxSysData2_chg_buf;                   
                rmem[21][15:0]<=rxSysData2_data0_wb;                   
                rmem[21][31:16]<=rxSysData2_data1_wb;                   
                rmem[22][15:0]<=rxSysData2_data2_wb;                   
                rmem[22][31:16]<=rxSysData2_data3_wb;                   
                rxSysData2_chg_buf<=rxSysData2_chg_buf+1;
            end
        end                   
        rxSysData2_pack_ff<=rxSysData2_pack_w;                   
    end

/*===========================================================
purpose:
    generate ch3:rxDatas for vitisUserStatusValue from fiberB of other device
input: 
    rxSysData3_pack_w       from rxModule, fiberB rxData tirg flag, high active
    rxSysData3_data0_wb     from rxModule, 16bit
    rxSysData3_data1_wb     from rxModule, 16bit
    rxSysData3_data2_wb     from rxModule, 16bit
    rxSysData3_data3_wb     from rxModule, 16bit
output: 
    rmem[24]    rxPackCnt
    rmem[25]    rxData0, 32bit
    rmem[26]    rxData1, 32bit
=============================================================*/
    reg rxSysData3_pack_ff;
    reg[31:0] rxSysData3_chg_buf;
    always @(posedge clk160m) begin
        if(rxSysData3_pack_w)begin
            if(!rxSysData3_pack_ff)begin
                rmem[24]<=rxSysData3_chg_buf;                   
                rmem[25][15:0]<=rxSysData3_data0_wb;                   
                rmem[25][31:16]<=rxSysData3_data1_wb;                   
                rmem[26][15:0]<=rxSysData3_data2_wb;                   
                rmem[26][31:16]<=rxSysData3_data3_wb;                   
                rxSysData3_chg_buf<=rxSysData3_chg_buf+1;
            end
        end                   
        rxSysData3_pack_ff<=rxSysData3_pack_w;                   
    end

/*===========================================================
purpose:
    generate ch4:rxDatas for vitisUserStatusValue from fiberB of other device
input: 
    rxSysData4_pack_w       from rxModule, fiberB rxData tirg flag, high active
    rxSysData4_data0_wb     from rxModule, 16bit
    rxSysData4_data1_wb     from rxModule, 16bit
    rxSysData4_data2_wb     from rxModule, 16bit
    rxSysData4_data3_wb     from rxModule, 16bit
output: 
    rmem[28]    rxPackCnt
    rmem[29]    rxData0, 32bit
    rmem[30]    rxData1, 32bit
=============================================================*/
    reg rxSysData4_pack_ff;
    reg[31:0] rxSysData4_chg_buf;
    always @(posedge clk160m) begin
        if(rxSysData4_pack_w)begin
            if(!rxSysData4_pack_ff)begin
                rmem[28]<=rxSysData4_chg_buf;                   
                rmem[29][15:0]<=rxSysData4_data0_wb;                   
                rmem[29][31:16]<=rxSysData4_data1_wb;                   
                rmem[30][15:0]<=rxSysData4_data2_wb;                   
                rmem[30][31:16]<=rxSysData4_data3_wb;                   
                rxSysData4_chg_buf<=rxSysData4_chg_buf+1;
            end
        end                   
        rxSysData4_pack_ff<=rxSysData4_pack_w;                   
    end

//===========================================================================================





/*===========================================================
purpose:
    generate s1RfRxPack_cnt
input: 
    s1RfRxPack_w
output: 
    rmem[15][7:0]
=============================================================*/
    reg s1RfRxPack_wf;
    reg[7:0] s1RfRxPack_cnt;
    always @(posedge clk160m) begin
        if(s1RfRxPack_w)begin
            if(!s1RfRxPack_wf)begin
                s1RfRxPack_cnt<=s1RfRxPack_cnt+1;
                rmem[15][7:0]<=s1RfRxPack_cnt;       
            end
        end                   
        s1RfRxPack_wf<=s1RfRxPack_w;                   
    end
//===========================================================================================










/*===========================================================
purpose:
    generate s1FibRxPack_cnt
input: 
    s1FibRxPack_w
output: 
    rmem[15][15:8]
=============================================================*/
    reg s1FibRxPack_wf;
    reg[7:0] s1FibRxPack_cnt;
    always @(posedge clk160m) begin
        if(s1FibRxPack_w)begin
            if(!s1FibRxPack_wf)begin
                s1FibRxPack_cnt<=s1FibRxPack_cnt+1;
                rmem[15][15:8]<=s1FibRxPack_cnt;       
            end
        end                   
        s1FibRxPack_wf<=s1FibRxPack_w;                   
    end
//===========================================================================================



/*===========================================================
purpose:
    generate pulseFormInf for scope use
input: 
    wgRfout_f
output: 
    stack: smem0[0~31] 
    stackPtr: rmem[37][4:0]
    lowPeriald: rmem[38]
    high period: rmem[39]
    wgFreq: rmem[40][5:0]
=============================================================*/


    reg wgRfoutH_f;
    reg[31:0] wgRfoutTime;
    reg[4:0] wgRfoutCnt;
    reg[31:0] wgRfoutPeriod;
    reg[31:0] wgRfoutTime_buf;
    
    always @(posedge clk160m) begin
        if(wgRfoutH_f ^ wgRfout_f)begin
            smem0[wgRfoutCnt]<=wgRfoutTime_buf;
            rmem[37][4:0]<=wgRfoutCnt;
            wgRfoutCnt<=wgRfoutCnt+1;
            if(wgRfout_f)
                rmem[38]<=wgRfoutPeriod;//low period
            else
                rmem[39]<=wgRfoutPeriod;//high period
            rmem[40][5:0]<=s1WgRfFreq;    
            wgRfoutH_f<=wgRfout_f;
            wgRfoutTime<=1;
            wgRfoutPeriod<=1;     
        end
        else begin
            wgRfoutTime<=wgRfoutTime+1;
            wgRfoutTime_buf<=(wgRfoutTime<<1)+(wgRfout_f);
            if(!wgRfoutPeriod[31])
                wgRfoutPeriod<=wgRfoutPeriod+1;
            if(wgRfoutPeriod>=160*100000)begin
                rmem[38]<=0;//low period
                rmem[39]<=0;//high period
            end                
            if(wgRfoutTime>=160*10000)begin
                smem0[wgRfoutCnt[4:0]]<=wgRfoutTime_buf;
                rmem[37]<=wgRfoutCnt;
                wgRfoutCnt<=wgRfoutCnt+1;
                wgRfoutTime<=1;
            end
        end
    end
//===========================================================================================
    
    
    
    

        
    
/*===========================================================
generate real time cnt
generate
=============================================================*/
/*===========================================================
purpose:
    generate real time cnt
    save mem[0~95] to bmem[0~95]
input: 
    mem[31] change flag
    mem[0~95]
output:
    realTimeCnt
    bmem[0~95]
 =============================================================*/
    reg[23:0] realTimeCnt;
    always @(posedge clk160m) begin
        realTimeCnt<=realTimeCnt+1;
        if(memSaveBuf1!=mem[31])begin
            memSaveBuf1<=mem[31];
            for(i=0;i<96;i=i+1)begin
                bmem[i]<=mem[i];
            end    
        end        
    end
//===========================================================================================
    
    
    
    
    
    
    
    
/*===========================================================
purpose:
    generate localPreDataGate_f and all sspa paremeter
input: 
    mem[13][1] radiation on
    mem[8][31:16] preDataGateWidth
    mem[8][7:0] sampleEnd
    mem[95:32][31:0] pulse table data
output: 
    localPreDataGate_f(low active)
    localWgPulseWidth unit 0.1us
    localWgRfFreq
    localWgFlag
=============================================================*/
    reg[27:0] localPreDataGateTimeCnt;
    reg[27:0] localWgPriTime;//<=ibuf[1][23:0];
    reg localPreDataGate_f;
    reg[7:0] localWgSampleCnt; 
    reg[7:0] localWgSampleEnd; 
    reg[8:0] localWgSampleAddr; 
    reg[8:0] localWgSampleAddr0; 
    reg[8:0] localWgSampleAddr1; 
    reg[7:0] localWgRepeatCnt;
    reg[7:0] localWgFlag;//<=ibuf[1][31:24];
    reg[7:0] localWgRepeatEnd;//<=ibuf[0][31:24];
    reg[7:0] localWgRfFreq;//<=ibuf[0][23:16];
    reg[15:0] localWgPulseWidth;//<=ibuf[0][15:0];
    reg[31:0] memSaveBuf1;
    reg[31:0] memSaveFlag1;
    reg localWgSampleChg_f;
    
    always @(posedge clk160m) begin
        localPreDataGateTimeCnt<=localPreDataGateTimeCnt+1;
        if(localPreDataGateTimeCnt<bmem[8][31:16])begin //preDataGateWidth
            if(bmem[13][1])begin//localRedataGateOn_f
                localPreDataGate_f<=0;
            end    
        end    
        else    
            localPreDataGate_f<=1;
        //===========================================
        if(localPreDataGateTimeCnt==1)begin
            localWgSampleChg_f<=0;
            if(localWgPriTime<52*160)begin      //protect pri must over 52us
                localWgPriTime<=160*1000*100;        
            end
        end    
        if(localPreDataGateTimeCnt==(localWgPriTime-8))begin
            localWgRepeatCnt<=localWgRepeatCnt+1;
            if(localWgRepeatCnt>=localWgRepeatEnd)begin
                localWgRepeatCnt<=0;
                localWgSampleCnt<=localWgSampleCnt+1;    
                if(localWgSampleCnt>=localWgSampleEnd)begin
                    localWgSampleCnt<=0;
                    localWgSampleChg_f<=1;
                end           
            end
        end
        if(localPreDataGateTimeCnt==(localWgPriTime-6))begin
            localWgSampleAddr0<={localWgSampleCnt,1'b0};
            localWgSampleAddr1<={localWgSampleCnt,1'b1};
        end
        if(localPreDataGateTimeCnt==(localWgPriTime-4))begin
            localWgSampleAddr0<=localWgSampleAddr0+32;
            localWgSampleAddr1<=localWgSampleAddr1+32;
        end
        if(localPreDataGateTimeCnt==(localWgPriTime-2))begin
            localWgSampleEnd<= bmem[8][7:0];    //sampleEnd
            localWgRepeatEnd<=bmem[localWgSampleAddr0][31:24];
            localWgRfFreq<=bmem[localWgSampleAddr0][23:16];
            localWgPulseWidth<=bmem[localWgSampleAddr0][15:0];
            localWgFlag<=bmem[localWgSampleAddr1][31:24];
            localWgPriTime<={4'b0000,bmem[localWgSampleAddr1][23:0],4'b0000};
        end
        if(localPreDataGateTimeCnt>=localWgPriTime)begin
            localPreDataGateTimeCnt<=1;
        end    
    end
//===========================================================================================
    
    
    
    
    
    
    
/*===========================================================
purpose:
    generate emu Sp Signal
input: 
    mem[13][1] radiation on
    mem[8][31:16] preDataGateWidth
    mem[14][23:16] emu sp freq
    mem[14][4:0] emu sp pulse width table index
    mem[15][31:24] spEmuWgFlag
    mem[15][23:0] spEmuWgPriTime unit=0.1us
output: 
    spEmuPreDataGate_f
    spEmuWgRfFreq
    spEmuWgFlag
    spEmuWgPulseWidthTblInx
=============================================================*/
    reg spEmuPreDataGate_f;
    reg[5:0] spEmuWgRfFreq;
    reg[7:0] spEmuWgFlag;
    reg[4:0] spEmuWgPulseWidthTblInx;
    reg[31:0] spEmuWgPriTime;
    reg[31:0] spEmuPreDataGateTimeCnt;
    always @(posedge clk160m) begin
        spEmuPreDataGateTimeCnt<=spEmuPreDataGateTimeCnt+1;
        if(spEmuPreDataGateTimeCnt<bmem[8][31:16])begin //preDataGateWidth
            if(bmem[13][1])
                spEmuPreDataGate_f<=0;
        end    
        else    
            spEmuPreDataGate_f<=1;
        //===========================================    
        if(spEmuPreDataGateTimeCnt<52*160)begin
            if(spEmuPreDataGateTimeCnt==1)begin
                spEmuWgRfFreq<=bmem[14][23:16];
                spEmuWgPulseWidthTblInx<=bmem[14][4:0];
                spEmuWgFlag<=bmem[15][31:24];
                spEmuWgPriTime<={4'b0000,bmem[15][23:0],4'b0000};
            end
                
        end
        else begin
            if(spEmuPreDataGateTimeCnt>=spEmuWgPriTime)
                spEmuPreDataGateTimeCnt<=1;
        end
    end

//===================================================
// switch pin 
//===================================================
    reg[3:0] fpgaId;
    reg hostS1RxIn_f;
    reg hostS2RxIn_f;
    reg s1LocalRxIn_f;
    reg s1SyncRxIn_f;
    reg s1FibRxIn_f;
    reg s1RfRxIn_f;
    
    
    reg fibTxB1_f;
    reg fibTxB2_f;
    reg fibTxB3_f;
    reg fibTxB4_f;
    
    reg rxSysData1_in_f;
    reg rxSysData2_in_f;
    reg rxSysData3_in_f;
    reg rxSysData4_in_f;
    reg[7:0] fpgaIdDelay;
    reg[7:0] hdfoR;
    
    reg[15:0] s1SyncRxData0_reg;    
    reg[15:0] s1SyncRxData1_reg;   
    reg[15:0] s1SyncRxData2_reg;    
    reg[15:0] s1SyncRxData3_reg;
    
    
    reg[15:0] s1WgRxData0_reg;    
    reg[15:0] s1WgRxData1_reg;   
    reg[15:0] s1WgRxData2_reg;    
    reg[15:0] s1WgRxData3_reg;    
        
    
    reg s1SyncRxPack_f;
    reg s1WgRxPack_f;
    reg s1WgRxIn_f;
    reg[7:0] s1SyncRxPackCnt;

    reg[1:0] rxProcChkId;

    
    
    //always @* 
    //begin
    //always @* begin
    //end
    
    
    
    always @(posedge clk160m) begin
        fpgaId<=mem[8][11:8];
        rmem[36][3:0]<=fpgaId;
        //===================================
        fibTxB1_f<=txSysData1_data_w;
        fibTxB2_f<=txSysData1_data_w;
        fibTxB3_f<=txSysData1_data_w;
        fibTxB4_f<=txSysData1_data_w;
        hdfoR<=mem[17][7:0];
        //===================================
        if(fpgaId==0)begin//mast
            fpgaIdDelay<=0;
            rxProcChkId<=2'b01;
        end    
        if(fpgaId==1)begin//sub
            fpgaIdDelay<=bmem[16][7:0];
            rxProcChkId<=2'b00;
        end    
        if(fpgaId==2)begin//ctr
            fpgaIdDelay<=bmem[16][15:8];
            rxProcChkId<=2'b00;
        end    
        if(fpgaId==3)begin//drv
            fpgaIdDelay<=bmem[16][23:16];
            rxProcChkId<=2'b11;
        end    
        if(fpgaId==4)begin//drv
            fpgaIdDelay<=bmem[16][23:16];
            rxProcChkId<=2'b11;
        end    
        if(fpgaId==15)begin//mter
            fpgaIdDelay<=bmem[16][31:24];
            rxProcChkId<=2'b11;
        end    
        //===================================
        if(fpgaId==15)begin//mter
            hdfioDirA[0]<=1;
            hdfioDirA[2]<=1;
            hdfioDirA[6]<=1;
            hdfioOA[0]<=0;
            hdfioOA[2]<=txSysData1_data_w;
            rxSysData1_in_f<=hdfioIA[3];
            hdfioOA[6]<=s1VideoGate_f;
        end
        else begin
            hdfioDirA<=0;
            rxSysData1_in_f<=fibRxB1;
            rxSysData2_in_f<=fibRxB3;
            rxSysData3_in_f<=fibRxB5;
            rxSysData4_in_f<=fibRxB7;
        end    
        //==============================    
        if(bmem[13][9:8]==0)//hostS1RxFrom rf
            hostS1RxIn_f<=rfInA[4];
        if(bmem[13][9:8]==1)//hostS1RxFrom fiber
            hostS1RxIn_f<=fibRxA[0];
        if(bmem[13][9:8]==2)begin//hostS1RxFrom emu
            if(bmem[13][15:14]==0)//emuDelay
                hostS1RxIn_f<=s1SyncTxData_w;
            if(bmem[13][15:14]==1)
                hostS1RxIn_f<=hostEmuRxDataBuf[1][31];
            if(bmem[13][15:14]==2)
                hostS1RxIn_f<=hostEmuRxDataBuf[2][31];
            if(bmem[13][15:14]==3)
                hostS1RxIn_f<=hostEmuRxDataBuf[3][31];
        end
        //==============================    
        if(bmem[13][11:10]==0)//hostS2RxFrom
            hostS2RxIn_f<=rfInA[10];
        if(bmem[13][11:10]==1)//hostS2RxFrom
            hostS2RxIn_f<=fibRxA[1];
        if(bmem[13][11:10]==2)begin//hostS2RxFrom
            if(bmem[13][15:14]==0)//emuDelay
                hostS2RxIn_f<=s1SyncTxData_w;
            if(bmem[13][15:14]==1)
                hostS2RxIn_f<=hostEmuRxDataBuf[1][31];
            if(bmem[13][15:14]==2)
                hostS2RxIn_f<=hostEmuRxDataBuf[2][31];
            if(bmem[13][15:14]==3)
                hostS2RxIn_f <=hostEmuRxDataBuf[3][31];
        end        
        //==============================    
        if(bmem[8][11:8]==15)
            s1FibRxIn_f <= hdfioIA[1];
        else    
            s1FibRxIn_f <= fibRxA[0];
        s1RfRxIn_f <= rfInA[4];
        //===========================================================
        if(bmem[13][13:12]==0)begin//wgRxFrom rf
            s1WgRxIn_f <= rfInA[4];
            s1WgRxData0_reg<=s1RfRxData0_wb;
            s1WgRxData1_reg<=s1RfRxData1_wb;
            s1WgRxData2_reg<=s1RfRxData2_wb;
            s1WgRxData3_reg<=s1RfRxData3_wb;
            s1WgRxPack_f<=s1RfRxPack_w;
        end    
        if(bmem[13][13:12]==1)begin//wgRxFrom fib
            if(bmem[8][11:8]==15)
                s1WgRxIn_f <=hdfioIA[1];
            else    
                s1WgRxIn_f <=fibRxA[0];
            s1WgRxData0_reg<=s1FibRxData0_wb;
            s1WgRxData1_reg<=s1FibRxData1_wb;
            s1WgRxData2_reg<=s1FibRxData2_wb;
            s1WgRxData3_reg<=s1FibRxData3_wb;
            s1WgRxPack_f<=s1FibRxPack_w;
        end    
        if(bmem[13][13:12]==2)begin//wgRxFrom emu
            if(bmem[13][15:14]==0)begin//emuDelay
                s1LocalRxIn_f<=hostS1TxData_w;
                s1WgRxIn_f<=hostS1TxData_w;
            end      
            if(bmem[13][15:14]==1)begin
                s1LocalRxIn_f<=s1EmuRxDataBuf[1][31];
                s1WgRxIn_f<=s1EmuRxDataBuf[1][31];
            end    
            if(bmem[13][15:14]==2)begin
                s1LocalRxIn_f<=s1EmuRxDataBuf[2][31];
                s1WgRxIn_f<=s1EmuRxDataBuf[2][31];
            end    
            if(bmem[13][15:14]==3)begin
                s1LocalRxIn_f<=s1EmuRxDataBuf[3][31];
                s1WgRxIn_f<=s1EmuRxDataBuf[3][31];
            end    
            s1WgRxData0_reg<=s1LocalRxData0_wb;
            s1WgRxData1_reg<=s1LocalRxData1_wb;
            s1WgRxData2_reg<=s1LocalRxData2_wb;
            s1WgRxData3_reg<=s1LocalRxData3_wb;
            s1WgRxPack_f<=s1LocalRxPack_w;
        end 
        if(bmem[13][13:12]==3)begin//
            s1WgRxIn_f <= hostS1TxData_w;
            s1WgRxData0_reg <=s1LocalRxData0_wb;
            s1WgRxData1_reg<=s1LocalRxData1_wb;
            s1WgRxData2_reg<=s1LocalRxData2_wb;
            s1WgRxData3_reg<=s1LocalRxData3_wb;
            s1WgRxPack_f<=s1LocalRxPack_w;
        end 
        //===========================================================
        if(bmem[13][21:21]==0)begin//subSyncRxFrom
            s1SyncRxIn_f<= rfInA[4];
            s1SyncRxData0_reg<=s1RfRxData0_wb;
            s1SyncRxData1_reg<=s1RfRxData1_wb;
            s1SyncRxData2_reg<=s1RfRxData2_wb;
            s1SyncRxData3_reg<=s1RfRxData3_wb;
            s1SyncRxPack_f<=s1RfRxPack_w;
            s1SyncRxPackCnt<=s1RfRxPack_cnt;
        end      
        else begin                    
            s1SyncRxIn_f<= fibRxA[0];
            s1SyncRxData0_reg<=s1FibRxData0_wb;
            s1SyncRxData1_reg<=s1FibRxData1_wb;
            s1SyncRxData2_reg<=s1FibRxData2_wb;
            s1SyncRxData3_reg<=s1FibRxData3_wb;
            s1SyncRxPack_f<=s1FibRxPack_w;
            s1SyncRxPackCnt<=s1FibRxPack_cnt;
        end      
    end

    
    
/*===========================================================
purpose: 
    switch singnal channel
input:
output: 
=============================================================*/
    reg hostWgPreDataGate_f;
    reg[15:0] hostWgPulseWidth;
    reg[7:0] hostWgRfFreq;
    reg[7:0] hostWgFlag;
    reg rf1TxData;
    reg rf2TxData;
    reg fib1TxData;
    reg fib2TxData;
    reg fib3TxData;
    reg fib4TxData;
    
    //always @* begin
    always @(posedge clk160m) begin

        if(bmem[13][5:4]==0)begin //radiation off
            hostWgPreDataGate_f<=1;
            hostWgPulseWidth<=1000;//unit 0.1us
            hostWgRfFreq<=0;
            hostWgFlag<=0;
        end
        if(bmem[13][5:4]==1)begin //sp
            hostWgPreDataGate_f<=hdfioIA[7];
            hostWgPulseWidth<=bmem[hdfioIA[13:9]+96][15:0];//unit 0.1us
            hostWgRfFreq<={hdfioIA[6],7'b0000000};
            hostWgFlag<=spEmuWgFlag;
        end
        if(bmem[13][5:4]==2)begin //local
            hostWgPreDataGate_f<=localPreDataGate_f;
            hostWgPulseWidth<=localWgPulseWidth;
            hostWgRfFreq<=localWgRfFreq;
            hostWgFlag<=localWgFlag;
        end
        if(bmem[13][5:4]==3)begin //emuSp
            hostWgPreDataGate_f<=spEmuPreDataGate_f;
            hostWgPulseWidth<=bmem[spEmuWgPulseWidthTblInx+96][15:0];//unit 0.1us
            hostWgRfFreq<=spEmuWgRfFreq;
            hostWgFlag<=spEmuWgFlag;
        end
        // 0:aRfmaCko,  1:aRfmaDio1,  2:aRfmaD0,  3:aRfmbCko,  4:aRfmbDio1,  5:aRfmbD0,
        // 6:bRfmaCko,  7:bRfmaDio1,  8:bRfmaD0,  9:bRfmbCko,  10:bRfmbDio1,  11:bRfmbD0,
        //input wire [11:0] rfInA,
        //output [3:0] fibTxA,    		
        //input   wire [3:0] fibRxA,
        if(bmem[13][7:6]==0)begin//mastere
            if(bmem[13][8:8]==1)begin
                fib1TxData<=hostS1TxData_w;
                rf1TxData<=0;
                txSyncClkEn1_f<=0;
            end
            else begin
               rf1TxData<=hostS1TxData_w;
               fib1TxData<=0;
               txSyncClkEn1_f<=1;
            end
            
            if(bmem[13][10:10]==1)begin
                rf2TxData<=0;
                fib2TxData<=hostS2TxData_w;
                txSyncClkEn2_f<=0;
            end
            else begin
                rf2TxData<=hostS2TxData_w;
                fib2TxData<=0;
                txSyncClkEn2_f<=1;
            end
            fib3TxData<=0;
            fib4TxData<=0;
        end
        if(bmem[13][7:6]==1)begin//sub
            rf1TxData<=s1SyncTxData_w;
            rf2TxData<=0;
            fib1TxData<=s1SyncTxData_w;
            fib2TxData<=s1WgRxIn_f;//data through
            fib3TxData<=s1WgRxIn_f;//data through
            fib4TxData<=s1WgRxIn_f;//data through
            if(bmem[13][21:21]==0)
                txSyncClkEn1_f<=1; 
            else               
                txSyncClkEn1_f<=0; 
            
        end
        if(bmem[13][7:6]==2)begin//ctr
            txSyncClkEn1_f<=0; 
            rf1TxData<=0;
            rf2TxData<=0;
            fib1TxData<=s1WgRxIn_f;//data through
            fib2TxData<=s1WgRxIn_f;//data through
            fib3TxData<=s1WgRxIn_f;//data through
            fib4TxData<=s1WgRxIn_f;//data through
        end
        if(bmem[13][7:6]==3)begin//endPoint
            txSyncClkEn1_f<=0; 
            rf1TxData<=0;
            rf2TxData<=0;
            fib1TxData<=s1WgRxIn_f;
            fib2TxData<=s1WgRxIn_f;
            fib3TxData<=s1WgRxIn_f;
            fib4TxData<=s1WgRxIn_f;
        end
    end
    
    
    
reg[23:0] hostAutoPreDataGateWaitCnt;
reg wgProtectFlag;
/*===========================================================
purpose: 
    generate wgActTimeCnt
input:
    hostWgPreDataGate_f
    bmem[12][15:0] hostAutoDelayTime
    bmem[12][31:16] hostAutoPreDataPri
output: 
    wgActTimeCnt;
    hostInhibit_f;
    preTxTime[hostTxSerial[0]]<=realTimeCnt;
=============================================================*/
    reg [23:0] wgActTimeCnt;
    reg [23:0] wgActWaitTimeCnt;
    reg [23:0] wgActWidthTimeCnt;
    reg hostWgPreDataGate_ff;
    reg hostInhibit_f;
    reg[23:0] preTxTime[1:0];
    always @(posedge clk160m) begin
        if(!wgActTimeCnt[23])
            wgActTimeCnt<=wgActTimeCnt+1;
        if(!wgActWaitTimeCnt[23])
            wgActWaitTimeCnt<=wgActWaitTimeCnt+1;
        if(!hostWgPreDataGate_f)begin
            if(hostWgPreDataGate_ff)begin//H2L
                wgActTimeCnt<=0;
                wgActWaitTimeCnt<=0;
                wgActWidthTimeCnt<=1;
                hostInhibit_f<=0;
                preTxTime[hostTxSerial[0]]<=realTimeCnt;
            end
        end
        hostWgPreDataGate_ff<=hostWgPreDataGate_f;
        //=====================================================
        if(wgActWaitTimeCnt>=bmem[12][15:0])begin    //hostAutoDelayTime
            wgActWidthTimeCnt<=wgActWidthTimeCnt+1;
            if(wgActWidthTimeCnt>=bmem[12][31:16])//hostAutoPreDataPri
                wgActWidthTimeCnt<=1;
            if(wgActWaitTimeCnt==bmem[12][15:0] || wgActWidthTimeCnt==1)begin
                wgActTimeCnt<=0;
                hostInhibit_f<=1;
                preTxTime[hostTxSerial[0]]<=realTimeCnt;
                wgActWidthTimeCnt<=2;
            end
        end
    end
    
/*===========================================================
purpose: 
    generate hostWgTrigGate_f hostVideoGate_f
input:
    wgActTimeCnt//pri time
    hostWgPulseWidth    
    bmem[6][19:0] vgTimeDelay
    bmem[9][19:0] wgPulseTimeDelay(vg sub)
    bmem[4][31:16] preTrigTime
    bmem[4][15:8] preRfOutTime
output: 
    hostWgTrigGate_f(high act)
    hostVideoGate_f(high act)
=============================================================*/
    reg[19:0] hostVideoGateDelayTimeCnt;
    reg[19:0] hostVideoGatePulseWidth;
    reg[19:0] hostWgTrigGateWidthTimeCnt;
    reg hostWgTrigGate_f;
    reg hostVideoGate_f;
    reg[19:0] hostVideoGateDelayTime;
    reg[19:0] hostVideoGateWidthTimeCnt;
    reg[19:0] hostWgTrigGateDelayTime;
    
    always @(posedge clk160m) begin
        if(wgActTimeCnt==0)begin
            if(!hostInhibit_f)begin            
                hostVideoGateDelayTimeCnt<=1;
                hostWgTrigGate_f<=0;
                hostVideoGate_f<=0;
            end    
        end
        else begin
            hostWgTrigGateWidthTimeCnt<=hostWgTrigGateWidthTimeCnt+1;
            hostVideoGateWidthTimeCnt<=hostVideoGateWidthTimeCnt+1;
            if(hostWgTrigGateWidthTimeCnt==16)//preDataGateWidth
                hostWgTrigGate_f<=0;
            if(hostVideoGateWidthTimeCnt==hostVideoGatePulseWidth)
                hostVideoGate_f<=0;
            if(hostVideoGateDelayTimeCnt<12800)begin//80us
                hostVideoGateDelayTimeCnt<=hostVideoGateDelayTimeCnt+1;
                if(hostVideoGateDelayTimeCnt==1)
                    hostVideoGateDelayTime<=bmem[6][19:0];//hostPreTrig to vg-gate time
                if(hostVideoGateDelayTimeCnt==2)
                    hostWgTrigGateDelayTime<=hostVideoGateDelayTime-bmem[9][19:0];
                if(hostVideoGateDelayTimeCnt==3)
                    hostWgTrigGateDelayTime<=hostWgTrigGateDelayTime-{bmem[4][31:16],4'b0000};
                if(hostVideoGateDelayTimeCnt==4)
                    hostWgTrigGateDelayTime<=hostWgTrigGateDelayTime-{bmem[4][15:8],4'b0000};
                if(hostVideoGateDelayTimeCnt==hostWgTrigGateDelayTime)begin
                    hostWgTrigGate_f<=1;
                    hostWgTrigGateWidthTimeCnt<=1;
                    hostVideoGatePulseWidth<={hostWgPulseWidth,4'b0000};    
                end   
                if(hostVideoGateDelayTimeCnt==hostVideoGateDelayTime)begin
                    hostVideoGate_f<=1;
                    hostVideoGateWidthTimeCnt<=1;
                end   
            end
        end
    end
/*===========================================================
purpose: 
    generate hostPreDataGate_f(for transmit purpose)
input:
    wgActTimeCnt
    hostCommandData
    hostSoundData
    hostInhibit_f
    bmem[2][27] wgProtectFlag
    hostWgRfFreq
    hostWgPulseWidth
    commDelayTime
    hostS1RxPackCnt
output: 
    hostPreDataGate_f(low act)
    hostTxSerial(for calculate response back time purpose)
    hostS1TxData[3:0][15:0]
    hostS2TxData[3:0][15:0]

=============================================================*/
    reg[7:0] hostPreDataGateTimeCnt;
    reg hostPreDataGate_f;
    reg[7:0] hostTxSerial;
    reg[15:0] hostS1TxData0;
    reg[15:0] hostS1TxData1;
    reg[15:0] hostS1TxData2;
    reg[15:0] hostS1TxData3;
    reg[15:0] hostS2TxData0;
    reg[15:0] hostS2TxData1;
    reg[15:0] hostS2TxData2;
    reg[15:0] hostS2TxData3;
    reg[31:0] hostSxTxStatusBuf;
    reg[31:0] hostSxTxStatusBufCnt;
    reg[0:0] debug0_f;
    reg[0:0] debug1_f;
    reg[0:0] hostSxRepeatCnt;
    reg[8:0] hostSxRepeatBuf;
    
    always @(posedge clk160m) begin
        if(wgActTimeCnt==0)begin
            hostPreDataGate_f<=0;
            hostPreDataGateTimeCnt<=1;
            hostTxSerial<=hostTxSerial+1;
            //=========================================
            hostS1TxData0<={hostTxSerial,8'h00};//8:8 TxSerialCnt,4m clock sync delay time
            ///hostS1TxData1[15:0]<=hostCommandData;
            hostS1TxData2[15:8]<=hostS1SoundData;
            hostS1TxData2[7]<=hostInhibit_f;
            hostS1TxData2[6]<=bmem[2][27];//wgProtectBit
            hostS1TxData2[5:0]<=hostWgRfFreq;
            //==
            hostS2TxData0<={hostTxSerial,8'h00};
            //hostS2TxData1[15:0]<=hostCommandData;
            hostS2TxData2[15:8]<=hostS2SoundData;
            hostS2TxData2[7]<=hostInhibit_f;
            hostS2TxData2[6]<=bmem[2][27];//wgProtectBit
            hostS2TxData2[5:0]<=hostWgRfFreq;
            //============================================
            hostSxRepeatCnt<=hostSxRepeatCnt+1;
            if(hostSxRepeatCnt==0)begin
                if(mem[101]==hostSxTxStatusBuf)begin //no sync status data
                    hostS1TxData1<={hostSxTxStatusBufCnt[1:0],2'b00,hostS1RxPackCnt[2:0],9'b111111111}; //2:2:3:1:8 txSerailCnt,txId,s1RxPackCnt,dataDisable_f,data
                    hostS2TxData1<={hostSxTxStatusBufCnt[1:0],2'b00,hostS2RxPackCnt[2:0],9'b111111111};
                    hostSxRepeatBuf<=9'b111111111;
                    end    
                else begin
                    hostS1TxData1<={hostSxTxStatusBufCnt[1:0],2'b00,hostS1RxPackCnt[2:0],mem[101][8:0]};
                    hostS2TxData1<={hostSxTxStatusBufCnt[1:0],2'b00,hostS2RxPackCnt[2:0],mem[101][8:0]};
                    hostSxRepeatBuf<=mem[101][8:0];
                    hostSxTxStatusBuf<=mem[101];
                    rmem[42]<=hostSxTxStatusBufCnt;//txed flag
                    hostSxTxStatusBufCnt<=hostSxTxStatusBufCnt+1;   
                    test1_f<=test1_f^1;        
                end    
            end
            else begin
                hostS1TxData1<={hostSxTxStatusBufCnt[1:0],2'b00,hostS1RxPackCnt[2:0],hostSxRepeatBuf};
                hostS2TxData1<={hostSxTxStatusBufCnt[1:0],2'b00,hostS2RxPackCnt[2:0],hostSxRepeatBuf};
            end
            
            if(hostInhibit_f)begin
                hostS1TxData3[15:11]<=5'b0000;
                hostS2TxData3[15:11]<=5'b0000;
                hostS1TxData3[10:0]<=s1CommDelayTime[11:1];
                hostS2TxData3[10:0]<=s2CommDelayTime[11:1];
            end
            else begin
                hostS1TxData3[15:0]<=hostWgPulseWidth;
                hostS2TxData3[15:0]<=hostWgPulseWidth;
            end    
        end
        else begin
            if(hostPreDataGateTimeCnt<=16)begin
                hostPreDataGateTimeCnt<=hostPreDataGateTimeCnt+1;
            end
            else
                hostPreDataGate_f<=1;
        end        
    end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
/*===========================================================
purpose:
    generate hostS1RxGate_f 
input:
    hostS1RxPack_w
    hostS1RxData0_wb[7:0] rfBaseClkSyncDeltaTime
output: 
    hostS1RxGate_f 
=============================================================*/
    reg[15:0] hostS1RxGateDelayTimeCnt;
    reg hostS1RxGate_f;
    reg[15:0] hostS1RxGateTimeCnt;
    always @(posedge clk160m) begin
        if(hostS1RxPack_w)begin
            hostS1RxGateDelayTimeCnt<={8'b0000_0000,hostS1RxData0_wb[7:0]};    
            hostS1RxGate_f<=1;
        end    
        else begin
            hostS1RxGateTimeCnt<=hostS1RxGateTimeCnt+1;
            if(hostS1RxGateTimeCnt==16)
                hostS1RxGate_f<=1;
            if(hostS1RxGateDelayTimeCnt<16'hff00)begin
                hostS1RxGateDelayTimeCnt<=hostS1RxGateDelayTimeCnt+1;
                if(hostS1RxGateDelayTimeCnt==320)begin
                    hostS1RxGate_f<=0;
                    hostS1RxGateTimeCnt<=1;
                end   
            end
        end
    end
    


/*===========================================================
purpose:
    generate hostS2RxGate_f 
input:
    hostS2RxPack_w
    hostS2RxData0_wb[7:0] rfBaseClkSyncDeltaTime
output: 
    hostS2RxGate_f 
=============================================================*/
    reg[15:0] hostS2RxGateDelayTimeCnt;
    reg hostS2RxGate_f;
    reg[15:0] hostS2RxGateTimeCnt;
    always @(posedge clk160m) begin
        if(hostS2RxPack_w)begin
            hostS2RxGateDelayTimeCnt<={8'b0000_0000,hostS2RxData0_wb[7:0]};    
            hostS2RxGate_f<=1;
        end    
        else begin
            hostS2RxGateTimeCnt<=hostS2RxGateTimeCnt+1;
            if(hostS2RxGateTimeCnt==16)
                hostS2RxGate_f<=1;
            if(hostS2RxGateDelayTimeCnt<16'hff00)begin
                hostS2RxGateDelayTimeCnt<=hostS2RxGateDelayTimeCnt+1;
                if(hostS2RxGateDelayTimeCnt==320)begin
                    hostS2RxGate_f<=0;
                    hostS2RxGateTimeCnt<=1;
                end   
            end
        end
    end

        
/*===========================================================
purpose:
    generate hostS1 commDelayTime 
input:
    hostInhibit_f
    hostS1RxGate_f
    preTxTime[1~0]
    realTimeCnt
    hostS1RxData0_wb[8]  seiral cnt lsb
    bmem[11][19:0] commBaseTime :3de8
    bmem[7][15:0] fiber delay 0x100
    bmem[7][31:16] rf delay 0x100
output: 
    commDelayTime
    rmem[5:0]
=============================================================*/
    reg[23:0] s1CommTime;
    reg[23:0] s1CommTime0;
    reg[23:0] s1CommTime1;
    reg[15:0] hostS1RxGateHTimeCnt;
    reg[23:0] s1CommDeltaTime;
    reg[23:0] s1CommDelayTime;
    always @(posedge clk160m) begin
        if(!hostS1RxGate_f)begin
            hostS1RxGateHTimeCnt<=0;    
        end    
        else begin
            if(!hostS1RxGateHTimeCnt[15])begin
                hostS1RxGateHTimeCnt<=hostS1RxGateHTimeCnt+1;
                if(hostInhibit_f)begin
                    if(hostS1RxGateHTimeCnt==0)begin
                        s1CommTime0<=realTimeCnt-preTxTime[hostS1RxData0_wb[8]];
                        s1CommTime1<=realTimeCnt-preTxTime[!hostS1RxData0_wb[8]];
                    end
                    if(hostS1RxGateHTimeCnt==1)begin
                        if(s1CommTime0>=s1CommTime1)
                            s1CommTime<=s1CommTime0;
                        else    
                            s1CommTime<=s1CommTime1;
                    end 
                    
                    if(hostS1RxGateHTimeCnt==2)begin
                        rmem[4]<=s1CommTime;
                        if(s1CommTime<15595)
                            s1CommTime<=15595;
                    end
                    if(hostS1RxGateHTimeCnt==3)begin
                        rmem[0]<={hostS1RxData1_wb,hostS1RxData0_wb};
                        rmem[1]<={hostS1RxData3_wb,hostS1RxData2_wb};
                        rmem[2]<=s1CommTime;
                        rmem[3]<=s1CommTime-bmem[11][15:0];
                        s1CommDeltaTime<=s1CommTime-bmem[11][15:0];
                    end
                    if(hostS1RxGateHTimeCnt==4)begin
                        if(bmem[13][9:8]==0)//hostS1RxFrom rf
                            s1CommDeltaTime<=s1CommDeltaTime-bmem[7][31:16];// rf delay
                        if(bmem[13][9:8]==1)//hostS1RxFrom fiber
                            s1CommDeltaTime<=s1CommDeltaTime-bmem[7][15:0];//fiber delay
                        if(bmem[13][9:8]==2)//hostS1RxFrom emu
                            s1CommDeltaTime<=s1CommDeltaTime-256;
                    end                
                    if(hostS1RxGateHTimeCnt==5)begin
                        //s1CommDeltaTime<=s1CommDeltaTime-fpgaIdDelay;
                    end                
                    if(hostS1RxGateHTimeCnt==6)begin
                        if(!s1CommDeltaTime[23])begin
                            if(s1CommDelayTime<s1CommDeltaTime)
                                s1CommDelayTime<=s1CommDelayTime+1;
                            if(s1CommDelayTime>s1CommDeltaTime)
                                s1CommDelayTime<=s1CommDelayTime-1;
                        end
                        else
                            s1CommDelayTime<=0;
                    end
                    if(hostS1RxGateHTimeCnt==7)begin
                        rmem[5]<=s1CommDelayTime;
                    end

                end
            end
        end
    end
    



/*===========================================================
purpose:
    generate hostS2 commDelayTime 
input:
    hostInhibit_f
    hostS2RxGate_f
    preTxTime[1~0]
    realTimeCnt
    hostS2RxData0_wb[8]  seiral cnt lsb
    bmem[11][19:0] commBaseTime :3de8
    bmem[7][15:0] fiber delay 0x100
    bmem[7][31:16] rf delay 0x100
output: 
    commDelayTime
    rmem[13:8]
=============================================================*/
    reg[23:0] s2CommTime;
    reg[23:0] s2CommTime0;
    reg[23:0] s2CommTime1;
    reg[15:0] hostS2RxGateHTimeCnt;
    reg[23:0] s2CommDeltaTime;
    reg[23:0] s2CommDelayTime;
    always @(posedge clk160m) begin
        if(!hostS2RxGate_f)begin
            hostS2RxGateHTimeCnt<=0;    
        end    
        else begin
            if(!hostS2RxGateHTimeCnt[15])begin
                hostS2RxGateHTimeCnt<=hostS2RxGateHTimeCnt+1;
                if(hostInhibit_f)begin
                    if(hostS2RxGateHTimeCnt==0)begin
                        s2CommTime0<=realTimeCnt-preTxTime[hostS2RxData0_wb[8]];
                        s2CommTime1<=realTimeCnt-preTxTime[!hostS2RxData0_wb[8]];
                    end
                    if(hostS2RxGateHTimeCnt==1)begin
                        if(s2CommTime0>=s2CommTime1)
                            s2CommTime<=s2CommTime0;
                        else    
                            s2CommTime<=s2CommTime1;
                    end 
                    
                    if(hostS2RxGateHTimeCnt==2)begin
                        rmem[12]<=s2CommTime;
                        if(s2CommTime<15595)
                            s2CommTime<=15595;
                    end
                    if(hostS2RxGateHTimeCnt==3)begin
                        rmem[8]<={hostS2RxData1_wb,hostS2RxData0_wb};
                        rmem[9]<={hostS2RxData3_wb,hostS2RxData2_wb};
                        rmem[10]<=s2CommTime;
                        rmem[11]<=s2CommTime-bmem[11][15:0];
                        s2CommDeltaTime<=s2CommTime-bmem[11][15:0];
                    end
                    if(hostS2RxGateHTimeCnt==4)begin
                        if(bmem[13][9:8]==0)//hostS2RxFrom rf
                            s2CommDeltaTime<=s2CommDeltaTime-bmem[7][31:16];// rf delay
                        if(bmem[13][9:8]==1)//hostS2RxFrom fiber
                            s2CommDeltaTime<=s2CommDeltaTime-bmem[7][15:0];//fiber delay
                        if(bmem[13][9:8]==2)//hostS2RxFrom emu
                            s2CommDeltaTime<=s2CommDeltaTime-256;
                    end                
                    if(hostS2RxGateHTimeCnt==5)begin
                        //s2CommDeltaTime<=s2CommDeltaTime-fpgaIdDelay;
                    end                
                    if(hostS2RxGateHTimeCnt==6)begin
                        if(!s2CommDeltaTime[23])begin
                            if(s2CommDelayTime<s2CommDeltaTime)
                                s2CommDelayTime<=s2CommDelayTime+1;
                            if(s2CommDelayTime>s2CommDeltaTime)
                                s2CommDelayTime<=s2CommDelayTime-1;
                        end
                        else
                            s2CommDelayTime<=0;
                    end
                    if(hostS2RxGateHTimeCnt==7)begin
                        rmem[13]<=s2CommDelayTime;
                    end

                end
            end
        end
    end
    

      
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************








    









    
    

        


//===================================================
// generate s1SyncPreDataGate 
//===================================================



/*===========================================================
purpose:
    generate s1SyncPreDataGate_f 
input:
    s1RxPack_f
    s1SyncRxData0_reg
    s1SyncRxData1_reg
    s1SyncRxData2_reg
    s1SyncRxData3_reg
output: 
    s1SyncPreDataGate_f
=============================================================*/
    reg[7:0] s1SyncRxPackHTimeCnt;
    reg s1SyncPreDataGate_f;
    reg[15:0] s1SyncTxData0;
    reg[15:0] s1SyncTxData1;
    reg[15:0] s1SyncTxData2;
    reg[15:0] s1SyncTxData3;
    reg[19:0] s1VideoGateCommPathTime;
    reg[19:0] s1SyncWgPulseWidth;
    reg[23:0] wgData;
    reg[15:0] s1SyncRespDelayTimeCnt;
    reg[15:0] s1SyncRespDelayTime;
    reg[15:0] s1SyncPreDataGateTimeCnt;
    reg[7:0] testBuf;
    reg[7:0] s1PackRxCnt;
    reg[7:0] s1StatusDataCnt;
    
    reg[31:0] s1TxStatusBuf;
    reg[31:0] s1TxStatusBufCnt;
    reg[4:0] s1RxCommandDataCnt;
    reg test1_f;
    
    always @(posedge clk160m) begin
        if(s1SyncRxPack_f)begin
            if(!s1SyncRxPackHTimeCnt[7])begin
                s1SyncRxPackHTimeCnt<=s1SyncRxPackHTimeCnt+1;
                if(s1SyncRxPackHTimeCnt==0)begin
                    s1PackRxCnt<=s1PackRxCnt+1;
                    rmem[40][15:8]<=s1PackRxCnt;
                    s1SyncRespDelayTimeCnt<={8'b0000_0000,s1SyncRxData0_reg[7:0]};//<<debug    
                    s1SyncPreDataGate_f<=1;
                    s1SyncTxData0<=s1SyncRxData0_reg;
                    //s1TxData1<=s1StatusData;
                    s1SyncTxData2[15:8]<=s1SoundData;
                    s1SyncTxData3[15:0]<=0;
                    
                    rmem[47]<={s1SyncRxData1_reg,s1SyncRxData0_reg};
                    rmem[48]<={s1SyncRxData3_reg,s1SyncRxData2_reg};
                    
                    //============================================
                    if(mem[100]==s1TxStatusBuf)begin
                        s1SyncTxData1<={4'b0001,s1SyncRxPackCnt[2:0],9'b111111111};
                    end    
                    else begin
                        s1SyncTxData1<={4'b0001,s1SyncRxPackCnt[2:0],mem[100][8:0]};
                        s1TxStatusBuf<=mem[100];
                        rmem[41]<=s1TxStatusBufCnt;
                        s1TxStatusBufCnt<=s1TxStatusBufCnt+1;           
                    end  
                    if(!s1SyncRxData1_reg[8:8])begin  
                        smem1[s1RxCommandDataCnt]<=s1SyncRxData1_reg;
                        s1RxCommandDataCnt<=s1RxCommandDataCnt+1;
                        rmem[43]<=s1RxCommandDataCnt;
                    end
                    //============================================
                end
            end
        end    
        else begin
            s1SyncRxPackHTimeCnt<=0;
            s1SyncPreDataGateTimeCnt<=s1SyncPreDataGateTimeCnt+1;
            if(s1SyncPreDataGateTimeCnt==16)//mem[8][31:16])//1us
                s1SyncPreDataGate_f<=1;
            if(s1SyncRespDelayTimeCnt<19200)begin//120us
                s1SyncRespDelayTimeCnt<=s1SyncRespDelayTimeCnt+1;
                if(s1SyncRespDelayTimeCnt==s1SyncRespDelayTime)begin
                     s1SyncPreDataGate_f<=0;
                     s1SyncPreDataGateTimeCnt<=1;
                end   
            end
        end
    end    
    
    



/*===========================================================
purpose:
    generate s1WgGate_f 
input:
    s1WgRxPack_f
    s1WgRxData0_reg
    s1WgRxData1_reg
    s1WgRxData2_reg
    s1WgRxData3_reg
output: 
    s1WgGate_f (low act)
    wgData[23:0]
    rmem[5]
=============================================================*/
    reg[7:0] s1WgRxPackHTimeCnt;
    reg[15:0] s1WgRespDelayTimeCnt;
    reg[15:0] s1WgRespDelayTime;
    reg[15:0] s1WgPreDataGateTimeCnt;
    reg[7:0] s1WgPackRxCnt;
    reg s1WgGate_f;
    reg s1WgInhibit_f;
    reg s1WgSspaProtect_f;
    reg[5:0] s1WgRfFreq;
    
    
    
    always @(posedge clk160m) begin
        if(s1WgRxPack_f)begin
            testBuf[0]<=0;
            if(!s1WgRxPackHTimeCnt[7])begin
                s1WgRxPackHTimeCnt<=s1WgRxPackHTimeCnt+1;
                if(s1WgRxPackHTimeCnt==0)begin
                    testBuf[1]=!testBuf[1];
                    s1WgPackRxCnt<=s1WgPackRxCnt+1;
                    rmem[40][23:16]<=s1WgPackRxCnt;
                    if(mem[13][13:12]==2)//local
                        s1WgRespDelayTimeCnt<=s1WgRxData0_reg[7:0];    
                    else    
                        s1WgRespDelayTimeCnt<=s1VideoGateCommPathTime+s1WgRxData0_reg[7:0];    
                    s1WgGate_f<=1;
                    s1WgInhibit_f<=s1WgRxData2_reg[7];
                    s1WgSspaProtect_f<=s1WgRxData2_reg[6];
                    s1WgRfFreq<=s1WgRxData2_reg[5:0];
                    //============================================
                    if(s1WgRxData2_reg[7])begin 
                        s1VideoGateCommPathTime<={9'b000000000,s1WgRxData3_reg[10:0]};  
                        //s1VideoGateCommPathTime<=0;
                    end    
                    else begin    
                        s1SyncWgPulseWidth<={s1WgRxData3_reg[15:0],4'b0000};
                    end    
                end
                if(s1WgRxPackHTimeCnt==1)begin
                    if(mem[13][13:12]!=2)
                        s1WgRespDelayTimeCnt<=s1WgRespDelayTimeCnt+fpgaIdDelay;
                    wgData[23:23]<=s1WgSspaProtect_f;
                    wgData[22:16]<=7'b000_0000;
                    wgData[15:8]<={2'b00,s1WgRfFreq};
                    wgData[7:6]<=2'b11;
                    wgData[5:0]<=s1WgRfFreq ^ 6'b11_1111;
                end
                if(s1WgRxPackHTimeCnt==2)begin
                    rmem[49]<={s1WgRespDelayTime,s1WgRespDelayTimeCnt};
                end
            end
        end    
        else begin
            testBuf[0]<=1;
            s1WgRxPackHTimeCnt<=0;
            s1WgPreDataGateTimeCnt<=s1WgPreDataGateTimeCnt+1;
            if(s1WgPreDataGateTimeCnt==16)
                s1WgGate_f<=1;
            if(s1WgRespDelayTimeCnt<19200)begin//120us
                s1WgRespDelayTimeCnt<=s1WgRespDelayTimeCnt+1;
                if(s1WgRespDelayTimeCnt==s1WgRespDelayTime)begin
                    if(!s1WgInhibit_f)begin
                        s1WgGate_f<=0;
                        s1WgPreDataGateTimeCnt<=1;
                    end    
                end   
            end
        end
    end    
    
    
    
    
    

/*===========================================================
purpose:
    generate s1WgTrigGate_f and s1VideoGate_f
input:
    s1WgGate_f
    s1VideoGateCommPathTime
    bmem[10][19:0] s1VgTimeDelay
    bmem[9][19:0] wgPulseTimeDelay(vg sub)
    bmem[4][31:16] preTrigTime
    bmem[4][15:8] preRfOutTime
output: 
    s1WgTrigGate_f
    s1VideoGate_f
=============================================================*/
    reg[19:0] s1VideoGateDelayTimeCnt;
    reg[19:0] s1VideoGateWidthTime;
    reg s1WgGate_ff;
    reg s1VideoGate_f;
    reg[19:0] s1WgTrigGateWidthTimeCnt;
    reg s1WgTrigGate_f;
    reg[19:0] s1VideoGateDelayTime;
    reg[19:0] s1VideoGateWidthTimeCnt;
    reg[19:0] s1WgTrigGateDelayTime;
    
    always @(posedge clk160m) begin
        if(s1VideoGateDelayTimeCnt<12800)//80usus
            s1VideoGateDelayTimeCnt<=s1VideoGateDelayTimeCnt+1;
        if(!s1WgGate_f)begin
            if(s1WgGate_ff)begin//H2L
                if(!s1WgInhibit_f)begin
                    s1VideoGateDelayTimeCnt<=1;
                    s1VideoGate_f<=0;
                    s1VideoGateWidthTime<=s1SyncWgPulseWidth;
                end    
            end
            s1WgGate_ff<=s1WgGate_f;
        end  
        else begin
            s1WgGate_ff<=s1WgGate_f;
        end
        //====    
        s1WgTrigGateWidthTimeCnt<=s1WgTrigGateWidthTimeCnt+1;
        s1VideoGateWidthTimeCnt<=s1VideoGateWidthTimeCnt+1;
        if(s1WgTrigGateWidthTimeCnt==16)
            s1WgTrigGate_f<=0;
        if(s1VideoGateWidthTimeCnt==s1VideoGateWidthTime)
            s1VideoGate_f<=0;
        //====    
        if(s1VideoGateDelayTimeCnt==1)
            s1VideoGateDelayTime<=bmem[10][19:0];
        if(s1VideoGateDelayTimeCnt==2)
            s1VideoGateDelayTime<=s1VideoGateDelayTime-s1VideoGateCommPathTime;
        if(s1VideoGateDelayTimeCnt==3)
            s1WgTrigGateDelayTime<=s1VideoGateDelayTime-bmem[9][19:0];
        if(s1VideoGateDelayTimeCnt==4)
            s1WgTrigGateDelayTime<=s1WgTrigGateDelayTime-{bmem[4][31:16],4'b0000};
        if(s1VideoGateDelayTimeCnt==5)
            s1WgTrigGateDelayTime<=s1WgTrigGateDelayTime-{bmem[4][15:8],4'b0000};
        if(s1VideoGateDelayTimeCnt==s1WgTrigGateDelayTime)begin
            if(!s1WgInhibit_f)
                s1WgTrigGate_f<=1;
            s1WgTrigGateWidthTimeCnt<=1;
        end   
        if(s1VideoGateDelayTimeCnt==s1VideoGateDelayTime)begin
            if(!s1WgInhibit_f)
                s1VideoGate_f<=1;
            s1VideoGateWidthTimeCnt<=1;
        end   
    end    


    
    
    

/*===========================================================
purpose:
    generate wg signale
input:
    s1WgTrigGate_f
    bmem[10][19:0] s1VgTimeDelay
    bmem[9][19:0] wgPulseTimeDelay(vg sub)
    bmem[4][31:16] preTrigTime
    bmem[4][15:8] preRfOutTime
    bmem[4][7:0] afterTrigTime
output: 
    wgClk_f
    wgDataBit_f
    wgTrig_f
    wgRfout_f
=============================================================*/
    reg wgDataBit_f;
    reg wgClk_f;
    reg wgTrig_f;
    reg wgRfout_f;
    reg [3:0] wgBaseTimeCnt;    
    reg[19:0] wgTimeClk;
    reg[19:0] wgRfoutTimeCnt;
    reg[19:0] wgTrigStartTime;
    reg[19:0] wgRfoutStartTime;
    reg[19:0] wgRfoutEndTime;
    reg[19:0] wgTrigEndTime;
    always @(posedge clk160m) begin
        if(s1WgTrigGate_f)begin
                wgBaseTimeCnt<=0;
                wgTimeClk<=0;
                wgClk_f<=0;
                wgRfout_f <= 0;
                wgTrig_f <= 1;
        end
        else begin
            wgBaseTimeCnt<=wgBaseTimeCnt+1;
            wgRfoutTimeCnt<=wgRfoutTimeCnt+1;
            if(wgRfoutTimeCnt==wgRfoutEndTime)
                wgRfout_f <= 0;
            if(wgRfoutTimeCnt==wgTrigEndTime)
                wgTrig_f <= 1;
            if(wgBaseTimeCnt==0)begin
                if(wgTimeClk<16'hff00)begin
                    wgTimeClk<=wgTimeClk+1;
                    if(wgTimeClk<24)begin
                        wgClk_f <= 1;
                        if(wgData&(24'h80_0000>>(wgTimeClk)))
                            wgDataBit_f <= 1;
                        else
                            wgDataBit_f <= 0;
                    end        
                    if(wgTimeClk==24)begin
                        wgDataBit_f <= 0;
                        wgTrigStartTime<=bmem[4][31:16]+24;
                        wgRfoutEndTime<=s1VideoGateWidthTime;
                    end    
                    if(wgTimeClk==25)begin
                        wgDataBit_f <= 0;
                        wgRfoutStartTime<=wgTrigStartTime+bmem[4][15:8];
                        wgTrigEndTime<=wgRfoutEndTime+{bmem[4][7:0],4'b0000};
                    end    
                    if((wgTimeClk==wgTrigStartTime))
                        wgTrig_f <= 0;
                    if((wgTimeClk==wgRfoutStartTime))begin
                        wgRfout_f <= 1;
                        wgRfoutTimeCnt<=1;
                    end    
                end
            end
            if(wgBaseTimeCnt==8)begin
                wgClk_f<=0;
            end
        end            
    end        
        


    
//===================================================
// la register assign
//===================================================
    reg[15:0] laChR;
    //always @* 
    always @(posedge clk160m) begin
        if(bmem[5][19:16] == 4'b0000)begin
            laChR[0] <= hostWgPreDataGate_f;
            laChR[1] <= hostPreDataGate_f;
            laChR[2] <= hostWgTrigGate_f;
            laChR[3] <= s1WgTrigGate_f;
            laChR[4] <= hostVideoGate_f;
            laChR[5] <= s1VideoGate_f;
            laChR[6] <= hostS1TxData_w;
            laChR[7] <= s1SyncPreDataGate_f;
            //===========================
        end
        if(bmem[5][19:16] == 4'b0001)begin
            laChR[0] <= hostWgTrigGate_f;
            laChR[1] <= s1WgTrigGate_f;
            laChR[2] <= wgDataBit_f;
            laChR[3] <= wgClk_f;
            laChR[4] <= wgTrig_f;
            laChR[5] <= wgRfout_f; 
            laChR[6] <= hostVideoGate_f;
            laChR[7] <= s1VideoGate_f;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0010)begin
            laChR[0] <= hostS1TxData_w;
            laChR[1] <= s1SyncTxData_w;
            laChR[2] <= hostS1RxIn_f;
            laChR[3] <= hostS2RxIn_f;
            laChR[4] <= s1SyncRxIn_f;
            laChR[5] <= s1SyncRxPack_f; 
            laChR[6] <= hostS1RxPack_w;
            laChR[7] <= hostS2RxPack_w;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0011)begin
            laChR[0] <= hostVideoGate_f;
            laChR[1] <= s1VideoGate_f;
            laChR[2] <= hostWgTrigGate_f;
            laChR[3] <= s1WgTrigGate_f;
            laChR[4] <= hostS1RxIn_f;
            laChR[5] <= s1LocalRxIn_f; 
            laChR[6] <= hostS1RxClk4m_w;
            laChR[7] <= s1LocalRxClk4m_w;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0100)begin
            laChR[0] <= s1FibRxIn_f;
            laChR[1] <= s1FibRxPack_w;
            laChR[2] <= s1RfRxIn_f;
            laChR[3] <= s1RfRxPack_w;
            laChR[4] <= s1LocalRxIn_f;
            laChR[5] <= s1LocalRxPack_w; 
            laChR[6] <= s1WgRxIn_f;
            laChR[7] <= s1WgRxPack_f;
            //laChR[0] = hdfioiA[0];
            //laChR[1] = hdfioiA[1];
            //laChR[2] = hdfioiA[2];
            //laChR[3] = hdfioiA[3];
            //laChR[4] = hdfioiA[4];
            //laChR[5] = hdfioiA[5]; 
            //laChR[6] = hdfioiA[6];
            //laChR[7] = hdfioiA[7];
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0101)begin
            laChR[0] <= s1WgGate_f;
            laChR[1] <= s1WgInhibit_f;
            laChR[2] <= s1WgTrigGate_f;
            laChR[3] <= s1VideoGate_f;
            laChR[4] <= testBuf[0];
            laChR[5] <= testBuf[1];
            laChR[6] <= testBuf[2];
            laChR[7] <= testBuf[3];
        
        

            //laChR[0] = hdfioiA[8];
            //laChR[1] = hdfioiA[9];
            //laChR[2] = hdfioiA[10];
            //laChR[3] = hdfioiA[11];
            //laChR[4] = hdfioiA[12];
            //laChR[5] = hdfioiA[13];
            //laChR[6] = wgRfOut;
            //laChR[7] = debugPin1_f;
            //===========================
        end
        
        
        //input wire [11:0] rfInA,
        // 0:aRfmaCko,  1:aRfmaDio1,  2:aRfmaD0,  3:aRfmbCko,  4:aRfmbDio1,  5:aRfmbD0,
        // 6:bRfmaCko,  7:bRfmaDio1,  8:bRfmaD0,  9:bRfmbCko,  10:bRfmbDio1,  11:bRfmbD0,
       
        //rfOutA
        // 0:aRfmaDio2,  1:aRfmbDio2, 2:bRfmaDio2,  3:bRfmbDio2,        
        
        if(bmem[5][19:16] == 4'b0110)begin
            laChR[0] <= rfInA[0]; //1 RFMA_CKO
            laChR[1] <= rfOutA[0];//1 RFMA_DIO2 txd 
            laChR[2] <= rfInA[4]; //1 RFMB_DIO1  rxd
            laChR[3] <= rfInA[6]; //2 RFMA_CKO
            laChR[4] <= rfOutA[2];//2 RFMA_DIO2 txd
            laChR[5] <= rfInA[10];//2 RFMB_DIO1 rxd
            laChR[6] <= gpsPps;
            laChR[7] <= hostS1TxDataClk_w;
            //===========================
        end  
          
        if(bmem[5][19:16] == 4'b0111)begin
            laChR[0] <= fibTxA[0];
            laChR[1] <= fibRxA[0];
            laChR[2] <= fibTxA[1];
            laChR[3] <= fibRxA[1];
            laChR[4] <= fibTxA[2];
            laChR[5] <= fibRxA[2];
            laChR[6] <= fibTxA[3];
            laChR[7] <= fibRxA[3];
            //===========================
        end
          
          
        if(bmem[5][19:16] == 4'b1000)begin
            laChR[0] <= fibTxB1;
            laChR[1] <= fibRxB1;
            laChR[2] <= fibTxB3;
            laChR[3] <= fibRxB3;
            laChR[4] <= fibTxB5;
            laChR[5] <= fibRxB5; 
            laChR[6] <= fibTxB7;
            laChR[7] <= fibRxB7;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1001)begin
            laChR[0] <= txSysData1_load_w;
            laChR[1] <= txSysData1_clk_w;
            laChR[2] <= txSysData1_data_w;
            laChR[3] <= rxSysData1_in_f;;
            laChR[4] <= rxSysData1_clk_w;
            laChR[5] <= rxSysData1_pack_w; 
            laChR[6] <= hostS1TxEnd_w;
            laChR[7] <= hostS1RxPack_w;
            //===========================
        end  
        
        if(bmem[5][19:16] == 4'b1010)begin
            laChR[0] <= a_snd_clk;
            laChR[1] <= a_snd_tx;
            laChR[2] <= aSndRx;
            laChR[3] <= b_snd_clk;
            laChR[4] <= b_snd_tx;
            laChR[5] <= bSndRx;
            laChR[6] <= 0;
            laChR[7] <= 0;
            //===========================
        end  
        
        if(bmem[5][19:16] == 4'b1011)begin
            laChR[0] <= inpChk0;     //rs485Di fpga->485
            laChR[1] <= inpChk1;     //rs485Ro 485->fpga
            laChR[2] <= inpChkA[3];  //rs485De fpga->485
            laChR[3] <= inpChk2;     //ipcRx  fpga->ipc
            laChR[4] <= inpChk3;     //ipcTx  ipc->fpda
            laChR[5] <= s1WgRxIn_f;
            laChR[6] <= s1WgRxPack_f;
            laChR[7] <= 0;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1100)begin
            laChR[0] <= hdfoR[0];
            laChR[1] <= hdfoR[1];
            laChR[2] <= hdfoR[2];
            laChR[3] <= hdfoR[3];
            laChR[4] <= hdfoR[4];
            laChR[5] <= hdfoR[5];
            laChR[6] <= hdfoR[6];
            laChR[7] <= hdfoR[7];
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1101)begin
            laChR[0] <= hdfioIA[0];
            laChR[1] <= hdfioIA[1];
            laChR[2] <= hdfioIA[2];
            laChR[3] <= hdfioIA[3];
            laChR[4] <= hdfioIA[4];
            laChR[5] <= hdfioIA[5];
            laChR[6] <= hdfioIA[6];
            laChR[7] <= hdfioIA[7];
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1110)begin
            /*
            laChR[0] = debug0_f;
            laChR[1] = debug1_f;
            laChR[2] = hdfioIA[8];
            laChR[3] = hdfioIA[9];
            laChR[4] = hdfioIA[10];
            laChR[5] = hdfioIA[11];
            laChR[6] = hdfioIA[12];
            laChR[7] = hdfioIA[13];
                        */
                        
            laChR[0] <= rxSysData1_in_f;
            laChR[1] <= rxSysData1_pack_w;
            laChR[2] <= rxSysData2_in_f;
            laChR[3] <= rxSysData2_pack_w;
            laChR[4] <= rxSysData3_in_f;
            laChR[5] <= rxSysData3_pack_w;
            laChR[6] <= rxSysData4_in_f;
            laChR[7] <= rxSysData4_pack_w;
                        
                        
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1111)begin
            laChR[0] <= mem[17][8];
            //laChR[1] <= mem[17][9];
            laChR[1] <= test1_f;
            laChR[2] <= mem[17][10];
            laChR[3] <= mem[17][11];
            laChR[4] <= s1LocalRxIn_f;
            laChR[5] <= s1LocalRxPack_w; 
            laChR[6] <= s1SyncRxPack_f;
            laChR[7] <= s1WgTrigGate_f;
            //===========================
        end  
        
    
    
        
        
        
    end
    
//===================================================
// outport  assign
//===================================================
assign ramOutData = ramOutDataR;
assign ledV3=baseTimer[24];
assign ledV4=base160Timer[25];
assign laCh[15:0]=laChR[15:0];
assign hdfoA=hdfoR;
assign fibTxA[0]=fib1TxData;
assign fibTxA[1]=fib2TxData;
assign fibTxA[2]=fib3TxData;
assign fibTxA[3]=fib4TxData;
assign rfOutA[0]=rf1TxData;
assign rfOutA[2]=rf2TxData;
assign fibTxB1=fibTxB1_f;
assign fibTxB3=fibTxB2_f;
assign fibTxB5=fibTxB3_f;
assign fibTxB7=fibTxB4_f;
assign wgRfOut=wgRfout_f;


assign hdfioA[0] = hdfioDirA[0]?1'bz:hdfioOA[0];
assign hdfioIA[0] = hdfioA[0];
assign hdfioA[1] = hdfioDirA[1]?1'bz:hdfioOA[1];
assign hdfioIA[1] = hdfioA[1];
assign hdfioA[2] = hdfioDirA[2]?1'bz:hdfioOA[2];
assign hdfioIA[2] = hdfioA[2];
assign hdfioA[3] = hdfioDirA[3]?1'bz:hdfioOA[3];
assign hdfioIA[3] = hdfioA[3];

assign hdfioA[4] = hdfioDirA[4]?1'bz:hdfioOA[4];
assign hdfioIA[4] = hdfioA[4];
assign hdfioA[5] = hdfioDirA[5]?1'bz:hdfioOA[5];
assign hdfioIA[5] = hdfioA[5];
assign hdfioA[6] = hdfioDirA[6]?1'bz:hdfioOA[6];
assign hdfioIA[6] = hdfioA[6];
assign hdfioA[7] = hdfioDirA[7]?1'bz:hdfioOA[7];
assign hdfioIA[7] = hdfioA[7];

assign hdfioA[8] = hdfioDirA[8]?1'bz:hdfioOA[8];
assign hdfioIA[8] = hdfioA[8];
assign hdfioA[9] = hdfioDirA[9]?1'bz:hdfioOA[9];
assign hdfioIA[9] = hdfioA[9];
assign hdfioA[10] = hdfioDirA[10]?1'bz:hdfioOA[10];
assign hdfioIA[10] = hdfioA[10];
assign hdfioA[11] = hdfioDirA[11]?1'bz:hdfioOA[11];
assign hdfioIA[11] = hdfioA[11];

assign hdfioA[12] = hdfioDirA[12]?1'bz:hdfioOA[12];
assign hdfioIA[12] = hdfioA[12];
assign hdfioA[13] = hdfioDirA[13]?1'bz:hdfioOA[13];
assign hdfioIA[13] = hdfioA[13];
assign hdfioA[14] = hdfioDirA[14]?1'bz:hdfioOA[14];
assign hdfioIA[14] = hdfioA[14];
assign hdfioA[15] = hdfioDirA[15]?1'bz:hdfioOA[15];
assign hdfioIA[15] = hdfioA[15];

assign hdfioA[16] = hdfioDirA[16]?1'bz:hdfioOA[16];
assign hdfioIA[16] = hdfioA[16];
assign hdfioA[17] = hdfioDirA[17]?1'bz:hdfioOA[17];
assign hdfioIA[17] = hdfioA[17];
assign hdfioA[18] = hdfioDirA[18]?1'bz:hdfioOA[18];
assign hdfioIA[18] = hdfioA[18];
assign hdfioA[19] = hdfioDirA[15]?1'bz:hdfioOA[19];
assign hdfioIA[19] = hdfioA[19];


reg wgRfout_of;
reg wgTrig_of;
reg wgDataBit_of;
reg wgClk_of;

    always @* begin
        if(mem[0][25])begin
            wgRfout_of<=wgRfout_f;
        end
        else begin
            wgRfout_of<=0;
        end
    end        
    

    always @* begin
        if(mem[0][24])begin
            wgTrig_of<=wgTrig_f;
            wgDataBit_of<=wgDataBit_f;
            wgClk_of<=wgClk_f;
        end
        else begin
            wgTrig_of<=1;
            wgDataBit_of<=0;
            wgClk_of<=0;
        end
    end        



//===================================================
// timer cnt 
//===================================================
    reg[31:0]   baseTimer;
    reg[31:0]   base160Timer;
    always @(posedge sysClk)begin
        baseTimer <= baseTimer + 1'b1;
    end
    always @(posedge clk160m)begin
        base160Timer <= base160Timer + 1'b1;
    end

    always @(posedge clk160m)begin
        rmem[46][19:0] <= hdfioIA[19:0];
    end

      
//===================================================
// ram process 
//===================================================
    reg[RamDataWidth-1:0]             ramOutDataR;
    always @(posedge ramClk) begin
        if(ramEn & ramWe[0])
            mem[ramAddr[12:2]][7:0] <= ramInData[7:0];
        if(ramEn & ramWe[1])
            mem[ramAddr[12:2]][15:8] <= ramInData[15:8];
        if(ramEn & ramWe[2])
            mem[ramAddr[12:2]][23:16] <= ramInData[23:16];
        if(ramEn & ramWe[3])
            mem[ramAddr[12:2]][31:24] <= ramInData[31:24];
        ramOutDataR=rmem[ramAddr[9:2]];
                   
        if(ramAddr[9:9]==0)    
            ramOutDataR=rmem[ramAddr[9:2]];
        else begin
            if(ramAddr[8:7]==0)
                ramOutDataR=smem0[ramAddr[6:2]];
            if(ramAddr[8:7]==1)
                ramOutDataR=smem1[ramAddr[6:2]];
            if(ramAddr[8:7]==2)
                ramOutDataR=smem2[ramAddr[6:2]];
            if(ramAddr[8:7]==3)
                ramOutDataR=smem3[ramAddr[6:2]];
        end
            
    end
//===================================================
// generate emu rftx 4m clk
//===================================================
    reg [4:0] emuRfTxClkTimeCnt;  
    reg emuRfTxClk4m;
    reg[15:0] emuRfTxClk4mAdj;
    always @(posedge clk160m) begin
        emuRfTxClk4mAdj<=emuRfTxClk4mAdj+1;
        if(emuRfTxClkTimeCnt<19)begin
            if(emuRfTxClk4mAdj<50000)
                emuRfTxClkTimeCnt<=emuRfTxClkTimeCnt+1;
            else
                emuRfTxClk4mAdj<=0;     
        end    
        else begin    
            emuRfTxClkTimeCnt<=0;
            emuRfTxClk4m<=emuRfTxClk4m^1;
        end    
    end    
//===================================================
// generate s1EmuRxDataBuf
//===================================================
    reg[31:0] s1EmuRxDataBuf[3:0];
    always @(posedge clk160m) begin
        s1EmuRxDataBuf[0]<={s1EmuRxDataBuf[0][30:0],hostS1TxData_w};
        s1EmuRxDataBuf[1]<={s1EmuRxDataBuf[1][30:0],s1EmuRxDataBuf[0][31]};
        s1EmuRxDataBuf[2]<={s1EmuRxDataBuf[2][30:0],s1EmuRxDataBuf[1][31]};
        s1EmuRxDataBuf[3]<={s1EmuRxDataBuf[3][30:0],s1EmuRxDataBuf[2][31]};
    end    

//===================================================
// generate hostEmuRxDataBuf
//===================================================
    reg[31:0] hostEmuRxDataBuf[3:0];
    always @(posedge clk160m) begin
        hostEmuRxDataBuf[0]<={hostEmuRxDataBuf[0][30:0],s1SyncTxData_w};
        hostEmuRxDataBuf[1]<={hostEmuRxDataBuf[1][30:0],hostEmuRxDataBuf[0][31]};
        hostEmuRxDataBuf[2]<={hostEmuRxDataBuf[2][30:0],hostEmuRxDataBuf[1][31]};
        hostEmuRxDataBuf[3]<={hostEmuRxDataBuf[3][30:0],hostEmuRxDataBuf[2][31]};
    end    



//===================================================
// tx process
/*
    tx_data0[15:9]= serialCnt,[7:0] pretrigOffsetTime[7:0]
    tx_data1[15:0] = cmdData  & statusData  0b1xxx...=command  0b0xxx---  value// 
    tx_data2[15:0] = soundData:chFlag:chFreq  8:3:5
    tx_data3[15:0] = spare:commDelay 5:11 or pulse width
*/
//===================================================
    wire hostS1TxLoad_w;
    wire hostS1TxData_w;
    wire hostS1TxEnd_w;
    wire hostS1TxDataClk_w;
    TXPROC hostS1TxProc(
        .clk160m_i(clk160m),
        .preDataGate_i(hostPreDataGate_f),
        //.txCon_i(bmem[13][16]),
        .txCon_i(1),
        .txData0_ib(hostS1TxData0),
        .txData1_ib(hostS1TxData1),
        .txData2_ib(hostS1TxData2),
        .txData3_ib(hostS1TxData3),
        .txSyncClkEn_i(txSyncClkEn1_f),
        .txSyncClk_i(rfInA[0]),
        .txLoad_o(hostS1TxLoad_w),				
        .txData_o(hostS1TxData_w),				
        .txEnd_o(hostS1TxEnd_w),				
        .txDataClk_o(hostS1TxDataClk_w)				
    );

    wire hostS2TxLoad_w;
    wire hostS2TxData_w;
    wire hostS2TxEnd_w;
    wire hostS2TxDataClk_w;
    TXPROC hostS2TxProc(
        .clk160m_i(clk160m),
        .preDataGate_i(hostPreDataGate_f),
        .txCon_i(bmem[13][16]),
        .txData0_ib(hostS2TxData0),
        .txData1_ib(hostS2TxData1),
        .txData2_ib(hostS2TxData2),
        .txData3_ib(hostS2TxData3),
        .txSyncClkEn_i(txSyncClkEn2_f),
        .txSyncClk_i(rfInA[6]),
        .txLoad_o(hostS2TxLoad_w),				
        .txData_o(hostS2TxData_w),				
        .txEnd_o(hostS2TxEnd_w),				
        .txDataClk_o(hostS2TxDataClk_w)				
    );


    wire hostS1RxClk4m_w;
    wire hostS1RxPack_w;
    wire[15:0] hostS1RxData0_wb;
    wire[15:0] hostS1RxData1_wb;
    wire[15:0] hostS1RxData2_wb;
    wire[15:0] hostS1RxData3_wb;
    RXPROC hostS1RxProc(
        .clk160m_i(clk160m),
        .rxData_i(hostS1RxIn_f),
        .chkId_i(rxProcChkId),
        .rxClk4m_o(hostS1RxClk4m_w),
        .rxPack_o(hostS1RxPack_w),  //1us high
        .rxData0_ob(hostS1RxData0_wb),
        .rxData1_ob(hostS1RxData1_wb),
        .rxData2_ob(hostS1RxData2_wb),
        .rxData3_ob(hostS1RxData3_wb)
    );
    
    
    wire hostS2RxClk4m_w;
    wire hostS2RxPack_w;
    wire[15:0] hostS2RxData0_wb;
    wire[15:0] hostS2RxData1_wb;
    wire[15:0] hostS2RxData2_wb;
    wire[15:0] hostS2RxData3_wb;
    RXPROC hostS2RxProc(
        .clk160m_i(clk160m),
        .rxData_i(hostS2RxIn_f),
        .chkId_i(rxProcChkId),
        .rxClk4m_o(hostS2RxClk4m_w),
        .rxPack_o(hostS2RxPack_w),  //1us high
        .rxData0_ob(hostS2RxData0_wb),
        .rxData1_ob(hostS2RxData1_wb),
        .rxData2_ob(hostS2RxData2_wb),
        .rxData3_ob(hostS2RxData3_wb)
    );

    TXPROC s1SyncTxProc(
        .clk160m_i(clk160m),
        .preDataGate_i(s1SyncPreDataGate_f),
        .txCon_i(bmem[13][16]),
        .txData0_ib(s1SyncTxData0),
        .txData1_ib(s1SyncTxData1),
        .txData2_ib(s1SyncTxData2),
        .txData3_ib(s1SyncTxData3),
        .txSyncClkEn_i(txSyncClkEn1_f),
        .txSyncClk_i(rfInA[0]),
        .txLoad_o(s1SyncTxLoad_w),				
        .txData_o(s1SyncTxData_w),				
        .txEnd_o(s1SyncTxEnd_w),				
        .txDataClk_o(s1SyncTxDataClk_w)				
    );



    //====================================
    wire s1FibRxClk4m_w;
    wire s1FibRxPack_w;
    wire[15:0] s1FibRxData0_wb;
    wire[15:0] s1FibRxData1_wb;
    wire[15:0] s1FibRxData2_wb;
    wire[15:0] s1FibRxData3_wb;
    RXPROC s1FibRxProc(
        .clk160m_i(clk160m),
        .rxData_i(s1FibRxIn_f),
        .chkId_i(rxProcChkId),
        .rxClk4m_o(s1FibRxClk4m_w),
        .rxPack_o(s1FibRxPack_w),  //1us high
        .rxData0_ob(s1FibRxData0_wb),
        .rxData1_ob(s1FibRxData1_wb),
        .rxData2_ob(s1FibRxData2_wb),
        .rxData3_ob(s1FibRxData3_wb)
    );


    wire s1RfRxClk4m_w;
    wire s1RfRxPack_w;
    wire[15:0] s1RfRxData0_wb;
    wire[15:0] s1RfRxData1_wb;
    wire[15:0] s1RfRxData2_wb;
    wire[15:0] s1RfRxData3_wb;
    RXPROC s1RfRxProc(
        .clk160m_i(clk160m),
        .rxData_i(s1RfRxIn_f),
        .chkId_i(rxProcChkId),
        .rxClk4m_o(s1RfRxClk4m_w),
        .rxPack_o(s1RfRxPack_w),  //1us high
        .rxData0_ob(s1RfRxData0_wb),
        .rxData1_ob(s1RfRxData1_wb),
        .rxData2_ob(s1RfRxData2_wb),
        .rxData3_ob(s1RfRxData3_wb)
    );


    wire s1LocalRxClk4m_w;
    wire s1LocalRxPack_w;
    wire[15:0] s1LocalRxData0_wb;
    wire[15:0] s1LocalRxData1_wb;
    wire[15:0] s1LocalRxData2_wb;
    wire[15:0] s1LocalRxData3_wb;
    RXPROC s1LocalRxProc(
        .clk160m_i(clk160m),
        .rxData_i(s1LocalRxIn_f),
        .chkId_i(2'b11),
        .rxClk4m_o(s1LocalRxClk4m_w),
        .rxPack_o(s1LocalRxPack_w),  //1us high
        .rxData0_ob(s1LocalRxData0_wb),
        .rxData1_ob(s1LocalRxData1_wb),
        .rxData2_ob(s1LocalRxData2_wb),
        .rxData3_ob(s1LocalRxData3_wb)
    );



//===================================================
// fiberX txModule
//===================================================
    TXSYSDATA txSysData1(
        .clk160m_i(clk160m),
        .preDataGate_i(txSysPreData_f),
        .txData0_ib(txSysData[0]),
        .txData1_ib(txSysData[1]),
        .txData2_ib(txSysData[2]),
        .txData3_ib(txSysData[3]),
        .txLoad_o(txSysData1_load_w),				
        .txClk_o(txSysData1_clk_w),				
        .txData_o(txSysData1_data_w)				
    );

//===================================================
// fiberB1 rxModule
//===================================================
    wire rxSysData1_clk_w;
    wire rxSysData1_pack_w;
    wire[15:0] rxSysData1_data0_wb;
    wire[15:0] rxSysData1_data1_wb;
    wire[15:0] rxSysData1_data2_wb;
    wire[15:0] rxSysData1_data3_wb;
    RXSYSDATA rxSysData1(
        .clk160m_i(clk160m),
        .rxData_i(rxSysData1_in_f),
        .rxClk4m_o(rxSysData1_clk_w),
        .rxPack_o(rxSysData1_pack_w),  //1us high
        .rxData0_ob(rxSysData1_data0_wb),
        .rxData1_ob(rxSysData1_data1_wb),
        .rxData2_ob(rxSysData1_data2_wb),
        .rxData3_ob(rxSysData1_data3_wb)
    );
//===================================================
// fiberB3 rxModule
//===================================================
    wire rxSysData2_clk_w;
    wire rxSysData2_pack_w;
    wire[15:0] rxSysData2_data0_wb;
    wire[15:0] rxSysData2_data1_wb;
    wire[15:0] rxSysData2_data2_wb;
    wire[15:0] rxSysData2_data3_wb;
    RXSYSDATA rxSysData2(
        .clk160m_i(clk160m),
        .rxData_i(rxSysData2_in_f),
        .rxClk4m_o(rxSysData2_clk_w),
        .rxPack_o(rxSysData2_pack_w),  //1us high
        .rxData0_ob(rxSysData2_data0_wb),
        .rxData1_ob(rxSysData2_data1_wb),
        .rxData2_ob(rxSysData2_data2_wb),
        .rxData3_ob(rxSysData2_data3_wb)
    );
//===================================================
// fiberB5 rxModule
//===================================================
    wire rxSysData3_clk_w;
    wire rxSysData3_pack_w;
    wire[15:0] rxSysData3_data0_wb;
    wire[15:0] rxSysData3_data1_wb;
    wire[15:0] rxSysData3_data2_wb;
    wire[15:0] rxSysData3_data3_wb;
    RXSYSDATA rxSysData3(
        .clk160m_i(clk160m),
        .rxData_i(rxSysData3_in_f),
        .rxClk4m_o(rxSysData3_clk_w),
        .rxPack_o(rxSysData3_pack_w),  //1us high
        .rxData0_ob(rxSysData3_data0_wb),
        .rxData1_ob(rxSysData3_data1_wb),
        .rxData2_ob(rxSysData3_data2_wb),
        .rxData3_ob(rxSysData3_data3_wb)
    );
//===================================================
// fiberB7 rxModule
//===================================================
    wire rxSysData4_clk_w;
    wire rxSysData4_pack_w;
    wire[15:0] rxSysData4_data0_wb;
    wire[15:0] rxSysData4_data1_wb;
    wire[15:0] rxSysData4_data2_wb;
    wire[15:0] rxSysData4_data3_wb;
    RXSYSDATA rxSysData4(
        .clk160m_i(clk160m),
        .rxData_i(rxSysData4_in_f),
        .rxClk4m_o(rxSysData4_clk_w),
        .rxPack_o(rxSysData4_pack_w),  //1us high
        .rxData0_ob(rxSysData4_data0_wb),
        .rxData1_ob(rxSysData4_data1_wb),
        .rxData2_ob(rxSysData4_data2_wb),
        .rxData3_ob(rxSysData4_data3_wb)
    );









//===================================================
// defential output buffers
//===================================================
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    )OBUFDS_inst0 (
        .O(dfOutP[0]),        
        .OB(dfOutN[0]),
        .I(wgClk_of)        
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst1 (
        .O(dfOutP[1]),        
        .OB(dfOutN[1]),       
        .I(wgDataBit_of)       
    );
    //  
    OBUFDS #(
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")       
    ) OBUFDS_inst2 (
        .O(dfOutP[2]),  
        .OB(dfOutN[2]), 
        .I(wgTrig_of) 
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst3 (
        .O(dfOutP[3]),        
        .OB(dfOutN[3]),       
        .I(wgRfout_of)      
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst4 (
        .O(dfOutP[4]),        
        .OB(dfOutN[4]),       
        .I(a_snd_clk)        
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst5 (
        .O(dfOutP[5]),        
        .OB(dfOutN[5]),       
        .I(a_snd_tx)       
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")       
    ) OBUFDS_inst6 (
        .O(dfOutP[6]),  
        .OB(dfOutN[6]), 
        .I(b_snd_clk) 
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst7 (
        .O(dfOutP[7]),        
        .OB(dfOutN[7]),       
        .I(b_snd_tx)      
    );
    
    
//===================================================
// defential inputt buffers
//===================================================
    IBUFDS #(
        .DIFF_TERM("FALSE"),       // Differential Termination
        .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    ) IBUFDS_inst0 (
        .O(aSndRx),          
        .I(dfInP[0]),             
        .IB(dfInN[0])             
    );
    //
    IBUFDS #(
        .DIFF_TERM("FALSE"),       // Differential Termination
        .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS_inst1 (
        .O(bSndRx),          
        .I(dfInP[1]),             
        .IB(dfInN[1])             
   );

  
endmodule



