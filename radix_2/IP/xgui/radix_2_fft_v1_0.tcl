# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXI_ADDR_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_DATA_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_ID_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXI_ADDR_W { PARAM_VALUE.AXI_ADDR_W } {
	# Procedure called to update AXI_ADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ADDR_W { PARAM_VALUE.AXI_ADDR_W } {
	# Procedure called to validate AXI_ADDR_W
	return true
}

proc update_PARAM_VALUE.AXI_DATA_W { PARAM_VALUE.AXI_DATA_W } {
	# Procedure called to update AXI_DATA_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_DATA_W { PARAM_VALUE.AXI_DATA_W } {
	# Procedure called to validate AXI_DATA_W
	return true
}

proc update_PARAM_VALUE.AXI_ID_W { PARAM_VALUE.AXI_ID_W } {
	# Procedure called to update AXI_ID_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ID_W { PARAM_VALUE.AXI_ID_W } {
	# Procedure called to validate AXI_ID_W
	return true
}

proc update_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to update N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N { PARAM_VALUE.N } {
	# Procedure called to validate N
	return true
}


proc update_MODELPARAM_VALUE.N { MODELPARAM_VALUE.N PARAM_VALUE.N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N}] ${MODELPARAM_VALUE.N}
}

proc update_MODELPARAM_VALUE.AXI_ADDR_W { MODELPARAM_VALUE.AXI_ADDR_W PARAM_VALUE.AXI_ADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ADDR_W}] ${MODELPARAM_VALUE.AXI_ADDR_W}
}

proc update_MODELPARAM_VALUE.AXI_DATA_W { MODELPARAM_VALUE.AXI_DATA_W PARAM_VALUE.AXI_DATA_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_DATA_W}] ${MODELPARAM_VALUE.AXI_DATA_W}
}

proc update_MODELPARAM_VALUE.AXI_ID_W { MODELPARAM_VALUE.AXI_ID_W PARAM_VALUE.AXI_ID_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ID_W}] ${MODELPARAM_VALUE.AXI_ID_W}
}

