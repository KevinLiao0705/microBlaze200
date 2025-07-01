# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct D:\kevin\myCode\microBlaze1\vitisCar\syncBlaze\platform.tcl
# 
# OR launch xsct and run below command.
# source D:\kevin\myCode\microBlaze1\vitisCar\syncBlaze\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {syncBlaze}\
-hw {D:\kevin\myCode\microBlaze1\design_1_wrapper.xsa}\
-proc {microblaze_0} -os {standalone} -out {D:/kevin/myCode/microBlaze1/vitisCar}

platform write
platform generate -domains 
platform active {syncBlaze}
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform generate
platform active {syncBlaze}
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform generate -domains 
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform generate -domains 
platform active {syncBlaze}
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform generate -domains standalone_domain 
platform config -updatehw {D:/kevin/myCode/microBlaze1/design_1_wrapper.xsa}
platform generate -domains 
