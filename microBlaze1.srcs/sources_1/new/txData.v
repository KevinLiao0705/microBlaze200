`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/22 16:26:03
// Design Name: 
// Module Name: txData
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


module TXSYSDATA(
        input 					    clk160m_i,
        input 					    preDataGate_i,
        input [15:0]                txData0_ib,
        input [15:0]                txData1_ib,
        input [15:0]                txData2_ib,
        input [15:0]                txData3_ib,
        output                      txClk_o,
        output                      txLoad_o,
        output                      txData_o				
    );
    
      reg[7:0] txClkHCnt;
      reg[5:0] txSync4mTimeCnt;
      reg txSync4mClk;
        
    //======================================================================    
    always @(posedge clk160m_i) begin
    //========================
        if(txSync4mTimeCnt==39)
            txSync4mTimeCnt<=0;
        else    
            txSync4mTimeCnt<=txSync4mTimeCnt+1;
        if(txSync4mTimeCnt<10)
            txSync4mClk<=1'b0;
        else if(txSync4mTimeCnt<30)
            txSync4mClk<=1'b1;
        else
            txSync4mClk<=1'b0;
    end 
    //======================================================================    
    
    
      reg[9:0] txBitCnt;
      reg[4:0] dataGateHTime;
      reg[4:0] clk4mHCnt;
      reg[4:0] clk4mLCnt;
      reg txload_f;
      reg txBitClk_f;        

    //======================================================================
    //4M txclk generator
    //input clk160m_i,preVideoGate_i
    //output clk4m,txload_f
    reg preDataGate_f;    
    always @(posedge clk160m_i) begin
        if(!txSync4mClk)begin
            clk4mHCnt<=0;
            if(clk4mLCnt<20)
                clk4mLCnt<=clk4mLCnt+1;
            if(clk4mLCnt==8)begin
                txload_f<=0;
                txBitClk_f<=0;
            end 	
        end 
        else begin
            clk4mLCnt<=0;
            if(clk4mHCnt<20)
                clk4mHCnt<=clk4mHCnt+1;
            if(clk4mHCnt==8)begin
                 txBitClk_f<=1;
                if(dataGateHTime<20)
                    dataGateHTime<=dataGateHTime+1;
                if(dataGateHTime==3)//6
                    txload_f<=1;
            end
        end
        if(!preDataGate_i)begin
            if(preDataGate_f)begin
                txBitCnt<=10'b0000000000;
                dataGateHTime<=5'b00000;
                clk4mHCnt<=5'b00000;
                clk4mLCnt<=5'b00000;
                txload_f<=1'b0;	
            end
            preDataGate_f<=preDataGate_i;
        end
        else begin
            preDataGate_f<=preDataGate_i;
        end
        
            		 
    end 
    
    
    
        
    //======================================================================    
    reg[7:0] txload_cnt;
    //reg[15:0] txd5;
    reg[15:0] txd4;
    reg[15:0] txd3;
    reg[15:0] txd2;
    reg[15:0] txd1;
    reg[15:0] txd0;
    
    //reg[15:0] txbuf0;
    //reg[15:0] txbuf1;
    reg[15:0] txbuf2;
    reg[15:0] txbuf3;
    reg[15:0] txbuf4;
    reg[15:0] txbuf5;
    reg[15:0] txbuf6;
    reg[15:0] txbuf7;
    reg[15:0] txbuf8;
    reg[15:0] txbuf9;
    reg[15:0] txbuf10;
    reg[15:0] txbuf11;
    reg[15:0] txbuf12;
    reg[15:0] txbuf13;
    //reg[15:0] txbuf14;
    //reg[15:0] txbuf15;
    


    //reg[15:0] txbuf0b;
    //reg[15:0] txbuf1b;
    reg[15:0] txbuf2b;
    reg[15:0] txbuf3b;
    reg[15:0] txbuf4b;
    reg[15:0] txbuf5b;
    reg[15:0] txbuf6b;
    reg[15:0] txbuf7b;
    reg[15:0] txbuf8b;
    reg[15:0] txbuf9b;
    reg[15:0] txbuf10b;
    reg[15:0] txbuf11b;
    reg[15:0] txbuf12b;
    reg[15:0] txbuf13b;
    //reg[15:0] txbuf14b;
    //reg[15:0] txbuf15b;
    reg txload2_f;

    
    //txdata dispatch 
    //input cly160m,txload,,Adata2-0,Atime,vg_tim_off;
    //output vgout_en_f,txbuf0-13,vg_tim
    always @(posedge clk160m_i) begin
        if(txload_f==0)begin
            txload_cnt<=0;
            txd0<=txData0_ib;
            txd1<=txData1_ib;
            txd2<=txData2_ib;
            txd3<=txData3_ib;
            txd4<=txData2_ib+txData3_ib;
		end			
		else begin	
            if(!txload_cnt[7])
                txload_cnt<=txload_cnt+1;
			if(txload_cnt==2)
                txd4<=txd4+txd1;
            if(txload_cnt==4)
                txd4<=txd4+txd0;
			if(txload_cnt==6)begin
			    txbuf3[15:0]<=16'b0101011011100010;
			    //==================================
                txbuf4[15:8]<={txd0[15],!txd0[15],txd0[14],!txd0[14],txd0[13],!txd0[13],txd0[12],!txd0[12]};
                txbuf4[7:0]<={txd0[11],!txd0[11],txd0[10],!txd0[10],txd0[9],!txd0[9],txd0[8],!txd0[8]};
                txbuf5[15:8]<={txd0[7],!txd0[7],txd0[6],!txd0[6],txd0[5],!txd0[5],txd0[4],!txd0[4]};
                txbuf5[7:0]<={txd0[3],!txd0[3],txd0[2],!txd0[2],txd0[1],!txd0[1],txd0[0],!txd0[0]};
			    //==================================
                txbuf6[15:8]<={txd1[15],!txd1[15],txd1[14],!txd1[14],txd1[13],!txd1[13],txd1[12],!txd1[12]};
                txbuf6[7:0]<={txd1[11],!txd1[11],txd1[10],!txd1[10],txd1[9],!txd1[9],txd1[8],!txd1[8]};
                txbuf7[15:8]<={txd1[7],!txd1[7],txd1[6],!txd1[6],txd1[5],!txd1[5],txd1[4],!txd1[4]};
                txbuf7[7:0]<={txd1[3],!txd1[3],txd1[2],!txd1[2],txd1[1],!txd1[1],txd1[0],!txd1[0]};
			    //==================================
                txbuf8[15:8]<={txd2[15],!txd2[15],txd2[14],!txd2[14],txd2[13],!txd2[13],txd2[12],!txd2[12]};
                txbuf8[7:0]<={txd2[11],!txd2[11],txd2[10],!txd2[10],txd2[9],!txd2[9],txd2[8],!txd2[8]};
                txbuf9[15:8]<={txd2[7],!txd2[7],txd2[6],!txd2[6],txd2[5],!txd2[5],txd2[4],!txd2[4]};
                txbuf9[7:0]<={txd2[3],!txd2[3],txd2[2],!txd2[2],txd2[1],!txd2[1],txd2[0],!txd2[0]};
			    //==================================
                txbuf10[15:8]<={txd3[15],!txd3[15],txd3[14],!txd3[14],txd3[13],!txd3[13],txd3[12],!txd3[12]};
                txbuf10[7:0]<={txd3[11],!txd3[11],txd3[10],!txd3[10],txd3[9],!txd3[9],txd3[8],!txd3[8]};
                txbuf11[15:8]<={txd3[7],!txd3[7],txd3[6],!txd3[6],txd3[5],!txd3[5],txd3[4],!txd3[4]};
                txbuf11[7:0]<={txd3[3],!txd3[3],txd3[2],!txd3[2],txd3[1],!txd3[1],txd3[0],!txd3[0]};
			    //==================================
                txbuf12[15:8]<={txd4[15],!txd4[15],txd4[14],!txd4[14],txd4[13],!txd4[13],txd4[12],!txd4[12]};
                txbuf12[7:0]<={txd4[11],!txd4[11],txd4[10],!txd4[10],txd4[9],!txd4[9],txd4[8],!txd4[8]};
                txbuf13[15:8]<={txd4[7],!txd4[7],txd4[6],!txd4[6],txd4[5],!txd4[5],txd4[4],!txd4[4]};
                txbuf13[7:0]<={txd4[3],!txd4[3],txd4[2],!txd4[2],txd4[1],!txd4[1],txd4[0],!txd4[0]};
			    //==================================
			end
			if(txload_cnt==8)
                txload2_f<=!txload2_f;
        end			
    end
    //======================================================================    
    
    
    
    
    //txdata transmit 	
    //input txbuf0-13,clk4m,txload_f,reset_n
    //output txData_f
    reg txData_f;
    reg txload2_ff;
    //always @(posedge txBitClk_f or posedge txload2_f) begin
    always @(posedge txBitClk_f) begin
        txData_f<=txbuf3b[15];
        txbuf3b<= {txbuf3b[14:0],txbuf4b[15]};
        txbuf4b<= {txbuf4b[14:0],txbuf5b[15]};
        txbuf5b<= {txbuf5b[14:0],txbuf6b[15]};
        txbuf6b<= {txbuf6b[14:0],txbuf7b[15]};
        txbuf7b<= {txbuf7b[14:0],txbuf8b[15]};
        txbuf8b<= {txbuf8b[14:0],txbuf9b[15]};
        txbuf9b<= {txbuf9b[14:0],txbuf10b[15]};
        txbuf10b<= {txbuf10b[14:0],txbuf11b[15]};
        txbuf11b<= {txbuf11b[14:0],txbuf12b[15]};
        txbuf12b<= {txbuf12b[14:0],txbuf13b[15]};
        txbuf13b<= {txbuf13b[14:0],!txbuf13b[0]};
        if(txload2_f)begin
            if(!txload2_ff)begin
                txbuf3b<=txbuf3;
                txbuf4b<=txbuf4;
                txbuf5b<=txbuf5;
                txbuf6b<=txbuf6;
                txbuf7b<=txbuf7;
                txbuf8b<=txbuf8;
                txbuf9b<=txbuf9;
                txbuf10b<=txbuf10;
                txbuf11b<=txbuf11;
                txbuf12b<=txbuf12;
                txbuf13b<=txbuf13;
            end
            txload2_ff<=txload2_f;
        end
        else begin
            if(txload2_ff)begin
                txbuf3b<=txbuf3;
                txbuf4b<=txbuf4;
                txbuf5b<=txbuf5;
                txbuf6b<=txbuf6;
                txbuf7b<=txbuf7;
                txbuf8b<=txbuf8;
                txbuf9b<=txbuf9;
                txbuf10b<=txbuf10;
                txbuf11b<=txbuf11;
                txbuf12b<=txbuf12;
                txbuf13b<=txbuf13;
            end
            txload2_ff<=txload2_f;
        end            
	end
	assign txClk_o=txBitClk_f;
	assign txLoad_o=txload_f;
	assign txData_o=txData_f;
	
	//clk4m_out=txBitClk;
    
    
    
    
    
endmodule