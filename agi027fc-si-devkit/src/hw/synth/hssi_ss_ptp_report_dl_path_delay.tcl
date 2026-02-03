#
# eth_f_ptp_report_dl_path_delay.tcl
#
# Description: This script calls Quartus Timing Analyzer to report routing adjustment that 
# impact PTP timestamp accuracy and then generate routing adjustment report.
# Please refer to User Guide for complete instructions.
#
package require ::quartus::project
package require ::quartus::report
package require ::quartus::sta
package require csv

set project_name [lindex $::quartus(args) 0]

# Open project on Quartus
project_open $project_name

# Always create the netlist first + set operating conditions
create_timing_netlist
read_sdc
update_timing_netlist

set hold_oc  []
set valid_oc []

# To check if a corner is hold-only
foreach_in_collection corner [get_available_operating_conditions] {
    if {[get_operating_conditions_info -is_hold_only $corner]} {
        lappend hold_oc $corner
    } else {
        lappend valid_oc $corner
    }
}

# Defining output filename
    set adv_output_fname    "ptp_hw_adv_adj"
    set adv_data_file       "Data_adv.csv"
    set adv_delay_file      "Delay_adv.csv"
    set basic_output_fname  "ptp_hw_basic_adj"
    set basic_data_file     "Data_basic.csv"
    set basic_delay_file    "Delay_basic.csv"

# Empty files
    close [open $adv_data_file  "w"]
    close [open $adv_delay_file "w"]
    close [open "$adv_output_fname.csv" "w"]
    close [open "$adv_output_fname.tcl" "w"]
    close [open $basic_data_file  "w"]
    close [open $basic_delay_file "w"]
    close [open "$basic_output_fname.csv" "w"]
    close [open "$basic_output_fname.tcl" "w"]

# Obtaining all instance paths with PTP
    set inst_all    []
    set reg_all     [get_registers -nowarn *|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|async_pulse_gen|sclk]

    foreach_in_collection reg $reg_all {
        set regc [get_object_info -name $reg]
        regexp {(.*)\|sip_inst} $regc   full inst
        lappend inst_all $inst
    }

# Obtaining all instance paths with PTP Advanced mode
    set inst_adv    []
    set reg_adv     [get_registers -nowarn *|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].tx_async_dly_meas_u|sclk_return_tod_samp_sync_inst|din_s1]

    foreach_in_collection reg $reg_adv {
        set rega [get_object_info -name $reg]
        regexp {(.*)\|sip_inst} $rega   full inst
        lappend inst_adv $inst
    }

    set unique_inst_all [lsort -unique -dictionary $inst_all]
    set unique_inst_adv [lsort -unique -dictionary $inst_adv]

# Grouping instance paths into two groups: PTP Advanced mode and PTP Basic mode
    set grp_adv     []
    set grp_basic   []

    # If inst for advanced mode is not empty
    if {[llength $unique_inst_adv]} {
        foreach element $unique_inst_adv {
            if {$element in $unique_inst_all} {
                lappend grp_adv $element
            }
        }
        foreach element $unique_inst_all {
            if {$element ni $unique_inst_adv} {
                lappend grp_basic $element
            }
        }
    } else {
        set grp_basic $unique_inst_all
    }

if {[llength $grp_adv]} {
    set adv_ts 1
    post_message -type info "Advanced timestamp accuracy mode is detected."
} else {
    set adv_ts 0
    post_message -type info "No advanced timestamp accuracy mode is detected."
}
if {[llength $grp_basic]} {
    set basic_ts 1
    post_message -type info "Basic timestamp accuracy mode is detected."
} else {
    set basic_ts 0
    post_message -type info "No basic timestamp accuracy mode is detected."
}

# Delete unused files
if {$adv_ts == 0} {
    file delete $adv_data_file
    file delete $adv_delay_file
    file delete "$adv_output_fname.csv"
    file delete "$adv_output_fname.tcl"
}
if {$basic_ts == 0} {
    file delete $basic_data_file
    file delete $basic_delay_file
    file delete "$basic_output_fname.csv"
    file delete "$basic_output_fname.tcl"
}


# Report PTP DL signal path delay
proc report_dl_path {ts hierarchy} {
    set i 0
    foreach hier $hierarchy {
        # Report path TX
            report_path -split_by_corner -npaths 20 -panel_name "TX_X_IP${i}_${ts}" -from ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|async_pulse_gen|sclk -to *|hdpldadapt_tx_chnl_*~rx_clock_pld_sclk.reg
            report_path -split_by_corner -npaths 20 -panel_name "TX_Y_IP${i}_${ts}" -from ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|async_pulse_gen|sclk -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].tx_async_dly_meas_u|sclk_samp_sync_inst|din_s1
            report_path -split_by_corner -npaths 20 -panel_name "TX_A_IP${i}_${ts}" -from *|hdpldadapt_rx_chnl_*|pld_pma_internal_clk1_hioint -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_rollover_lane[*].tx_rollover_cnt|sclk_return_sync_inst|din_s1
            report_path -split_by_corner -npaths 20 -panel_name "TX_B_IP${i}_${ts}" -from *|hdpldadapt_rx_chnl_*|pld_pma_internal_clk1_hioint -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].tx_async_dly_meas_u|sclk_return_samp_sync_inst|din_s1
        if {$ts eq "Advanced"} {
            report_path -split_by_corner -npaths 20 -panel_name "TX_C_IP${i}_${ts}" -from ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_rollover_lane[*].tx_rollover_cnt|gen_sclk_return_roll_tod.sclk_return_roll_reg -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].tx_async_dly_meas_u|sclk_return_tod_samp_sync_inst|din_s1
        }
        # Report path RX
            report_path -split_by_corner -npaths 20 -panel_name "RX_X_IP${i}_${ts}" -from ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|async_pulse_gen|sclk -to *|hdpldadapt_rx_chnl_*~pld_sclk1_rowclk.reg
            report_path -split_by_corner -npaths 20 -panel_name "RX_Y_IP${i}_${ts}" -from ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|async_pulse_gen|sclk -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].rx_async_dly_meas_u|sclk_samp_sync_inst|din_s1
            report_path -split_by_corner -npaths 20 -panel_name "RX_A_IP${i}_${ts}" -from *|hdpldadapt_rx_chnl_*|pld_pma_internal_clk2_hioint -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_rollover_lane[*].rx_rollover_cnt|sclk_return_sync_inst|din_s1
            report_path -split_by_corner -npaths 20 -panel_name "RX_B_IP${i}_${ts}" -from *|hdpldadapt_rx_chnl_*|pld_pma_internal_clk2_hioint -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].rx_async_dly_meas_u|sclk_return_samp_sync_inst|din_s1
        if {$ts eq "Advanced"} {
            report_path -split_by_corner -npaths 20 -panel_name "RX_C_IP${i}_${ts}" -from ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_rollover_lane[*].rx_rollover_cnt|gen_sclk_return_roll_tod.sclk_return_roll_reg -to ${hier}|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_u|gen_async_dly_meas_lane[*].rx_async_dly_meas_u|sclk_return_tod_samp_sync_inst|din_s1
        }
        incr i
    }
}


#----------------------------------------------------------------------------------------------------------
# Extracting targeted data and store in Data.csv
#----------------------------------------------------------------------------------------------------------
# proc search_chnl use for catching chnl[]
# proc search_lane use for catching lane[]

proc search_chnl {path output_file} {
    set raw  [open $output_file a+]
    set tr   [split $path "_"]
    set code [list [lindex $tr 2]]
    
    global valid_oc
    
    # Read data from report in GUI
    foreach oc $valid_oc {
        set oc_name [get_operating_conditions_info $oc -display_name]
        set report  "Timing Analyzer GUI||$path||$path $oc_name||Summary of Paths"
        set num_report_rows [get_number_of_rows -name $report]
        for {set i 1} {$i < $num_report_rows} {incr i} {
            set delay   [get_report_panel_data -name $report -row $i -col 0]
            set to_node [get_report_panel_data -name $report -row $i -col 2]
            regexp {chnl_\d{1,2}} $to_node chnl
            lappend chnls $chnl
            lappend codes $code

            dict set data "${path}_${oc}_${i}__${code}_${chnl}" oc     ${oc}
            dict set data "${path}_${oc}_${i}__${code}_${chnl}" code   ${code}
            dict set data "${path}_${oc}_${i}__${code}_${chnl}" chnl   ${chnl}
            dict set data "${path}_${oc}_${i}__${code}_${chnl}" delay  ${delay}
        }
    }

    set data_unique_codes [lsort -unique -dictionary $codes]
    set data_unique_chnls [lsort -unique -dictionary -decreasing $chnls]

    dict for {id info} $data {
        dict with info {
            foreach c $data_unique_codes {
                foreach ch $data_unique_chnls {
                    if {[string match "$ch" $chnl]} {
                        set index "${c}_${ch}"
                        append delays_per_ch($index) $delay ","
                    }
                }
            }
        }
    }

    # Write to Data.csv
        ## Example: [lindex $tr 0],[lindex $tr 1],[lindex $tr 2],,chnl_<number>,<delay_oc1>,<delay_oc2>,<delay_oc3>,<delay_oc4>,<delay_oc5>,<delay_oc6>
        ##          TX,X,IP0,,chnl_15,1.911,1.920,1.861,1.256,1.397,1.464
    foreach ch $data_unique_chnls {
        set idx "[list [lindex $tr 2]]_${ch}"
        set each_path [string trim [list [lindex $tr 0],[lindex $tr 1],[lindex $tr 2],,$ch,$delays_per_ch($idx)] "{ }"]
        puts $raw [string trimright $each_path ","]
    }
    close $raw
}

proc search_lane {path output_file} {
    set raw [open $output_file a+]
    set tr  [split $path "_"]
    
    global valid_oc
    
    # Read data from report in GUI
    foreach oc $valid_oc {
        set oc_name [get_operating_conditions_info $oc -display_name]
        set report  "Timing Analyzer GUI||$path||$path $oc_name||Summary of Paths"
        set num_report_rows [get_number_of_rows -name $report]
        for {set i 1} {$i < $num_report_rows} {incr i} {
            set delay   [get_report_panel_data -name $report -row $i -col 0]
            set to_node [get_report_panel_data -name $report -row $i -col 2]
            regexp {(.*)\|sip_inst} $to_node   full ip_inst
            regexp {lane\[(\d)\]}   $to_node   lane lane_num
            if {[lindex $tr 1] == "B"} {
                set from_node [get_report_panel_data -name $report -row $i -col 1]
                regexp {chnl_\d{1,2}} $from_node chnl
                lappend chnls $chnl
            }
            lappend insts $ip_inst
            lappend lanes $lane

            dict set data "${path}_${oc}_${i}__${ip_inst}_${lane}" oc       ${oc}
            dict set data "${path}_${oc}_${i}__${ip_inst}_${lane}" ip_inst  ${ip_inst}
            dict set data "${path}_${oc}_${i}__${ip_inst}_${lane}" lane     ${lane}
            dict set data "${path}_${oc}_${i}__${ip_inst}_${lane}" delay    ${delay}
            if {[lindex $tr 1] == "B"} {
                dict set data "${path}_${oc}_${i}__${ip_inst}_${lane}" chnl ${chnl}
            }
        }
    }

    set data_unique_ip_insts [lsort -unique -dictionary $insts]
    set data_num_ip_insts    [llength $data_unique_ip_insts]
    set data_unique_lanes    [lsort -unique -dictionary $lanes]
    set data_num_lanes  [llength $data_unique_lanes]
    if {[lindex $tr 1] == "B"} {
        set data_unique_chnls [lsort -unique -dictionary -decreasing $chnls]
    }
    
    set j 0
    foreach ip $data_unique_ip_insts {
        set k 0
        foreach ln $data_unique_lanes {
            dict for {id info} $data {
                dict with info {
                    if {[string first $ip $ip_inst] != -1} {
                        if {[string first $ln $lane] != -1} {
                            append delays_per_ch([expr $j*$data_num_lanes + $k]) $delay ","
                            set ip_path([expr $j*$data_num_lanes + $k]) $ip
                            if {[lindex $tr 1] == "B"} {
                                set chnl_inst($chnl) "${ip}\*${ln}"
                                set ip_number($chnl) "$j"
                                set ipnum_inst($j)   "$ip"
                                set lanenum_inst($k) "$ln"
                                set inst_lane_value  "$ln\/$chnl"
                            } else {
                                set inst_lane_value  "$ln"
                            }
                            set inst_lane([expr $j*$data_num_lanes + $k]) $inst_lane_value
                        }
                    }
                }
            }
            incr k
        }
        incr j
    }
    
    # Write to Data.csv
        ## Example: [lindex $tr 0],[lindex $tr 1],[lindex $tr 2],IP_INST[i].hw_ip_top|dut|eth_f_0,lane[i],<delay_oc1>,<delay_oc2>,<delay_oc3>,<delay_oc4>,<delay_oc5>,<delay_oc6>
        ##          TX,Y,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.438,0.438,0.437,0.299,0.317,0.346
    for {set index 0}  {$index < [array size delays_per_ch]} {incr index} {
        set each_path [string trim [list [lindex $tr 0],[lindex $tr 1],[lindex $tr 2],$ip_path($index),$inst_lane($index),$delays_per_ch($index)] "{ }"]
        puts $raw [string trimright $each_path ","]
    }
    close $raw
}

proc write_data_csv {ts paths out_file} {
    set i 0
    foreach path $paths {
            search_chnl "TX_X_IP${i}_${ts}" $out_file
            search_lane "TX_Y_IP${i}_${ts}" $out_file
            search_lane "TX_A_IP${i}_${ts}" $out_file
            search_lane "TX_B_IP${i}_${ts}" $out_file
        if {$ts eq "Advanced"} {
            search_lane "TX_C_IP${i}_${ts}" $out_file
        }

            search_chnl "RX_X_IP${i}_${ts}" $out_file
            search_lane "RX_Y_IP${i}_${ts}" $out_file
            search_lane "RX_A_IP${i}_${ts}" $out_file
            search_lane "RX_B_IP${i}_${ts}" $out_file
        if {$ts eq "Advanced"} {
            search_lane "RX_C_IP${i}_${ts}" $out_file
        }
        
        incr i
    }
}

#----------------------------------------------------------------------------------------------------------
# Building Max Path Delay Table in Delay.csv
#----------------------------------------------------------------------------------------------------------
# Catching/selecting targeted data from data.csv then built delay.csv
# Catch expression of TX/RX lane[*]

proc sum {args} {
    set result 0
    foreach n $args {
        set result [expr $result + $n]
    }
    return $result
}

proc min {args} {
    set result 0
    set sorted [lsort -real -increasing $args]
    set result [lindex $sorted 0]
    return $result
}

proc max {args} {
    set result 0
    set sorted [lsort -real -increasing $args]
    set result [lindex $sorted end]
    return $result
}

proc reading_data_csv {ts input_file} {
    global chnl_inst
    global ip_number
    global ipnum_inst
    global num_ip_insts
    global lanenum_inst
    global num_lanes
    global id_chnls
    set lanes    []
    set chnls    []
    set ip_insts []
    set id_chnls []

    set fread  [open $input_file  r]
    set lines  [split [read $fread] "\n"]
    close $fread

    foreach line $lines {
        set lr   [split $line ","]
        set txrx [lindex $lr 0]
        set path [lindex $lr 1]
        set code [lindex $lr 2]
        set inst [lindex $lr 3]
        set lnch [lindex $lr 4]
        
        if {($txrx eq "TX") && ($path eq "B")} {
            regexp {IP(\d*)} $code  full code_id
            set lnchr [split $lnch "/"]
            set lane  [lindex $lnchr 0]
            set chnl  [lindex $lnchr 1]
            lappend lanes $lane
            lappend chnls $chnl
            lappend ip_insts $inst
            set id_chnl "${code}\*${chnl}"
            lappend id_chnls $id_chnl
            set chnl_inst($id_chnl) "${inst}\*${lane}"
            set ip_number($id_chnl) "${code_id}"
        }
    }
    
    set unique_ip_insts [lsort -unique -dictionary $ip_insts]
    set unique_lanes    [lsort -unique -dictionary $lanes]
    set num_ip_insts    [llength $unique_ip_insts]
    set num_lanes       [llength $unique_lanes]

    set j 0
    foreach ip $unique_ip_insts {
        set k 0
        foreach ln $unique_lanes {
            set ipnum_inst($j)   "$ip"
            set lanenum_inst($k) "$ln"
            incr k
        }
        incr j
    }
}
proc write_delay_csv {ts input_file output_file} {
    global avg_tx_adj
    global avg_rx_adj
    global chnl_inst
    global ip_number
    global ipnum_inst
    global num_ip_insts
    global lanenum_inst
    global num_lanes
    global id_chnls
    global valid_oc

    set fwrite [open $output_file w]
    set fread  [open $input_file  r]
    set lines  [split [read $fread] "\n"]
    close $fread

    # Read Data.csv and regroup data according to TX / RX and lanes
        ## Example: lane[0] is grouped to chnl_15
    foreach line $lines {
        foreach id_ch $id_chnls {
            if {[string first "TX," $line] != -1} {
                set id [lindex [split $id_ch "*"] 0]
                set ch [lindex [split $id_ch "*"] 1]
                set ip [lindex [split $chnl_inst($id_ch) "*"] 0]
                set ln [lindex [split $chnl_inst($id_ch) "*"] 1]
                if {([string first "$id," $line] != -1) && ([string first "$ch," $line] != -1)} {
                    append tx($id_ch) $line "\n"
                }
                if {([string first "$ip," $line] != -1) && ([string first "$ln," $line] != -1)} {
                    append tx($id_ch) $line "\n"
                }
            } elseif {[string first "RX," $line ] != -1} {
                set id [lindex [split $id_ch "*"] 0]
                set ch [lindex [split $id_ch "*"] 1]
                set ip [lindex [split $chnl_inst($id_ch) "*"] 0]
                set ln [lindex [split $chnl_inst($id_ch) "*"] 1]
                if {([string first "$id," $line] != -1) && ([string first "$ch," $line] != -1)} {
                    append rx($id_ch) $line "\n"
                }
                if {([string first "$ip," $line] != -1) && ([string first "$ln," $line] != -1)} {
                    append rx($id_ch) $line "\n"
                }
            }
        }
    }

    # Separate paths into X, Y, A ,B ,C arrays
        # Example: $tx($id_ch)                                                                  line_num
        # TX,X,IP0,                                ,chnl_15,2.367,2.376,2.291,1.535,1.712,1.804     0
        # TX,Y,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.438,0.438,0.437,0.299,0.317,0.346     1
        # TX,A,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.987,0.988,0.979,0.755,0.833,0.853     2
        # TX,B,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.899,0.900,0.891,0.656,0.718,0.764     3
        # TX,C,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.411,0.411,0.409,0.279,0.308,0.338     4
    foreach id_ch $id_chnls {
            set tex($id_ch) [split [lindex $tx($id_ch) 0] ","]
            set tey($id_ch) [split [lindex $tx($id_ch) 1] ","]
            set tea($id_ch) [split [lindex $tx($id_ch) 2] ","]
            set teb($id_ch) [split [lindex $tx($id_ch) 3] ","]
        if {$ts eq "Advanced"} {
            set tec($id_ch) [split [lindex $tx($id_ch) 4] ","]
        }
        
            set rex($id_ch) [split [lindex $rx($id_ch) 0] ","]
            set rey($id_ch) [split [lindex $rx($id_ch) 1] ","]
            set rea($id_ch) [split [lindex $rx($id_ch) 2] ","]
            set reb($id_ch) [split [lindex $rx($id_ch) 3] ","]
        if {$ts eq "Advanced"} {
            set rec($id_ch) [split [lindex $rx($id_ch) 4] ","]
        }

        # Calculate TX Routing delay adjustment
        if {$ts eq "Advanced"} {
            # Advanced Timestamp Accuracy Mode: Simplified formula >> Routing delay adjustment = -C-((B+Y-X)/2)+B
            for {set oc_i 5} {$oc_i < [llength $tex($id_ch)]} {incr oc_i} {
                append tx_adj($id_ch) [expr - [lindex $tec($id_ch) $oc_i] - (([lindex $teb($id_ch) $oc_i] + [lindex $tey($id_ch) $oc_i] - [lindex $tex($id_ch) $oc_i])/2) + [lindex $teb($id_ch) $oc_i]] " "
            }
            for {set oc_i 5} {$oc_i < [llength $rex($id_ch)]} {incr oc_i} {
                append rx_adj($id_ch) [expr - [lindex $rec($id_ch) $oc_i] - (([lindex $reb($id_ch) $oc_i] + [lindex $rey($id_ch) $oc_i] - [lindex $rex($id_ch) $oc_i])/2) + [lindex $reb($id_ch) $oc_i]] " "
            }
        } else {
            # Basic Timestamp Accuracy Mode: Simplified formula >> Routing delay adjustment = (X+B-Y)/2 - A
            for {set oc_i 5} {$oc_i < [llength $tex($id_ch)]} {incr oc_i} {
                append tx_adj($id_ch) [expr (([lindex $tex($id_ch) $oc_i]+[lindex $teb($id_ch) $oc_i]-[lindex $tey($id_ch) $oc_i])/2) - [lindex $tea($id_ch) $oc_i]] " "
            }
            for {set oc_i 5} {$oc_i < [llength $rex($id_ch)]} {incr oc_i} {
                append rx_adj($id_ch) [expr (([lindex $rex($id_ch) $oc_i]+[lindex $reb($id_ch) $oc_i]-[lindex $rey($id_ch) $oc_i])/2) - [lindex $rea($id_ch) $oc_i]] " "
            }
        }
    }

    # Write Delay.csv
    # Example:
        ## Max Path Delay Table [0]
        ## TX/RX,Path,Code,Instance,Lane/Chnl,Slow vid2 100C Model,Slow vid2a 100C Model,Slow vid2b 100C Model,Fast vid2a 0C Model,Fast vid2a 100C Model,Fast vid2 100C Model,,Mean
        ## TX,X,IP0,,chnl_15,2.367,2.376,2.291,1.535,1.712,1.804
        ## TX,Y,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.438,0.438,0.437,0.299,0.317,0.346
        ## TX,A,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.987,0.988,0.979,0.755,0.833,0.853
        ## TX,B,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.899,0.900,0.891,0.656,0.718,0.764
        ## TX,C,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.411,0.411,0.409,0.279,0.308,0.338
        ##
        ## RX,X,IP0,,chnl_15,2.287,2.287,2.201,1.481,1.655,1.748
        ## RX,Y,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.386,0.386,0.384,0.278,0.292,0.293
        ## RX,A,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.811,0.811,0.803,0.603,0.665,0.705
        ## RX,B,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],1.152,1.152,1.144,0.882,0.985,1.027
        ## RX,C,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.461,0.461,0.460,0.347,0.373,0.374
        ##
        ## TX,Routing delay adjustment,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.926,0.93,0.8905,0.569,0.6465,0.685,,0.7745
        ## RX,Routing delay adjustment,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],0.8355,0.8355,0.7965,0.5075,0.562,0.588,,0.6875
    
    foreach oc $valid_oc {
        append oc_names [get_operating_conditions_info $oc -display_name] ","
    }
    set header [string trim [list TX/RX,Path,Code,Instance,Lane/Chnl,$oc_names,Mean] "{ }"]

    # Example: <TX/RX>,Routing delay adjustment,IP0,IP_INST[0].hw_ip_top|dut|eth_f_0,lane[0],<list of TX/RX Routing delay adjustment values>,<Mean TX/RX Routing delay adjustment value>
    set i 0
    foreach id_ch $id_chnls {
        # Mean TX/RX Routing delay adjustment
        set avg_tx_adj($id_ch) [expr ([eval max $tx_adj($id_ch)] + [eval min $tx_adj($id_ch)])/ 2]
        set avg_rx_adj($id_ch) [expr ([eval max $rx_adj($id_ch)] + [eval min $rx_adj($id_ch)])/ 2]
        
        set tx_line($id_ch) [string trim [list TX,adjustment,IP$ip_number($id_ch),[lindex $tey($id_ch) 3],[lindex $tey($id_ch) 4],[regsub -all " " $tx_adj($id_ch) ","],$avg_tx_adj($id_ch)] "{ }"]
        set rx_line($id_ch) [string trim [list RX,adjustment,IP$ip_number($id_ch),[lindex $tey($id_ch) 3],[lindex $tey($id_ch) 4],[regsub -all " " $rx_adj($id_ch) ","],$avg_rx_adj($id_ch)] "{ }"]
        
        puts $fwrite "Max Path Delay Table \[$i\]"
        puts $fwrite $header
        puts $fwrite $tx($id_ch)
        puts $fwrite $rx($id_ch)
        puts $fwrite $tx_line($id_ch)
        puts $fwrite $rx_line($id_ch)
        puts $fwrite "\n"
        incr i
    }

    # Display calculated Routing delay adjustment value in Quartus
        ## Example:
        ## Advanced Timestamp Accuracy Mode:
        ## PTP DL Path Routing Routing delay adjustment Summary:
        ## Mean TX Routing delay adjustment for IP_INST[0].hw_ip_top|dut|eth_f_0 lane[0] = 0.7745 ns
        ## Mean RX Routing delay adjustment for IP_INST[0].hw_ip_top|dut|eth_f_0 lane[0] = 0.6875 ns
    post_message -type info "${ts} Timestamp Accuracy Mode:"
    post_message -type info "PTP DL Path Routing delay adjustment Summary:"
    for {set i 0} {$i < $num_ip_insts} {incr i} {
        for {set j 0} {$j < $num_lanes} {incr j} {
            foreach id_ch $id_chnls {
                if {[string first "$ipnum_inst($i)\*$lanenum_inst($j)" $chnl_inst($id_ch)] != -1} {
                    post_message -type info "Mean TX Routing delay adjustment for $ipnum_inst($i) $lanenum_inst($j) = $avg_tx_adj($id_ch) ns"
                }
            }
        }
        for {set k 0} {$k < $num_lanes} {incr k} {
            foreach id_ch $id_chnls {
                if {[string first "$ipnum_inst($i)\*$lanenum_inst($k)" $chnl_inst($id_ch)] != -1} {
                    post_message -type info "Mean RX Routing delay adjustment for $ipnum_inst($i) $lanenum_inst($k) = $avg_rx_adj($id_ch) ns"
                }
            }
        }
    }
    close $fwrite
}

#----------------------------------------------------------------------------------------------------------
# Building Mean Routing Delay Adjustment Table in Adjustment.csv
#----------------------------------------------------------------------------------------------------------
# Printing Mean routing delay adjustment for each lane in CSV format

proc write_adj_csv {filename} {
    global avg_tx_adj
    global avg_rx_adj
    global chnl_inst
    global ip_number
    global ipnum_inst
    global num_ip_insts
    global lanenum_inst
    global num_lanes
    global id_chnls
    set fwrite [open $filename.csv w]
    set port_no []

    puts $fwrite "Mean Routing Delay Adjustment Table"
    puts $fwrite "Instance Name,Instance,Lane,Mean Routing Delay Adjustment (ns)"

    # Example: IP_INST[0].hw_ip_top|dut|eth_f_0,IP0,TX0,0.7745
    #          IP_INST[0].hw_ip_top|dut|eth_f_0,IP0,RX0,0.6875
    for {set i 0} {$i < $num_ip_insts} {incr i} {
        set inputString $ipnum_inst($i)
        regexp {eth_f_top_p\d{1,2}} $inputString value
        regexp {\d{1,2}} $value p_no
        if {$p_no in $port_no} {
            lappend port_no [expr $p_no+20]
            set inst_num [expr $p_no+20]
        } else {
            lappend port_no [expr $p_no]
            set inst_num $p_no
        }
        for {set j 0} {$j < $num_lanes} {incr j} {
            foreach id_ch $id_chnls {
                if {[string first "$ipnum_inst($i)\*$lanenum_inst($j)" $chnl_inst($id_ch)] != -1} {
                    regexp {\d{1,2}} $lanenum_inst($j) lane_num
                    set tx_line($id_ch) "$ipnum_inst($i),IP${inst_num},TX${lane_num},$avg_tx_adj($id_ch)"
                    puts $fwrite $tx_line($id_ch)
                }
            }
        }
        for {set k 0} {$k < $num_lanes} {incr k} {
            foreach id_ch $id_chnls {
                if {[string first "$ipnum_inst($i)\*$lanenum_inst($k)" $chnl_inst($id_ch)] != -1} {
                    regexp {\d{1,2}} $lanenum_inst($k) lane_num
                    set rx_line($id_ch) "$ipnum_inst($i),IP${inst_num},RX${lane_num},$avg_rx_adj($id_ch)"
                    puts $fwrite $rx_line($id_ch)
                }
            }
        }
    }
    close $fwrite
}

#----------------------------------------------------------------------------------------------------------
# Building Mean Routing Delay Adjustment TCL script for Hardware in hw_adjustment.tcl
#----------------------------------------------------------------------------------------------------------
# Printing Mean routing delay adjustment for each lane in TCL format

proc write_adj_tcl {filename} {
    global avg_tx_adj
    global avg_rx_adj
    global chnl_inst
    global ip_number
    global ipnum_inst
    global num_ip_insts
    global lanenum_inst
    global num_lanes
    global id_chnls
    set fwrite [open $filename.tcl w]
    set port_no []

    puts $fwrite "# Mean Routing Delay Adjustment (ns)"

    # Example:  # IP0: IP_INST[0].hw_ip_top|dut|eth_f_0
    #           set IP0_TX0_ROUTING_ADJ 0.7745
    #           set IP0_RX0_ROUTING_ADJ 0.6875
    for {set i 0} {$i < $num_ip_insts} {incr i} {
        puts $fwrite "# IP$i: $ipnum_inst($i)"
        set inputString $ipnum_inst($i)
        regexp {eth_f_top_p\d{1,2}} $inputString value
        regexp {\d{1,2}} $value p_no
        if {$p_no in $port_no} {
            lappend port_no [expr $p_no+20]
            set inst_num [expr $p_no+20]
        } else {
            lappend port_no [expr $p_no]
            set inst_num $p_no
        }
        
        #puts "inst_num: $inst_num"
        for {set j 0} {$j < $num_lanes} {incr j} {
            foreach id_ch $id_chnls {
                if {[string first "$ipnum_inst($i)\*$lanenum_inst($j)" $chnl_inst($id_ch)] != -1} {
                    regexp {\d{1,2}} $lanenum_inst($j) lane_num
                    set tx_var "IP${inst_num}_TX${lane_num}_ROUTING_ADJ"
                    set tx_line($id_ch) "set $tx_var $avg_tx_adj($id_ch)"
                    puts $fwrite $tx_line($id_ch)
                }
            }
        }
        for {set k 0} {$k < $num_lanes} {incr k} {
            foreach id_ch $id_chnls {
                if {[string first "$ipnum_inst($i)\*$lanenum_inst($k)" $chnl_inst($id_ch)] != -1} {
                    regexp {\d{1,2}} $lanenum_inst($k) lane_num
                    set rx_var "IP${inst_num}_RX${lane_num}_ROUTING_ADJ"
                    set rx_line($id_ch) "set $rx_var $avg_rx_adj($id_ch)"
                    puts $fwrite $rx_line($id_ch)
                }
            }
        }
    }
    close $fwrite
}


# Execute procs
if {$adv_ts == 1} {
    report_dl_path   "Advanced" $grp_adv
    load_package report
    load_report
    write_data_csv   "Advanced" $grp_adv $adv_data_file
    reading_data_csv "Advanced" $adv_data_file
    write_delay_csv  "Advanced" $adv_data_file $adv_delay_file
    write_adj_csv    $adv_output_fname
    write_adj_tcl    $adv_output_fname
}
if {$basic_ts == 1} {
    report_dl_path   "Basic" $grp_basic
    load_package report
    load_report
    write_data_csv   "Basic" $grp_basic $basic_data_file
    reading_data_csv "Basic" $basic_data_file
    write_delay_csv  "Basic" $basic_data_file $basic_delay_file
    write_adj_csv    $basic_output_fname
    write_adj_tcl    $basic_output_fname
}

# Error checking, number of rows should be equal
if {$adv_ts == 1} {
    set n1 [get_number_of_rows -name "Timing Analyzer GUI||TX_X_IP0_Advanced||TX_X_IP0_Advanced Aggregated Report||Summary of Paths"]
    set n2 [get_number_of_rows -name "Timing Analyzer GUI||RX_B_IP0_Advanced||RX_B_IP0_Advanced Aggregated Report||Summary of Paths"]
    if {$n1 != $n2} {
        post_message -type warning "Number of rows for reported TX/RX paths not equal"
    }
}
if {$basic_ts == 1} {
    set n3 [get_number_of_rows -name "Timing Analyzer GUI||TX_X_IP0_Basic||TX_X_IP0_Basic Aggregated Report||Summary of Paths"]
    set n4 [get_number_of_rows -name "Timing Analyzer GUI||RX_B_IP0_Basic||RX_B_IP0_Basic Aggregated Report||Summary of Paths"]
    if {$n3 != $n4} {
        post_message -type warning "Number of rows for reported TX/RX paths not equal"
    }
}

# Finish - unload report and close project
unload_report
project_close
