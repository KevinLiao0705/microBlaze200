# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RamAddrWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RamDataWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RamDepth" -parent ${Page_0}


}

proc update_PARAM_VALUE.RamAddrWidth { PARAM_VALUE.RamAddrWidth } {
	# Procedure called to update RamAddrWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RamAddrWidth { PARAM_VALUE.RamAddrWidth } {
	# Procedure called to validate RamAddrWidth
	return true
}

proc update_PARAM_VALUE.RamDataWidth { PARAM_VALUE.RamDataWidth } {
	# Procedure called to update RamDataWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RamDataWidth { PARAM_VALUE.RamDataWidth } {
	# Procedure called to validate RamDataWidth
	return true
}

proc update_PARAM_VALUE.RamDepth { PARAM_VALUE.RamDepth } {
	# Procedure called to update RamDepth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RamDepth { PARAM_VALUE.RamDepth } {
	# Procedure called to validate RamDepth
	return true
}


proc update_MODELPARAM_VALUE.RamAddrWidth { MODELPARAM_VALUE.RamAddrWidth PARAM_VALUE.RamAddrWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RamAddrWidth}] ${MODELPARAM_VALUE.RamAddrWidth}
}

proc update_MODELPARAM_VALUE.RamDataWidth { MODELPARAM_VALUE.RamDataWidth PARAM_VALUE.RamDataWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RamDataWidth}] ${MODELPARAM_VALUE.RamDataWidth}
}

proc update_MODELPARAM_VALUE.RamDepth { MODELPARAM_VALUE.RamDepth PARAM_VALUE.RamDepth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RamDepth}] ${MODELPARAM_VALUE.RamDepth}
}

