`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/13 15:39:17
// Design Name: 
// Module Name: rxproc
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


module RXSYSDATA1(
        input 					    clk160m_i,
        input                       rxData_i,
        //==================================
        output                      rxClk4m_o,
        output                      rxPack_o,
        output [15:0]               rxData0_ob,
        output [15:0]               rxData1_ob,
        output [15:0]               rxData2_ob,
        output [15:0]               rxData3_ob
    );
    



    reg[9:0] rxPackTime;
    reg rxPack_f;
    reg rxClk4m_f;
    reg[7:0] rxClkHTime;
    reg[15:0] rxd0;
    reg[15:0] rxd1;
    reg[15:0] rxd2;
    reg[15:0] rxd3;
    reg[15:0] rxd4;
    
    reg[15:0] rxd0b;
    reg[15:0] rxd1b;
    reg[15:0] rxd2b;
    reg[15:0] rxd3b;
    reg[15:0] rxd4b;
    
    
    reg[15:0] rxData0;
    reg[15:0] rxData1;
    reg[15:0] rxData2;
    reg[15:0] rxData3;
    

    reg[15:0] rxbuf0;
    reg[15:0] rxbuf1;
    reg[15:0] rxbuf2;
    reg[15:0] rxbuf3;
    reg[15:0] rxbuf4;
    reg[15:0] rxbuf5;
    reg[15:0] rxbuf6;
    reg[15:0] rxbuf7;
    reg[15:0] rxbuf8;
    reg[15:0] rxbuf9;
    reg[15:0] rxbuf10;
    reg[15:0] rxbuf11;
    reg[15:0] rxbuf12;
    reg[15:0] rxbuf13;
    reg[15:0] rxbuf14;
    reg[15:0] rxbuf15;
    reg[15:0] rxHead;
    reg[15:0] rxchk;

    initial begin
        rxPackTime=10'b1111111111;
    
    end
    always @(posedge clk160m_i) begin
		if(rxPackTime<640) //4 us
		    rxPackTime<=rxPackTime+1;
		if(rxPackTime==10)    
            rxPack_f<=1;
		if(rxPackTime==170)    
            rxPack_f<=0;
            
        if(!rxClk4m_f)
            rxClkHTime=0;
		else begin	
		    if(rxClkHTime<20)      
				rxClkHTime<=rxClkHTime+1;
			if(rxClkHTime==1)begin
                if(rxHead!=16'b0101011011100010)
                    rxClkHTime<=40;
                if(rxd0!=rxd0b)
                    rxClkHTime<=40;
                if(rxd1!=rxd1b)
                    rxClkHTime<=40;
                if(rxd2!=rxd2b)
                    rxClkHTime<=40;
                if(rxd3!=rxd3b)
                    rxClkHTime<=40;
                if(rxd4!=rxd4b)
                    rxClkHTime<=40;
                //if(rxd5!=rxd5b)
                //    rxClkHTime<=40;
                rxchk<=rxd0+rxd1;
            end
			if(rxClkHTime==3)
                rxchk<=rxchk+rxd2;
            if(rxClkHTime==5)
                rxchk<=rxchk+rxd3;
			if(rxClkHTime==9 && rxchk==rxd4)begin
                rxPackTime<=0;
                rxData0<=rxd0;
                rxData1<=rxd1;
                rxData2<=rxd2;
                rxData3<=rxd3;
            end	
		end
	end	 
	
	
    always @(posedge rxClk4m_f) begin
        rxbuf0<={rxbuf0[14:0],rxbuf1[15]};
        rxbuf1<={rxbuf1[14:0],rxbuf2[15]};
        rxbuf2<={rxbuf2[14:0],rxbuf3[15]};
	    rxbuf3<={rxbuf3[14:0],rxbuf4[15]};
	    //=============================
        rxbuf4<={rxbuf4[14:0],rxbuf5[15]};
        rxbuf5<={rxbuf5[14:0],rxbuf6[15]};
        //=====
        rxbuf6<={rxbuf6[14:0],rxbuf7[15]};
        rxbuf7<={rxbuf7[14:0],rxbuf8[15]};
        //=====
        rxbuf8<={rxbuf8[14:0],rxbuf9[15]};
        rxbuf9<={rxbuf9[14:0],rxbuf10[15]};
        //=====
        rxbuf10<={rxbuf10[14:0],rxbuf11[15]};
        rxbuf11<={rxbuf11[14:0],rxbuf12[15]};
        //=====
        rxbuf12<={rxbuf12[14:0],rxbuf13[15]};
        rxbuf13<={rxbuf13[14:0],rxData_i};
        //=====
        //rxbuf14<={rxbuf14[14:0],rxbuf15[15]};
        //rxbuf15<={rxbuf15[14:0],rxData_i};
        //========================
        rxHead[15:0]<=rxbuf3[15:0];
        
        rxd0[15:12]<={rxbuf4[15], rxbuf4[13], rxbuf4[11], rxbuf4[9]};
        rxd0[11:8] <={rxbuf4[7] , rxbuf4[5] , rxbuf4[3] , rxbuf4[1]};
        rxd0[7:4]  <={rxbuf5[15], rxbuf5[13], rxbuf5[11], rxbuf5[9]};
        rxd0[3:0]  <={rxbuf5[7] , rxbuf5[5] , rxbuf5[3] , rxbuf5[1]};
        //========================
        rxd1[15:12]<={rxbuf6[15], rxbuf6[13], rxbuf6[11], rxbuf6[9]};
        rxd1[11:8] <={rxbuf6[7] , rxbuf6[5] , rxbuf6[3] , rxbuf6[1]};
        rxd1[7:4]  <={rxbuf7[15], rxbuf7[13], rxbuf7[11], rxbuf7[9]};
        rxd1[3:0]  <={rxbuf7[7] , rxbuf7[5] , rxbuf7[3] , rxbuf7[1]};
        //========================
        rxd2[15:12]<={rxbuf8[15], rxbuf8[13], rxbuf8[11], rxbuf8[9]};
        rxd2[11:8] <={rxbuf8[7] , rxbuf8[5] , rxbuf8[3] , rxbuf8[1]};
        rxd2[7:4]  <={rxbuf9[15], rxbuf9[13], rxbuf9[11], rxbuf9[9]};
        rxd2[3:0]  <={rxbuf9[7] , rxbuf9[5] , rxbuf9[3] , rxbuf9[1]};
        //========================
        rxd3[15:12]<={rxbuf10[15], rxbuf10[13], rxbuf10[11], rxbuf10[9]};
        rxd3[11:8] <={rxbuf10[7] , rxbuf10[5] , rxbuf10[3] , rxbuf10[1]};
        rxd3[7:4]  <={rxbuf11[15], rxbuf11[13], rxbuf11[11], rxbuf11[9]};
        rxd3[3:0]  <={rxbuf11[7] , rxbuf11[5] , rxbuf11[3] , rxbuf11[1]};
        //========================
        rxd4[15:12]<={rxbuf12[15], rxbuf12[13], rxbuf12[11], rxbuf12[9]};
        rxd4[11:8] <={rxbuf12[7] , rxbuf12[5] , rxbuf12[3] , rxbuf12[1]};
        rxd4[7:4]  <={rxbuf13[15], rxbuf13[13], rxbuf13[11], rxbuf13[9]};
        rxd4[3:0]  <={rxbuf13[7] , rxbuf13[5] , rxbuf13[3] , rxbuf13[1]};
        //========================
        //rxd5[15:12]<={rxbuf14[15], rxbuf14[13], rxbuf14[11], rxbuf14[9]};
        //rxd5[11:8] <={rxbuf14[7] , rxbuf14[5] , rxbuf14[3] , rxbuf14[1]};
        //rxd5[7:4]  <={rxbuf15[15], rxbuf15[13], rxbuf15[11], rxbuf15[9]};
        //rxd5[3:0]  <={rxbuf15[7] , rxbuf15[5] , rxbuf15[3] , rxbuf15[1]};
        //================================================================
        rxd0b[15:12]<={!rxbuf4[14], !rxbuf4[12], !rxbuf4[10], !rxbuf4[8]};
        rxd0b[11:8] <={!rxbuf4[6] , !rxbuf4[4] , !rxbuf4[2] , !rxbuf4[0]};
        rxd0b[7:4]  <={!rxbuf5[14], !rxbuf5[12], !rxbuf5[10], !rxbuf5[8]};
        rxd0b[3:0]  <={!rxbuf5[6] , !rxbuf5[4] , !rxbuf5[2] , !rxbuf5[0]};
        //========================
        rxd1b[15:12]<={!rxbuf6[14], !rxbuf6[12], !rxbuf6[10], !rxbuf6[8]};
        rxd1b[11:8] <={!rxbuf6[6] , !rxbuf6[4] , !rxbuf6[2] , !rxbuf6[0]};
        rxd1b[7:4]  <={!rxbuf7[14], !rxbuf7[12], !rxbuf7[10], !rxbuf7[8]};
        rxd1b[3:0]  <={!rxbuf7[6] , !rxbuf7[4] , !rxbuf7[2] , !rxbuf7[0]};
        //========================
        rxd2b[15:12]<={!rxbuf8[14], !rxbuf8[12], !rxbuf8[10], !rxbuf8[8]};
        rxd2b[11:8] <={!rxbuf8[6] , !rxbuf8[4] , !rxbuf8[2] , !rxbuf8[0]};
        rxd2b[7:4]  <={!rxbuf9[14], !rxbuf9[12], !rxbuf9[10], !rxbuf9[8]};
        rxd2b[3:0]  <={!rxbuf9[6] , !rxbuf9[4] , !rxbuf9[2] , !rxbuf9[0]};
        //========================
        rxd3b[15:12]<={!rxbuf10[14], !rxbuf10[12], !rxbuf10[10], !rxbuf10[8]};
        rxd3b[11:8] <={!rxbuf10[6] , !rxbuf10[4] , !rxbuf10[2] , !rxbuf10[0]};
        rxd3b[7:4]  <={!rxbuf11[14], !rxbuf11[12], !rxbuf11[10], !rxbuf11[8]};
        rxd3b[3:0]  <={!rxbuf11[6] , !rxbuf11[4] , !rxbuf11[2] , !rxbuf11[0]};
        //========================
        rxd4b[15:12]<={!rxbuf12[14], !rxbuf12[12], !rxbuf12[10], !rxbuf12[8]};
        rxd4b[11:8] <={!rxbuf12[6] , !rxbuf12[4] , !rxbuf12[2] , !rxbuf12[0]};
        rxd4b[7:4]  <={!rxbuf13[14], !rxbuf13[12], !rxbuf13[10], !rxbuf13[8]};
        rxd4b[3:0]  <={!rxbuf13[6] , !rxbuf13[4] , !rxbuf13[2] , !rxbuf13[0]};
        //========================
        //rxd5b[15:12]<={!rxbuf14[14], !rxbuf14[12], !rxbuf14[10], !rxbuf14[8]};
        //rxd5b[11:8] <={!rxbuf14[6] , !rxbuf14[4] , !rxbuf14[2] , !rxbuf14[0]};
        //rxd5b[7:4]  <={!rxbuf15[14], !rxbuf15[12], !rxbuf15[10], !rxbuf15[8]};
        //rxd5b[3:0]  <={!rxbuf15[6] , !rxbuf15[4] , !rxbuf15[2] , !rxbuf15[0]};
        //========================
	end			
	
	
    //rxclk generator
    //==================================================================================
    reg[5:0] rx4mTimeCnt;
    reg[5:0] rxinHTimeCnt;
    always @(posedge clk160m_i) begin
        if(rx4mTimeCnt==39)
            rx4mTimeCnt<=0;
        else
            rx4mTimeCnt<=rx4mTimeCnt+1;
        //================
        if(rx4mTimeCnt<16)
            rxClk4m_f<=0;
		else if(rx4mTimeCnt<36)
            rxClk4m_f<=1;
        else
            rxClk4m_f<=0;
        //================
        if(!rxData_i) 
            rxinHTimeCnt<=0;
        else begin
            if(!rxinHTimeCnt[4])
                rxinHTimeCnt<=rxinHTimeCnt+1;
            if(rxinHTimeCnt==4)begin
                if(rx4mTimeCnt==0)
                    rx4mTimeCnt<=1;
                else if(rx4mTimeCnt==38)
                    rx4mTimeCnt<=0;
                else if(rx4mTimeCnt==39)
                    rx4mTimeCnt<=1;
                else if(rx4mTimeCnt<20)
                    rx4mTimeCnt<=rx4mTimeCnt;   
                else
                    rx4mTimeCnt<=rx4mTimeCnt+2;
            end
		end
	end	
	assign rxData0_ob = rxData0;
	assign rxData1_ob = rxData1;
	assign rxData2_ob = rxData2;
	assign rxData3_ob = rxData3;
	assign rxPack_o = rxPack_f;
	assign rxClk4m_o = rxClk4m_f;
		
		
endmodule