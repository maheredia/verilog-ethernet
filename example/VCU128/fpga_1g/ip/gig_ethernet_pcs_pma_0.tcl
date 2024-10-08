
create_ip -name gig_ethernet_pcs_pma -vendor xilinx.com -library ip -module_name gig_ethernet_pcs_pma_0

set_property -dict [list \
    CONFIG.Standard {SGMII} \
    CONFIG.Physical_Interface {LVDS} \
    CONFIG.Management_Interface {false} \
    CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
    CONFIG.LvdsRefClk {625} \
    CONFIG.TxLane0_Placement {DIFF_PAIR_1} \
    CONFIG.RxLane0_Placement {DIFF_PAIR_2} \
    CONFIG.Tx_In_Upper_Nibble {1} \
    CONFIG.InstantiateBitslice0 {TRUE} \
    CONFIG.RxNibbleBitslice0Used {FALSE} \
] [get_ips gig_ethernet_pcs_pma_0]
