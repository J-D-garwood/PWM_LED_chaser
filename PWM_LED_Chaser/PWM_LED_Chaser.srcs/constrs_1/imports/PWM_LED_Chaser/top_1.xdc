#######################################################################
## PWM LED chaser + fader -- ALINX AX7A035B (XC7A35T-2FGG484I)
## Part: xc7a35tfgg484-2
## GO THROUGH EACH LINE OF THIS AND MAKE SURE YOU UNDERSTAND WTF IS GOING ON!!!
#######################################################################

## --- Configuration --------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

## --- 200 MHz differential system clock (Bank 34 = 1.5 V) ------------
## 5.000 ns must match localparam CLK_HZ = 200_000_000 in top.v
create_clock -period 5.000 -name sys_clk [get_ports sys_clk_p]
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property PACKAGE_PIN T4 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]

## --- Reset: RESET key, active low, asynchronous to sys_clk ----------
set_property PACKAGE_PIN F15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_false_path -from [get_ports rst_n]

## --- Chaser LEDs: carrier board, Bank 15, LVCMOS33 ------------------
## NOTE: these are ACTIVE LOW (pin driven 0 = LED lit).
set_property PACKAGE_PIN L13 [get_ports led1]
set_property PACKAGE_PIN M13 [get_ports led2]
set_property PACKAGE_PIN K14 [get_ports led3]
set_property PACKAGE_PIN K13 [get_ports led4]
set_property IOSTANDARD LVCMOS33 [get_ports {led1 led2 led3 led4}]

## --- Fader LED: core board W5, Bank 34 = 1.5 V ----------------------
## NOTE: this one is ACTIVE HIGH -- opposite polarity to the four above.
set_property PACKAGE_PIN W5 [get_ports led5]
set_property IOSTANDARD LVCMOS15 [get_ports led5]
