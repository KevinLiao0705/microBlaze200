-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
-- Date        : Mon Jul 14 14:12:32 2025
-- Host        : DESKTOP-V5UHSH2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               e:/kevin/myCode/microBlaze200/microBlaze1.gen/sources_1/bd/design_1/ip/design_1_hw0_0_0/design_1_hw0_0_0_stub.vhdl
-- Design      : design_1_hw0_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_hw0_0_0 is
  Port ( 
    ramClk : in STD_LOGIC;
    ramAddr : in STD_LOGIC_VECTOR ( 12 downto 0 );
    ramInData : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ramOutData : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ramWe : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ramEn : in STD_LOGIC;
    ramRstp : in STD_LOGIC;
    sysClk : in STD_LOGIC;
    clk160m : in STD_LOGIC;
    resetN : in STD_LOGIC;
    gpsPps : in STD_LOGIC;
    ledV3 : out STD_LOGIC;
    ledV4 : out STD_LOGIC;
    rfInA : in STD_LOGIC_VECTOR ( 11 downto 0 );
    rfOutA : out STD_LOGIC_VECTOR ( 3 downto 0 );
    fibTxA : out STD_LOGIC_VECTOR ( 3 downto 0 );
    fibRxA : in STD_LOGIC_VECTOR ( 3 downto 0 );
    fibTxB1 : out STD_LOGIC;
    fibTxB3 : out STD_LOGIC;
    fibTxB5 : out STD_LOGIC;
    fibTxB7 : out STD_LOGIC;
    fibRxB1 : in STD_LOGIC;
    fibRxB3 : in STD_LOGIC;
    fibRxB5 : in STD_LOGIC;
    fibRxB7 : in STD_LOGIC;
    inpChk0 : in STD_LOGIC;
    inpChk1 : in STD_LOGIC;
    inpChk2 : in STD_LOGIC;
    inpChk3 : in STD_LOGIC;
    inpChkA : in STD_LOGIC_VECTOR ( 7 downto 0 );
    wgRfOut : out STD_LOGIC;
    hdfoA : out STD_LOGIC_VECTOR ( 7 downto 0 );
    laCh : out STD_LOGIC_VECTOR ( 15 downto 0 );
    hdfioA : in STD_LOGIC_VECTOR ( 13 downto 0 );
    dfInP : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dfInN : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dfOutP : out STD_LOGIC_VECTOR ( 7 downto 0 );
    dfOutN : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end design_1_hw0_0_0;

architecture stub of design_1_hw0_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "ramClk,ramAddr[12:0],ramInData[31:0],ramOutData[31:0],ramWe[3:0],ramEn,ramRstp,sysClk,clk160m,resetN,gpsPps,ledV3,ledV4,rfInA[11:0],rfOutA[3:0],fibTxA[3:0],fibRxA[3:0],fibTxB1,fibTxB3,fibTxB5,fibTxB7,fibRxB1,fibRxB3,fibRxB5,fibRxB7,inpChk0,inpChk1,inpChk2,inpChk3,inpChkA[7:0],wgRfOut,hdfoA[7:0],laCh[15:0],hdfioA[13:0],dfInP[15:0],dfInN[15:0],dfOutP[7:0],dfOutN[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "hw0,Vivado 2022.2";
begin
end;
