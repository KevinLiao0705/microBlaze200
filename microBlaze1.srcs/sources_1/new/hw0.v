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
        output [7:0]            hdfoA,    		
        output [15:0]        laCh,
        //==================================================
        //[5:0]:spFreqCh[5:0], 6:spInhib, 7:spPreTrig, 8:spGate,[13:9]:spPulseWidthCh[4:0]   
        input [13:0] hdfioA,        
        
            		
        /*
                    0:. aSndRx, 1:bSndRx
                    2: spFreqCh0, 3: spFreqCh1,  4: spFreqCh2, 5: spFreqCh3, 6: spFreqCh4, 7: spFreqCh5
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
    reg[15:0] wgMaxPulseWidth;
    reg[23:0] wgMinPri;
    //==========================
    wire s1TxLoad_w;
    wire s1TxData_w;
    wire s1TxEnd_w;
    wire s1TxDataClk_w;
    wire txSysData1_load_w;
    wire txSysData1_clk_w;
    wire txSysData1_data_w;
    reg[13:0] hdfioDirA;
    reg[13:0] hdfiooA;
    integer      i ;  
  

/*===========================================================
initialize
=============================================================*/
    reg txSyncClkEn_f;
    initial begin
        ramOutDataR = 0;
        //===
        for(i=0;i<256;i=i+1)begin
            rmem[i]=0;
        end
        rmem[0]=32'h1234_5678;
        rmem[1]=32'habcd_1234;
        //======================================        
        mem[0]=32'h0000_0000;//systemStatus0
        mem[1]=32'h0000_0000;//systemStatus1
        mem[2]=32'b00000000_00000000_00000000_00010000;//systemFlag0
        mem[3]=32'b00000000_00000000_00000000_00000001;//systemFlag1
        mem[4]=32'h0014_0a0a;//16:8:8 ,preTrigTime,  preRfoutTime  afterTrigTime,
        mem[5]=32'h0000_1000;//8:8:16, spare,laGroupCh,commTestPacks
        mem[6]=32'h0000_2580;//12:20, xxx,hostWgVideoGateDelayTime 
        mem[7]=32'h0100_0100;//16:16 chRfTimeDelay,chFiberTimeDelay
        mem[8]=32'h000a_1000;//16:8:8 preDataGateWidth:fgaId,sample end  0
        mem[9]=32'h0000_0221;//12:20, xxx,wgTrigGateDelayTime-sub 
        mem[10]=32'h0000_05ed;//12:20, xxx,s1WgVideoGateDelayTime 
        mem[11]=32'h0000_3ce8;//12:20, xxx,baseCommTime//3de8
        mem[31]=32'habcd_1234;//  

        //======================================        
        /*
                    wgRepeatEnd<=ibuf[0][31:24];
                    wgRfFreq<=ibuf[0][23:16];
                    wgPulseWidth<=ibuf[0][15:0];
                    wgPulseFlag<=ibuf[1][31:24];
                    wgPri<=ibuf[1][23:0];
                    pulseGen datas addr 0x20 end 0x60
                */
        for(i=0;i<32;i=i+1)begin
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
        localPreDataGateOn_f=0;     
        localWgRepeatCnt=0;
        localWgRepeatEnd=0;   
        localWgSampleCnt=0;
        localWgSampleEnd=0;
        wgActTimeCnt=24'hf0000;
        hostPreDataGate_f=1;                
        //===
        s1SyncWgPulseWidth=10*10;
        s1SyncPreDataGate_f=1;                
        s1SyncPreDataGate_ff=1;                
        wgClk_f=0;
        wgDataBit_f=0;
        wgTrig_f=1;
        wgRfout_f=0;
        wgTrigGate_f=0;
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
        //===================================
        s1CommDelayTime=16;
        txSyncClkEn_f=0;
        memSaveBuf1=0;
        hdfioDirA=0;
        hdfiooA=0;
        fpgaId=4'b1111;
        bmem[8][11:8]=4'b1111;
    end

    reg hostS1TxEnd_ff;
    reg[15:0] hostS1TxCnt;
    reg hostS1RxPack_ff;
    reg[15:0] hostS1RxCnt;
    always @(posedge clk160m) begin
        if(hostS1TxEnd_w)begin
            if(!hostS1TxEnd_ff)
                hostS1TxCnt<=hostS1TxCnt+1;
        end
        hostS1TxEnd_ff<=hostS1TxEnd_w;
        if(hostS1RxPack_w)begin        
            if(!hostS1RxPack_ff)
                hostS1RxCnt<=hostS1RxCnt+1;
        end
        hostS1RxPack_ff<=hostS1RxPack_w;
        if(hostS1TxCnt==1000)begin
            hostS1TxCnt=1;
            rmem[6][15:0]<=hostS1RxCnt;
            hostS1RxCnt<=0;
        end    
    end
/*===========================================================
txData test
=============================================================*/
    reg[23:0] txDataTimeCnt;
    reg[15:0] testTxBuf[3:0];
    reg testPreData_f;
    always @(posedge clk160m) begin
        txDataTimeCnt<=txDataTimeCnt+1;
        if(txDataTimeCnt>=160000)
            txDataTimeCnt<=1;
        if(txDataTimeCnt==1)begin
            testTxBuf[0]<=16'h1234;    
            testTxBuf[1]<=16'h5678;    
            testTxBuf[2]<=16'h9abc;    
            testTxBuf[3]<=16'hdef0;    
        end            
        if(txDataTimeCnt==2)
            testPreData_f<=0;
        if(txDataTimeCnt==162)
            testPreData_f<=1;
    end
    
/*===========================================================
checkTxSys
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


/*===========================================================
checkRxSys
=============================================================*/
    reg rxSysData1_pack_ff;
    reg[31:0] rxSysData1_chg_buf;
    always @(posedge clk160m) begin
        if(rxSysData1_pack_w)begin
            if(!rxSysData1_pack_ff)begin
                rmem[33]<=rxSysData1_chg_buf;                   
                rmem[34][15:0]<=rxSysData1_data0_wb;                   
                rmem[34][31:16]<=rxSysData1_data1_wb;                   
                rmem[35][15:0]<=rxSysData1_data2_wb;                   
                rmem[35][31:16]<=rxSysData1_data3_wb;                   
                rxSysData1_chg_buf<=rxSysData1_chg_buf+1;
            end
            rxSysData1_pack_ff<=rxSysData1_pack_w;
        end                   
        else
            rxSysData1_pack_ff<=rxSysData1_pack_w;                   
    end


/*===========================================================
generate pulseFormInf
=============================================================*/
    reg wgRfoutH_f;
    reg debugPin1_f;
    reg[31:0] wgRfoutTime;
    reg[31:0] wgRfoutCnt;
    reg[31:0] wgRfoutPeriod;
    always @(posedge clk160m) begin
        if(wgRfoutH_f ^ wgRfout_f)begin
            rmem[wgRfoutCnt[3:0]+48]<=(wgRfoutTime<<1)+(!wgRfout_f);
            rmem[37]<=wgRfoutCnt;
            debugPin1_f<=!debugPin1_f;
            wgRfoutCnt<=wgRfoutCnt+1;
            if(wgRfout_f)
                rmem[38]<=wgRfoutPeriod;//low period
            else
                rmem[39]<=wgRfoutPeriod;//high period
            rmem[40][5:0]<=s1SyncRfFreq;    
            wgRfoutH_f<=wgRfout_f;
            wgRfoutTime<=1;
            wgRfoutPeriod<=1;     
        end
        else begin
            wgRfoutTime<=wgRfoutTime+1;
            if(!wgRfoutPeriod[31])
                wgRfoutPeriod<=wgRfoutPeriod+1;
            if(wgRfoutPeriod>=160*100000)begin
                rmem[38]<=0;//low period
                rmem[39]<=0;//high period
            end                
            if(wgRfoutTime>=160*10000)begin
                rmem[wgRfoutCnt[3:0]+48]<=(wgRfoutTime<<1)+(wgRfout_f);
                rmem[37]<=wgRfoutCnt;
                wgRfoutCnt<=wgRfoutCnt+1;
                wgRfoutTime<=1;
            end
        end
    end

        
    
/*===========================================================
generate real time cnt
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
    reg localPreDataGateOn_f;
    
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
            if(localWgPriTime<52*160)begin
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
                    localPreDataGateOn_f<=0;                 
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
            localPreDataGateOn_f<=bmem[13][1];
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
    reg s1Inhibit_f;
    reg wgTrigGate_f;
    reg hostS1RxIn_f;
    reg hostS2RxIn_f;
    reg s1RxIn_f;
    reg fibTxB1_f;
    reg rxSysData1_in_f;
    reg chDelay;
    reg[7:0] hdfoR;
    always @* 
    begin
        fpgaId=bmem[8][11:8];
        rmem[36]=fpgaId;
        s1Inhibit_f=s1SyncInhibit_f;
        wgTrigGate_f=s1WgTrigGate_f;
        fibTxB1_f=txSysData1_data_w;
        //===================================
        hdfoR=mem[17][7:0];
        if(fpgaId==0)//mast
            chDelay=0;
        if(fpgaId==1)//sub
            chDelay=bmem[16][7:0];
        if(fpgaId==2)//ctr
            chDelay=bmem[16][15:8];
        if(fpgaId==3)//drv
            chDelay=bmem[16][23:16];
        if(fpgaId==15)//mter
            chDelay=bmem[16][31:24];
            
        if(fpgaId==15)begin//mter
            hdfioDirA[0]=1;
            hdfioDirA[2]=1;
            hdfioDirA[6]=1;
            //hdfiooA[2]=txSysData1_data_w;
            //hdfiooA[6]=s1VideoGate_f;
            rxSysData1_in_f=hdfioA[3];
        end
        else begin
            hdfioDirA=0;
            rxSysData1_in_f=fibRxB1;
            //=================
            if(bmem[13][9:8]==0)//hostS1RxFrom
                hostS1RxIn_f=rfInA[4];
            if(bmem[13][9:8]==1)//hostS1RxFrom
                hostS1RxIn_f=fibRxA[0];
            if(bmem[13][9:8]==2)begin//hostS1RxFrom
                if(bmem[13][15:14]==0)//emuDelay
                    hostS1RxIn_f=s1TxData_w;
                if(bmem[13][15:14]==1)
                    hostS1RxIn_f=hostEmuRxDataBuf[1][31];
                if(bmem[13][15:14]==2)
                    hostS1RxIn_f=hostEmuRxDataBuf[2][31];
                if(bmem[13][15:14]==3)
                    hostS1RxIn_f=hostEmuRxDataBuf[3][31];
            end
        end    
            
            
        //==============================    
        //========================        
        if(bmem[13][11:10]==0)//hostS2RxFrom
            hostS2RxIn_f=rfInA[10];
        if(bmem[13][11:10]==1)//hostS2RxFrom
            hostS2RxIn_f=fibRxA[1];
        if(bmem[13][11:10]==2)begin//hostS2RxFrom
            if(bmem[13][15:14]==0)//emuDelay
                hostS2RxIn_f=s1TxData_w;
            if(bmem[13][15:14]==1)
                hostS2RxIn_f=hostEmuRxDataBuf[1][31];
            if(bmem[13][15:14]==2)
                hostS2RxIn_f=hostEmuRxDataBuf[2][31];
            if(bmem[13][15:14]==3)
                hostS2RxIn_f=hostEmuRxDataBuf[3][31];
        end        
        if(bmem[13][13:12]==0)//s1RxFrom
            s1RxIn_f=rfInA[4];
        if(bmem[13][13:12]==1)//s1RxFrom
            s1RxIn_f=fibRxA[0];
        if(bmem[13][13:12]==2)begin//s1RxFrom
            if(bmem[13][15:14]==0)//emuDelay
                s1RxIn_f=hostS1TxData_w;
            if(bmem[13][15:14]==1)
                s1RxIn_f=s1EmuRxDataBuf[1][31];
            if(bmem[13][15:14]==2)
                s1RxIn_f=s1EmuRxDataBuf[2][31];
            if(bmem[13][15:14]==3)
                s1RxIn_f=s1EmuRxDataBuf[3][31];
        end        
        if(bmem[13][13:12]==3)//s1RxFrom
            s1RxIn_f=hdfioA[1];
        
        
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
    
    always @* begin
        if(bmem[13][5:4]==0)begin //sp
            hostWgPreDataGate_f=hdfioA[7];
            hostWgPulseWidth=bmem[hdfioA[13:9]+96][15:0];//unit 0.1us
            hostWgRfFreq={hdfioA[6],7'b0000000};
            hostWgFlag=spEmuWgFlag;
        end
        if(bmem[13][5:4]==1)begin //local
            hostWgPreDataGate_f=localPreDataGate_f;
            hostWgPulseWidth=localWgPulseWidth;
            hostWgRfFreq=localWgRfFreq;
            hostWgFlag=localWgFlag;
        end
        if(bmem[13][5:4]==2)begin //emuSp
            hostWgPreDataGate_f=spEmuPreDataGate_f;
            hostWgPulseWidth=bmem[spEmuWgPulseWidthTblInx+96][15:0];//unit 0.1us
            hostWgRfFreq=spEmuWgRfFreq;
            hostWgFlag=spEmuWgFlag;
        end
        // 0:aRfmaCko,  1:aRfmaDio1,  2:aRfmaD0,  3:aRfmbCko,  4:aRfmbDio1,  5:aRfmbD0,
        // 6:bRfmaCko,  7:bRfmaDio1,  8:bRfmaD0,  9:bRfmbCko,  10:bRfmbDio1,  11:bRfmbD0,
        //input wire [11:0] rfInA,
        //output [3:0] fibTxA,    		
        //input   wire [3:0] fibRxA,
        if(bmem[13][7:6]==0)begin//syncTxMode
            rf1TxData=hostS1TxData_w;
            rf2TxData=hostS2TxData_w;
            fib1TxData=hostS1TxData_w;
            fib2TxData=hostS2TxData_w;
            fib3TxData=hostS1TxData_w;
            fib4TxData=hostS2TxData_w;
        end
        if(bmem[13][7:6]==1)begin//sub
            rf1TxData=s1TxData_w;
            fib1TxData=s1TxData_w;
            fib2TxData=s1RxIn_f;//data through
            fib3TxData=s1RxIn_f;//data through
            fib4TxData=s1RxIn_f;//data through
        end
        if(bmem[13][7:6]==2)begin//ctr
            fib1TxData=s1RxIn_f;//data through
            fib2TxData=s1RxIn_f;//data through
            fib3TxData=s1RxIn_f;//data through
            fib4TxData=s1RxIn_f;//data through
        end
        if(bmem[13][7:6]==3)begin//local
            fib1TxData=hostS1TxData_w;
            fib2TxData=hostS1TxData_w;
            fib3TxData=hostS1TxData_w;
            fib4TxData=hostS1TxData_w;
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
    wgActTimeCnt<=0;
    hostInhibit_f<=1;
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
            hostWgPreDataGate_ff<=hostWgPreDataGate_f;
        end
        else begin
            hostWgPreDataGate_ff<=hostWgPreDataGate_f;
        end
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
    bmem[6][19:0] vgTimeDelay
    bmem[9][19:0] wgPulseTimeDelay(vg sub)
    bmem[4][31:16] preTrigTime
    bmem[4][15:8] preRfOutTime
output: 
    hostWgTrigGate_f hostVideoGate_f
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
                    hostVideoGateDelayTime<=bmem[6][19:0];
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
    generate hostPreDataGate_f
input:
    wgActTimeCnt
    hostCommandData
    hostSoundData
    hostInhibit_f
    bmem[2][27] wgProtectFlag
    hostWgRfFreq
    hostWgPulseWidth
    commDelayTime
output: 
    hostTxSerial
    hostS1TxData1[3:0][15:0]
    hostS2TxData1[3:0][15:0]
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
    
    always @(posedge clk160m) begin
        if(wgActTimeCnt==0)begin
            hostPreDataGate_f<=0;
            hostPreDataGateTimeCnt<=1;
            hostTxSerial<=hostTxSerial+1;
            //=========================================
            hostS1TxData0<={hostTxSerial,8'h00};
            hostS1TxData1[15:0]<=hostCommandData;
            hostS1TxData2[15:8]<=hostS1SoundData;
            hostS1TxData2[7]<=hostInhibit_f;
            hostS1TxData2[6]<=bmem[2][27];//wgProtectBit
            hostS1TxData2[5:0]<=hostWgRfFreq;
            //==
            hostS2TxData0<={hostTxSerial,8'h00};
            hostS2TxData1[15:0]<=hostCommandData;
            hostS2TxData2[15:8]<=hostS2SoundData;
            hostS2TxData2[7]<=hostInhibit_f;
            hostS2TxData2[6]<=bmem[2][27];//wgProtectBit
            hostS2TxData2[5:0]<=hostWgRfFreq;
            //==========================================
            if(hostInhibit_f)begin
                hostS1TxData3[15:11]<=5'b0000;
                hostS1TxData3[10:0]<=s1CommDelayTime[11:1];
                hostS2TxData3[15:11]<=5'b0000;
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
    hostS1RxGate_f
    hostS1RxData0_wb[8]  seiral cnt lsb
    bmem[11][19:0] commBaseTime :3de8
    bmem[7][15:0];//fiber delay 0x100
    bmem[7][31:16];// rf delay 0x100
output: 
    commDelayTime
    rmem[4:0]
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
                        if(bmem[13][9:8]==0)//hostS1RxFrom
                            s1CommDeltaTime<=s1CommDeltaTime-bmem[7][31:16];// rf delay
                        if(bmem[13][9:8]==1)//hostS1RxFrom
                            s1CommDeltaTime<=s1CommDeltaTime-bmem[7][15:0];//fiber delay
                        if(bmem[13][9:8]==2)//hostS1RxFrom
                            s1CommDeltaTime<=s1CommDeltaTime-256;
                    end                
                    if(hostS1RxGateHTimeCnt==5)begin
                        s1CommDeltaTime<=s1CommDeltaTime-chDelay;
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
    hostS2RxGate_f
    hostS2RxData0_wb[8]  seiral cnt lsb
    bmem[11][15:0] s1CommBaseTime :3deb
    bmem[7][15:0];//fiber delay 0x100
    bmem[7][31:16];// rf delay 0x100
output: 
    commDelayTime
    rmem[4:0]
=============================================================*/
    reg[23:0] s2CommTime;
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
                if(hostS2RxGateHTimeCnt==0)begin
                    s2CommTime<=realTimeCnt-preTxTime[!hostS2RxData0_wb[8]];
                end
                if(hostS2RxGateHTimeCnt==1)begin
                    if(s2CommTime<15595)
                        s2CommTime<=15595;
                end
                if(hostS2RxGateHTimeCnt==2)begin
                    rmem[8]<={hostS2RxData1_wb,hostS2RxData0_wb};
                    rmem[9]<={hostS2RxData3_wb,hostS2RxData2_wb};
                    rmem[10]<=s2CommTime;
                    rmem[11]<=s2CommTime-bmem[11][31:16];
                    s2CommDeltaTime<=s2CommTime-bmem[31][16:0];
                end
                if(hostS2RxGateHTimeCnt==3)begin
                    if(bmem[13][11:10]==0)//hostS2RxFrom
                        s2CommDeltaTime<=s2CommDeltaTime-bmem[7][31:16];// rf delay
                    if(bmem[13][11:10]==1)//hostS2RxFrom
                        s2CommDeltaTime<=s2CommDeltaTime-bmem[7][15:0];//fiber delay
                    if(bmem[13][11:10]==2)//hostS2RxFrom
                        s2CommDeltaTime<=s2CommDeltaTime-256;
                end                
                if(hostS2RxGateHTimeCnt==4)begin
                    if(!s2CommDeltaTime[23])begin
                        if(s2CommDelayTime<s2CommDeltaTime)
                            s2CommDelayTime<=s2CommDelayTime+1;
                        if(s2CommDelayTime>s2CommDeltaTime)
                            s2CommDelayTime<=s2CommDelayTime-1;
                    end
                    else
                        s2CommDelayTime<=0;
                end
                if(hostS2RxGateHTimeCnt==5)begin
                    rmem[12]<=s2CommDelayTime;
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
    s1RxPack_w
    s1RxData0_wb
    s1RxData1_wb
    s1RxData2_wb
    s1RxData3_wb
output: 
    s1SyncPreDataGate_f
    wgData[23:0]
    rmem[5]
=============================================================*/
    reg[7:0] s1RxPackHTimeCnt;
    reg s1SyncPreDataGate_f;
    reg[15:0] s1TxData0;
    reg[15:0] s1TxData1;
    reg[15:0] s1TxData2;
    reg[15:0] s1TxData3;
    reg s1SyncInhibit_f;
    reg s1SyncSspaProtect_f;
    reg[5:0] s1SyncRfFreq;
    reg[19:0] s1VideoGateCommPathTime;
    reg[15:0] s1SyncWgPulseWidth;
    reg[23:0] wgData;
    reg[15:0] s1SyncRespDelayTimeCnt;
    reg[15:0] s1SyncRespDelayTime;
    reg[15:0] s1SyncPreDataGateTimeCnt;
    reg[7:0] testBuf;
    
    
    always @(posedge clk160m) begin
        if(s1RxPack_w)begin
            if(!s1RxPackHTimeCnt[7])begin
                s1RxPackHTimeCnt<=s1RxPackHTimeCnt+1;
                if(s1RxPackHTimeCnt==0)begin
                    s1SyncRespDelayTimeCnt<={8'b0000_0000,s1RxData0_wb[7:0]};//<<debug    
                    s1SyncPreDataGate_f<=1;
                    s1TxData0<=s1RxData0_wb;
                    s1TxData1<=s1StatusData;
                    s1TxData2[15:8]<=s1SoundData;
                    s1TxData3[15:0]<=0;
                    s1SyncInhibit_f<=s1RxData2_wb[7];
                    s1SyncSspaProtect_f<=s1RxData2_wb[6];
                    s1SyncRfFreq<=s1RxData2_wb[5:0];
                    if(s1RxData2_wb[7])begin
                        //s1VideoGateCommPathTime<={9'b000000000,s1RxData3_wb[10:0]};
                        s1VideoGateCommPathTime<=0;

                    end    
                    else begin    
                        s1SyncWgPulseWidth<={s1RxData3_wb[15:0],4'b0000};
                        testBuf[0]=!testBuf[0];
                    end    
                end
                if(s1RxPackHTimeCnt==1)begin
                    wgData[23:23]<=s1SyncSspaProtect_f;
                    wgData[22:16]<=7'b000_0000;
                    wgData[15:8]<={2'b00,s1SyncRfFreq};
                    wgData[7:6]<=2'b11;
                    wgData[5:0]<=s1SyncRfFreq ^ 6'b11_1111;
                end
            end
        end    
        else begin
            s1RxPackHTimeCnt<=0;
            s1SyncPreDataGateTimeCnt<=s1SyncPreDataGateTimeCnt+1;
            if(s1SyncPreDataGateTimeCnt==16)//mem[8][31:16])//1us
                s1SyncPreDataGate_f<=1;
            if(s1SyncRespDelayTimeCnt<19200)begin//120us
                s1SyncRespDelayTimeCnt<=s1SyncRespDelayTimeCnt+1;
                if(s1SyncRespDelayTimeCnt==s1SyncRespDelayTime)begin
                    if(!s1SyncInhibit_f)begin
                        s1SyncPreDataGate_f<=0;
                        s1SyncPreDataGateTimeCnt<=1;
                    end    
                end   
            end
        end
    end    
    
    
    
    
    
    
    

/*===========================================================
purpose:
    generate s1WgTrigGate_f and s1VideoGate_f
input:
    s1SyncPreDataGate_f
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
    reg s1SyncPreDataGate_ff;
    reg s1VideoGate_f;
    reg[19:0] s1WgTrigGateWidthTimeCnt;
    reg s1WgTrigGate_f;
    reg[19:0] s1VideoGateDelayTime;
    reg[19:0] s1VideoGateWidthTimeCnt;
    reg[19:0] s1WgTrigGateDelayTime;
    
    always @(posedge clk160m) begin
        if(s1VideoGateDelayTimeCnt<12800)//80usus
            s1VideoGateDelayTimeCnt<=s1VideoGateDelayTimeCnt+1;
        if(!s1SyncPreDataGate_f)begin
            if(s1SyncPreDataGate_ff)begin//H2L
                if(!s1Inhibit_f)begin
                    s1VideoGateDelayTimeCnt<=1;
                    s1VideoGate_f<=0;
                    s1VideoGateWidthTime<=s1SyncWgPulseWidth;
                end    
            end
            s1SyncPreDataGate_ff<=s1SyncPreDataGate_f;
        end  
        else begin
            s1SyncPreDataGate_ff<=s1SyncPreDataGate_f;
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
            if(!s1Inhibit_f)
                s1WgTrigGate_f<=1;
            s1WgTrigGateWidthTimeCnt<=1;
        end   
        if(s1VideoGateDelayTimeCnt==s1VideoGateDelayTime)begin
            if(!s1Inhibit_f)
                s1VideoGate_f<=1;
            s1VideoGateWidthTimeCnt<=1;
        end   
    end    


    
    
    

/*===========================================================
purpose:
    generate wg signale
input:
    wgTrigGate_f
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
    reg[15:0] wgTimeClk;
    reg[19:0] wgRfoutTimeCnt;
    reg[15:0] wgTrigStartTime;
    reg[15:0] wgRfoutStartTime;
    reg[19:0] wgRfoutEndTime;
    reg[19:0] wgTrigEndTime;
    always @(posedge clk160m) begin
        if(wgTrigGate_f)begin
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
    always @* 
    begin
        if(bmem[5][19:16] == 4'b0000)begin
            laChR[0] = hostWgPreDataGate_f;
            laChR[1] = hostPreDataGate_f;
            laChR[2] = hostWgTrigGate_f;
            laChR[3] = s1WgTrigGate_f;
            laChR[4] = hostVideoGate_f;
            laChR[5] = s1VideoGate_f;
            laChR[6] = hostS1TxData_w;
            laChR[7] = s1SyncPreDataGate_f;
            //===========================
        end
        if(bmem[5][19:16] == 4'b0001)begin
            laChR[0] = hostWgTrigGate_f;
            laChR[1] = s1WgTrigGate_f;
            laChR[2] = wgDataBit_f;
            laChR[3] = wgClk_f;
            laChR[4] = wgTrig_f;
            laChR[5] = wgRfout_f; 
            laChR[6] = hostVideoGate_f;
            laChR[7] = s1VideoGate_f;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0010)begin
            laChR[0] = hostS1TxData_w;
            laChR[1] = s1TxData_w;
            laChR[2] = hostS1RxIn_f;
            laChR[3] = hostS2RxIn_f;
            laChR[4] = s1RxIn_f;
            laChR[5] = s1RxPack_w; 
            laChR[6] = hostS1RxPack_w;
            laChR[7] = hostS2RxPack_w;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0011)begin
            laChR[0] = hostVideoGate_f;
            laChR[1] = s1VideoGate_f;
            laChR[2] = hostWgTrigGate_f;
            laChR[3] = s1WgTrigGate_f;
            laChR[4] = hostS1RxIn_f;
            laChR[5] = s1RxIn_f; 
            laChR[6] = hostS1RxClk4m_w;
            laChR[7] = s1RxClk4m_w;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0100)begin
            laChR[0] = hdfioA[0];
            laChR[1] = hdfioA[1];
            laChR[2] = hdfioA[2];
            laChR[3] = hdfioA[3];
            laChR[4] = hdfioA[4];
            laChR[5] = hdfioA[5]; 
            laChR[6] = hdfioA[6];
            laChR[7] = hdfioA[7];
            //===========================
        end  
        if(bmem[5][19:16] == 4'b0101)begin
            laChR[0] = hdfioA[8];
            laChR[1] = hdfioA[9];
            laChR[2] = hdfioA[10];
            laChR[3] = hdfioA[11];
            laChR[4] = hdfioA[12];
            laChR[5] = hdfioA[13];
            laChR[6] = wgRfOut;
            laChR[7] = debugPin1_f;
            //===========================
        end
        
        if(bmem[5][19:16] == 4'b0110)begin
            laChR[0] = rfInA[0];
            laChR[1] = rfInA[1];
            laChR[2] = rfInA[4];
            laChR[3] = rfOutA[1];
            laChR[4] = rfInA[6];
            laChR[5] = rfInA[7]; 
            laChR[6] = rfInA[10];
            laChR[7] = rfOutA[3];
            //===========================
        end  
          
        if(bmem[5][19:16] == 4'b0111)begin
            laChR[0] = fibTxA[0];
            laChR[1] = fibRxA[0];
            laChR[2] = fibTxA[1];
            laChR[3] = fibRxA[1];
            laChR[4] = fibTxA[2];
            laChR[5] = fibRxA[2];
            laChR[6] = fibTxA[3];
            laChR[7] = fibRxA[3];
            //===========================
        end
          
          
        if(bmem[5][19:16] == 4'b1000)begin
            laChR[0] = fibTxB1;
            laChR[1] = fibRxB1;
            laChR[2] = fibTxB3;
            laChR[3] = fibRxB3;
            laChR[4] = fibTxB5;
            laChR[5] = fibRxB5; 
            laChR[6] = fibTxB7;
            laChR[7] = fibRxB7;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1001)begin
            laChR[0] = txSysData1_load_w;
            laChR[1] = txSysData1_clk_w;
            laChR[2] = txSysData1_data_w;
            laChR[3] = rxSysData1_in_f;;
            laChR[4] = rxSysData1_clk_w;
            laChR[5] = rxSysData1_pack_w; 
            laChR[6] = hostS1TxEnd_w;
            laChR[7] = hostS1RxPack_w;
            //===========================
        end  
        
        if(bmem[5][19:16] == 4'b1010)begin
            laChR[0] = a_snd_clk;
            laChR[1] = a_snd_tx;
            laChR[2] = aSndRx;
            laChR[3] = b_snd_clk;
            laChR[4] = b_snd_tx;
            laChR[5] = bSndRx;
            laChR[6] = 0;
            laChR[7] = 0;
            //===========================
        end  
        
        if(bmem[5][19:16] == 4'b1011)begin
            laChR[0] = inpChk0;     //rs485Di fpga->485
            laChR[1] = inpChk1;     //rs485Ro 485->fpga
            laChR[2] = inpChkA[3];  //rs485De fpga->485
            laChR[3] = inpChk2;     //ipcRx  fpga->ipc
            laChR[4] = inpChk3;     //ipcTx  ipc->fpda
            laChR[5] = 0;
            laChR[6] = 0;
            laChR[7] = 0;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1100)begin
            laChR[0] = hdfoR[0];
            laChR[1] = hdfoR[1];
            laChR[2] = hdfoR[2];
            laChR[3] = hdfoR[3];
            laChR[4] = hdfoR[4];
            laChR[5] = hdfoR[5];
            laChR[6] = hdfoR[6];
            laChR[7] = hdfoR[7];
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1101)begin
            laChR[0] = hdfioA[0];
            laChR[1] = hdfioA[1];
            laChR[2] = hdfioA[2];
            laChR[3] = hdfioA[3];
            laChR[4] = hdfioA[4];
            laChR[5] = hdfioA[5];
            laChR[6] = hdfioA[6];
            laChR[7] = hdfioA[7];
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1110)begin
            laChR[0] = hdfioA[8];
            laChR[1] = hdfioA[9];
            laChR[2] = hdfioA[10];
            laChR[3] = hdfioA[11];
            laChR[4] = hdfioA[12];
            laChR[5] = hdfioA[13];
            laChR[6] = 0;
            laChR[7] = 0;
            //===========================
        end  
        if(bmem[5][19:16] == 4'b1111)begin
            laChR[0] = mem[17][8];
            laChR[1] = mem[17][9];
            laChR[2] = mem[17][10];
            laChR[3] = mem[17][11];
            laChR[4] = s1RxIn_f;
            laChR[5] = s1RxPack_w; 
            laChR[6] = testBuf[0];
            laChR[7] = s1WgTrigGate_f;
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
assign rfOutA[1]=rf1TxData;
assign rfOutA[3]=rf2TxData;
assign fibTxB1=fibTxB1_f;
assign fibTxB3=fibTxB1_f;
assign fibTxB5=fibTxB1_f;
assign fibTxB7=fibTxB1_f;
assign wgRfOut=wgRfout_f;




    

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
        hostEmuRxDataBuf[0]<={hostEmuRxDataBuf[0][30:0],s1TxData_w};
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
        .txCon_i(bmem[13][16]),
        .txData0_ib(hostS1TxData0),
        .txData1_ib(hostS1TxData1),
        .txData2_ib(hostS1TxData2),
        .txData3_ib(hostS1TxData3),
        .txSyncClkEn_i(txSyncClkEn_f),
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
        .txSyncClkEn_i(txSyncClkEn_f),
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
        .rxClk4m_o(hostS2RxClk4m_w),
        .rxPack_o(hostS2RxPack_w),  //1us high
        .rxData0_ob(hostS2RxData0_wb),
        .rxData1_ob(hostS2RxData1_wb),
        .rxData2_ob(hostS2RxData2_wb),
        .rxData3_ob(hostS2RxData3_wb)
    );

    TXPROC s1TxProc(
        .clk160m_i(clk160m),
        .preDataGate_i(s1SyncPreDataGate_f),
        .txCon_i(bmem[13][16]),
        .txData0_ib(s1TxData0),
        .txData1_ib(s1TxData1),
        .txData2_ib(s1TxData2),
        .txData3_ib(s1TxData3),
        .txSyncClkEn_i(0),
        .txSyncClk_i(0),
        .txLoad_o(s1TxLoad_w),				
        .txData_o(s1TxData_w),				
        .txEnd_o(s1TxEnd_w),				
        .txDataClk_o(s1TxDataClk_w)				
    );


    wire s1RxClk4m_w;
    wire s1RxPack_w;
    wire[15:0] s1RxData0_wb;
    wire[15:0] s1RxData1_wb;
    wire[15:0] s1RxData2_wb;
    wire[15:0] s1RxData3_wb;
    RXPROC s1RxProc(
        .clk160m_i(clk160m),
        .rxData_i(s1RxIn_f),
        //.rxData_i(s1EmuRxDataBuf[3][31]),
        //.rxData_i(s1RxBit),
        .rxClk4m_o(s1RxClk4m_w),
        .rxPack_o(s1RxPack_w),  //1us high
        .rxData0_ob(s1RxData0_wb),
        .rxData1_ob(s1RxData1_wb),
        .rxData2_ob(s1RxData2_wb),
        .rxData3_ob(s1RxData3_wb)
    );

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
// defential output buffers
//===================================================
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    )OBUFDS_inst0 (
        .O(dfOutP[0]),        
        .OB(dfOutN[0]),
        .I(wgClk_f)        
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst1 (
        .O(dfOutP[1]),        
        .OB(dfOutN[1]),       
        .I(wgDataBit_f)       
    );
    //  
    OBUFDS #(
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")       
    ) OBUFDS_inst2 (
        .O(dfOutP[2]),  
        .OB(dfOutN[2]), 
        .I(wgTrig_f) 
    );
    //
    OBUFDS #(
        .IOSTANDARD("DEFAULT"), 
        .SLEW("SLOW")           
    ) OBUFDS_inst3 (
        .O(dfOutP[3]),        
        .OB(dfOutN[3]),       
        .I(wgRfout_f)      
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



