## top_edge_detection.xdc - 博宸精芯 ZYNQ_MINI (XC7Z010clg400-1)
## 注意: 以下管脚为模板, 请按你板子的原理图逐一核对修改.

## 板载时钟 (按原理图改, 常见 50/100MHz)
set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVCMOS33} [get_ports clk_board];
create_clock -name clk_board -period 10.000 [get_ports clk_board];

## 复位按键
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports rst_n];

## DVP 摄像头
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports cam_pclk];
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports cam_vsync];
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports cam_href];
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports cam_data[0]];
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports cam_data[1]];
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports cam_data[2]];
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports cam_data[3]];
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33} [get_ports cam_data[4]];
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports cam_data[5]];
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33} [get_ports cam_data[6]];
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports cam_data[7]];
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports cam_xclk];
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports cam_scl];
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports cam_sda];

## HDMI TMDS
set_property -dict {PACKAGE_PIN D11 IOSTANDARD TMDS_33} [get_ports hdmi_clk_p];
set_property -dict {PACKAGE_PIN D12 IOSTANDARD TMDS_33} [get_ports hdmi_clk_n];
set_property -dict {PACKAGE_PIN C11 IOSTANDARD TMDS_33} [get_ports hdmi_d0_p];
set_property -dict {PACKAGE_PIN C12 IOSTANDARD TMDS_33} [get_ports hdmi_d0_n];
set_property -dict {PACKAGE_PIN A10 IOSTANDARD TMDS_33} [get_ports hdmi_d1_p];
set_property -dict {PACKAGE_PIN A11 IOSTANDARD TMDS_33} [get_ports hdmi_d1_n];
set_property -dict {PACKAGE_PIN B10 IOSTANDARD TMDS_33} [get_ports hdmi_d2_p];
set_property -dict {PACKAGE_PIN B11 IOSTANDARD TMDS_33} [get_ports hdmi_d2_n];

## 阈值拨码开关
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports threshold_sw[0]];
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports threshold_sw[1]];
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports threshold_sw[2]];
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports threshold_sw[3]];
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports threshold_sw[4]];
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports threshold_sw[5]];
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports threshold_sw[6]];
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports threshold_sw[7]];

set_false_path -from [get_clocks -include_generated_clocks [get_ports cam_pclk]] \
                -to   [get_clocks -include_generated_clocks [get_pins -hierarchical *clk_wiz*/clk_out1]];
