# This is for IPs configurations

# ## ila_rx

# set MODULE  ila_rx
# set CONFIG  [dict create C_DATA_DEPTH 8192 C_ADV_TRIGGER True ALL_PROBE_SAME_MU_CNT 4 C_INPUT_PIPE_STAGES 2 C_CLK_PERIOD 8]
# set WIDTHS  [list 1 1 1 1 1]

# create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $MODULE -dir . -force

# set COUNT 0
# foreach WIDTH $WIDTHS {
#     set_property "CONFIG.C_PROBE${COUNT}_WIDTH" $WIDTH [get_ips $MODULE]
#     incr COUNT
# }

# foreach KEY [dict keys $CONFIG] VALUE [dict values $CONFIG] {
#     set_property "CONFIG.$KEY" $VALUE [get_ips $MODULE]
# }

# set_property CONFIG.C_NUM_OF_PROBES [llength $WIDTHS] [get_ips $MODULE]

# generate_target all [get_ips $MODULE] -force
# create_ip_run [get_ips $MODULE] -force
# launch_runs ${MODULE}_synth_1
# wait_on_run ${MODULE}_synth_1

# ## ila_sys

# set MODULE  ila_sys
# set CONFIG  [dict create C_DATA_DEPTH 1024 C_ADV_TRIGGER True ALL_PROBE_SAME_MU_CNT 4 C_INPUT_PIPE_STAGES 2 C_CLK_PERIOD 8]
# set WIDTHS  [list 8 1 1 1 1 1 1 48 48 16 8 1 1 1 1 5 1 16 1]

# create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $MODULE -dir . -force

# set COUNT 0
# foreach WIDTH $WIDTHS {
#     set_property "CONFIG.C_PROBE${COUNT}_WIDTH" $WIDTH [get_ips $MODULE]
#     incr COUNT
# }

# foreach KEY [dict keys $CONFIG] VALUE [dict values $CONFIG] {
#     set_property "CONFIG.$KEY" $VALUE [get_ips $MODULE]
# }

# set_property CONFIG.C_NUM_OF_PROBES [llength $WIDTHS] [get_ips $MODULE]

# generate_target all [get_ips $MODULE] -force
# create_ip_run [get_ips $MODULE] -force
# launch_runs ${MODULE}_synth_1
# wait_on_run ${MODULE}_synth_1

# ## ila_rgmii_tx

# set MODULE  ila_rgmii_tx
# set CONFIG  [dict create C_DATA_DEPTH 1024 C_ADV_TRIGGER True ALL_PROBE_SAME_MU_CNT 4 C_INPUT_PIPE_STAGES 2 C_CLK_PERIOD 8]
# set WIDTHS  [list 8 1 1]

# create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $MODULE -dir . -force

# set COUNT 0
# foreach WIDTH $WIDTHS {
#     set_property "CONFIG.C_PROBE${COUNT}_WIDTH" $WIDTH [get_ips $MODULE]
#     incr COUNT
# }

# foreach KEY [dict keys $CONFIG] VALUE [dict values $CONFIG] {
#     set_property "CONFIG.$KEY" $VALUE [get_ips $MODULE]
# }

# set_property CONFIG.C_NUM_OF_PROBES [llength $WIDTHS] [get_ips $MODULE]

# generate_target all [get_ips $MODULE] -force
# create_ip_run [get_ips $MODULE] -force
# launch_runs ${MODULE}_synth_1
# wait_on_run ${MODULE}_synth_1

## ila_rgmii_rx

set MODULE  ila_rgmii_rx
set CONFIG  [dict create C_DATA_DEPTH 1024 C_ADV_TRIGGER True ALL_PROBE_SAME_MU_CNT 4 C_INPUT_PIPE_STAGES 2 C_CLK_PERIOD 8]
set WIDTHS  [list 8 1 1]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $MODULE -dir . -force

set COUNT 0
foreach WIDTH $WIDTHS {
    set_property "CONFIG.C_PROBE${COUNT}_WIDTH" $WIDTH [get_ips $MODULE]
    incr COUNT
}

foreach KEY [dict keys $CONFIG] VALUE [dict values $CONFIG] {
    set_property "CONFIG.$KEY" $VALUE [get_ips $MODULE]
}

set_property CONFIG.C_NUM_OF_PROBES [llength $WIDTHS] [get_ips $MODULE]

generate_target all [get_ips $MODULE] -force
create_ip_run [get_ips $MODULE] -force
launch_runs ${MODULE}_synth_1
wait_on_run ${MODULE}_synth_1
