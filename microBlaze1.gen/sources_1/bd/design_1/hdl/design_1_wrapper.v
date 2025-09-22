//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Mon Jul 14 14:10:13 2025
//Host        : DESKTOP-V5UHSH2 running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (dfInN,
    dfInP,
    dfOutN,
    dfOutP,
    fibRx1,
    fibRx3,
    fibRx5,
    fibRx7,
    fibRxA,
    fibTx1,
    fibTx3,
    fibTx5,
    fibTx7,
    fibTxA,
    gpInA,
    gpOutA,
    gpsPps,
    hdfioA,
    hdfoA,
    laCh,
    ledV3,
    ledV4,
    rfInA,
    rfOutA,
    rs485Di,
    rs485Ro,
    sysClk50m,
    uartIpcRx2,
    uartIpcRxH,
    uartIpcTx2,
    uartIpcTxH,
    wgRfOut);
  input [15:0]dfInN;
  input [15:0]dfInP;
  output [7:0]dfOutN;
  output [7:0]dfOutP;
  input fibRx1;
  input fibRx3;
  input fibRx5;
  input fibRx7;
  input [3:0]fibRxA;
  output fibTx1;
  output fibTx3;
  output fibTx5;
  output fibTx7;
  output [3:0]fibTxA;
  input [9:0]gpInA;
  output [7:0]gpOutA;
  input gpsPps;
  inout [13:0]hdfioA;
  output [7:0]hdfoA;
  output [15:0]laCh;
  output ledV3;
  output ledV4;
  input [11:0]rfInA;
  output [3:0]rfOutA;
  output rs485Di;
  input rs485Ro;
  input sysClk50m;
  output uartIpcRx2;
  output uartIpcRxH;
  input uartIpcTx2;
  input uartIpcTxH;
  output wgRfOut;

  wire [15:0]dfInN;
  wire [15:0]dfInP;
  wire [7:0]dfOutN;
  wire [7:0]dfOutP;
  wire fibRx1;
  wire fibRx3;
  wire fibRx5;
  wire fibRx7;
  wire [3:0]fibRxA;
  wire fibTx1;
  wire fibTx3;
  wire fibTx5;
  wire fibTx7;
  wire [3:0]fibTxA;
  wire [9:0]gpInA;
  wire [7:0]gpOutA;
  wire gpsPps;
  wire [13:0]hdfioA;
  wire [7:0]hdfoA;
  wire [15:0]laCh;
  wire ledV3;
  wire ledV4;
  wire [11:0]rfInA;
  wire [3:0]rfOutA;
  wire rs485Di;
  wire rs485Ro;
  wire sysClk50m;
  wire uartIpcRx2;
  wire uartIpcRxH;
  wire uartIpcTx2;
  wire uartIpcTxH;
  wire wgRfOut;

  design_1 design_1_i
       (.dfInN(dfInN),
        .dfInP(dfInP),
        .dfOutN(dfOutN),
        .dfOutP(dfOutP),
        .fibRx1(fibRx1),
        .fibRx3(fibRx3),
        .fibRx5(fibRx5),
        .fibRx7(fibRx7),
        .fibRxA(fibRxA),
        .fibTx1(fibTx1),
        .fibTx3(fibTx3),
        .fibTx5(fibTx5),
        .fibTx7(fibTx7),
        .fibTxA(fibTxA),
        .gpInA(gpInA),
        .gpOutA(gpOutA),
        .gpsPps(gpsPps),
        .hdfioA(hdfioA),
        .hdfoA(hdfoA),
        .laCh(laCh),
        .ledV3(ledV3),
        .ledV4(ledV4),
        .rfInA(rfInA),
        .rfOutA(rfOutA),
        .rs485Di(rs485Di),
        .rs485Ro(rs485Ro),
        .sysClk50m(sysClk50m),
        .uartIpcRx2(uartIpcRx2),
        .uartIpcRxH(uartIpcRxH),
        .uartIpcTx2(uartIpcTx2),
        .uartIpcTxH(uartIpcTxH),
        .wgRfOut(wgRfOut));
endmodule
