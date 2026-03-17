# Define a 100 MHz system clock (10ns period) tied to the 'clk' input port
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]