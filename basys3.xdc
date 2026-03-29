## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]


#VGA Connector
set_property PACKAGE_PIN G19 [get_ports {vgaRGB[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRGB[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRGB[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRGB[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[3]}]
set_property PACKAGE_PIN N18 [get_ports {vgaRGB[4]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[4]}]
set_property PACKAGE_PIN L18 [get_ports {vgaRGB[5]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[5]}]
set_property PACKAGE_PIN K18 [get_ports {vgaRGB[6]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[6]}]
set_property PACKAGE_PIN J18 [get_ports {vgaRGB[7]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[7]}]
set_property PACKAGE_PIN J17 [get_ports {vgaRGB[8]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[8]}]
set_property PACKAGE_PIN H17 [get_ports {vgaRGB[9]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[9]}]
set_property PACKAGE_PIN G17 [get_ports {vgaRGB[10]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[10]}]
set_property PACKAGE_PIN D17 [get_ports {vgaRGB[11]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRGB[11]}]
set_property PACKAGE_PIN P19 [get_ports HS]						
	set_property IOSTANDARD LVCMOS33 [get_ports HS]
set_property PACKAGE_PIN R19 [get_ports VS]						
	set_property IOSTANDARD LVCMOS33 [get_ports VS]
	
	
set_property PACKAGE_PIN U18 [get_ports BTNC]						
	set_property IOSTANDARD LVCMOS33 [get_ports BTNC]
set_property PACKAGE_PIN W19 [get_ports BTNL]						
	set_property IOSTANDARD LVCMOS33 [get_ports BTNL]
set_property PACKAGE_PIN T17 [get_ports BTNR]						
	set_property IOSTANDARD LVCMOS33 [get_ports BTNR]




