############## clock define##################
#create_clock -period 5.000 [get_ports clkSys_clk_p]
#set_property PACKAGE_PIN V4 [get_ports clkSys_clk_p]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports clkSys_clk_p]
#set_property PACKAGE_PIN W4 [get_ports clkSys_clk_n]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports clkSys_clk_n]



#create_clock -period 20.000 [get_ports {sysClk50m}]
set_property PACKAGE_PIN W19 [get_ports {sysClk50m}]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports {sysClk}]
set_property IOSTANDARD LVCMOS25 [get_ports {sysClk50m}]
# switchK1, resetBN
#set_property PACKAGE_PIN H13 [get_ports {sysResetN}]
#set_property IOSTANDARD LVCMOS25 [get_ports {sysResetN}]
# ledV3
set_property PACKAGE_PIN H14 [get_ports {ledV3}]
set_property IOSTANDARD LVCMOS25 [get_ports {ledV3}]
# ledV4
set_property PACKAGE_PIN J14 [get_ports {ledV4}]
set_property IOSTANDARD LVCMOS25 [get_ports {ledV4}]


#====================================================================

# ioA40
set_property PACKAGE_PIN T5 [get_ports {gpsPps}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpsPps}]





# rs485Ro
set_property PACKAGE_PIN W17 [get_ports {rs485Ro}]
set_property IOSTANDARD LVCMOS25 [get_ports {rs485Ro}]

# rs485Di
set_property PACKAGE_PIN AB20 [get_ports {rs485Di}]
set_property IOSTANDARD LVCMOS25 [get_ports {rs485Di}]

######################################################################
# ioA0 RFMA_CKO
set_property PACKAGE_PIN T4 [get_ports {rfInA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[0]}]

# ioA1 RFMA_DIO2
set_property PACKAGE_PIN U3 [get_ports {rfOutA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfOutA[0]}]

# ioA2 RFMA_DIO1
set_property PACKAGE_PIN V4 [get_ports {rfInA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[1]}]

# ioA3 RFMA_D0
set_property PACKAGE_PIN Y3 [get_ports {rfInA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[2]}]

# ioA4  RFMB_CKO
set_property PACKAGE_PIN R2 [get_ports {rfInA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[3]}]

# ioA5 RFMB_DIO2
set_property PACKAGE_PIN U1 [get_ports {rfOutA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfOutA[1]}]

# ioA6 RFMB_DIO1
set_property PACKAGE_PIN W1 [get_ports {rfInA[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[4]}]

# ioA7 RFMB_D0
set_property PACKAGE_PIN Y1 [get_ports {rfInA[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[5]}]

# ioA8 RFMA_CKO
set_property PACKAGE_PIN AB1 [get_ports {rfInA[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[6]}]

# ioA9 RFMA_DIO2
set_property PACKAGE_PIN AB2 [get_ports {rfOutA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfOutA[2]}]

# ioA10 RFMA_DIO1
set_property PACKAGE_PIN W5 [get_ports {rfInA[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[7]}]

# ioA11 RFMA_D0
set_property PACKAGE_PIN R6 [get_ports {rfInA[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[8]}]

# ioA12 RFMB_CKO
set_property PACKAGE_PIN W6 [get_ports {rfInA[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[9]}]

# ioA13 RFMB_DIO2
set_property PACKAGE_PIN Y6 [get_ports {rfOutA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfOutA[3]}]

# ioA14 RFMB_DIO1
set_property PACKAGE_PIN W7 [get_ports {rfInA[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[10]}]

# ioA15 RFMB_D0
set_property PACKAGE_PIN V8 [get_ports {rfInA[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {rfInA[11]}]

######################################################################
# ioA16
set_property PACKAGE_PIN AB5 [get_ports {fibTxA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTxA[0]}]

# ioA17
set_property PACKAGE_PIN AB6 [get_ports {fibRxA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRxA[0]}]

# ioA18
set_property PACKAGE_PIN AB7 [get_ports {fibTx1}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTx1}]

# ioA19
set_property PACKAGE_PIN AB8 [get_ports {fibRx1}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRx1}]

# ioA20
set_property PACKAGE_PIN AB10 [get_ports {fibTxA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTxA[1]}]

# ioA21
set_property PACKAGE_PIN AB11 [get_ports {fibRxA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRxA[1]}]

# ioA22
set_property PACKAGE_PIN AA13 [get_ports {fibTx3}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTx3}]

# ioA23
set_property PACKAGE_PIN AA9 [get_ports {fibRx3}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRx3}]

# ioA24
set_property PACKAGE_PIN Y8 [get_ports {fibTxA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTxA[2]}]

# ioA25
set_property PACKAGE_PIN Y11 [get_ports {fibRxA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRxA[2]}]

# ioA26
set_property PACKAGE_PIN V9 [get_ports {fibTx5}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTx5}]

# ioA27
set_property PACKAGE_PIN W10 [get_ports {fibRx5}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRx5}]

# ioA28
set_property PACKAGE_PIN W12 [get_ports {fibTxA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTxA[3]}]

# ioA29
set_property PACKAGE_PIN Y14 [get_ports {fibRxA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRxA[3]}]

# ioA30
set_property PACKAGE_PIN W14 [get_ports {fibTx7}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibTx7}]

# ioA31
set_property PACKAGE_PIN W15 [get_ports {fibRx7}]
set_property IOSTANDARD LVCMOS25 [get_ports {fibRx7}]

# ioA32
set_property PACKAGE_PIN AB15 [get_ports {gpInA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[0]}]

# ioA33
set_property PACKAGE_PIN AB16 [get_ports {gpInA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[1]}]

# ioA34  sw1_1
#set_property PULLUP TRUE [get_ports {gpInA[2]}]
set_property PACKAGE_PIN AB17 [get_ports {gpInA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[2]}]

# ioA35 sw1_2
#set_property PULLUP TRUE [get_ports {gpInA[3]}]
set_property PACKAGE_PIN AB18 [get_ports {gpInA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[3]}]


# iob68  sw1_3
#set_property PULLUP TRUE [get_ports {gpInA[8]}]
set_property PACKAGE_PIN V20 [get_ports {gpInA[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[8]}]

# iob69sw1_4
#set_property PULLUP TRUE [get_ports {gpInA[9]}]
set_property PACKAGE_PIN Y19 [get_ports {gpInA[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[9]}]


# ioA36 ledR
set_property PACKAGE_PIN R14 [get_ports {gpOutA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[0]}]

# ioA37 ledG
set_property PACKAGE_PIN V15 [get_ports {gpOutA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[1]}]

#set_property PACKAGE_PIN V15 [get_ports {ledG}]
#set_property IOSTANDARD LVCMOS25 [get_ports {ledG}]


# ioA38 ledB
set_property PACKAGE_PIN Y17 [get_ports {gpOutA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[2]}]

# ioA39 rs485De
set_property PACKAGE_PIN AA19 [get_ports {gpOutA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[3]}]

# ioA41 wfRfOut
set_property PACKAGE_PIN U5 [get_ports {wgRfOut}]
set_property IOSTANDARD LVCMOS25 [get_ports {wgRfOut}]


# ioA44
set_property PACKAGE_PIN AA3 [get_ports {gpOutA[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[4]}]

# ioA45
set_property PACKAGE_PIN T1 [get_ports {gpOutA[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[5]}]

# ioA46
set_property PACKAGE_PIN U2 [get_ports {gpOutA[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[6]}]

# ioA47 ledV1
set_property PACKAGE_PIN K13 [get_ports {gpOutA[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpOutA[7]}]









###############################################################################################
# ioB40 slotSw3
set_property PACKAGE_PIN H18 [get_ports {gpInA[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[7]}]

# ioB41 slotSw2
set_property PACKAGE_PIN K16 [get_ports {gpInA[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[6]}]

# ioB42 slotSw1
set_property PACKAGE_PIN K18 [get_ports {gpInA[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[5]}]

# ioB43 slotSw0
set_property PACKAGE_PIN J16 [get_ports {gpInA[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpInA[4]}]

# ioB46
set_property PACKAGE_PIN M20 [get_ports {uartIpcTx2}]
set_property IOSTANDARD LVCMOS25 [get_ports {uartIpcTx2}]

# ioB47
set_property PACKAGE_PIN L16 [get_ports {uartIpcRx2}]
set_property IOSTANDARD LVCMOS25 [get_ports {uartIpcRx2}]

# ioB46
set_property PACKAGE_PIN N15 [get_ports {uartIpcTxH}]
set_property IOSTANDARD LVCMOS25 [get_ports {uartIpcTxH}]

# ioB47
set_property PACKAGE_PIN H22 [get_ports {uartIpcRxH}]
set_property IOSTANDARD LVCMOS25 [get_ports {uartIpcRxH}]

####################################################################################
# ioB22
set_property PACKAGE_PIN P16 [get_ports {hdfoA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[0]}]

# ioB23
set_property PACKAGE_PIN T18 [get_ports {hdfoA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[1]}]

# ioB24
set_property PACKAGE_PIN U18 [get_ports {hdfoA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[2]}]

# ioB25
set_property PACKAGE_PIN R17 [get_ports {hdfoA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[3]}]

# ioB26
set_property PACKAGE_PIN P15 [get_ports {hdfoA[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[4]}]

# ioB27
set_property PACKAGE_PIN R16 [get_ports {hdfoA[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[5]}]

# ioB28
set_property PACKAGE_PIN V17 [get_ports {hdfoA[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[6]}]

# ioB29
set_property PACKAGE_PIN U17 [get_ports {hdfoA[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfoA[7]}]


#############################################################################################
# ioB0 spFreqCh0
set_property PACKAGE_PIN G15 [get_ports {hdfioA[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[0]}]

# ioB1 spFreqCh1
set_property PACKAGE_PIN G18 [get_ports {hdfioA[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[1]}]

# ioB2 spFreqCh2
set_property PACKAGE_PIN H15 [get_ports {hdfioA[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[2]}]

# ioB3 spFreqCh3
set_property PACKAGE_PIN H17 [get_ports {hdfioA[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[3]}]

# ioB4 spFreqCh4
set_property PACKAGE_PIN J17 [get_ports {hdfioA[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[4]}]

# ioB5 spFreqCh5
set_property PACKAGE_PIN J19 [get_ports {hdfioA[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[5]}]

# ioB6 spInhib
set_property PACKAGE_PIN J15 [get_ports {hdfioA[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[6]}]

# ioB7 spPreTrig
set_property PACKAGE_PIN K14 [get_ports {hdfioA[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[7]}]

# ioB8 spGate
set_property PACKAGE_PIN L15 [get_ports {hdfioA[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[8]}]

# ioB9 spPulseWidthCh0
set_property PACKAGE_PIN L19 [get_ports {hdfioA[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[9]}]

# ioB10 spPulseWidthCh1
set_property PACKAGE_PIN M18 [get_ports {hdfioA[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[10]}]

# ioB11 spPulseWidthCh2
set_property PACKAGE_PIN H20 [get_ports {hdfioA[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[11]}]

# ioB12 spPulseWidthCh3
set_property PACKAGE_PIN J21 [get_ports {hdfioA[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[12]}]

# ioB13 spPulseWidthCh4
set_property PACKAGE_PIN K21 [get_ports {hdfioA[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hdfioA[13]}]


############################################################################################
# DF8 L11 laCh0, laCh2
set_property PACKAGE_PIN B17 [get_ports {laCh[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[0]}]
set_property PACKAGE_PIN B18 [get_ports {laCh[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[2]}]

# DF9 L5 laCh4, laCh6
set_property PACKAGE_PIN E16 [get_ports {laCh[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[4]}]
set_property PACKAGE_PIN D16 [get_ports {laCh[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[6]}]

# DF12 L17 laCh1, laCh3
set_property PACKAGE_PIN A18 [get_ports {laCh[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[1]}]
set_property PACKAGE_PIN A19 [get_ports {laCh[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[3]}]

# DF13 L16 laCh5, laCh7
set_property PACKAGE_PIN B20 [get_ports {laCh[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[5]}]
set_property PACKAGE_PIN A20 [get_ports {laCh[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[7]}]

# DF10 L13 laCh8, laCh10
set_property PACKAGE_PIN C18 [get_ports {laCh[8]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[8]}]
set_property PACKAGE_PIN C19 [get_ports {laCh[10]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[10]}]

# DF11 L19 laCh12, laCh14
set_property PACKAGE_PIN D20 [get_ports {laCh[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[12]}]
set_property PACKAGE_PIN C20 [get_ports {laCh[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[14]}]

# DF14 L21 laCh9, laCh11
set_property PACKAGE_PIN B21 [get_ports {laCh[9]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[9]}]
set_property PACKAGE_PIN A21 [get_ports {laCh[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[11]}]

# DF15 L23 laCh13, laCh15
set_property PACKAGE_PIN E21 [get_ports {laCh[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[13]}]
set_property PACKAGE_PIN D21 [get_ports {laCh[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {laCh[15]}]


#/==============================================================
# DF0  L8 wgClk
set_property PACKAGE_PIN C13 [get_ports {dfOutP[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[0]}]
set_property PACKAGE_PIN B13 [get_ports {dfOutN[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[0]}]

# DF1 L6 wgData
set_property PACKAGE_PIN D14 [get_ports {dfOutP[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[1]}]
set_property PACKAGE_PIN D15 [get_ports {dfOutN[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[1]}]

# DF2 L10 wgTrig 
set_property PACKAGE_PIN A13 [get_ports {dfOutP[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[2]}]
set_property PACKAGE_PIN A14 [get_ports {dfOutN[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[2]}]

# DF3 L9 wgRfout
set_property PACKAGE_PIN A15 [get_ports {dfOutP[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[3]}]
set_property PACKAGE_PIN A16 [get_ports {dfOutN[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[3]}]

# DF4 L1 bSndClk
set_property PACKAGE_PIN F13 [get_ports {dfOutP[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[4]}]
set_property PACKAGE_PIN F14 [get_ports {dfOutN[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[4]}]

# DF5 L3 aSndTx
set_property PACKAGE_PIN C14 [get_ports {dfOutP[5]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[5]}]
set_property PACKAGE_PIN C15 [get_ports {dfOutN[5]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[5]}]

# DF6 L15 aSndRx
set_property PACKAGE_PIN F18 [get_ports {dfInP[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfInP[0]}]
set_property PACKAGE_PIN E18 [get_ports {dfInN[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfInN[0]}]


# DF16 L14 bSndClk
set_property PACKAGE_PIN E19 [get_ports {dfOutP[6]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[6]}]
set_property PACKAGE_PIN D19 [get_ports {dfOutN[6]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[6]}]

# DF17 L18 bSndTx
set_property PACKAGE_PIN F19 [get_ports {dfOutP[7]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutP[7]}]
set_property PACKAGE_PIN F20 [get_ports {dfOutN[7]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfOutN[7]}]

# DF18 L20 bSndRx
set_property PACKAGE_PIN C22 [get_ports {dfInP[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfInP[1]}]
set_property PACKAGE_PIN B22 [get_ports {dfInN[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dfInN[1]}]
#/==============================================================





#############SPI Configurate Setting##################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]