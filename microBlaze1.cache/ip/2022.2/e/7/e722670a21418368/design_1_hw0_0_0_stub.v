// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Mon Jul 14 14:12:28 2025
// Host        : DESKTOP-V5UHSH2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_hw0_0_0_stub.v
// Design      : design_1_hw0_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "hw0,Vivado 2022.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(ramClk, ramAddr, ramInData, ramOutData, ramWe, 
  ramEn, ramRstp, sysClk, clk160m, resetN, gpsPps, ledV3, ledV4, rfInA, rfOutA, fibTxA, fibRxA, fibTxB1, 
  fibTxB3, fibTxB5, fibTxB7, fibRxB1, fibRxB3, fibRxB5, fibRxB7, inpChk0, inpChk1, inpChk2, inpChk3, 
  inpChkA, wgRfOut, hdfoA, laCh, hdfioA, dfInP, dfInN, dfOutP, dfOutN)
/* synthesis syn_black_box black_box_pad_pin="ramClk,ramAddr[12:0],ramInData[31:0],ramOutData[31:0],ramWe[3:0],ramEn,ramRstp,sysClk,clk160m,resetN,gpsPps,ledV3,ledV4,rfInA[11:0],rfOutA[3:0],fibTxA[3:0],fibRxA[3:0],fibTxB1,fibTxB3,fibTxB5,fibTxB7,fibRxB1,fibRxB3,fibRxB5,fibRxB7,inpChk0,inpChk1,inpChk2,inpChk3,inpChkA[7:0],wgRfOut,hdfoA[7:0],laCh[15:0],hdfioA[13:0],dfInP[15:0],dfInN[15:0],dfOutP[7:0],dfOutN[7:0]" */;
  input ramClk;
  input [12:0]ramAddr;
  input [31:0]ramInData;
  output [31:0]ramOutData;
  input [3:0]ramWe;
  input ramEn;
  input ramRstp;
  input sysClk;
  input clk160m;
  input resetN;
  input gpsPps;
  output ledV3;
  output ledV4;
  input [11:0]rfInA;
  output [3:0]rfOutA;
  output [3:0]fibTxA;
  input [3:0]fibRxA;
  output fibTxB1;
  output fibTxB3;
  output fibTxB5;
  output fibTxB7;
  input fibRxB1;
  input fibRxB3;
  input fibRxB5;
  input fibRxB7;
  input inpChk0;
  input inpChk1;
  input inpChk2;
  input inpChk3;
  input [7:0]inpChkA;
  output wgRfOut;
  output [7:0]hdfoA;
  output [15:0]laCh;
  input [13:0]hdfioA;
  input [15:0]dfInP;
  input [15:0]dfInN;
  output [7:0]dfOutP;
  output [7:0]dfOutN;
endmodule
