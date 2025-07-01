# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\kevin\myCode\microBlaze1\vitisCar\syncMain_system\_ide\scripts\systemdebugger_syncmain_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\kevin\myCode\microBlaze1\vitisCar\syncMain_system\_ide\scripts\systemdebugger_syncmain_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS2 201706300081" && level==0 && jtag_device_ctx=="jsn-JTAG-HS2-201706300081-13636093-0"}
fpga -file D:/kevin/myCode/microBlaze1/vitisCar/syncMain/_ide/bitstream/design_1_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/kevin/myCode/microBlaze1/vitisCar/syncBlaze/export/syncBlaze/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/kevin/myCode/microBlaze1/vitisCar/syncMain/Debug/syncMain.elf
bpadd -addr &main
