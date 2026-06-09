# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: E:\kevin\myCode\microBlaze200\vitisJson\syncMain_system\_ide\scripts\systemdebugger_syncmain_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source E:\kevin\myCode\microBlaze200\vitisJson\syncMain_system\_ide\scripts\systemdebugger_syncmain_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Platform Cable USB 13724327082d01" && level==0 && jtag_device_ctx=="jsn-DLC9LP-13724327082d01-13636093-0"}
fpga -file E:/kevin/myCode/microBlaze200/vitisJson/syncMain/_ide/bitstream/download.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw E:/kevin/myCode/microBlaze200/vitisJson/syncBlaze/export/syncBlaze/hw/design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow E:/kevin/myCode/microBlaze200/vitisJson/syncMain/Debug/syncMain.elf
bpadd -addr &main
