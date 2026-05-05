# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct D:\kevin\myCode\microBlaze200\moreFun\design_1_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source D:\kevin\myCode\microBlaze200\moreFun\design_1_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {design_1_wrapper}\
-hw {D:\kevin\myCode\microBlaze200\design_1_wrapper.xsa}\
-out {D:/kevin/myCode/microBlaze200/moreFun}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {design_1_wrapper}
platform generate -quick
platform config -updatehw {D:/kevin/myCode/microBlaze200/design_1_wrapper.xsa}
platform generate
