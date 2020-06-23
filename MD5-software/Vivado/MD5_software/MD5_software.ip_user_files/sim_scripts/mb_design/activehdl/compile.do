vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/microblaze_v11_0_2
vlib activehdl/xil_defaultlib
vlib activehdl/lmb_v10_v3_0_10
vlib activehdl/lmb_bram_if_cntlr_v4_0_17
vlib activehdl/axi_lite_ipif_v3_0_4
vlib activehdl/axi_intc_v4_1_14
vlib activehdl/xlconcat_v2_1_3
vlib activehdl/mdm_v3_2_17
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/proc_sys_reset_v5_0_13
vlib activehdl/interrupt_control_v3_1_4
vlib activehdl/axi_gpio_v2_0_22
vlib activehdl/lib_pkg_v1_0_2
vlib activehdl/lib_srl_fifo_v1_0_2
vlib activehdl/axi_uartlite_v2_0_24
vlib activehdl/axi_timer_v2_0_22
vlib activehdl/fit_timer_v2_0_10

vmap xpm activehdl/xpm
vmap microblaze_v11_0_2 activehdl/microblaze_v11_0_2
vmap xil_defaultlib activehdl/xil_defaultlib
vmap lmb_v10_v3_0_10 activehdl/lmb_v10_v3_0_10
vmap lmb_bram_if_cntlr_v4_0_17 activehdl/lmb_bram_if_cntlr_v4_0_17
vmap axi_lite_ipif_v3_0_4 activehdl/axi_lite_ipif_v3_0_4
vmap axi_intc_v4_1_14 activehdl/axi_intc_v4_1_14
vmap xlconcat_v2_1_3 activehdl/xlconcat_v2_1_3
vmap mdm_v3_2_17 activehdl/mdm_v3_2_17
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13
vmap interrupt_control_v3_1_4 activehdl/interrupt_control_v3_1_4
vmap axi_gpio_v2_0_22 activehdl/axi_gpio_v2_0_22
vmap lib_pkg_v1_0_2 activehdl/lib_pkg_v1_0_2
vmap lib_srl_fifo_v1_0_2 activehdl/lib_srl_fifo_v1_0_2
vmap axi_uartlite_v2_0_24 activehdl/axi_uartlite_v2_0_24
vmap axi_timer_v2_0_22 activehdl/axi_timer_v2_0_22
vmap fit_timer_v2_0_10 activehdl/fit_timer_v2_0_10

vlog -work xpm  -sv2k12 "+incdir+../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/ec67/hdl" "+incdir+../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/4fba" \
"C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_2 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/f871/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_microblaze_0_0/sim/mb_design_microblaze_0_0.vhd" \

vcom -work lmb_v10_v3_0_10 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/2e88/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_dlmb_v10_0/sim/mb_design_dlmb_v10_0.vhd" \
"../../../bd/mb_design/ip/mb_design_ilmb_v10_0/sim/mb_design_ilmb_v10_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_17 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/db6f/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_dlmb_bram_if_cntlr_0/sim/mb_design_dlmb_bram_if_cntlr_0.vhd" \
"../../../bd/mb_design/ip/mb_design_ilmb_bram_if_cntlr_0/sim/mb_design_ilmb_bram_if_cntlr_0.vhd" \
"../../../bd/mb_design/ip/mb_design_lmb_bram_0/mb_design_lmb_bram_0_sim_netlist.vhdl" \
"../../../bd/mb_design/ip/mb_design_xbar_0/mb_design_xbar_0_sim_netlist.vhdl" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work axi_intc_v4_1_14 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/f78a/hdl/axi_intc_v4_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_microblaze_0_axi_intc_0/sim/mb_design_microblaze_0_axi_intc_0.vhd" \

vlog -work xlconcat_v2_1_3  -v2k5 "+incdir+../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/ec67/hdl" "+incdir+../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/4fba" \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/ec67/hdl" "+incdir+../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/4fba" \
"../../../bd/mb_design/ip/mb_design_microblaze_0_xlconcat_0/sim/mb_design_microblaze_0_xlconcat_0.v" \

vcom -work mdm_v3_2_17 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/f9aa/hdl/mdm_v3_2_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_mdm_1_0/sim/mb_design_mdm_1_0.vhd" \
"../../../bd/mb_design/ip/mb_design_clk_wiz_1_0/mb_design_clk_wiz_1_0_sim_netlist.vhdl" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_rst_clk_wiz_1_100M_0/sim/mb_design_rst_clk_wiz_1_100M_0.vhd" \

vcom -work interrupt_control_v3_1_4 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_22 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/f71e/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_axi_gpio_0_0/sim/mb_design_axi_gpio_0_0.vhd" \
"../../../bd/mb_design/ip/mb_design_axi_gpio_1_0/sim/mb_design_axi_gpio_1_0.vhd" \
"../../../bd/mb_design/ip/mb_design_axi_gpio_2_0/sim/mb_design_axi_gpio_2_0.vhd" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_uartlite_v2_0_24 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/d8db/hdl/axi_uartlite_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_axi_uartlite_0_0/sim/mb_design_axi_uartlite_0_0.vhd" \

vcom -work axi_timer_v2_0_22 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/a141/hdl/axi_timer_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_axi_timer_0_0/sim/mb_design_axi_timer_0_0.vhd" \

vcom -work fit_timer_v2_0_10 -93 \
"../../../../../Trab5/Vivado/CountDownTimerProj5_p4/CountDownTimerProj5_p4.srcs/sources_1/bd/mb_design/ipshared/e81b/hdl/fit_timer_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/mb_design/ip/mb_design_fit_timer_0_0/sim/mb_design_fit_timer_0_0.vhd" \
"../../../bd/mb_design/sim/mb_design.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

