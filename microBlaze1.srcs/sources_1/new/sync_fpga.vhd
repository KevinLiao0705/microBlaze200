

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--  Entity Declaration

ENTITY sync_fpga IS
	-- {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
	PORT
	(
		
--2 port memmery use
------------------------------------------------------------		
        AVCKI 	    	:in  	STD_LOGIC;
        AVCSI 	    	:in  	STD_LOGIC;
        AVRDI 	    	:in  	STD_LOGIC;
        AVWRI 	    	:in  	STD_LOGIC;
        AVADDI 	    	:in  	STD_LOGIC_VECTOR(9 downto 0);
        AVRDDO			:out 	STD_LOGIC_VECTOR(7 DOWNTO 0);
        AVWRDI 	    	:in  	STD_LOGIC_VECTOR(7 downto 0);
------------------------------------------------------------		
        RST_N 			:in  	STD_LOGIC;
		clkA 			:IN 	STD_LOGIC;
------------------------------------------------------------		
		oToNios			:OUT 	STD_LOGIC_VECTOR(7 downto 0);
		iFrmNios		:in		STD_LOGIC_VECTOR(7 downto 0);
		iCtrNios		:in		STD_LOGIC_VECTOR(7 downto 0);
------------------------------------------------------------		
		RF1_RXD			:in  	STD_LOGIC;	--RF1_GIO1
		RF1_TXD			:OUT  	STD_LOGIC;	--RF1_GIO2
		RF1_CKO			:in  	STD_LOGIC;	--RF1_CKO
		RF1_TXSW		:OUT	STD_LOGIC;
		RF1_RXSW		:OUT	STD_LOGIC;
------------------------------------------------------------		
		RF2_RXD			:in  	STD_LOGIC;	--RF1_GIO1
		RF2_TXD			:OUT  	STD_LOGIC;	--RF1_GIO2
		RF2_CKO			:in  	STD_LOGIC;	--RF1_CKO
		RF2_TXSW		:OUT	STD_LOGIC;
		RF2_RXSW		:OUT	STD_LOGIC;
------------------------------------------------------------		
		FIB1_RXD		:in  	STD_LOGIC;	--FIBER1_RX
		FIB1_TXD		:OUT  	STD_LOGIC;	--FIBER1_TX
		FIB1_LPR		:in  	STD_LOGIC;	--FIBER2_RX
		FIB1_LPT		:OUT  	STD_LOGIC;	--FIBER2_TX
------------------------------------------------------------		
		FIB2_RXD		:in  	STD_LOGIC;	--FIBER1_RX
		FIB2_TXD		:OUT  	STD_LOGIC;	--FIBER1_TX
		FIB2_LPR		:in  	STD_LOGIC;	--FIBER2_RX
		FIB2_LPT		:OUT  	STD_LOGIC;	--FIBER2_TX
------------------------------------------------------------		
		WG_FREQ			:OUT 	STD_LOGIC_VECTOR(5 downto 0);
		WG_PHASE		:OUT 	STD_LOGIC_VECTOR(7 downto 0);
		WG_VGO			:OUT	STD_LOGIC;
		WG_PWEN			:OUT	STD_LOGIC;
		WG_RFON			:OUT	STD_LOGIC;	
		WG_PWOK			:IN		STD_LOGIC;
		WG_RFOK			:IN		STD_LOGIC;
------------------------------------------------------------
		SP_T0SUBX		:IN 	STD_LOGIC;	--T0-X
		SP_CH0			:IN 	STD_LOGIC;
		SP_CH1			:IN 	STD_LOGIC;
		SP_CH2			:IN 	STD_LOGIC;
		SP_CH3			:IN 	STD_LOGIC;
		SP_CH4			:IN 	STD_LOGIC;
		SP_CH5			:IN 	STD_LOGIC;
		SP_INHIB		:IN 	STD_LOGIC;
		SP_T0VGI		:IN 	STD_LOGIC;
------------------------------------------------------------
		GPS_CK10MI		:IN 	STD_LOGIC;
		GPS_1PPS		:IN 	STD_LOGIC;	
------------------------------------------------------------
		TX_VGO			:OUT	STD_LOGIC;	
		
		VGS_HC			:OUT	STD_LOGIC;	
		VGS_S1			:OUT	STD_LOGIC;	
		VGS_S2			:OUT	STD_LOGIC;	
		
		WGS_S1			:OUT	STD_LOGIC;	
		WGS_S2			:OUT	STD_LOGIC;	
		ALARM_OUT		:OUT  	STD_LOGIC;	
------------------------------------------------------------
		LPIN			:IN		STD_LOGIC_VECTOR(31 downto 0);
		LPNS			:IN		STD_LOGIC_VECTOR(15 downto 0);
------------------------------------------------------------
		dipsw			:IN 	STD_LOGIC_VECTOR(3 downto 0);
		keyin			:IN 	STD_LOGIC_VECTOR(3 downto 0);
		testout 		:OUT 	STD_LOGIC_VECTOR(7 downto 0);
		led				:OUT 	STD_LOGIC_VECTOR(2 downto 0);
		TOLA			:OUT 	STD_LOGIC_VECTOR(35 downto 0);
		ninb			:OUT	STD_LOGIC_VECTOR(7 downto 0);
		nout32			:in  	STD_LOGIC_VECTOR(31 downto 0)


		
		
	);
	-- {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!

	
END sync_fpga;


--  Architecture Body



ARCHITECTURE sync_fpga_body OF sync_fpga IS
	
	
Component DPRAM_128
	PORT
	(
		address_a	: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END Component;


Component txproc
	PORT
	(
        reset_n	    	: 	in  STD_LOGIC;
        clksys 	    	: 	in  STD_LOGIC;
        video_gate  	: 	in  STD_LOGIC;
        txcon_f		  	: 	in  STD_LOGIC;
        tx_data0    	: 	in  STD_LOGIC_VECTOR(15 downto 0);
        tx_data1    	: 	in  STD_LOGIC_VECTOR(15 downto 0);
        tx_data2    	: 	in  STD_LOGIC_VECTOR(15 downto 0);
        tx_data3    	: 	in  STD_LOGIC_VECTOR(15 downto 0);
        tx_data4    	: 	in  STD_LOGIC_VECTOR(15 downto 0);
        txout_f			: 	out  STD_LOGIC;				
        clk4m_out		: 	out  STD_LOGIC;			
        rfen_f		    :   in  STD_LOGIC;
        syncin_f	    :   in  STD_LOGIC
        
	);
END Component;


Component tlpproc 
	PORT
	(
        reset_n	    	: 	in  STD_LOGIC;
        clksys 	    	: 	in  STD_LOGIC;
        txreg		   	: 	in  STD_LOGIC_VECTOR(7 downto 0);
        video_gate		:	in  STD_LOGIC;
        txout_f			: 	out  STD_LOGIC				
	);
END Component;

Component rlpproc 
	PORT
	(
        clksys 	    	: 	in  STD_LOGIC;
        rxin_i	    	: 	in  STD_LOGIC;
		------------------------------------------------------		
		rxclk_o			:	out STD_LOGIC;
        rxpack_o		: 	out STD_LOGIC;						
        rxreg			: 	out STD_LOGIC_VECTOR(7 downto 0)
	);
END Component;





Component rxproc
	PORT
	(
        reset_n	    	: 	in  STD_LOGIC;
        clksys 	    	: 	in  STD_LOGIC;
        rxin_f	    	: 	in  STD_LOGIC;
        rtime_cnt		: 	in  STD_LOGIC_VECTOR(15 downto 0);
		vgrx_tim_off	:	in  STD_LOGIC_VECTOR(15 downto 0);
		vgrt_tim_off	:	in  STD_LOGIC_VECTOR(15 downto 0);
		rxid			:	in  STD_LOGIC_VECTOR(6  downto 0);
		vgrx_tim		:	out STD_LOGIC_VECTOR(15 downto 0);
		vgrt_tim		:	out STD_LOGIC_VECTOR(15 downto 0);
		vgout_en_tim_o  :	out STD_LOGIC_VECTOR(15 downto 0);
        rxclk_out		: 	out STD_LOGIC;				
        rxpack_out		: 	out STD_LOGIC;				
        vgout_en		:	out STD_LOGIC;	
        rx_data0		: 	out STD_LOGIC_VECTOR(15 downto 0);
        rx_data1		: 	out STD_LOGIC_VECTOR(15 downto 0);
        rx_data2		: 	out STD_LOGIC_VECTOR(15 downto 0);
        rx_data3		: 	out STD_LOGIC_VECTOR(15 downto 0);
        rx_data4		: 	out STD_LOGIC_VECTOR(15 downto 0)
	);
END Component;





signal system_set: 	STD_LOGIC_VECTOR (1 downto 0);



type ARR64X8 is array(0 to 63)of std_logic_vector(7 downto 0);
signal mAreg:ARR64X8;
signal mBreg:ARR64X8;



type ARR8X8 is array(0 to 7)of std_logic_vector(7 downto 0);


signal P2MEM_CS: 	STD_LOGIC_VECTOR (7 downto 0);

signal P2MEM0_ADD: STD_LOGIC_VECTOR (6 downto 0);
signal P2MEM1_ADD: STD_LOGIC_VECTOR (6 downto 0);

signal P2MEM0_DATA: STD_LOGIC_VECTOR (7 downto 0);
signal P2MEM1_DATA: STD_LOGIC_VECTOR (7 downto 0);

SIGNAL P2MEM0_WR:	std_logic;
SIGNAL P2MEM1_WR:	std_logic;


signal P2MEM0_QA: STD_LOGIC_VECTOR (7 downto 0);
signal P2MEM1_QA: STD_LOGIC_VECTOR (7 downto 0);

signal P2MEM0_QB: STD_LOGIC_VECTOR (7 downto 0);
signal P2MEM1_QB: STD_LOGIC_VECTOR (7 downto 0);


SIGNAL oToNios_r	:std_logic_Vector(7 downto 0);


SIGNAL vgloop_cnt	:std_logic_Vector(15 downto 0);
SIGNAL vgloop_f		:std_logic;
	
	
SIGNAL memclk_cnt	:std_logic_Vector(2 downto 0);
SIGNAL memadr_clk	:std_logic;
SIGNAL memrw_clk	:std_logic;

SIGNAL rmemA_adr	:std_logic_Vector(6 downto 0);			
SIGNAL wmemB_adr	:std_logic_Vector(6 downto 0);			
SIGNAL rmemA_en_f	:std_logic;
SIGNAL wmemB_en_f	:std_logic;
SIGNAL rmemA_start_f	:std_logic;
SIGNAL wmemB_start_f	:std_logic;

SIGNAL Hrmem_pus_tim		:std_logic_Vector(7 downto 0);			
SIGNAL Hrmem_pus_f		:std_logic;			
SIGNAL Hwmem_pus_f		:std_logic;			
SIGNAL Hnrwmem_pus_f		:std_logic;			

SIGNAL Srmem_pus_f		:std_logic;			
SIGNAL Swmem_pus_f		:std_logic;			
SIGNAL Snrwmem_pus_f		:std_logic;			



SIGNAL auto_rwmem_tim	:std_logic_Vector(23 downto 0);			
SIGNAL vg_rwmem_tim		:std_logic_Vector(23 downto 0);			
SIGNAL fpga_rm_f		:std_logic;			
SIGNAL fpga_wm_f		:std_logic;			
SIGNAL nios_rwm_f		:std_logic;			

SIGNAL load_mema_tim	:std_logic_Vector(3 downto 0);			
SIGNAL load_mema_f		:std_logic;			

SIGNAL sp_t0subx_tim	:std_logic_Vector(9 downto 0);			
SIGNAL sp_t0subx_f		:std_logic;			
SIGNAL stop_vgin_tim	:std_logic_Vector(19 downto 0);			


SIGNAL Srx_err_count:std_logic_Vector(15 downto 0);
SIGNAL Srx_data3_buf:std_logic_Vector(15 downto 0);
SIGNAL Srx_data3_pre:std_logic_Vector(15 downto 0);


SIGNAL Atx_count:std_logic_Vector(15 downto 0);
SIGNAL Btx_count:std_logic_Vector(15 downto 0);


--GLOBLE USE-------------------------------------

SIGNAL Rvgout_f		:std_logic;
SIGNAL lvgout_f		:std_logic;
SIGNAL lvgout_tim	:std_logic_Vector(19 downto 0);	
SIGNAL lvgout_tlim	:std_logic_Vector(19 downto 0);	


SIGNAL rfenA_f		:std_logic;
SIGNAL rfenB_f		:std_logic;
SIGNAL rfenS_f		:std_logic;

SIGNAL debug_f		:std_logic;
SIGNAL debug_in_f	:std_logic;
SIGNAL debug_out_f	:std_logic;
SIGNAL debug_tim	:std_logic_Vector(19 downto 0);	



SIGNAL Arxps_f		:std_logic;
SIGNAL Brxps_f		:std_logic;
SIGNAL Srxps_f		:std_logic;


SIGNAL syn_rxrt_mode_f:std_logic;
SIGNAL basetime_cnt:std_logic_Vector(23 downto 0);	
--KEYBO USE	
SIGNAL keyin_buf:std_logic_Vector(3 downto 0);
SIGNAL keyin_pre:std_logic_Vector(3 downto 0);
SIGNAL keyin_tim:std_logic_Vector(3 downto 0);
SIGNAL keyflag	:std_logic_Vector(3 downto 0);
SIGNAL keyflag_b:std_logic;
--PPS USE
SIGNAL pps_cnt:std_logic_Vector(31 downto 0);	
SIGNAL pps_cntb:std_logic_Vector(31 downto 0);	
SIGNAL pps_f:std_logic;
SIGNAL pps_edge_f:std_logic;
--LED USE
SIGNAL led0_f:std_logic;
SIGNAL led1_f:std_logic;
SIGNAL led2_f:std_logic;
SIGNAL ledtime_cnt:std_logic_Vector(31 downto 0);
SIGNAL chA_led_f:std_logic;
SIGNAL chB_led_f:std_logic;
SIGNAL chS_led_f:std_logic;
SIGNAL chA_led_tim:std_logic_Vector(23 downto 0);
SIGNAL chB_led_tim:std_logic_Vector(23 downto 0);
SIGNAL chS_led_tim:std_logic_Vector(23 downto 0);


SIGNAL vg_mode:std_logic_Vector(1 downto 0);	
SIGNAL Aprvg_in_tim:std_logic_Vector(19 downto 0);	
SIGNAL Aprvg_in_f:std_logic;	


SIGNAL adj1588_tim				:std_logic_Vector(15 downto 0);	
SIGNAL adj1588_st_f				:std_logic;	


SIGNAL A1588_start			:std_logic_Vector(15 downto 0);	
SIGNAL A1588_end			:std_logic_Vector(15 downto 0);	
SIGNAL A1588_prd			:std_logic_Vector(15 downto 0);	
SIGNAL A1588_dly			:std_logic_Vector(15 downto 0);	


SIGNAL B1588_start			:std_logic_Vector(15 downto 0);	
SIGNAL B1588_end			:std_logic_Vector(15 downto 0);	
SIGNAL B1588_prd			:std_logic_Vector(15 downto 0);	
SIGNAL B1588_dly			:std_logic_Vector(15 downto 0);	


SIGNAL i1588_adj			:std_logic_Vector(15 downto 0);	
SIGNAL adj1588_Hoff_tim		:std_logic_Vector(7 downto 0);	

SIGNAL rchflag				:std_logic_Vector(7 downto 0);	
SIGNAL srchflag				:std_logic_Vector(7 downto 0);	
SIGNAL hchflag				:std_logic_Vector(7 downto 0);	
SIGNAL Autonrwmem_tim		:std_logic_Vector(19 downto 0);	
SIGNAL Autonrwmem_pus_f		:std_logic;			

SIGNAL AutormA_pus_f		:std_logic;			
SIGNAL AutowmB_pus_f		:std_logic;			

--TEST USE
SIGNAL test_f:std_logic;
SIGNAL test_cnt:std_logic_Vector(3 downto 0);	



SIGNAL svgrt_delt_chkcnt:std_logic_Vector(23 downto 0);	
SIGNAL svgrt_delt_chktim:std_logic_Vector(23 downto 0);	
SIGNAL svgrt_delt_prev:std_logic_Vector(15 downto 0);	
SIGNAL svgrt_delt_data:std_logic_Vector(15 downto 0);	
SIGNAL svgrt_delt_delt:std_logic_Vector(15 downto 0);	

--HOST USE----------------------------------------------------
SIGNAL Hadjtime_cnt:std_logic_Vector(31 downto 0);	
SIGNAL Hadjtime_set:std_logic_Vector(31 downto 0);	
SIGNAL Hadjadd_f:std_logic;
SIGNAL Hadjdec_f:std_logic;
SIGNAL Hadddec_f:std_logic;
SIGNAL Htime_adj_f:std_logic;
SIGNAL Stime_adj_f:std_logic;
SIGNAL Hrtime_cnt:std_logic_Vector(15 downto 0);	
SIGNAL Hrtimeb_cnt:std_logic_Vector(15 downto 0);	

SIGNAL Hdata_gate_tim	:std_logic_Vector(19 downto 0);	--generate Hdata gate
SIGNAL Hdata_gate		:std_logic;						--Hdata gate f	

SIGNAL Htxrx_sw_f		:std_logic;						--Hdata gate f	
SIGNAL Hvgout_en_tim	:std_logic_Vector(15 downto 0);

SIGNAL HAvideo_gate_count:std_logic_Vector(15 downto 0);
SIGNAL HBvideo_gate_count:std_logic_Vector(15 downto 0);

SIGNAL HA_gate_en		:std_logic;					
SIGNAL HB_gate_en		:std_logic;					
SIGNAL HAvideo_gate		:std_logic;					
SIGNAL HBvideo_gate		:std_logic;					
SIGNAL HAdata_gate		:std_logic;					
SIGNAL HBdata_gate		:std_logic;					

SIGNAL HA_rf_en			:std_logic;					
SIGNAL HB_rf_en			:std_logic;					
SIGNAL HA_com_typ		:std_logic;					
SIGNAL HB_com_typ		:std_logic;					


---------------------------------------------------------------
SIGNAL Hvg_tim_off:std_logic_Vector(15 downto 0);	--Host VG offset
SIGNAL Hvg_tim:std_logic_Vector(15 downto 0);		--Host VG time
SIGNAL Hvgout_tim:std_logic_Vector(15 downto 0);	--Hvg out period
SIGNAL Hvgout_en_f:std_logic;						--Hvg out enable time
SIGNAL Hvgout_f:std_logic;							--Hvgout_f our
SIGNAL Hvideo_gate:std_logic;						--Hvideo_gate in
--HOST TXA--------------------------------------------------
SIGNAL Atxout_f:std_logic;							--Host a chanel tx data out bit
SIGNAL Aclk4m_out:std_logic;						--Host a chanel tx clk out bit
SIGNAL Atx_data0:std_logic_Vector(15 downto 0);		--Host a chanel data0
SIGNAL Atx_data1:std_logic_Vector(15 downto 0);		--Host a chanel data1
SIGNAL Atx_data2:std_logic_Vector(15 downto 0);		--Host a chanel data2
SIGNAL Atx_data3:std_logic_Vector(15 downto 0);		--Host a chanel data3
SIGNAL Atx_data4:std_logic_Vector(15 downto 0);		--Host a chanel data3
SIGNAL Atx_start_f		:std_logic;
------------------------------------------------------------
SIGNAL Adlybuf0:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf1:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf2:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf3:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf4:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf5:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf6:std_logic_Vector(15 downto 0);
SIGNAL Adlybuf7:std_logic_Vector(15 downto 0);

------------------------------------------------------------



SIGNAL onetst_vgin_tx:std_logic;
SIGNAL contst_vgin_tx:std_logic;
SIGNAL contst_vgin_ps:std_logic;
SIGNAL contst_vgin_tim:std_logic_Vector(19 downto 0);	
SIGNAL contst_vgin_cnt:std_logic_Vector(15 downto 0);	
SIGNAL contst_vgin_pri:std_logic_Vector(19 downto 0);	


SIGNAL Ctxout_f:std_logic;
SIGNAL Cclk4m_out:std_logic;
SIGNAL Dtxout_f:std_logic;
SIGNAL Dclk4m_out:std_logic;


--HOST TXB--------------------------------------------------
SIGNAL Btxout_f:std_logic;
SIGNAL Bclk4m_out:std_logic;
SIGNAL Btx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Btx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Btx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Btx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Btx_data4:std_logic_Vector(15 downto 0);	
SIGNAL Btx_start_f		:std_logic;

--SIGNAL Bvgout_tim:std_logic_Vector(15 downto 0);	
------------------------------------------------------------
SIGNAL Bdlybuf0:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf1:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf2:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf3:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf4:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf5:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf6:std_logic_Vector(15 downto 0);
SIGNAL Bdlybuf7:std_logic_Vector(15 downto 0);


--HOST RXA----------------------------------------------
--SIGNAL Avgrt_delt		:std_logic_Vector(15 downto 0);	
--SIGNAL Avgrt_delt_lim	:std_logic_Vector(15 downto 0);	
--SIGNAL Avgrt_adj		:std_logic_Vector(15 downto 0);	
--SIGNAL Avgrt_adj_off	:std_logic_Vector(15 downto 0);	
--SIGNAL Avg_tim			:std_logic_Vector(15 downto 0);	
--------------------------------------------------------
SIGNAL Arxvgout_en_f		:std_logic;
SIGNAL Arxvgout_en_tim	:std_logic_Vector(15 downto 0);	
--SIGNAL Hvgout_tim		:std_logic_Vector(15 downto 0);	
--SIGNAL Hvgout_f			:std_logic;
--------------------------------------------------------


SIGNAL Crxin_f:std_logic;
SIGNAL Crxpack_out:std_logic;
SIGNAL Crx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Crx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Crx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Crx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Crx_data4:std_logic_Vector(15 downto 0);	

SIGNAL Drxin_f:std_logic;
SIGNAL Drxpack_out:std_logic;
SIGNAL Drx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Drx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Drx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Drx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Drx_data4:std_logic_Vector(15 downto 0);	









SIGNAL Arxin_f:std_logic;
SIGNAL Arxclk_out:std_logic;
SIGNAL Arxpack_out:std_logic;
SIGNAL Avgrx_tim:std_logic_Vector(15 downto 0);	
SIGNAL Avgrt_tim:std_logic_Vector(15 downto 0);	
SIGNAL Avgrx_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Avgrt_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Arx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Arx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Arx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Arx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Arx_data4:std_logic_Vector(15 downto 0);	
SIGNAL Arx_count:std_logic_Vector(15 downto 0);	
SIGNAL Arx_count_pre:std_logic_Vector(15 downto 0);	
SIGNAL Acorr_rat_tim:std_logic_Vector(15 downto 0);	
SIGNAL Acorr_rat_cnt:std_logic_Vector(15 downto 0);	



--HOST RXB----------------------------------------------
--SIGNAL Bvgrt_delt		:std_logic_Vector(15 downto 0);	
--SIGNAL Bvgrt_delt_lim	:std_logic_Vector(15 downto 0);	
--SIGNAL Bvgrt_adj		:std_logic_Vector(15 downto 0);	
--SIGNAL Bvgrt_adj_off	:std_logic_Vector(15 downto 0);	
--SIGNAL Bvg_tim			:std_logic_Vector(15 downto 0);	
--------------------------------------------------------
SIGNAL Brxvgout_en_f		:std_logic;
SIGNAL Brxvgout_en_tim	:std_logic_Vector(15 downto 0);	
--SIGNAL Bvgout_tim		:std_logic_Vector(15 downto 0);	
--SIGNAL Bvgout_f			:std_logic;
--------------------------------------------------------
SIGNAL Brxin_f:std_logic;
SIGNAL Brxclk_out:std_logic;
SIGNAL Brxpack_out:std_logic;
SIGNAL Bvgrx_tim:std_logic_Vector(15 downto 0);	
SIGNAL Bvgrt_tim:std_logic_Vector(15 downto 0);	
SIGNAL Bvgrx_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Bvgrt_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Brx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Brx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Brx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Brx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Brx_data4:std_logic_Vector(15 downto 0);	
SIGNAL Brx_count:std_logic_Vector(15 downto 0);	
SIGNAL Brx_count_pre:std_logic_Vector(15 downto 0);	
SIGNAL Bcorr_rat_tim:std_logic_Vector(15 downto 0);	
SIGNAL Bcorr_rat_cnt:std_logic_Vector(15 downto 0);	











--SLAVE USE
SIGNAL Sadjtime_cnt:std_logic_Vector(31 downto 0);	
SIGNAL Sadjtime_set:std_logic_Vector(31 downto 0);	
SIGNAL Sadjadd_f:std_logic;
SIGNAL Sadjdec_f:std_logic;
SIGNAL Sadddec_f:std_logic;
SIGNAL debug_Srtime_adj:std_logic_Vector(31 downto 0);	


SIGNAL Srtime_cnt:std_logic_Vector(15 downto 0);	
SIGNAL Srtimeb_cnt:std_logic_Vector(15 downto 0);	


--SLAVE RX----------------------------------------------
SIGNAL Svgrt_delt		:std_logic_Vector(15 downto 0);	
SIGNAL Svgrt_delt_lim	:std_logic_Vector(15 downto 0);	
SIGNAL Svgrt_adj		:std_logic_Vector(15 downto 0);	
SIGNAL Svgrt_adj_off	:std_logic_Vector(15 downto 0);	
SIGNAL Svg_tim			:std_logic_Vector(15 downto 0);	
--------------------------------------------------------
SIGNAL Svgout_bt_f		:std_logic;
SIGNAL Svgout_en_f		:std_logic;
SIGNAL Svgout_en_tim	:std_logic_Vector(15 downto 0);	
SIGNAL Svgout_tim		:std_logic_Vector(15 downto 0);	
SIGNAL Svgout_f			:std_logic;
--------------------------------------------------------
SIGNAL Srxin_f:std_logic;
SIGNAL Srxclk_out:std_logic;
SIGNAL Srxpack_out:std_logic;
SIGNAL Srxpack_bd_out:std_logic;
SIGNAL Svgrx_tim:std_logic_Vector(15 downto 0);	
SIGNAL Svgrt_tim:std_logic_Vector(15 downto 0);	
SIGNAL Svgrx_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Svgrt_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Srx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Srx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Srx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Srx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Srx_data4:std_logic_Vector(15 downto 0);	
SIGNAL Strx_count:std_logic_Vector(15 downto 0);	
SIGNAL Sdrx_count:std_logic_Vector(15 downto 0);	

SIGNAL Svgrx_bas_off:std_logic_Vector(15 downto 0);	
SIGNAL Svgrx_dly_off:std_logic_Vector(15 downto 0);	


--SLAVE TXS-------------------------------------------------
SIGNAL Stxout_f:std_logic;
SIGNAL Stx_data0:std_logic_Vector(15 downto 0);	
SIGNAL Stx_data1:std_logic_Vector(15 downto 0);	
SIGNAL Stx_data2:std_logic_Vector(15 downto 0);	
SIGNAL Stx_data3:std_logic_Vector(15 downto 0);	
SIGNAL Stx_data4:std_logic_Vector(15 downto 0);	
SIGNAL Stxvg_tim_off:std_logic_Vector(15 downto 0);	
SIGNAL Stxvg_tim:std_logic_Vector(15 downto 0);	
--SIGNAL Bvgout_tim:std_logic_Vector(15 downto 0);	
SIGNAL Sclk4m_out:std_logic;
SIGNAL Stxvgout_en_f:std_logic;
--SIGNAL Bvgout_f:std_logic;
--SIGNAL Svideo_gate:std_logic;
------------------------------------------------------------
SIGNAL Sdlybuf0:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf1:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf2:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf3:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf4:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf5:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf6:std_logic_Vector(15 downto 0);
SIGNAL Sdlybuf7:std_logic_Vector(15 downto 0);
------------------------------------------------------------
SIGNAL Sdata_gate_tim	:std_logic_Vector(19 downto 0);
SIGNAL Sdata_gate		:std_logic;
SIGNAL Stxrx_sw_f		:std_logic;





--global
SIGNAL txcon_set_f:std_logic;

SIGNAL HAid		:std_logic_Vector(6 downto 0);
SIGNAL HBid		:std_logic_Vector(6 downto 0);
SIGNAL Sid1		:std_logic_Vector(6 downto 0);
SIGNAL Sid2		:std_logic_Vector(6 downto 0);
SIGNAL Sid_f	:std_logic_Vector(6 downto 0);


SIGNAL Hvgout_prd_cnt	:std_logic_Vector(23 downto 0);
SIGNAL Hvgout_prd		:std_logic_Vector(23 downto 0);
SIGNAL Svgout_prd_cnt	:std_logic_Vector(23 downto 0);
SIGNAL Svgout_prd		:std_logic_Vector(23 downto 0);
SIGNAL Svgout_prd_tim	:std_logic_Vector(3 downto 0);





	
SIGNAL TR_mode		:std_logic_Vector(7 downto 0);
SIGNAL sp_freqch		:std_logic_Vector(7 downto 0);
SIGNAL my_freqch		:std_logic_Vector(7 downto 0);


SIGNAL wg_i_data			:std_logic_Vector(23 downto 0);
SIGNAL wg_ic_data		:std_logic_Vector(23 downto 0);
SIGNAL wg_q_data			:std_logic_Vector(23 downto 0);
SIGNAL wg_qc_data		:std_logic_Vector(23 downto 0);
SIGNAL wgst_tim_off		:std_logic_Vector(15 downto 0);
SIGNAL wg_i_clk_off		:std_logic_Vector(7 downto 0);
SIGNAL wg_q_clk_off		:std_logic_Vector(7 downto 0);
SIGNAL wg_i_data_off		:std_logic_Vector(7 downto 0);
SIGNAL wg_q_data_off		:std_logic_Vector(7 downto 0);
SIGNAL wgclk_prd		:std_logic_Vector(7 downto 0);
SIGNAL wgclk_lim		:std_logic_Vector(4 downto 0);


SIGNAL wg_i_data_buf		:std_logic_Vector(23 downto 0);
SIGNAL wg_ic_data_buf		:std_logic_Vector(23 downto 0);
SIGNAL wg_q_data_buf		:std_logic_Vector(23 downto 0);
SIGNAL wg_qc_data_buf		:std_logic_Vector(23 downto 0);

SIGNAL wgout_en_f		:std_logic;
SIGNAL wgout_f			:std_logic;
SIGNAL wgst_tim			:std_logic_Vector(15 downto 0);
SIGNAL wgst_pus_f		:std_logic;
SIGNAL wgst_pus_tim		:std_logic_Vector(7 downto 0);
SIGNAL wgoff_tim		:std_logic_Vector(15 downto 0);

SIGNAL rwgst_pus_f		:std_logic;
SIGNAL lwgout_f			:std_logic;



SIGNAL lwgst_tim			:std_logic_Vector(19 downto 0);
SIGNAL lwgst_pus_f		:std_logic;
SIGNAL lwgst_pus_tim		:std_logic_Vector(7 downto 0);


---------------------------------------
SIGNAL wg_i_clk_f		:std_logic;
SIGNAL wg_i_clk_cnt		:std_logic_Vector(4 downto 0);
SIGNAL wg_i_clk_tim		:std_logic_Vector(7 downto 0);

SIGNAL wg_q_clk_f		:std_logic;
SIGNAL wg_q_clk_cnt		:std_logic_Vector(4 downto 0);
SIGNAL wg_q_clk_tim		:std_logic_Vector(7 downto 0);
	

SIGNAL wg_i_data_f		:std_logic;
SIGNAL wg_i_data_cnt	:std_logic_Vector(4 downto 0);
SIGNAL wg_i_data_tim	:std_logic_Vector(7 downto 0);

SIGNAL wg_ic_data_f		:std_logic;
--SIGNAL wg_ic_data_cnt	:std_logic_Vector(4 downto 0);
--SIGNAL wg_ic_data_tim	:std_logic_Vector(7 downto 0);

SIGNAL wg_q_data_f		:std_logic;
SIGNAL wg_q_data_cnt	:std_logic_Vector(4 downto 0);
SIGNAL wg_q_data_tim	:std_logic_Vector(7 downto 0);

SIGNAL wg_qc_data_f		:std_logic;

SIGNAL wg_cs_f			:std_logic;
SIGNAL wg_sysclk_f		:std_logic;


SIGNAL lagrp		:std_logic_Vector(7 downto 0);

SIGNAL local_f		:std_logic;



SIGNAL fblpin1_tim		:std_logic_Vector(15 downto 0);
SIGNAL fblpin1_f		:std_logic;
SIGNAL fblpin1_out_f	:std_logic;



SIGNAL fblpin2_tim		:std_logic_Vector(15 downto 0);
SIGNAL fblpin2_f		:std_logic;
SIGNAL fblpin2_out_f	:std_logic;


SIGNAL fblp1_off_h		:std_logic_Vector(15 downto 0);
SIGNAL fblp1_off_l		:std_logic_Vector(15 downto 0);
SIGNAL fblp2_off_h		:std_logic_Vector(15 downto 0);
SIGNAL fblp2_off_l		:std_logic_Vector(15 downto 0);

SIGNAL w_fblp1_off_h		:std_logic_Vector(15 downto 0);
SIGNAL w_fblp1_off_l		:std_logic_Vector(15 downto 0);
SIGNAL w_fblp2_off_h		:std_logic_Vector(15 downto 0);
SIGNAL w_fblp2_off_l		:std_logic_Vector(15 downto 0);


SIGNAL vgdly_f			:std_logic;
SIGNAL vgdly_tim		:std_logic_Vector(15 downto 0);
SIGNAL inhib_f			:std_logic;

SIGNAL fblpin1_inhib_f	:std_logic;
SIGNAL fblpin2_inhib_f	:std_logic;
SIGNAL w_fblpin1_out_f	:std_logic;
SIGNAL w_fblpin2_out_f	:std_logic;


SIGNAL hvgout_re_tim	:std_logic_Vector(15 downto 0);
SIGNAL spt0vgi_fe_tim	:std_logic_Vector(15 downto 0);
SIGNAL hvgoff_tim		:std_logic_Vector(15 downto 0);
SIGNAL spt0vgi_chk_tim	:std_logic_Vector(19 downto 0);


SIGNAL rlppack1_f			:std_logic;
SIGNAL rlprxin1_f			:std_logic;
SIGNAL rlpclk1_f			:std_logic;

SIGNAL rlppack2_f			:std_logic;
SIGNAL rlprxin2_f			:std_logic;
SIGNAL rlpclk2_f			:std_logic;

SIGNAL tlpreg	:std_logic_Vector(7 downto 0);
SIGNAL rlpreg1	:std_logic_Vector(7 downto 0);
SIGNAL rlpreg2	:std_logic_Vector(7 downto 0);

SIGNAL rlp1_f	:std_logic;
SIGNAL rlp1_tim	:std_logic_Vector(19 downto 0);
SIGNAL rlp2_f	:std_logic;
SIGNAL rlp2_tim	:std_logic_Vector(19 downto 0);


SIGNAL wg_vgo_f	:std_logic;


SIGNAL rbuf		:std_logic_Vector(15 downto 0);



SIGNAL tstsp_en_f :std_logic;


SIGNAL wg_offset_h	:std_logic_Vector(15 downto 0);
SIGNAL wg_offset_l	:std_logic_Vector(15 downto 0);
SIGNAL wgoff_f		:std_logic;



--SIGNAL wg_qc_data_cnt	:std_logic_Vector(4 downto 0);
--SIGNAL wg_qc_data_tim	:std_logic_Vector(7 downto 0);
	
BEGIN

	HAid	<="1010100";
	HBid	<="1010101";
	Sid1	<="1010110";
	Sid2	<="1010111";
-------------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			system_set<="01";--test 10
			txcon_set_f<='0';	
			syn_rxrt_mode_f<='0';--0:delay,1:time sync
			Htime_adj_f<='0';
			Stime_adj_f<='0';
			vg_mode<="00";	--test 00
			rfenA_f<='1';
			rfenB_f<='1';
			rfenS_f<='1';
			HA_gate_en<='1';
			HB_gate_en<='1';
			HA_rf_en<='1';
			HB_rf_en<='1';
			local_f<='0';
				
			Hvg_tim_off<="0001"&"1001"&"0000"&"0000";
			Svgrt_tim_off<="0001"&"1001"&"0000"&"0000";
			Svgrx_tim_off<="0000"&"0100"&"1101"&"0010";
			
			
			Sadjtime_set	<="1111"&"1111"&"1111"&"1111"&"1111"&"1111"&"1111"&"0000";
			Hadjtime_set	<="1111"&"1111"&"1111"&"1111"&"1111"&"1111"&"1111"&"0000";
			
			Svgrt_adj_off<="0000"&"0000"&"0000"&"1011";
			Svgrt_delt_lim<="0000"&"0001"&"0100"&"0000";
			i1588_adj	<="0000"&"0000"&"0000"&"0000";
			TR_mode<="00000000";

			wg_i_data		<="11111111"&"11011111"&"11111111";
			wg_ic_data		<="11111110"&"00100011"&"11111111";
			wg_q_data		<="11111111"&"11010011"&"11111111";
			wg_qc_data		<="11111111"&"00101111"&"11111111";
			wgst_tim_off	<="0000"&"0011"&"1100"&"0111";
			wg_i_clk_off	<="10000000";
			wg_q_clk_off	<="10101000";
			wg_i_data_off	<="11010000";
			wg_q_data_off	<="10101000";
			wgclk_prd		<="0100"&"1111";
			wgclk_lim		<="10010";
			contst_vgin_pri <="00100111000011111111";
			
		else	
			if(iFrmNios(0)='1')then
				if(rising_edge(clkA))then
					if(load_mema_f='1')then
						load_mema_tim<="0000";
					else	
						if(load_mema_tim<8)then
							load_mema_tim<=load_mema_tim+1;
							if(load_mema_tim="0010")then
								system_set		<=mAreg(12)(1 downto 0);
								txcon_set_f		<=mAreg(12)(2);
								syn_rxrt_mode_f	<=mAreg(12)(3);
--								time_adj_f		<=mAreg(12)(4);
								vg_mode			<=mAreg(12)(7 downto 6);
								
								HA_gate_en		<=mAreg(13)(0);
								HB_gate_en		<=mAreg(13)(1);
								local_f			<=not mAreg(13)(2);
								HA_rf_en		<=mAreg(13)(4);
								HB_rf_en		<=mAreg(13)(5);
								HA_com_typ		<=mAreg(13)(6);
								HB_com_typ		<=mAreg(13)(7);
								
								Hvg_tim_off		<=mAreg(14)&mAreg(15);
								Svgrt_tim_off	<=mAreg(16)&mAreg(17);

								Svgrx_bas_off	<=mAreg(18)&mAreg(19);
								Svgrx_dly_off	<=mAreg(20)&mAreg(21);
								Svgrt_delt_lim	<=mAreg(22)&mAreg(23);
								Svgrt_adj_off	<=mAreg(24)&mAreg(25);--fix
								
								fblp1_off_h		<=mAreg(28)&mAreg(29);
								fblp2_off_h		<=mAreg(30)&mAreg(31);

--								Hadjtime_set	<=mAreg(28)&mAreg(29)&mAreg(30)&mAreg(31);
--								Sadjtime_set	<=mAreg(28)&mAreg(29)&mAreg(30)&mAreg(31);
								i1588_adj		<=mAreg(32)&mAreg(33);
								TR_mode			<=mAreg(34);
								my_freqch		<=mAreg(35);
								contst_vgin_pri(19 downto 11)<='0' & mAreg(36); 
								contst_vgin_pri(10 downto 0)<=mAreg(37) & "000";
								 
								
								
								lagrp			<=mAreg(38);
								wg_i_data		<=mAreg(40)&mAreg(41)&"11111111";--mAreg(42);
								wg_ic_data		<=mAreg(42)&mAreg(43)&"11111111";--mAreg(45);
								wg_q_data		<=mAreg(44)&mAreg(45)&"11111111";--mAreg(48);
								wg_qc_data		<=mAreg(46)&mAreg(47)&"11111111";--mAreg(51);
								wg_offset_h		<=mAreg(48)&mAreg(49);
								wg_offset_l		<=mAreg(50)&mAreg(51);
								
								wgst_tim_off	<=mAreg(52)&mAreg(53);
								wg_i_clk_off	<=mAreg(54);
								wg_q_clk_off	<=mAreg(55);
								wg_i_data_off	<=mAreg(56);
								wg_q_data_off	<=mAreg(57);
								wgclk_prd		<=mAreg(58);
								wgclk_lim		<=mAreg(59)(4 downto 0);
								
							end if;
							if(load_mema_tim="0100")then
								fblp1_off_l		<=fblp1_off_h+640;
								fblp2_off_l		<=fblp2_off_h+640;
								w_fblp1_off_h   <=fblp1_off_h+40;
								w_fblp1_off_l   <=fblp1_off_h+600;
								w_fblp2_off_h   <=fblp2_off_h+40;
								w_fblp2_off_l   <=fblp2_off_h+600;
								rbuf<=Hvg_tim_off-6400;
								Svgrx_tim_off<=Svgrx_bas_off-Svgrx_dly_off;
								if(contst_vgin_pri<159999)then
							      contst_vgin_pri <="00100111000011111111";
							    else  
								  contst_vgin_pri<=contst_vgin_pri-1;
								end if;  
								if(system_set="00")then
									rfenA_f<=TR_mode(0);
									rfenB_f<=TR_mode(4);
								end if;	
								if(system_set="01")then
									rfenS_f<=TR_mode(0);
								end if;	
								if(system_set="10")then
									rfenS_f<=TR_mode(4);
								end if;	
							end if;	
							if(load_mema_tim="0110")then
								Svgrx_tim_off<=Svgrx_tim_off+rbuf;
							end if;
						end if;	
					end if;
				end if;	
			end if;			
				
		end if;
	end process;
	



	

--	mBreg(0)<="00000000";
--	mBreg(1)<="00000001";
--	mBreg(2)<="00000010";
--	mBreg(3)<="00000011";
--	mBreg(4)<="00000100";
--	mBreg(5)<="00000101";
--	mBreg(6)<="00000110";
--	mBreg(7)<="00000111";
--	mBreg(8)<="00001000";
--	mBreg(9)<="00001001";
--	mBreg(10)<="00001010";
--	mBreg(11)<="00001011";
--	mBreg(12)<="00001100";
--	mBreg(13)<="00001101";
--	mBreg(14)<="00001110";
--	mBreg(15)<="00001111";
	
--	mBreg(0)<=mAreg(0);
--	mBreg(1)<=mAreg(1);
--	mBreg(2)<=mAreg(2);
--	mBreg(3)<=mAreg(3);
--	mBreg(4)<=mAreg(4);
--	mBreg(5)<=mAreg(5);
--	mBreg(6)<=mAreg(6);
--	mBreg(7)<=mAreg(7);
--	mBreg(8)<=mAreg(8);
--	mBreg(9)<=mAreg(9);
--	mBreg(10)<=mAreg(10);
--	mBreg(11)<=mAreg(11);
--	mBreg(12)<=mAreg(12);
--	mBreg(13)<=mAreg(13);
--	mBreg(14)<=mAreg(14);
--	mBreg(15)<=mAreg(15);
	
	
	

---------------------------------------------------
--basetime generate 
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(rising_edge(clkA))then
			basetime_cnt<=basetime_cnt+1;
		end if;
	end process;
---------------------------------------------------



-----------------------------------------------------	
--keybo 	
-----------------------------------------------------
--	PROCESS(basetime_cnt(15))
--  	BEGIN
--		if(RST_N='0')then
--			keyin_buf<="1111";
--			keyin_pre<="1111";
--			keyflag<="0000";
--			keyin_tim<="0000";
--		else
--			if(rising_edge(basetime_cnt(15)))then 
--				keyin_buf(0)<=keyin(0);
--				keyin_buf(1)<=keyin(1);
--				keyin_buf(2)<=keyin(2);
--				keyin_buf(3)<=keyin(3);
--				if(keyin_buf=keyin_pre)then
--					keyin_tim<=keyin_tim+1;
--					if(keyin_tim="1111")then
--						keyflag<=keyin_buf xor "1111";
--					end if;	
--				else
--					keyin_tim<="0000";
--					keyin_pre<=keyin_buf;
--				end if;	
--			end if;	
--		end if;	
--	end process;
-----------------------------------------------------	





---------------------------------------------------
	PROCESS(clkA,pps_f)
  	BEGIN
		if(rising_edge(clkA))then
			if(pps_f='0')then
				pps_edge_f<='0';
				pps_cnt<=pps_cnt+1;
			else
				if(pps_edge_f='0')then
					pps_cntb<=pps_cnt;
					pps_cnt<="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000" ;
					pps_edge_f<='1';
				else
					pps_cnt<=pps_cnt+1;
				end if;	
			end if;
		end if;		
	end process;
---------------------------------------------------







	PROCESS(HAvideo_gate)
  	BEGIN
		if(RST_N='0')then
			HAvideo_gate_count<="0000000000000000";
			Atx_count<="0000000000000000";
			Acorr_rat_tim<="0000000000000000";
		else 	
			if(rising_edge(HAvideo_gate))then
				HAvideo_gate_count<=HAvideo_gate_count+1;
				Atx_count<=Atx_count+1;
				Acorr_rat_tim<=Acorr_rat_tim+1;
				if(Acorr_rat_tim>=999)then
					Acorr_rat_tim<="0000000000000000";
					Acorr_rat_cnt<=Arx_count-Arx_count_pre;
					Arx_count_pre<=Arx_count;
				end if;	
			end if;
		end if;
	end process;			



	PROCESS(Arxpack_out)
  	BEGIN
		if(RST_N='0')then
			Arx_count<="0000000000000000";
		else 	
			if(rising_edge(Arxpack_out))then
				Arx_count<=Arx_count+1;
			end if;
		end if;
	end process;			
	
	

	PROCESS(HBvideo_gate)
  	BEGIN
		if(RST_N='0')then
			HBvideo_gate_count<="0000000000000000";
			Btx_count<="0000000000000000";
			Bcorr_rat_tim<="0000000000000000";
		else 	
			if(rising_edge(HBvideo_gate))then
				HBvideo_gate_count<=HBvideo_gate_count+1;
				Btx_count<=Btx_count+1;
				Bcorr_rat_tim<=Bcorr_rat_tim+1;
				if(Bcorr_rat_tim>=999)then
					Bcorr_rat_tim<="0000000000000000";
					Bcorr_rat_cnt<=Brx_count-Brx_count_pre;
					Brx_count_pre<=Brx_count;
				end if;	
			end if;
		end if;
	end process;			

	

	PROCESS(Brxpack_out)
  	BEGIN
		if(RST_N='0')then
			Brx_count<="0000000000000000";
		else 	
			if(rising_edge(Brxpack_out))then
				Brx_count<=Brx_count+1;
			end if;
		end if;
	end process;			

	PROCESS(Srxpack_out)
  	BEGIN
		if(RST_N='0')then
			Strx_count<="0000000000000000";
			Sdrx_count<="0000000000000000";
		else 	
			if(rising_edge(Srxpack_out))then
				if(Srx_data0(8)='0')then
					Strx_count<=Strx_count+1;
				else 
					Sdrx_count<=Sdrx_count+1;
				end if;	
			end if;
		end if;
	end process;			
	


--load mem	
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			mBreg(0)<="00000000";
			mBreg(1)<="00000000";
			mBreg(2)<="00000000";
			mBreg(3)<="00000000";
			mBreg(4)<="00000000";
			mBreg(5)<="00000000";
			mBreg(6)<="00000000";
			mBreg(7)<="00000000";
			mBreg(8)<="00000000";
			mBreg(9)<="00000000";
			mBreg(10)<="00000000";
			mBreg(11)<="00000000";
			mBreg(12)<="00000000";
			mBreg(13)<="00000000";
			mBreg(14)<="00000000";
			mBreg(15)<="00000000";
		else 	
			if(rising_edge(clkA))then
				if(system_set="00")then
					if(Arxpack_out='1')then
						mBreg(0)<=Arx_data1(15 downto 8);
						mBreg(1)<=Arx_data1( 7 downto 0);
						mBreg(2)<=Arx_data2(15 downto 8);
						mBreg(3)<=Arx_data2( 7 downto 0);
						mBreg(4)<=Arx_data3(15 downto 8);
						mBreg(5)<=Arx_data3( 7 downto 0);
						mBreg(6)<=Arx_data4(15 downto 8);
						mBreg(7)<=Arx_data4( 7 downto 0);
						mBreg(16)<=Arx_count(15 downto 8);
						mBreg(17)<=Arx_count( 7 downto 0);
						
						
					else 
						if(Arxps_f='0')then
							mBreg(0)<="00000000"; 
							mBreg(1)<="00000000"; 
							mBreg(2)<="00000000"; 
							mBreg(3)<="00000000"; 
						end if;	
					end if; 	
					if(Brxpack_out='1')then
						mBreg(8)<=Brx_data1(15 downto 8);
						mBreg(9)<=Brx_data1( 7 downto 0);
						mBreg(10)<=Brx_data2(15 downto 8);
						mBreg(11)<=Brx_data2( 7 downto 0);
						mBreg(12)<=Brx_data3(15 downto 8);
						mBreg(13)<=Brx_data3( 7 downto 0);
						mBreg(14)<=Brx_data4(15 downto 8);
						mBreg(15)<=Brx_data4( 7 downto 0);
						mBreg(18)<=Brx_count(15 downto 8);
						mBreg(19)<=Brx_count( 7 downto 0);
					else 
						if(Brxps_f='0')then
							mBreg(8)<="00000000"; 
							mBreg(9)<="00000000"; 
							mBreg(10)<="00000000"; 
							mBreg(11)<="00000000"; 
						end if;	
					end if; 	
					mBreg(20)<="000" & Hvgout_prd(23 downto 19);
					mBreg(21)<=Hvgout_prd(18 downto 11);
					mBreg(22)<=Hvgout_prd(10 downto 3);
					
					mBreg(23)<=HAvideo_gate_count(15 downto 8);
					mBreg(24)<=HAvideo_gate_count( 7 downto 0);
					mBreg(25)(0) <= Aprvg_in_f;		
					mBreg(25)(1) <= rlp1_f;		
					mBreg(25)(2) <= rlp2_f;		
					mBreg(26)<=HBvideo_gate_count(15 downto 8);
					mBreg(27)<=HBvideo_gate_count( 7 downto 0);
					mBreg(28)<=A1588_dly(15 downto 8);
					mBreg(29)<=A1588_dly( 7 downto 0);
					mBreg(30)<=Acorr_rat_cnt(15 downto 8);
					mBreg(31)<=Acorr_rat_cnt( 7 downto 0);
					mBreg(32)<=Bcorr_rat_cnt(15 downto 8);
					mBreg(33)<=Bcorr_rat_cnt( 7 downto 0);
--					mBreg(39)<=Srx_err_count(7 downto 0);
					mBreg(34)<=B1588_dly(15 downto 8);
					mBreg(35)<=B1588_dly( 7 downto 0);
					
--					hvgoff_tim<=hvgout_re_tim-spt0vgi_fe_tim;
--					mBreg(36)<=hvgoff_tim(15 downto 8);
--					mBreg(37)<=hvgoff_tim( 7 downto 0);
					
					
					
					

					mBreg(40)<=rchflag;
					
--	/////////////////////////////////////////////////////////////				
						
				else	
					if(Srxpack_out='1')then
						if(Srx_data0(8)='0')then
							mBreg(0)<=Srx_data1(15 downto 8);
							mBreg(1)<=Srx_data1( 7 downto 0);
							mBreg(2)<=Srx_data2(15 downto 8);
							mBreg(3)<=Srx_data2( 7 downto 0);
							mBreg(4)<=Srx_data3(15 downto 8);
							mBreg(5)<=Srx_data3( 7 downto 0);
							mBreg(6)<=Srx_data4(15 downto 8);
							mBreg(7)<=Srx_data4( 7 downto 0);
							mBreg(16)<=Strx_count(15 downto 8);
							mBreg(17)<=Strx_count( 7 downto 0);
							wgout_en_f<=Srx_data1(0);
							
						else	
							mBreg(8)<=Srx_data1(15 downto 8);
							mBreg(9)<=Srx_data1( 7 downto 0);
							mBreg(10)<=Srx_data2(15 downto 8);
							mBreg(11)<=Srx_data2( 7 downto 0);
							mBreg(12)<=Srx_data3(15 downto 8);
							mBreg(13)<=Srx_data3( 7 downto 0);
							mBreg(14)<=Srx_data4(15 downto 8);
							mBreg(15)<=Srx_data4( 7 downto 0);
							mBreg(18)<=Sdrx_count(15 downto 8);
							mBreg(19)<=Sdrx_count( 7 downto 0);
						end if;	
						mBreg(23)<=Svgrt_delt(15 downto 8);	
						mBreg(24)<=Svgrt_delt( 7 downto 0);
					end if;	
					
					if(iCtrNios(4)='0')then	--local
						wgout_en_f<='1';
					end if;	
					mBreg(20)<="000" & Svgout_prd(23 downto 19);
					mBreg(21)<=Svgout_prd(18 downto 11);
					mBreg(22)<=Svgout_prd(10 downto 3);
					mBreg(39)<=Srx_err_count(7 downto 0);
					mBreg(40)<=rchflag;
				end if;		
			end if;		
		end if; 				
	end process;					
						
						
						
						
						
						

	PROCESS(Hvgout_f,clkA)
  	BEGIN
		if(RST_N='0')then
			Hvgout_prd_cnt<="000000000000000000000000";
		else 	
			if(rising_edge(clkA))then
				if(Hvgout_f='1')then
					if(Hvgout_prd_cnt>1280)then
						Hvgout_prd<=Hvgout_prd_cnt;
						Hvgout_prd_cnt<="000000000000000000000000";
					else
						Hvgout_prd_cnt<=Hvgout_prd_cnt+1;
					end if;
				else	
					Hvgout_prd_cnt<=Hvgout_prd_cnt+1;
					if(Hvgout_prd_cnt>800000)then
						Hvgout_prd<="000000000000000000000000";
					end if;	
				end if;	
			end if;	
		end if;
	end process;			
	
--	PROCESS(Rvgout_f,clkA)
--  	BEGIN-
--		if(RST_N='0')then
--			Svgout_prd_cnt<="000000000000000000000000";
--		else 	
--			if(rising_edge(clkA))then
--				if(Rvgout_f='1')then
--					if(Svgout_prd_cnt>1280)then
--						Svgout_prd<=Svgout_prd_cnt;
--						Svgout_prd_cnt<="000000000000000000000000";
--					else
--						Svgout_prd_cnt<=Svgout_prd_cnt+1;
--					end if;
--				else	
--					Svgout_prd_cnt<=Svgout_prd_cnt+1;
--					if(Svgout_prd_cnt>800000)then
--						Svgout_prd<="000000000000000000000000";
--					end if;	
--				end if;	
--			end if;	
--		end if;
--	end process;			
	


	PROCESS(Rvgout_f,clkA)
  	BEGIN
		if(RST_N='0')then
			Svgout_prd_cnt<="000000000000000000000000";
		else 	
			if(rising_edge(clkA))then
				Svgout_prd_cnt<=Svgout_prd_cnt+1;
				if(Rvgout_f='1')then
					if(Svgout_prd_tim<10)then
						Svgout_prd_tim<=Svgout_prd_tim+1;
					end if;	
					if(Svgout_prd_tim=2)then
						Svgout_prd<=Svgout_prd_cnt;
						Svgout_prd_cnt<="000000000000000000000000";
					end if;
				else	
					Svgout_prd_tim<="0000";
				end if;	
			end if;	
		end if;
	end process;			

	


------------------------------------------------------
	tlpreg(0)<=inhib_f;

------------------------------------------------------
lptxp:tlpproc
	PORT MAP
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,	
        txreg			=> tlpreg,
        video_gate		=>	Rvgout_f,
		txout_f			=>	vgloop_f
	);
------------------------------------------------------



	
------------------------------------------------------
	
------------------------------------------------------
lprxp1:rlpproc
	PORT MAP
	(
        clksys 	    	=>	clkA,	
		rxin_i			=>  rlprxin1_f,	
        rxreg	    	=>  rlpreg1,
        rxclk_o			=>	rlpclk1_f,
		rxpack_o		=>	rlppack1_f
	);
------------------------------------------------------
lprxp2:rlpproc
	PORT MAP
	(
        clksys 	    	=>	clkA,	
		rxin_i			=>  rlprxin2_f,	
        rxreg	    	=>  rlpreg2,
        rxclk_o			=>	rlpclk2_f,
		rxpack_o		=>	rlppack2_f
	);
------------------------------------------------------


	
	
--	PROCESS(Rvgout_f,clkA)
-- 	BEGIN
--		if(RST_N='0')then
--			vgloop_f<='0';
--		else 	
--			if(rising_edge(clkA))then
--				if(Rvgout_f='1')then
--					if(vgloop_cnt/=0)then
--						vgloop_cnt<="0000000000000000";
--					end if;	
--				else	
--					if(vgloop_cnt<3200)then
--						vgloop_cnt<=vgloop_cnt+1;
--					end if;	
--					if(inhib_f='1')then
--						if(vgloop_cnt<1600)then
--							vgloop_f<='0';
--						else	
--							vgloop_f<=vgloop_cnt(3);
--						end if;	
--					else
--						vgloop_f<=vgloop_cnt(3);
--					end if;
--				end if;	
--			end if;
--		end if;	
--	end process;			
	
	
	

	PROCESS(Rvgout_f,clkA)
  	BEGIN
		if(RST_N='0')then
			vgdly_f<='0';
		else 	
			if(rising_edge(clkA))then
				if(Rvgout_f='0')then
					if(vgdly_tim<10000)then	
						vgdly_tim<=vgdly_tim+1;
						if(vgdly_tim=6400)then
							vgdly_f<='1';
						end if;	
						if(vgdly_tim=7040)then
							vgdly_f<='0';
						end if;	
					end if;	
				else
					if(vgdly_tim/=0)then	
					  vgdly_tim<="0000000000000000";				
					end if;  
				end if;	
			end if;	
		end if;
	end process;			


	


	PROCESS(rlppack1_f,clkA)
  	BEGIN
		if(RST_N='0')then
			rlp1_f<='0';
		else 	
			if(rising_edge(clkA))then
				if(rlppack1_f='1')then
					rlp1_tim<="00000000000000000000";
					rlp1_f<='1';
				else
					if(rlp1_tim<1000000)then
						rlp1_tim<=rlp1_tim+1;
					else	
					  rlp1_f<='0';	
					end if; 
				end if;	
			end if;	
		end if;
	end process;			
	
	
	PROCESS(rlppack2_f,clkA)
  	BEGIN
		if(RST_N='0')then
			rlp2_f<='0';
		else 	
			if(rising_edge(clkA))then
				if(rlppack2_f='1')then
					rlp2_tim<="00000000000000000000";
					rlp2_f<='1';
				else
					if(rlp2_tim<1000000)then
						rlp2_tim<=rlp2_tim+1;
					else	
					  rlp2_f<='0';	
					end if; 
				end if;	
			end if;	
		end if;
	end process;			
	



	fblpin1_inhib_f<=rlpreg1(0);

	
	PROCESS(fblpin1_f,clkA)
  	BEGIN
		if(RST_N='0')then
			fblpin1_out_f<='0';
		else 	
			if(rising_edge(clkA))then
				if(fblpin1_f='1')then
						fblpin1_tim<="0000000000000000";
				else
					if(fblpin1_tim<30000)then
						fblpin1_tim<=fblpin1_tim+1;
					end if;	
				end if;	
				if(fblpin1_tim=fblp1_off_h)then
				    fblpin1_out_f<='1';
			    end if;  
				if(fblpin1_tim=w_fblp1_off_h)then
				    w_fblpin1_out_f<=not fblpin1_inhib_f;
			    end if;  
				if(fblpin1_tim=w_fblp1_off_l)then
				    w_fblpin1_out_f<='0';
			    end if;  
			    if(fblpin1_tim=fblp1_off_l)then
					fblpin1_out_f<='0';
				end if;  
			end if;	
		end if;
	end process;			



	fblpin2_inhib_f<=rlpreg2(0);

	PROCESS(fblpin2_f,clkA)
  	BEGIN
		if(RST_N='0')then
			fblpin2_out_f<='0';
		else 	
			if(rising_edge(clkA))then
				if(fblpin2_f='1')then
						fblpin2_tim<="0000000000000000";
				else
					if(fblpin2_tim<30000)then
						fblpin2_tim<=fblpin2_tim+1;
					end if;	
				end if;	
				if(fblpin2_tim=fblp2_off_h)then
				    fblpin2_out_f<='1';
			    end if;  
				if(fblpin2_tim=w_fblp2_off_h)then
				    w_fblpin2_out_f<=not fblpin2_inhib_f;
			    end if;  
				if(fblpin2_tim=w_fblp2_off_l)then
				    w_fblpin2_out_f<='0';
			    end if;  
			    if(fblpin2_tim=fblp2_off_l)then
					fblpin2_out_f<='0';
				end if;  
			end if;	
		end if;
	end process;			















	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			adj1588_tim<="0000000000000000";
		else 	
			if(rising_edge(clkA))then
				if(adj1588_st_f='1')then
					adj1588_tim<="0000000000000000";
				else
					adj1588_tim<=adj1588_tim+1;
				end if;
			end if;
		end if;	
	end process;




	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
		else 	
			if(rising_edge(clkA))then
				if(Arxvgout_en_f='1') and (Arxvgout_en_tim="0000000000000111")then
					A1588_prd<=Arx_data4+i1588_adj;
					A1588_end<=Hrtime_cnt;
				end if;		
				if(Arxvgout_en_f='1') and (Arxvgout_en_tim="0000000000001001")then
					A1588_prd<=A1588_prd+Arx_data0(7 downto 0);
				end if;		
				if(Arxvgout_en_f='1') and (Arxvgout_en_tim="0000000000001011")then
					A1588_end<=A1588_end-A1588_start;
				end if;	
				if(Arxvgout_en_f='1') and (Arxvgout_en_tim="0000000000001101")then
					A1588_dly<=A1588_end-A1588_prd;
				end if;		
			end if;
		end if;
	end process;			



	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
		else 	
			if(rising_edge(clkA))then
				if(Brxvgout_en_f='1') and (Brxvgout_en_tim="0000000000000111")then
					B1588_prd<=Brx_data4+i1588_adj;
					B1588_end<=Srtime_cnt;
				end if;		
				if(Brxvgout_en_f='1') and (Brxvgout_en_tim="0000000000001001")then
					B1588_prd<=B1588_prd+Brx_data0(7 downto 0);
				end if;		
				if(Brxvgout_en_f='1') and (Brxvgout_en_tim="0000000000001011")then
					B1588_end<=B1588_end-B1588_start;
				end if;	
				if(Brxvgout_en_f='1') and (Brxvgout_en_tim="0000000000001101")then
					B1588_dly<=B1588_end-B1588_prd;
				end if;		
			end if;
		end if;
	end process;			


-- only slave C E use
---------------------------------------------------
-- adjust srtime
-- output Svg_tim,Svgout_bt_f
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Srtime_cnt<="0000000000000000";
			Srtimeb_cnt<="0000000000000000";
			Sadjtime_cnt<="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000" ;	
			Svg_tim<="0000000000000000";
			Svgout_bt_f<='0';
			Srx_err_count<="0000000000000000";
		else 	
			if(rising_edge(clkA))then
				svgrt_delt_chkcnt<=svgrt_delt_chkcnt+1;
				Sadjtime_cnt<=Sadjtime_cnt+1;
				if(debug_Srtime_adj<80000000)then
					debug_Srtime_adj<=debug_Srtime_adj+1;
				else
					debug_Srtime_adj<="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000" ;	
--					Sadjadd_f<='1';
				end if;	
					
				if(Stime_adj_f='0')then
					Srtime_cnt<=Srtime_cnt+1;
					Srtimeb_cnt<=Srtime_cnt+1;
				else
					if(Sadjadd_f='1')then
						Srtime_cnt<=Srtime_cnt+2;
						Srtimeb_cnt<=Srtime_cnt+1;
						Sadjadd_f<='0';
					elsif(Sadjdec_f='1')then
						Srtime_cnt<=Srtime_cnt;
						Srtimeb_cnt<=Srtime_cnt;
						Sadjdec_f<='0';
					else
						Srtime_cnt<=Srtime_cnt+1;
						Srtimeb_cnt<=Srtime_cnt+1;
					end if;
					-----------------------------------
					if(Sadjtime_cnt>Sadjtime_set)then
						if(Sadddec_f='0')then
							Sadjadd_f<='1';
						else
							Sadjdec_f<='1';		
						end if;	
						Sadjtime_cnt<="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000" ;	
					end if;
				end if;
				--------------------------------------------------
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000000100")then
					if(syn_rxrt_mode_f='1')then
						Svgrt_delt<=Svgrx_tim-Svgrt_tim;
						Svgrt_adj<=Svgrt_tim-Svgrx_tim_off;
						svgrt_delt_data<=Svgrx_tim-Svgrt_tim;
					end if;	
					adj1588_st_f<='1';
					adj1588_Hoff_tim<=Srx_data0(7 downto 0);
				end if;		
				----------------------------------------------------------------
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000000110")then
					if(Syn_rxrt_mode_f='1')then
						Svgrt_adj<=Svgrt_adj+Svgrt_adj_off;
						if(Svgrt_delt(15)='1')then
							Svgrt_delt<=Svgrt_tim-Svgrx_tim;
							sadddec_f<='0';	
						else
							sadddec_f<='1';	
						end if;	
					end if;	
					adj1588_st_f<='0';
				end if;		
				----------------------------------------------------------------
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000001000")then
					if(Syn_rxrt_mode_f='1')then
						if(Svgrt_delt>Svgrt_delt_lim)then
							Srtime_cnt<=Svgrt_adj;
							Srtimeb_cnt<=Svgrt_adj;
							svgrt_delt_prev<="0000000000000000";
						else
							svgrt_delt_prev<=svgrt_delt_data;
						end if;	
						if(svgrt_delt_chkcnt<8000000)then
							svgrt_delt_chktim<=svgrt_delt_chkcnt;
							svgrt_delt_delt  <=svgrt_delt_data-svgrt_delt_prev;
						else
							svgrt_delt_chktim<="0000"&"0000"&"0000"&"0000"&"0000"&"0000";
							svgrt_delt_delt  <=	"0000"&"0000"&"0000"&"0000";
						end if;	
						svgrt_delt_chkcnt<="0000"&"0000"&"0000"&"0000"&"0000"&"0000";
						
					end if;	
				end if;		
				----------------------------------------------------------------
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000001010")then
					if(syn_rxrt_mode_f='0')then
						Svg_tim<=Svgrx_tim;
					else
						Svg_tim<=Svgrt_tim;
					end if;	
					
				end if;	
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000001100")then
					if(Srx_data0(8)='0')then
						Svgout_bt_f<='1';
						srchflag   <= Srx_data2(7 downto 0);
					else	
						Svgout_bt_f<='0';
					end if;	
					wgst_tim<=Svg_tim-wgst_tim_off;
				end if;		
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000001110")then
					Srx_data3_buf<=Srx_data3-Srx_data3_pre;
				end if;	
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000010000")then
					Srx_data3_buf<=Srx_data3_buf-1;
				end if;	
				if(Svgout_en_f='1') and (Svgout_en_tim="0000000000010010")then
					Srx_err_count<=Srx_err_count+Srx_data3_buf;
					Srx_data3_pre<=Srx_data3;
				end if;	
				
				
----------------------------------------------------------------------------
				if(keyflag(3)='1')then
					Srtime_cnt<=Hrtime_cnt;
				end if;	
				if(keyflag(2)='1')then
					Srtime_cnt<=Hrtime_cnt+"0000000101010000";
				end if;	
			end if;
		end if;
	end process;
---------------------------------------------------




--only host use
---------------------------------------------------
--HOST REAL TIME ADJUST
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Hrtime_cnt<="0000000000000000";
			Hrtimeb_cnt<="0000000000000000";
			Hadjtime_cnt<="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000" ;	
		else	
			if(rising_edge(clkA))then
				if(Htime_adj_f='0')then
					Hrtime_cnt<=Hrtime_cnt+1;
				else
					if(Hadjadd_f='1')then
						Hrtime_cnt<=Hrtime_cnt+2;
						Hrtimeb_cnt<=Hrtime_cnt+1;
						Hadjadd_f<='0';
					elsif(Hadjdec_f='1')then
						Hrtime_cnt<=Hrtime_cnt;
						Hrtimeb_cnt<=Hrtime_cnt;
						Hadjdec_f<='0';
					else
						Hrtime_cnt<=Hrtime_cnt+1;
						Hrtimeb_cnt<=Hrtime_cnt+1;
					end if;
					if(Hadjtime_cnt>Hadjtime_set)then
						if(Hadddec_f='0')then
							Hadjadd_f<='1';
						else
							Hadjdec_f<='1';		
						end if;	
						Hadjtime_cnt<="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000" ;	
					end if;
				end if;		
			end if;		
		end if;
	end process;
---------------------------------------------------



---------------------------------------------------
--generate lvgout_f
---------------------------------------------------
	PROCESS(clkA,Hvgout_f,Svgout_f)
  	BEGIN
		if(RST_N='0')then
			lvgout_tim<="00000000000000000000";
			lvgout_tlim<="00100111000011111111";--2ms
			lvgout_f<='0';
			ninb(0)<='0';
		else
			if(rising_edge(clkA))then
			
				if(lwgst_pus_tim<159)then
					lwgst_pus_tim<=lwgst_pus_tim+1;
				else
					lwgst_pus_f<='0';
				end if;	
			
			
				if(lvgout_tim<lvgout_tlim)then
					lvgout_tim<=lvgout_tim+1;
					if(lvgout_tim<640)then
						lvgout_f<='1';
						if(lvgout_tim=40)then
							lwgout_f<='1';
						end if;  
						if(lvgout_tim=600)then
							lwgout_f<='0';
						end if;  
					else
						lvgout_f<='0';
					end if;
					
					if(lvgout_tim=6400)then
						ninb(0)<='1';
					end if;
					
					if(lvgout_tim=7040)then
						ninb(0)<='0';
					end if;
					
				    if(lvgout_tim=80000)then	--1ms
						if(nout32(15 downto 0)<20000)then
							lvgout_tlim<="00100111000100000000";--2ms
						else
							lvgout_tlim(19)<='0';
							lvgout_tlim(18 downto 0)<=nout32(15 downto 0) &"000";
						end if;
					end if;		
				    if(lvgout_tim=80002)then	
						lvgout_tlim<=lvgout_tlim-1;
					end if;
				    if(lvgout_tim=80004)then	
						lwgst_tim<=lvgout_tlim-wgst_tim_off;
					end if;
					if(lvgout_tim=lwgst_tim)then
						lwgst_pus_f<='1';
						lwgst_pus_tim<="00000000";
					end if;	
						

				else
					lvgout_tim<="00000000000000000000";
					lvgout_f<='0';
					ninb(0)<='0';
				end if;		
			end if;
		end if;				
	end process;



---------------------------------------------------
--generate Autonrwmem_f
---------------------------------------------------
	PROCESS(clkA,Hvgout_f,Svgout_f)
  	BEGIN
		if(RST_N='0')then
			Autonrwmem_tim<="00000000000000000000";
			Autonrwmem_pus_f<='0';
		else
			if(rising_edge(clkA))then
				if(Autonrwmem_tim<"11110000000000000000")then
					Autonrwmem_tim<=Autonrwmem_tim+1;
					if(Autonrwmem_tim="11011011000000000000")then
						AutowmB_pus_f<='1';
					end if;	
					if(Autonrwmem_tim="11011011000010000000")then
						AutowmB_pus_f<='0';
					end if;	
					if(Autonrwmem_tim="11100000000000000000")then
						Autonrwmem_pus_f<='1';
					end if;	
					if(Autonrwmem_tim="11100000000001010000")then
						Autonrwmem_pus_f<='0';
					end if;	
					if(Autonrwmem_tim="11100101000000000000")then
						AutormA_pus_f<='1';
					end if;	
					if(Autonrwmem_tim="11100101000010000000")then
						AutormA_pus_f<='0';
					end if;	
				else
					Autonrwmem_tim<="00000000000000000000";
				end if;
				
				if(system_set="00" and Hvgout_f='1')then
					Autonrwmem_tim<="00000000000000000000";
				end if;	
				if(system_set="01" and Svgout_f='1')then
					Autonrwmem_tim<="00000000000000000000";
				end if;	
				if(system_set="10" and Svgout_f='1')then
					Autonrwmem_tim<="00000000000000000000";
				end if;	

				
			end if;
		end if;				
	end process;
	


--only host use
---------------------------------------------------
--generate Hdata_gate
---------------------------------------------------
	PROCESS(clkA,Hvgout_f)
  	BEGIN
		if(RST_N='0')then
			Hdata_gate_tim<="11110000000000000000";
			Hdata_gate<='0';
			Htxrx_sw_f<='0';
			Hwmem_pus_f<='0';
			Hnrwmem_pus_f<='0';
		else
			if(rising_edge(clkA))then
				if(Hvgout_f='1')then
					Hdata_gate_tim<="00000000000000000000";
					Hdata_gate<='0';
					Hwmem_pus_f<='0';
					Hnrwmem_pus_f<='0';
				else
					if(Hdata_gate_tim<524288)then	--"10000000000000000000";
						Hdata_gate_tim<=Hdata_gate_tim+1;
					end if;	
					if(Hdata_gate_tim=6400)then		--80us
						Hdata_gate<='1';
					end if;
					if(Hdata_gate_tim=6400+640)then		--80us
						Hdata_gate<='0';
					end if;
					if(Hdata_gate_tim=19200)then	--240us
						Htxrx_sw_f<='1';
					end if;	
					if(Hdata_gate_tim=99200)then	--1240us
						Htxrx_sw_f<='0';
						Hwmem_pus_f<='1';
					end if;	
					if(Hdata_gate_tim=99200+80)then	--1241us
						Hwmem_pus_f<='0';
					end if;	
					if(Hdata_gate_tim=105600)then	--1320us
						Hnrwmem_pus_f<='1';
					end if;	
					if(Hdata_gate_tim=105600+80)then--1321Us
						Hnrwmem_pus_f<='0';
					end if;	
				end if;	
			end if;
		end if;
	end process;
---------------------------------------------------


--only slave use
---------------------------------------------------
--generate Sdata_gate
---------------------------------------------------
	PROCESS(clkA,Svgout_f)
  	BEGIN
		if(RST_N='0')then
			Sdata_gate_tim<="11110000000000000000";
			Sdata_gate<='0';
			Stxrx_sw_f<='1';--rx
			swmem_pus_f<='0';
			srmem_pus_f<='0';
			Snrwmem_pus_f<='0';					
		else
			if(rising_edge(clkA))then
			
				if(Svgout_f='1')then
					Sdata_gate_tim<="00000000000000000000";
					Sdata_gate<='0';
					swmem_pus_f<='0';
					srmem_pus_f<='0';
					Snrwmem_pus_f<='0';					
				else
					if(Sdata_gate_tim<524288)then	--"10000000000000000000";
						Sdata_gate_tim<=Sdata_gate_tim+1;
					end if;	
					if(Sdata_gate_tim=19200)then	--240us
						Stxrx_sw_f<='0';
						swmem_pus_f<='1';
					end if;	
					if(Sdata_gate_tim=19200+80)then	--241us
						swmem_pus_f<='0';
					end if;	
					if(Sdata_gate_tim=25600)then	--320us
						srmem_pus_f<='1';
					end if;	
					if(Sdata_gate_tim=25600+80)then	--321us
						srmem_pus_f<='0';
					end if;	
					
					if(system_set="10")then	
						if(Sdata_gate_tim=83200)then		--240+800us
							Sdata_gate<='1';
						end if;	
						if(Sdata_gate_tim=83200+640)then	--1040+8us
							Sdata_gate<='0';
						end if;	
					else
						if(Sdata_gate_tim=67200)then		--240+600us
							Sdata_gate<='1';
						end if;
						if(Sdata_gate_tim=67200+640)then	--840+8us
							Sdata_gate<='0';
						end if;
					end if;	
					
					if(Sdata_gate_tim=99200)then			--1240us
						Stxrx_sw_f<='1';
						Snrwmem_pus_f<='1';					
					end if;
					if(Sdata_gate_tim=99200+80)then			--1241us
						Snrwmem_pus_f<='0';					
					end if;
				end if;	
			end if;
		end if;
	end process;
---------------------------------------------------






--only host use
---------------------------------------------------
--generate Hvgout_f
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Hvgout_tim<="1111000000000000";
			Hvgout_f<='0';
		else
			if(rising_edge(clkA))then
				if(Hvgout_tim<640)then
					Hvgout_tim<=Hvgout_tim+1;
				else
					Hvgout_f<='0';
				end if;	
				if(Hvgout_en_f='1')then
					if(Hvg_tim=Hrtime_cnt)then
						Hvgout_f<='1';
						Hvgout_tim<="0000000000000000";
					end if;
					if(Hvg_tim=Hrtimeb_cnt)then
						Hvgout_f<='1';
						Hvgout_tim<="0000000000000000";
					end if;
				end if;	
			end if;
		end if;
	end process;
---------------------------------------------------


--	debug_in_f<=Rvgout_f;
--	debug_in_f<=SP_T0SUBX;	
	debug_in_f<=Hvgout_f;
---------------------------------------------------
--generate debug_f
---------------------------------------------------
	PROCESS(clkA,debug_in_f)
  	BEGIN
		if(rising_edge(clkA))then
			if(debug_in_f='1')then
				debug_tim<="00000000000000000000";
				if(debug_f='1')then
				  debug_out_f<='1';
				else  
				  debug_out_f<='0';
				end if;  
			else
				debug_out_f<='0';
				if(debug_tim<900000)then
				  debug_tim<=debug_tim+1;
				end if;  
				if(debug_tim=300000)then
				  debug_f<='0';
				end if;
				if(debug_tim=10000)then
				  debug_f<='1';
				end if;
			end if;	
		end if;
	end process;
---------------------------------------------------






--only slave use
---------------------------------------------------
--generate Svgout_f
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Svgout_tim<="1111000000000000";
			Svgout_f<='0';
		    wgout_f<='0';
		else 	
			if(rising_edge(clkA))then
				if(Svgout_tim<640)then
					Svgout_tim<=Svgout_tim+1;
					if(Svgout_tim=40)then
					  wgout_f<='1';
					end if;  
					if(Svgout_tim=600)then
					  wgout_f<='0';
					end if;  
				else
					Svgout_f<='0';
				end if;	
				
				if(wgst_pus_tim<159)then
					wgst_pus_tim<=wgst_pus_tim+1;
				else
					wgst_pus_f<='0';
				end if;	
				
				if(Svgout_en_f='1') and (Svgout_en_tim > "0000000000010000")then
					if(Svgout_bt_f='1')then
						if(Svg_tim=Srtime_cnt)then
							Svgout_f<='1';
							Svgout_tim<="0000000000000000";
						end if;
						if(wgst_tim=Srtime_cnt)then
							wgst_pus_f<='1';
							wgst_pus_tim<="00000000";
						end if;
						if(Svg_tim=Srtimeb_cnt)then
							Svgout_f<='1';
							Svgout_tim<="0000000000000000";
						end if;
						if(wgst_tim=Srtimeb_cnt)then
							wgst_pus_f<='1';
							wgst_pus_tim<="00000000";
						end if;	
					end if;	
				end if;	
			end if;	
		end if;
	end process;
---------------------------------------------------



--only slave use
---------------------------------------------------


--generate wg
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			wgoff_tim<="1111000000000000";
		else 	
			if(rising_edge(clkA))then
			
				if(rwgst_pus_f='1')then
					wgoff_tim<="0000000000000000";
					wg_i_clk_f<='0';
					wg_i_clk_cnt<="00000";
					wg_q_clk_f<='0';
					wg_q_clk_cnt<="00000";
					wg_i_data_buf<=wg_i_data;
					wg_ic_data_buf<=wg_ic_data;
					wg_q_data_buf<=wg_q_data;
					wg_qc_data_buf<=wg_qc_data;
					
					wg_i_data_cnt<="00000";
					wg_i_data_f<='1';
					wg_ic_data_f<='1';
					wg_q_data_cnt<="00000";
					wg_q_data_f<='1';
					wg_qc_data_f<='1';
					wg_sysclk_f<='0';
					
					wgoff_f<='0';
					
					
				else
					if(wgoff_tim<2000)then
						wgoff_tim<=wgoff_tim+1;
						wg_cs_f<='1';
						wg_sysclk_f<=wgoff_tim(2);
					else
						wg_cs_f<='0';	
						wg_sysclk_f<='0';
					end if;	
--********************************************************					
					if(wgoff_tim=wg_offset_h)then
						wgoff_f<='1';
					end if;	
					if(wgoff_tim=wg_offset_l)then
						wgoff_f<='0';
					end if;	
--********************************************************					
					
					
					
					
--********************************************************					
					if(wgoff_tim<wg_i_clk_off)then
						wg_i_clk_tim<="00000000";
					else
						if(wg_i_clk_tim<wgclk_prd)then
							wg_i_clk_tim<=wg_i_clk_tim+1;				
						else
							wg_i_clk_tim<="00000000";
							if(wg_i_clk_cnt<wgclk_lim)then
								wg_i_clk_f<=not wg_i_clk_f;
								wg_i_clk_cnt<=wg_i_clk_cnt+1;
							end if;	
						end if;	
					end if;
--********************************************************					
					if(wgoff_tim<wg_q_clk_off)then
						wg_q_clk_tim<="00000000";
					else
						if(wg_q_clk_tim<wgclk_prd)then
							wg_q_clk_tim<=wg_q_clk_tim+1;				
						else
							wg_q_clk_tim<="00000000";
							if(wg_q_clk_cnt<wgclk_lim)then
								wg_q_clk_f<=not wg_q_clk_f;
								wg_q_clk_cnt<=wg_q_clk_cnt+1;
							end if;	
						end if;	
					end if;
--********************************************************					
					if(wgoff_tim<wg_i_data_off)then
						wg_i_data_tim<="00000000";
					else
						if(wg_i_data_tim<wgclk_prd)then
							wg_i_data_tim<=wg_i_data_tim+1;				
						else
							wg_i_data_tim<="00000000";
							if(wg_i_data_cnt<wgclk_lim)then
								wg_i_data_f<=wg_i_data_buf(23);
								wg_i_data_buf<=wg_i_data_buf(22 downto 0) & '0';
								wg_ic_data_f<=wg_ic_data_buf(23);
								wg_ic_data_buf<=wg_ic_data_buf(22 downto 0) & '0';
								wg_i_data_cnt<=wg_i_data_cnt+1;
							end if;	
						end if;	
					end if;
--********************************************************					
					if(wgoff_tim<wg_q_data_off)then
						wg_q_data_tim<="00000000";
					else
						if(wg_q_data_tim<wgclk_prd)then
							wg_q_data_tim<=wg_q_data_tim+1;				
						else
							wg_q_data_tim<="00000000";
							if(wg_q_data_cnt<wgclk_lim)then
								wg_q_data_f<=wg_q_data_buf(23);
								wg_q_data_buf<=wg_q_data_buf(22 downto 0) & '0';
								wg_qc_data_f<=wg_qc_data_buf(23);
								wg_qc_data_buf<=wg_qc_data_buf(22 downto 0) & '0';
								wg_q_data_cnt<=wg_q_data_cnt+1;
							end if;	
						end if;	
					end if;
--********************************************************					


				end if;
			end if;	
		end if;		
	end process;
---------------------------------------------------


			
			
			
			

















	






--flash_led
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			led0_f<='0';
			led1_f<='0';
			led2_f<='0';
		else
			if(rising_edge(clkA))then
				if(Arxpack_out='1')then
					chA_led_tim<="000000000000000000000000";
					chA_led_f<='1';
					Arxps_f<='1';
				else
					if(chA_led_tim>80000)then		--50ms
						Arxps_f<='0';
					end if;	
					if(chA_led_tim<4000000)then		--50ms
						chA_led_tim<=chA_led_tim+1;
					else
						chA_led_f<='0';
					end if;	
				end if;
				if(Brxpack_out='1')then
					chB_led_tim<="000000000000000000000000";
					chB_led_f<='1';
					Brxps_f<='1';
				else
					if(chB_led_tim>80000)then		--50ms
						Brxps_f<='0';
					end if;	
					if(chB_led_tim<4000000)then
						chB_led_tim<=chB_led_tim+1;
					else
						chB_led_f<='0';
					end if;	
				end if;
				
				if(Srxpack_out='1')then
					chS_led_tim<="000000000000000000000000";
					chS_led_f<='1';
					Srxps_f<='0';
				else
					if(chS_led_tim>80000)then		--50ms
						Srxps_f<='0';
					end if;	
					if(chS_led_tim<4000000)then
						chS_led_tim<=chS_led_tim+1;
					else
						chS_led_f<='0';
					end if;	
				end if;
				
				
				if(ledtime_cnt>16000000)then
					ledtime_cnt<="00000000000000000000000000000000";
					led1_f<=iFrmNios(0);--load_mem
					led0_f<=iFrmNios(1);--error
					led2_f<=chB_led_f or chA_led_f or chS_led_f;
				else
					ledtime_cnt<=ledtime_cnt+1;
					if(ledtime_cnt=8000000)then
						led1_f<='1'; 
						led0_f<=iFrmNios(1);--error; 
						led2_f<='0'; 
					end if;	
				end if;	
			end if;	
		end if;	
	end process;
---------------------------------------------------








		


--load Atx_data
-----------------------------------------------------	
	PROCESS(clkA,Hdata_gate,Hvideo_gate)
  	BEGIN
		if(RST_N='0')then
			Hvgout_en_tim<="1111000000000000";
			Hvgout_en_f<='0';
		else
			if(rising_edge(clkA))then 
				if(Hvideo_gate='1')then
					Atx_data0(15 downto 8)<=Sid1 & '0';
					Atx_data0(7 downto 0)<="00000000";--cannot be use;
					Atx_data1<="000000000000000" & HA_rf_en;
					Atx_data2<="00000000" & hchflag;
					Atx_data3<=Atx_count;
					Atx_data4<=Hrtime_cnt;
					---------------------------------------
					Btx_data0(15 downto 8)<=Sid2 & '0';
					Btx_data0(7 downto 0)<="00000000";--cannot be use;
					Btx_data1<="000000000000000" & HB_rf_en;
					Btx_data2<="00000000" & hchflag;
					Btx_data3<=Btx_count;
					Btx_data4<=Hrtime_cnt;
					---------------------------------------
					Hvg_tim<=Hrtime_cnt+Hvg_tim_off;
					Hvgout_en_tim<="0000000000000000";
					Hvgout_en_f<='0';
					A1588_start<=Hrtime_cnt;
					B1588_start<=Hrtime_cnt;
				else
					if(Hvgout_en_tim<8000)then
						Hvgout_en_tim<=Hvgout_en_tim+1;
						Hvgout_en_f<='1';
					else
						Hvgout_en_f<='0';
					end if;	
				end if;
				if(Hdata_gate='1')then
					Atx_data0(15 downto 8)<=Sid1 & '1';
					Atx_data0(7 downto 0)<=	"00000000";
					Atx_data1(15 downto 8)<=mAreg(4);
					Atx_data1( 7 downto 0)<=mAreg(5);
					Atx_data2(15 downto 8)<=mAreg(6);
					Atx_data2( 7 downto 0)<=mAreg(7);
					Atx_data3<="0000000000000000";
					Atx_data4<=Hrtime_cnt;
					---------------------------------------
					Btx_data0(15 downto 8)<=Sid2 & '1';
					Btx_data0(7 downto 0)<="00000000";
					Btx_data1(15 downto 8)<=mAreg(8);
					Btx_data1( 7 downto 0)<=mAreg(9);
					Btx_data2(15 downto 8)<=mAreg(10);
					Btx_data2( 7 downto 0)<=mAreg(11);
					Btx_data3<="0000000000000000";
					Btx_data3<=Hrtime_cnt;
					---------------------------------------
					Hvgout_en_f<='0';
					Hvgout_en_tim<="1111000000000000";
				end if;
			end if;	
		end if;
	end process;		
	
	
--load Stx_data HOST TXB
-----------------------------------------------------	
	PROCESS(clkA,Sdata_gate)
  	BEGIN
		if(rising_edge(clkA))then 
			if(Sdata_gate='1')then
				if(system_set="01")then
					Stx_data0(15 downto 8)<=HAid & '0';
				elsif(system_set="10")then 	
					Stx_data0(15 downto 8)<=HBid & '0';
				else
					Stx_data0(15 downto 8)<=HAid & '0';
				end if;	
				Stx_data0(7 downto 0)<="00000000";
				Stx_data1(15 downto 8)<=mAreg(0);
				Stx_data1( 7 downto 0)<=mAreg(1);
				Stx_data2(15 downto 8)<=mAreg(2);
				Stx_data2( 7 downto 0)<=mAreg(3);
				Stx_data3<=Svgrt_delt;
				Stx_data4<=adj1588_tim+adj1588_Hoff_tim;
			end if;
		end if;
	end process;		
-----------------------------------------------------	
		



	
	

--delay process HOST TXA USE
-----------------------------------------------------	
	process(clkA)
	begin
		if(rising_edge(clkA))then 
			Adlybuf0<=Adlybuf0(14 downto 0)& Adlybuf1(15);
			Adlybuf1<=Adlybuf1(14 downto 0)& Adlybuf2(15);
			Adlybuf2<=Adlybuf2(14 downto 0)& Adlybuf3(15);
			Adlybuf3<=Adlybuf3(14 downto 0)& Adlybuf4(15);
			Adlybuf4<=Adlybuf4(14 downto 0)& Adlybuf5(15);
			Adlybuf5<=Adlybuf5(14 downto 0)& Adlybuf6(15);
			Adlybuf6<=Adlybuf6(14 downto 0)& Adlybuf7(15);
			Adlybuf7<=Adlybuf7(14 downto 0)& Atxout_f;
		end if;	
	end process;
--delay process HOST TXB USE
-----------------------------------------------------	
	process(clkA)
	begin
		if(rising_edge(clkA))then 
			Bdlybuf0<=Bdlybuf0(14 downto 0)& Bdlybuf1(15);
			Bdlybuf1<=Bdlybuf1(14 downto 0)& Bdlybuf2(15);
			Bdlybuf2<=Bdlybuf2(14 downto 0)& Bdlybuf3(15);
			Bdlybuf3<=Bdlybuf3(14 downto 0)& Bdlybuf4(15);
			Bdlybuf4<=Bdlybuf4(14 downto 0)& Bdlybuf5(15);
			Bdlybuf5<=Bdlybuf5(14 downto 0)& Bdlybuf6(15);
			Bdlybuf6<=Bdlybuf6(14 downto 0)& Bdlybuf7(15);
			Bdlybuf7<=Bdlybuf7(14 downto 0)& Btxout_f;
		end if;	
	end process;
--delay process SLAVE TXS USE
-----------------------------------------------------	
	process(clkA)
	begin
		if(rising_edge(clkA))then 
			Sdlybuf0<=Sdlybuf0(14 downto 0)& Sdlybuf1(15);
			Sdlybuf1<=Sdlybuf1(14 downto 0)& Sdlybuf2(15);
			Sdlybuf2<=Sdlybuf2(14 downto 0)& Sdlybuf3(15);
			Sdlybuf3<=Sdlybuf3(14 downto 0)& Sdlybuf4(15);
			Sdlybuf4<=Sdlybuf4(14 downto 0)& Sdlybuf5(15);
			Sdlybuf5<=Sdlybuf5(14 downto 0)& Sdlybuf6(15);
			Sdlybuf6<=Sdlybuf6(14 downto 0)& Sdlybuf7(15);
			Sdlybuf7<=Sdlybuf7(14 downto 0)& Stxout_f;
		end if;	
	end process;



--generate auto con vidio gate in pulse
---------------------------------------------------
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			contst_vgin_ps<='0';
			contst_vgin_tim<="00000000000000000000";
			contst_vgin_cnt<="0000000000000000";
		else
			if(rising_edge(clkA))then
				if(contst_vgin_cnt<639)then
					contst_vgin_cnt<=contst_vgin_cnt+1;
				else
					contst_vgin_ps<='0';
				end if;	
				
				if(tstsp_en_f='0')and(vg_mode="11")then--  (stop_vgin_tim<790000)then    --and(vg_mode="11") 
					contst_vgin_tim<="00000000000000000000";
					contst_vgin_cnt<="0000000000000000";
					contst_vgin_ps<='0';
				else
					if(contst_vgin_tim>=contst_vgin_pri)then
						contst_vgin_tim<="00000000000000000000";
						contst_vgin_cnt<="0000000000000000";
						contst_vgin_ps<='1';--<<debug
					else
						contst_vgin_tim<=contst_vgin_tim+1;
					end if;	
				end if;	
			end if;
		end if;	
	end process;
---------------------------------------------------
	

--generate Host rmem pulse
------------------------------------------------------
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Hrmem_pus_f<='0';
			Hrmem_pus_tim<="11110000";
		else	
			if(rising_edge(clkA))then
				if(Hvideo_gate='0')then
					Hrmem_pus_tim<="00000000";
				else
					if(Hrmem_pus_tim<250)then
						Hrmem_pus_tim<=Hrmem_pus_tim+1;
						if(Hrmem_pus_tim="00000000")then
							Hrmem_pus_f<='1';
						end if;	
						if(Hrmem_pus_tim="10000000")then
							Hrmem_pus_f<='0';
						end if;	
					end if;
				end if;
			end if;	
		end if;
	end process;
---------------------------------------------------







--generate memclk
-----------------------------------------------------	
	process(clkA)
	begin
		if(rising_edge(clkA))then 
			memclk_cnt<=memclk_cnt+1;
			if(memclk_cnt(2 downto 0)="000")then
				memadr_clk<='1';
			end if;	
			if(memclk_cnt(2 downto 0)="100")then
				memadr_clk<='0';
			end if;	
			if(memclk_cnt(2 downto 0)="010")then
				memrw_clk<='1';
			end if;	
			if(memclk_cnt(2 downto 0)="110")then
				memrw_clk<='0';
			end if;	
		end if;	
	end process;
	
-----------------------------------------------------	
--read_mem_global
	process(memadr_clk)
	begin
		if(rising_edge(memadr_clk))then 
			if(rmemA_start_f='1')then
				rmemA_adr<="0000000";
			else
				if(rmemA_adr<64)then
					rmemA_en_f<='1';
					rmemA_adr<=rmemA_adr+1;
				else
					rmemA_en_f<='0';
				end if;
			end if;	
		end if;	
	end process;
	
	
	process(memrw_clk)
	begin
		if(RST_N='0')then
			load_mema_f<='0';
		else
		if(rmemA_en_f='1')then
			if(rising_edge(memrw_clk))then 
				case rmemA_adr is
					when "0000001"=>mAreg(0)<=P2MEM0_QB;
					when "0000010"=>mAreg(1)<=P2MEM0_QB;
					when "0000011"=>mAreg(2)<=P2MEM0_QB;
					when "0000100"=>mAreg(3)<=P2MEM0_QB;
					when "0000101"=>mAreg(4)<=P2MEM0_QB;
					when "0000110"=>mAreg(5)<=P2MEM0_QB;
					when "0000111"=>mAreg(6)<=P2MEM0_QB;
					when "0001000"=>mAreg(7)<=P2MEM0_QB;
					when "0001001"=>mAreg(8)<=P2MEM0_QB;
					when "0001010"=>mAreg(9)<=P2MEM0_QB;
					when "0001011"=>mAreg(10)<=P2MEM0_QB;
					when "0001100"=>mAreg(11)<=P2MEM0_QB;
					when "0001101"=>mAreg(12)<=P2MEM0_QB;
					when "0001110"=>mAreg(13)<=P2MEM0_QB;
					when "0001111"=>mAreg(14)<=P2MEM0_QB;
					when "0010000"=>mAreg(15)<=P2MEM0_QB;
					when "0010001"=>mAreg(16)<=P2MEM0_QB;
					when "0010010"=>mAreg(17)<=P2MEM0_QB;
					when "0010011"=>mAreg(18)<=P2MEM0_QB;
					when "0010100"=>mAreg(19)<=P2MEM0_QB;
					when "0010101"=>mAreg(20)<=P2MEM0_QB;
					when "0010110"=>mAreg(21)<=P2MEM0_QB;
					when "0010111"=>mAreg(22)<=P2MEM0_QB;
					when "0011000"=>mAreg(23)<=P2MEM0_QB;
					when "0011001"=>mAreg(24)<=P2MEM0_QB;
					when "0011010"=>mAreg(25)<=P2MEM0_QB;
					when "0011011"=>mAreg(26)<=P2MEM0_QB;
					when "0011100"=>mAreg(27)<=P2MEM0_QB;
					when "0011101"=>mAreg(28)<=P2MEM0_QB;
					when "0011110"=>mAreg(29)<=P2MEM0_QB;
					when "0011111"=>mAreg(30)<=P2MEM0_QB;
					when "0100000"=>mAreg(31)<=P2MEM0_QB;
					when "0100001"=>mAreg(32)<=P2MEM0_QB;
					when "0100010"=>mAreg(33)<=P2MEM0_QB;
					when "0100011"=>mAreg(34)<=P2MEM0_QB;
					when "0100100"=>mAreg(35)<=P2MEM0_QB;
					when "0100101"=>mAreg(36)<=P2MEM0_QB;
					when "0100110"=>mAreg(37)<=P2MEM0_QB;
					when "0100111"=>mAreg(38)<=P2MEM0_QB;
					when "0101000"=>mAreg(39)<=P2MEM0_QB;
					when "0101001"=>mAreg(40)<=P2MEM0_QB;
					when "0101010"=>mAreg(41)<=P2MEM0_QB;
					when "0101011"=>mAreg(42)<=P2MEM0_QB;
					when "0101100"=>mAreg(43)<=P2MEM0_QB;
					when "0101101"=>mAreg(44)<=P2MEM0_QB;
					when "0101110"=>mAreg(45)<=P2MEM0_QB;
					when "0101111"=>mAreg(46)<=P2MEM0_QB;
					when "0110000"=>mAreg(47)<=P2MEM0_QB;
					when "0110001"=>mAreg(48)<=P2MEM0_QB;
					when "0110010"=>mAreg(49)<=P2MEM0_QB;
					when "0110011"=>mAreg(50)<=P2MEM0_QB;
					when "0110100"=>mAreg(51)<=P2MEM0_QB;
					when "0110101"=>mAreg(52)<=P2MEM0_QB;
					when "0110110"=>mAreg(53)<=P2MEM0_QB;
					when "0110111"=>mAreg(54)<=P2MEM0_QB;
					when "0111000"=>mAreg(55)<=P2MEM0_QB;
					when "0111001"=>mAreg(56)<=P2MEM0_QB;
					when "0111010"=>mAreg(57)<=P2MEM0_QB;
					when "0111011"=>mAreg(58)<=P2MEM0_QB;
					when "0111100"=>mAreg(59)<=P2MEM0_QB;
					when "0111101"=>mAreg(60)<=P2MEM0_QB;
					when "0111110"=>mAreg(61)<=P2MEM0_QB;
										load_mema_f<='1';
					when "0111111"=>mAreg(62)<=P2MEM0_QB;
										load_mema_f<='0';
					when others =>
				end case;				
			end if;	
			end if;	
		end if;	
	end process;
	
	P2MEM0_ADD<=rmemA_adr;
	P2MEM0_WR<='0';

-----------------------------------------------------	
--write_mem_global
	process(memadr_clk)
	begin
		if(rising_edge(memadr_clk))then 
			if(wmemB_start_f='1')then
				wmemB_adr<="0000000";
			else
				if(wmemB_adr<64)then
					wmemB_en_f<='1';
					wmemB_adr<=wmemB_adr+1;
				else
					wmemB_en_f<='0';
				end if;
			end if;	
		end if;	
	end process;
	
	
	process(memrw_clk)
	begin
		if(wmemB_en_f='1')then
			if(rising_edge(memrw_clk))then 
				case wmemB_adr is
					when "0000001"=>P2MEM1_DATA<=mBreg(0);
					when "0000010"=>P2MEM1_DATA<=mBreg(1);
					when "0000011"=>P2MEM1_DATA<=mBreg(2);
					when "0000100"=>P2MEM1_DATA<=mBreg(3);
					when "0000101"=>P2MEM1_DATA<=mBreg(4);
					when "0000110"=>P2MEM1_DATA<=mBreg(5);
					when "0000111"=>P2MEM1_DATA<=mBreg(6);
					when "0001000"=>P2MEM1_DATA<=mBreg(7);
					when "0001001"=>P2MEM1_DATA<=mBreg(8);
					when "0001010"=>P2MEM1_DATA<=mBreg(9);
					when "0001011"=>P2MEM1_DATA<=mBreg(10);
					when "0001100"=>P2MEM1_DATA<=mBreg(11);
					when "0001101"=>P2MEM1_DATA<=mBreg(12);
					when "0001110"=>P2MEM1_DATA<=mBreg(13);
					when "0001111"=>P2MEM1_DATA<=mBreg(14);
					when "0010000"=>P2MEM1_DATA<=mBreg(15);
					when "0010001"=>P2MEM1_DATA<=mBreg(16);
					when "0010010"=>P2MEM1_DATA<=mBreg(17);
					when "0010011"=>P2MEM1_DATA<=mBreg(18);
					when "0010100"=>P2MEM1_DATA<=mBreg(19);
					when "0010101"=>P2MEM1_DATA<=mBreg(20);
					when "0010110"=>P2MEM1_DATA<=mBreg(21);
					when "0010111"=>P2MEM1_DATA<=mBreg(22);
					when "0011000"=>P2MEM1_DATA<=mBreg(23);
					when "0011001"=>P2MEM1_DATA<=mBreg(24);
					when "0011010"=>P2MEM1_DATA<=mBreg(25);
					when "0011011"=>P2MEM1_DATA<=mBreg(26);
					when "0011100"=>P2MEM1_DATA<=mBreg(27);
					when "0011101"=>P2MEM1_DATA<=mBreg(28);
					when "0011110"=>P2MEM1_DATA<=mBreg(29);
					when "0011111"=>P2MEM1_DATA<=mBreg(30);
					when "0100000"=>P2MEM1_DATA<=mBreg(31);
					when "0100001"=>P2MEM1_DATA<=mBreg(32);
					when "0100010"=>P2MEM1_DATA<=mBreg(33);
					when "0100011"=>P2MEM1_DATA<=mBreg(34);
					when "0100100"=>P2MEM1_DATA<=mBreg(35);
					when "0100101"=>P2MEM1_DATA<=mBreg(36);
					when "0100110"=>P2MEM1_DATA<=mBreg(37);
					when "0100111"=>P2MEM1_DATA<=mBreg(38);
					when "0101000"=>P2MEM1_DATA<=mBreg(39);
					when "0101001"=>P2MEM1_DATA<=mBreg(40);
					when "0101010"=>P2MEM1_DATA<=mBreg(41);
					when "0101011"=>P2MEM1_DATA<=mBreg(42);
					when "0101100"=>P2MEM1_DATA<=mBreg(43);
					when "0101101"=>P2MEM1_DATA<=mBreg(44);
					when "0101110"=>P2MEM1_DATA<=mBreg(45);
					when "0101111"=>P2MEM1_DATA<=mBreg(46);
					when "0110000"=>P2MEM1_DATA<=mBreg(47);
					when "0110001"=>P2MEM1_DATA<=mBreg(48);
					when "0110010"=>P2MEM1_DATA<=mBreg(49);
					when "0110011"=>P2MEM1_DATA<=mBreg(50);
					when "0110100"=>P2MEM1_DATA<=mBreg(51);
					when "0110101"=>P2MEM1_DATA<=mBreg(52);
					when "0110110"=>P2MEM1_DATA<=mBreg(53);
					when "0110111"=>P2MEM1_DATA<=mBreg(54);
					when "0111000"=>P2MEM1_DATA<=mBreg(55);
					when "0111001"=>P2MEM1_DATA<=mBreg(56);
					when "0111010"=>P2MEM1_DATA<=mBreg(57);
					when "0111011"=>P2MEM1_DATA<=mBreg(58);
					when "0111100"=>P2MEM1_DATA<=mBreg(59);
					when "0111101"=>P2MEM1_DATA<=mBreg(60);
					when "0111110"=>P2MEM1_DATA<=mBreg(61);
					when "0111111"=>P2MEM1_DATA<=mBreg(62);
					when others =>
				end case;				
			end if;	
		end if;	
	end process;
	
	
	P2MEM1_ADD<=wmemB_adr;
	P2MEM1_WR<=wmemB_en_f and memrw_clk and RST_N;

	






--====================================================================
AVALONE_IF:
	process(AVCKI,AVCSI,AVRDI,AVWRI,AVADDI,AVWRDI)
	begin
		if(AVCSI = '1')then
			case AVADDI(9 downto 7) is
				when "001"	=>	
					P2MEM_CS 	<= "00000010";--P2MEM_CS(1) for P2MEM0
					AVRDDO 		<= P2MEM0_QA;
				when "010"	=>	
					P2MEM_CS 	<= "00000100";
					AVRDDO 		<= P2MEM1_QA;
				when others	=>	
					AVRDDO  	<= "00000000";
					P2MEM_CS 	<= "00000000";
			end case;
		else
			P2MEM_CS <= "00000000";
		end if;
	end process;



P2MEM0:DPRAM_128	--nios write globle data to fprg
	PORT MAP
	(
		address_a	=>  AVADDI(6 downto 0),	
		address_b	=>  P2MEM0_ADD,			
		clock_a		=>  AVCKI,				
		clock_b		=>  AVCKI,	
		data_a		=>  AVWRDI,
		data_b		=>  P2MEM0_DATA,
		wren_a		=>  (AVWRI and P2MEM_CS(1)),
		wren_b		=>  P2MEM0_WR,
		q_a			=>  P2MEM0_QA,
		q_b			=>  P2MEM0_QB
	);
	
P2MEM1:DPRAM_128	--fpga write globle data to nios
	PORT MAP
	(
		address_a	=>  AVADDI(6 downto 0),	
		address_b	=>  P2MEM1_ADD,			
		clock_a		=>  AVCKI,				
		clock_b		=>  AVCKI,	
		data_a		=>  AVWRDI,
		data_b		=>  P2MEM1_DATA,
		wren_a		=>  (AVWRI and P2MEM_CS(2)),
		wren_b		=>  P2MEM1_WR,
		q_a			=>  P2MEM1_QA,
		q_b			=>  P2MEM1_QB
	);
	
	





------------------------------------------------------
------------------------------------------------------
Atxp:txproc											
	PORT MAP										
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,
        video_gate  	=>	Atx_start_f,
        txcon_f		  	=>	txcon_set_f,
        tx_data0    	=> 	Atx_data0,
        tx_data1    	=>	Atx_data1,
        tx_data2    	=>	Atx_data2,
        tx_data3    	=>	Atx_data3,
        tx_data4    	=>	Atx_data4,
        txout_f			=>	Atxout_f,
        clk4m_out		=>	Aclk4m_out,
        rfen_f			=>	rfenA_f,
        syncin_f		=>	RF1_CKO	
	);
-----------------------------------------------------	



	
------------------------------------------------------
------------------------------------------------------
Btxp:txproc
	PORT MAP
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,
        video_gate  	=>	Btx_start_f,
        txcon_f		  	=>	txcon_set_f,
        tx_data0    	=> 	Btx_data0,
        tx_data1    	=>	Btx_data1,
        tx_data2    	=>	Btx_data2,
        tx_data3    	=>	Btx_data3,
        tx_data4    	=>	Btx_data4,
        txout_f			=>	Btxout_f,
        clk4m_out		=>	Bclk4m_out,
        rfen_f			=>	rfenB_f,
        syncin_f		=>	RF2_CKO	
	);
------------------------------------------------------






------------------------------------------------------
------------------------------------------------------
--Ctxp:txproc											
--	PORT MAP										
--	(
--        reset_n	    	=>	RST_N,	
--        clksys 	    	=>	clkA,
--        video_gate  	=>	Atx_start_f,
--        txcon_f		  	=>	txcon_set_f,
--        tx_data0    	=> 	Atx_data0,
--        tx_data1    	=>	Atx_data1,
--        tx_data2    	=>	Atx_data2,
--        tx_data3    	=>	Atx_data3,
--        tx_data4    	=>	Atx_data4,
--        txout_f			=>	Ctxout_f,
--        clk4m_out		=>	Cclk4m_out,
--        rfen_f			=>	'0',    
--        syncin_f		=>	'0'    	
--	);
-----------------------------------------------------	



	
------------------------------------------------------
------------------------------------------------------
--Dtxp:txproc
--	PORT MAP
--	(
--       reset_n	    	=>	RST_N,	
--        clksys 	    	=>	clkA,
--        video_gate  	=>	Btx_start_f,
--        txcon_f		  	=>	txcon_set_f,
--        tx_data0    	=> 	Btx_data0,
--        tx_data1    	=>	Btx_data1,
--        tx_data2    	=>	Btx_data2,
--        tx_data3    	=>	Btx_data3,
--        tx_data4    	=>	Btx_data4,
--        txout_f			=>	Dtxout_f,
--        clk4m_out		=>	Dclk4m_out,
--        rfen_f			=>	'0',
--        syncin_f		=>	'0'	
--	);
------------------------------------------------------



















------------------------------------------------------
------------------------------------------------------
Stxp:txproc
	PORT MAP
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,
        video_gate  	=>	Sdata_gate,
        txcon_f		  	=>	txcon_set_f,
        tx_data0    	=> 	Stx_data0,
        tx_data1    	=>	Stx_data1,
        tx_data2    	=>	Stx_data2,
        tx_data3    	=>	Stx_data3,
        tx_data4    	=>	Stx_data4,
        txout_f			=>	Stxout_f,
        clk4m_out		=>	Sclk4m_out,
        rfen_f			=>	rfenS_f,
        syncin_f		=>	RF2_CKO	
	);
------------------------------------------------------




------------------------------------------------------
------------------------------------------------------
Arxp:rxproc
	PORT MAP
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,	
        rxin_f	    	=>  Arxin_f,
        rtime_cnt		=>	Hrtime_cnt,
		vgrx_tim_off	=>	Avgrx_tim_off,
		vgrt_tim_off	=>	Avgrt_tim_off,
		rxid			=>	HAid,
		vgrx_tim		=>	Avgrx_tim,
		vgrt_tim		=>	Avgrt_tim,
		vgout_en_tim_o  =>  Arxvgout_en_tim,
        rxclk_out		=>	Arxclk_out,
        rxpack_out		=>	Arxpack_out,
        vgout_en		=>  Arxvgout_en_f,	
        rx_data0		=>	Arx_data0,
        rx_data1		=>	Arx_data1,
        rx_data2		=>	Arx_data2,
        rx_data3		=>  Arx_data3,
        rx_data4		=>  Arx_data4
	);
------------------------------------------------------


------------------------------------------------------
------------------------------------------------------
Brxp:rxproc
	PORT MAP
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,	
        rxin_f	    	=>  Brxin_f,
        rtime_cnt		=>	Hrtime_cnt,
		vgrx_tim_off	=>	Bvgrx_tim_off,
		vgrt_tim_off	=>	Bvgrt_tim_off,
		rxid			=>	HBid,
		vgrx_tim		=>	Bvgrx_tim,
		vgrt_tim		=>	Bvgrt_tim,
		vgout_en_tim_o  =>  Brxvgout_en_tim,
        rxclk_out		=>	Brxclk_out,
        rxpack_out		=>	Brxpack_out,
		vgout_en		=>  Brxvgout_en_f,	
        rx_data0		=>	Brx_data0,
        rx_data1		=>	Brx_data1,
        rx_data2		=>	Brx_data2,
        rx_data3		=>  Brx_data3,
        rx_data4		=>  Brx_data4
	);
------------------------------------------------------





------------------------------------------------------
------------------------------------------------------
--Crxp:rxproc
--	PORT MAP
--	(
--        reset_n	    	=>	RST_N,	
--        clksys 	    	=>	clkA,	
--        rxin_f	    	=>  Crxin_f,
--        rtime_cnt		=>	Hrtime_cnt,
--		vgrx_tim_off	=>	Avgrx_tim_off,
--		vgrt_tim_off	=>	Avgrt_tim_off,
--		rxid			=>	HAid,
----		vgrx_tim		=>	Avgrx_tim,
----		vgrt_tim		=>	Cvgrt_tim,
----		vgout_en_tim_o  =>  Crxvgout_en_tim,
----      rxclk_out		=>	Crxclk_out,
--        rxpack_out		=>	Crxpack_out,
----      vgout_en		=>  Crxvgout_en_f,	
--        rx_data0		=>	Crx_data0,
--        rx_data1		=>	Crx_data1,
--        rx_data2		=>	Crx_data2,
--        rx_data3		=>  Crx_data3,
--        rx_data4		=>  Crx_data4
--	);
------------------------------------------------------


------------------------------------------------------
------------------------------------------------------
--Drxp:rxproc
--	PORT MAP
--	(
--        reset_n	    	=>	RST_N,	
--        clksys 	    	=>	clkA,	
--        rxin_f	    	=>  Drxin_f,
--        rtime_cnt		=>	Hrtime_cnt,
--		vgrx_tim_off	=>	Bvgrx_tim_off,
--		vgrt_tim_off	=>	Bvgrt_tim_off,
--		rxid			=>	HBid,
----		vgrx_tim		=>	Dvgrx_tim,
----		vgrt_tim		=>	Dvgrt_tim,
----		vgout_en_tim_o  =>  Drvgout_en_tim,
----      rxclk_out		=>	Drxclk_out,
--        rxpack_out		=>	Drxpack_out,
----		vgout_en		=>  Drvgout_en_f,	
--        rx_data0		=>	Drx_data0,
--        rx_data1		=>	Drx_data1,
--        rx_data2		=>	Drx_data2,
--        rx_data3		=>  Drx_data3,
--        rx_data4		=>  Drx_data4
--	);
------------------------------------------------------









	
	

------------------------------------------------------
------------------------------------------------------
Srxp:rxproc
	PORT MAP
	(
        reset_n	    	=>	RST_N,	
        clksys 	    	=>	clkA,	
        rxin_f	    	=>  Srxin_f,
        rtime_cnt		=>	Srtime_cnt,
		vgrx_tim_off	=>	Svgrx_tim_off,
		vgrt_tim_off	=>	Svgrt_tim_off,
		rxid			=>	Sid_f,
		vgrx_tim		=>	Svgrx_tim,
		vgrt_tim		=>	Svgrt_tim,
		vgout_en_tim_o =>   Svgout_en_tim,
        rxclk_out		=>	Srxclk_out,
        rxpack_out		=>	Srxpack_out,
        vgout_en		=>  Svgout_en_f,	
        rx_data0		=>	Srx_data0,
        rx_data1		=>	Srx_data1,
        rx_data2		=>	Srx_data2,
        rx_data3		=>  Srx_data3,
        rx_data4		=>  Srx_data4
	);
------------------------------------------------------


	onetst_vgin_tx		<=  keyflag(0);
	contst_vgin_tx		<=  contst_vgin_ps;




	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			sp_t0subx_f<='0';
			sp_t0subx_tim<="1111111100";
		else
			if(rising_edge(clkA))then
				if(SP_T0SUBX='0')then
					sp_t0subx_f<='0';
					sp_t0subx_tim<="0000000000";
--					if(stop_vgin_tim<800000)then
--					  stop_vgin_tim<=stop_vgin_tim+1;
--					end if;  
				else
--					stop_vgin_tim<="00000000000000000000";
					if(sp_t0subx_tim<640)then
					    sp_t0subx_f<='1';
						sp_t0subx_tim<=sp_t0subx_tim+1;
					else
						sp_t0subx_f<='0';
					end if;
				end if; 
			end if;
		end if;
	end process;	 	




	PROCESS(clkA)
  	BEGIN
		if(rising_edge(clkA))then
			if(sp_t0subx_f='0')then
				if(stop_vgin_tim<800000)then
				  stop_vgin_tim<=stop_vgin_tim+1;
				  tstsp_en_f<='0';	
				else
				  tstsp_en_f<='1';	
				end if;  
			else
			    tstsp_en_f<='0';	
				stop_vgin_tim<="00000000000000000000";
			end if;	
		end if;
	end process;	 	









	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Aprvg_in_f<='0';
		else
			if(rising_edge(clkA))then
				if(sp_t0subx_f='1')then
					Aprvg_in_tim<="00000000000000000000";
					sp_freqch(0)<=SP_CH0;
					sp_freqch(1)<=SP_CH1;
					sp_freqch(2)<=SP_CH2;
					sp_freqch(3)<=SP_CH3;
					sp_freqch(4)<=SP_CH4;
					sp_freqch(5)<=SP_CH5;
					sp_freqch(6)<='0';
					sp_freqch(7)<=SP_INHIB;
				else
					if(Aprvg_in_tim<800000)then
					    Aprvg_in_f<='1';
						Aprvg_in_tim<=Aprvg_in_tim+1;
					else
						Aprvg_in_f<='0';
					end if;
				end if; 
			end if;
		end if;
	end process;	 	


--generate auto con vidio gate in pulse
---------------------------------------------------
---------------------------------------------------
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			Hvideo_gate<='0';
		else
			if(rising_edge(clkA))then
				case vg_mode is
					when "00"=>
						Hvideo_gate		<='0';
					when "01"=>
						Hvideo_gate		<=  sp_t0subx_f;
						hchflag			<=  sp_freqch;		
					when "10"=>
						Hvideo_gate		<=  contst_vgin_tx;-- or onetst_vgin_tx;
						hchflag			<=  my_freqch;		
					when "11"=>
						Hvideo_gate		<=  sp_t0subx_f or contst_vgin_tx;-- or onetst_vgin_tx;
						hchflag			<=  sp_freqch;
--					when "100"=>
--						Hvideo_gate		<=  contst_vgin_tx;-- or onetst_vgin_tx;
--						hchflag			<=  my_freqch;		
					when others =>
					
				end case;				
			end if;
		end if;	
	end process;
---------------------------------------------------

	WG_FREQ	<=	rchflag(5 downto 0);



--	Hvideo_gate		<=  Aprvg_in and  AVWR_REG(0)(0);--aprvg_in_en
--	one_shot_tx		<=  keyflag(0)and AVWR_REG(0)(1);--one_shot_enable
--	con_shot_tx		<=  con_shot_ps and AVWR_REG(0)(2);--con_shot_enable
	
	HAvideo_gate	<=	Hvideo_gate and HA_gate_en; 
	HBvideo_gate	<=	Hvideo_gate and HB_gate_en; 
	HAdata_gate		<=	Hdata_gate	and HA_gate_en;
	HBdata_gate		<=	Hdata_gate	and HB_gate_en;
	
	PROCESS(system_set)
	begin
		if(system_set="00")then
			Atx_start_f		<=	HAvideo_gate or HAdata_gate ; 
			Btx_start_f		<=	HBvideo_gate or HBdata_gate ; 
		end if;
		if(system_set="01")then
			Atx_start_f		<=	'0'; 
			Btx_start_f		<=	'0'; 
		end if;
		if(system_set="10")then
			Atx_start_f		<=	'0'; 
			Btx_start_f		<=	'0'; 
		end if;
	end process;	
		








--	Hvideo_gate<=keyflag(0);


--	Srxin_f<=Adlybuf0(15);
--	Srxin_f<=Atxout_f	;
	
--	Arxin_f<=Sdlybuf0(15);
--	Arxin_f<=Stxout_f;
	
	
--	Hvideo_gate<=not keyin(0);
--	Svideo_gate<=not keyin(0);
--	Arxin_f<=Atxout_f;
--	Srxin_f<=Adlybuf0(15);
--	led_0<=Atxload_f;

--	testout(0)<=Hvgout_f;
--	testout(1)<=Svgout_f;
--	testout(2)<=Srxpack_out;
--	testout(3)<=Svgout_en_f;
--	testout(4)<=Hvgout_f;
--	testout(5)<=8;
--	testout(6)<=Aclk4m_out;
--	testout(7)<=Srxclk_out;



	WG_VGO <= wg_vgo_f;


	process(system_set)
	begin
		if(system_set="00")then
			oToNios_r(0)<=Hnrwmem_pus_f or Autonrwmem_pus_f;
			rmemA_start_f<=Hrmem_pus_f or AutormA_pus_f;
			wmemB_start_f<=Hwmem_pus_f or AutowmB_pus_f;
			Rvgout_f	 <=Hvgout_f;
			rwgst_pus_f	 <=wgst_pus_f;
--			wg_vgo_f     <=wgout_f and not iCtrNios(5);	
			wg_vgo_f     <=wgoff_f and not iCtrNios(5);	
			
			
			rchflag		 <=hchflag;
			inhib_f	   	 <=hchflag(7);
		else
			oToNios_r(0)<=Snrwmem_pus_f or Autonrwmem_pus_f;
			rmemA_start_f<=Srmem_pus_f or AutormA_pus_f;
			wmemB_start_f<=Swmem_pus_f or AutowmB_pus_f;
			if(iCtrNios(4)='0')then	--local
				Rvgout_f<=lvgout_f;
				rwgst_pus_f<=lwgst_pus_f;
--				wg_vgo_f   <=lwgout_f and not iCtrNios(5) and wgout_en_f;	
				wg_vgo_f   <=wgoff_f and not iCtrNios(5) and wgout_en_f;	
				inhib_f	   <=iCtrNios(5) or not wgout_en_f;		
				rchflag	   <=nout32(23 downto 16);
			else
				Rvgout_f	<=Svgout_f;
				rwgst_pus_f<=wgst_pus_f;
--				wg_vgo_f   <=wgout_f and not srchflag(7) and wgout_en_f;	
				wg_vgo_f   <=wgoff_f and not srchflag(7) and wgout_en_f;	
				inhib_f	   <=srchflag(7) or not wgout_en_f;			
				rchflag	   <=srchflag;
			end if;
		end if;
	end process;		

	oToNios_r(3)<=WG_PWOK;
	oToNios_r(4)<=WG_RFOK;
	oToNios_r(5)<='0';
	oToNios_r(6)<='0';
	oToNios_r(7)<='0';
	oToNios<=oToNios_r;

	ALARM_OUT<=iFrmNios(3);
	RF1_TXSW<=not iFrmNios(4);
	RF1_RXSW<=not iFrmNios(5);
	RF2_TXSW<=not iFrmNios(6);
	RF2_RXSW<=not iFrmNios(7);
	
	VGS_HC<=vgdly_f;
	VGS_S1<=fblpin1_out_f;
	VGS_S2<=fblpin2_out_f;
	WGS_S1<=w_fblpin1_out_f;
	WGS_S2<=w_fblpin2_out_f;

	

--	testout(0)<=Aclk4m_out;--jp7_7
--	testout(1)<=Atxout_f;
--	testout(2)<=Htxrx_sw_f;
--	testout(3)<=Hvgout_f;
--	testout(4)<=wmemB_en_f;
--	testout(5)<=rmemA_en_f;
--	testout(6)<=Hnrwmem_pus_f;




	PROCESS(TR_mode)
	begin
		if(system_set="00")then
			if(TR_mode(3)='0')then
				if(TR_mode(1 downto 0)="00")then
					FIB1_TXD  <=Atxout_f;
					Arxin_f	  <=FIB1_RXD;
					oToNios_r(1)<='1';--0:tx 1:rx 
				end if;	
				if(TR_mode(1 downto 0)="01")then
					RF1_TXD   <=Atxout_f;
					Arxin_f	  <=RF1_RXD;
					oToNios_r(1)<=Htxrx_sw_f;
				end if;	
				if(TR_mode(5 downto 4)="00")then
					FIB2_TXD  <=Btxout_f;
					Brxin_f	  <=FIB2_RXD;
					oToNios_r(2)<='1';--0:tx 1:rx 
				end if;	
				if(TR_mode(5 downto 4)="01")then
					RF2_TXD   <=Btxout_f;
					Brxin_f	  <=RF2_RXD;
					oToNios_r(2)<=Htxrx_sw_f;
				end if;	
				FIB1_LPT  <=vgloop_f;
				FIB2_LPT  <=vgloop_f;
				fblpin1_f <=rlppack1_f;
				fblpin2_f <=rlppack2_f;
				rlprxin1_f<=FIB1_LPR;
				rlprxin2_f<=FIB2_LPR;
				
			else
				oToNios_r(1)<='1';--0:tx 1:rx 
				oToNios_r(2)<='1';--0:tx 1:rx 
				RF1_TXD<='0';   
				RF2_TXD<='0';   
				if(TR_mode(1 downto 0)="00")then
					FIB1_TXD  <= vgloop_f;
					FIB2_TXD  <='0';
					FIB1_LPT  <='0';
					FIB2_LPT  <='0';
					rlprxin1_f <= FIB1_RXD;  
					fblpin1_f <=rlppack1_f;
					
				end if;
				if(TR_mode(1 downto 0)="01")then
					FIB1_TXD  <='0';
					FIB2_TXD  <= vgloop_f;
					FIB1_LPT  <='0';
					FIB2_LPT  <='0';
					rlprxin1_f <= FIB2_RXD;  
					fblpin1_f <=rlppack1_f;
				end if;
				if(TR_mode(1 downto 0)="10")then
					FIB1_TXD  <='0';
					FIB2_TXD  <='0';
					FIB1_LPT  <= vgloop_f;
					FIB2_LPT  <='0';
					rlprxin1_f <= FIB1_LPR;  
					fblpin1_f <=rlppack1_f;
					
				end if;
				if(TR_mode(1 downto 0)="11")then
					FIB1_TXD  <='0';
					FIB2_TXD  <='0';
					FIB1_LPT  <='0';
					FIB2_LPT  <= vgloop_f;
					rlprxin1_f <= FIB2_LPR;  
					fblpin1_f <=rlppack1_f;
					
				end if;
			end if;
		end if;
		if(system_set="01")then
		    Sid_f<=Sid1;
			if(TR_mode(3 downto 0)="0000")then
				FIB1_TXD  <=Stxout_f;
				Srxin_f	  <=FIB1_RXD;
				oToNios_r(1)<='1';--0:tx 1:rx 
				oToNios_r(2)<='1';--0:tx 1:rx 
			end if;	
			if(TR_mode(3 downto 0)="0001")then
				RF2_TXD   <=Stxout_f;
				Srxin_f	  <=RF2_RXD;
				oToNios_r(1)<='1';--0:tx 1:rx 
				oToNios_r(2)<=Stxrx_sw_f;
			end if;	
			FIB1_LPT  <=vgloop_f;
		end if;
		if(system_set="10")then
		    Sid_f<=Sid2;
			if(TR_mode(7 downto 4)="0000")then
				FIB1_TXD  <=Stxout_f;
				Srxin_f	  <=FIB1_RXD;
				oToNios_r(1)<='1';--0:tx 1:rx 
				oToNios_r(2)<='1';--0:tx 1:rx 
			end if;	
			if(TR_mode(7 downto 4)="0001")then
				RF2_TXD   <=Stxout_f;
				Srxin_f	  <=RF2_RXD;
				oToNios_r(1)<='1';--0:tx 1:rx 
				oToNios_r(2)<=Stxrx_sw_f;
			end if;	
			FIB1_LPT  <=vgloop_f;
		end if;
	end process;	

	
--**********************************
--  transfer test direct
--**********************************
--	Srxin_f<=Atxout_f;
--	Arxin_f<=Stxout_f;
--##################################


--**********************************
--  transfer test by delay
--**********************************
--	Srxin_f<=Adlybuf0(15);
--	Arxin_f<=Sdlybuf0(15);
--##################################


--**********************************
--  transfer test by fiber
--**********************************
--	FIB1_TXD  <=Atxout_f;
--	Srxin_f<=FIB1_LPR;
--	FIB1_LPT  <=Stxout_f;
--	Arxin_f<=FIB1_RXD;
--##################################

--**********************************
--  transfer test by RF
--**********************************
--	RF1_TXD   <=Atxout_f;
--	Srxin_f	  <=RF2_RXD;
--	RF2_TXD   <=Stxout_f;
--	Arxin_f	  <=RF1_RXD;
--##################################
		
	
	
	
	
	
	
--	testout(0)<=Atx_start_f;	--jp7_7
--	testout(1)<=RF1_CKO;		--jp7_9
--	testout(3)<=Atxout_f;		--jp7_10
---	testout(4)<=Aclk4m_out;		--jp7_11
--	testout(5)<=Srxin_f;		--jp7_12
--	testout(6)<=Hvgout_f;		--jp7_13
--	testout(7)<=Svgout_f;		--jp7_14
	
	
	

--	testout(0)<=wg_qc_data_f;	--jp7_7
--	testout(1)<=wg_i_data_f;	--jp7_9
--	testout(3)<=wg_q_data_f;		--jp7_10
--	testout(4)<=wg_ic_data_f;		--jp7_11
--	testout(5)<=wg_i_data_f;		--jp7_12
--	testout(6)<=SP_T0SUBX;		--jp7_13
--	testout(7)<=wgout_f;		--jp7_14
	
	

	WG_PHASE(4)<=wg_i_clk_f;
	WG_PHASE(5)<=wg_q_clk_f;
	WG_PHASE(1)<=wg_i_data_f;
	WG_PHASE(0)<=wg_ic_data_f;
	WG_PHASE(3)<=wg_q_data_f;
	WG_PHASE(2)<=wg_qc_data_f;
	WG_PHASE(6)<=wg_sysclk_f;
	WG_PHASE(7)<='0';--not wg_cs_f;
	WG_PWEN	   <=iCtrNios(2);	
	WG_RFON	   <=iCtrNios(3);	
	
	

	process(lagrp)
	begin
		case lagrp(3 downto 0) is
			when "0000"	=>	
				TOLA(0)<=Hvgout_f;
				TOLA(1)<=Svgout_f;
				TOLA(2)<=wgout_f;
				TOLA(3)<=lvgout_f;
				TOLA(4)<=Atx_start_f;
				TOLA(5)<=inhib_f;--Btx_start_f;
				TOLA(6)<=vgloop_f;
				TOLA(7)<=rlpclk1_f;--rmemA_start_f;
				TOLA(8)<=rlppack1_f;--wmemB_start_f;
				TOLA(9)<=debug_f;--rlpclk2_f;--Hrmem_pus_f;
				TOLA(10)<=debug_out_f;--rlppack2_f;--AutormA_pus_f;
				TOLA(11)<=FIB1_LPR;
				TOLA(12)<=FIB2_LPR;
				TOLA(13)<=w_fblpin1_out_f;
				TOLA(14)<=w_fblpin2_out_f;
				TOLA(15)<=vgdly_f;
				TOLA(16)<=fblpin1_out_f;
				TOLA(17)<=fblpin2_out_f;
				
				
				
			when "0001"	=>	
				TOLA(0)<=Hvgout_f;
				TOLA(1)<=Svgout_f;
				TOLA(2)<=Atxout_f;
			    TOLA(3)<=Aclk4m_out;
				TOLA(4)<=Btxout_f;
			    TOLA(5)<=Bclk4m_out;
				TOLA(6)<=Stxout_f;
			    TOLA(7)<=Sclk4m_out;
				TOLA(8)<=Arxin_f;
				TOLA(9)<=Arxclk_out;
				TOLA(10)<=Arxpack_out;
				TOLA(11)<=Brxin_f;
				TOLA(12)<=Brxclk_out;
				TOLA(13)<=Brxpack_out;
				TOLA(14)<=Srxin_f;
				TOLA(15)<=Srxclk_out;
				TOLA(16)<=Srxpack_out;
				TOLA(17)<=Atx_start_f;
			when "0010"	=>	
				TOLA(17 downto 0)<= "00" & LPNS(15 downto 0);
			when "0011"	=>	
				TOLA(17 downto 0)<= LPIN(17 downto 0);
			when "0100"	=>	
				TOLA(17 downto 0)<= "00000000" & LPIN(27 downto 18);
			when "0101"	=>	
				TOLA(0)<=Hvgout_f;
				TOLA(1)<=Svgout_f;
				TOLA(2)<= SP_CH0;
				TOLA(3)<= SP_CH1;
				TOLA(4)<= SP_CH2;
				TOLA(5)<= SP_CH3;
				TOLA(6)<= SP_CH4;
				TOLA(7)<= SP_CH5;
				TOLA(8)<= SP_INHIB;
				TOLA(9)<= SP_T0SUBX;
				TOLA(10)<= SP_T0VGI;
				TOLA(11)<= WG_PWOK;
				TOLA(12)<= WG_RFOK;
				TOLA(13)<= GPS_CK10MI;
				TOLA(14)<= GPS_1PPS;
				TOLA(15)<= sp_t0subx_f;
				TOLA(16)<= '0';
				TOLA(17)<= '0';
			when "0110"	=>	
				TOLA(0)<=Hvgout_f;
				TOLA(1)<=Svgout_f;
				TOLA(2)<=iFrmNios(0);
				TOLA(3)<=iFrmNios(1);
				TOLA(4)<=iFrmNios(2);
				TOLA(5)<=iFrmNios(3);
				TOLA(6)<=iFrmNios(4);
				TOLA(7)<=iFrmNios(5);
				TOLA(8)<=iFrmNios(6);
				TOLA(9)<=iFrmNios(7);
				TOLA(10)<=RF1_RXD;
				TOLA(11)<=RF1_CKO;
				TOLA(12)<=RF2_RXD;
				TOLA(13)<=RF2_CKO;
				TOLA(14)<=FIB1_RXD;
				TOLA(15)<=FIB1_LPR;
				TOLA(16)<=FIB2_RXD;
				TOLA(17)<=FIB2_LPR;
			when "0111"	=>	
				TOLA(0)<=lvgout_f;
				TOLA(16 downto 1)<=nout32(15 downto 0);
			when others	=>	
		end case;
	end process;


	process(lagrp)
	begin
		case lagrp(7 downto 4) is
			when "0000"	=>	
				TOLA(18)<=Hvgout_f;
				TOLA(19)<=Svgout_f;
				TOLA(20)<=wgout_f;
				TOLA(21)<=wg_i_clk_f;
				TOLA(22)<=wg_q_clk_f;
				TOLA(23)<=wg_i_data_f;
				TOLA(24)<=wg_ic_data_f;
				TOLA(25)<=wg_q_data_f;
				TOLA(26)<=wg_qc_data_f;
				TOLA(27)<=wg_cs_f;
				TOLA(28)<=wg_sysclk_f;
				TOLA(29)<=wgst_pus_f;
				TOLA(30)<=SP_T0SUBX;
				TOLA(31)<=SP_T0VGI;
				TOLA(32)<=Atx_start_f;
				TOLA(33)<=sp_t0subx_f;
				TOLA(34)<=lvgout_f;
				TOLA(35)<='0';
			when "0001"	=>	
				TOLA(18)<=Hvgout_f;
				TOLA(19)<=Svgout_f;
				TOLA(20)<=Atxout_f;
			    TOLA(21)<=Aclk4m_out;
				TOLA(22)<=Btxout_f;
			    TOLA(23)<=Bclk4m_out;
				TOLA(24)<=Stxout_f;
			    TOLA(25)<=Sclk4m_out;
				TOLA(26)<=Arxin_f;
				TOLA(27)<=Arxclk_out;
				TOLA(28)<=Arxpack_out;
				TOLA(29)<=Brxin_f;
				TOLA(30)<=Brxclk_out;
				TOLA(31)<=Brxpack_out;
				TOLA(32)<=Srxin_f;
				TOLA(33)<=Srxclk_out;
				TOLA(34)<=Srxpack_out;
				TOLA(35)<=Atx_start_f;
			when "0010"	=>	
				TOLA(35 downto 18)<= rmemA_start_f & wmemB_start_f & LPNS(15 downto 0);
			when "0011"	=>	
				TOLA(35 downto 18)<= LPIN(17 downto 0);
			when "0100"	=>	
				TOLA(35 downto 18)<= oToNios_r & LPIN(27 downto 18);
			when "0101"	=>	
				TOLA(18)<=Hvgout_f;
				TOLA(19)<=Svgout_f;
				TOLA(20)<= SP_CH0;
				TOLA(21)<= SP_CH1;
				TOLA(22)<= SP_CH2;
				TOLA(23)<= SP_CH3;
				TOLA(24)<= SP_CH4;
				TOLA(25)<= SP_CH5;
				TOLA(26)<= SP_INHIB;
				TOLA(27)<= SP_T0SUBX;
				TOLA(28)<= SP_T0VGI;
				TOLA(29)<= WG_PWOK;
				TOLA(30)<= WG_RFOK;
				TOLA(31)<= GPS_CK10MI;
				TOLA(32)<= GPS_1PPS;
				TOLA(33)<= sp_t0subx_f;
				TOLA(34)<= '0';
				TOLA(35)<= '0';
			when "0110"	=>	
				TOLA(18)<=Hvgout_f;
				TOLA(19)<=Svgout_f;
				TOLA(20)<=iFrmNios(0);
				TOLA(21)<=iFrmNios(1);
				TOLA(22)<=iFrmNios(2);
				TOLA(23)<=iFrmNios(3);
				TOLA(24)<=iFrmNios(4);
				TOLA(25)<=iFrmNios(5);
				TOLA(26)<=iFrmNios(6);
				TOLA(27)<=iFrmNios(7);
				TOLA(28)<=RF1_RXD;
				TOLA(29)<=RF1_CKO;
				TOLA(30)<=RF2_RXD;
				TOLA(31)<=RF2_CKO;
				TOLA(32)<=FIB1_RXD;
				TOLA(33)<=FIB1_LPR;
				TOLA(34)<=FIB2_RXD;
				TOLA(35)<=FIB2_LPR;
			when others	=>	
		end case;
	end process;


	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			hvgout_re_tim<="0000000000000000";
		else
			if(rising_edge(Hvgout_f))then
                hvgout_re_tim<=basetime_cnt(15 downto 0);

			end if;
		end if;
	end process;					
                
	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			spt0vgi_fe_tim<="0000000000000000";
		else
			if(falling_edge(SP_T0VGI))then
                spt0vgi_fe_tim<=basetime_cnt(15 downto 0);
			end if;
		end if;
	end process;					
                


	PROCESS(clkA)
  	BEGIN
		if(RST_N='0')then
			spt0vgi_chk_tim<="00000000000000000000";
		else
			if(rising_edge(clkA))then
				if(SP_T0VGI='0')then
--					if(spt0vgi_chk_tim/=0)then
						spt0vgi_chk_tim<="00000000000000000000";
--					end if;	
				else	
					if(spt0vgi_chk_tim<10000)then
						spt0vgi_chk_tim<=spt0vgi_chk_tim+1;
						if(spt0vgi_chk_tim=6400)then
							hvgoff_tim<=hvgout_re_tim-spt0vgi_fe_tim+6272;
						end if;	
						if(spt0vgi_chk_tim=6408)then
							mBreg(36)<=hvgoff_tim(15 downto 8);
							mBreg(37)<=hvgoff_tim( 7 downto 0);
						end if;	
					else	
--						hvgoff_tim<="1111111110000000";
						
--						if(spt0vgi_chk_tim=6404)then
--							mBreg(36)<=hvgoff_tim(15 downto 8);
--							mBreg(37)<=hvgoff_tim( 7 downto 0);
--						end if;	

					end if;	
				end if;	
			end if;
		end if;
	end process;					

						
	
	
	

--	testout(0)<=Atxout_f;		--jp7_7
--	testout(1)<=Btxout_f;		--jp7_9
--	testout(3)<=Ctxout_f;		--jp7_10
--	testout(4)<=Dtxout_f;		--jp7_11
--	testout(5)<=Crxpack_out;	--jp7_12
--	testout(6)<=Hvgout_f;		--jp7_13
--	testout(7)<=Drxpack_out;		--jp7_14



	TX_VGO<=Rvgout_f;	

--  	testout(0)<=Srxin_f   ;		--jp7_7
--  	testout(1)<=Srxclk_out;		--jp7_8
--  	testout(2)<=Sclk4m_out;		--jp7_9
--  	testout(3)<=Stxout_f;		--jp7_10
-- 		testout(4)<=Srxpack_out;	--jp7_11
--	testout(5)<=Arxpack_out;	--jp7_12
--	testout(6)<=Hvgout_f;		--jp7_13
--	testout(7)<=Svgout_f;		--jp7_14

	
	
	led(0)<=led0_f;
	led(1)<=not led1_f;
	led(2)<=not led2_f;--have problem 

--	led(0)<='0';		--;middle led oppo
--	led(1)<='0';		--;buttom led oppo
--	led(2)<='1';		--;top led oppo --have problem 

	
	
END sync_fpga_body;







