# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 10 {OUR STUFF}
add wave -hex UUT/milestone1/m1state
add wave -hex UUT/milestone1/m1state
add wave -hex UUT/milestone1/ucounter
add wave -hex UUT/milestone1/ycounter
add wave -hex UUT/milestone1/vcounter
add wave -hex UUT/milestone1/un5
add wave -hex UUT/milestone1/un3
add wave -hex UUT/milestone1/un1
add wave -hex UUT/milestone1/up1
add wave -hex UUT/milestone1/up3
add wave -hex UUT/milestone1/up5

add wave -hex UUT/milestone1/vn5
add wave -hex UUT/milestone1/vn3
add wave -hex UUT/milestone1/vn1
add wave -hex UUT/milestone1/vp1
add wave -hex UUT/milestone1/vp3
add wave -hex UUT/milestone1/vp5

add wave -hex UUT/milestone1/yn5
add wave -hex UUT/milestone1/yn3
add wave -hex UUT/milestone1/yn1
add wave -hex UUT/milestone1/yp1
add wave -hex UUT/milestone1/yp3
add wave -hex UUT/milestone1/yp5