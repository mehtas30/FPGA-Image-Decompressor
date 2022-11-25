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
add wave -hex UUT/milestone1/ucounter
add wave -hex UUT/milestone1/ycounter
add wave -hex UUT/milestone1/vcounter
add wave -hex UUT/milestone1/ybuff

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
add wave -hex UUT/milestone1/ubufferodd
add wave -hex UUT/milestone1/ubuffereven
add wave -hex UUT/milestone1/upodd
add wave -hex UUT/milestone1/upeven
add wave -hex UUT/milestone1/vbufferodd
add wave -hex UUT/milestone1/vbuffereven
add wave -hex UUT/milestone1/vpodd
add wave -hex UUT/milestone1/vpeven
add wave -hex UUT/milestone1/vbuff
add wave -hex UUT/milestone1/ubuff
add wave -hex UUT/milestone1/pixCount

add wave -divider -height 10 {RGB GOON SQUAD}
add wave -hex UUT/milestone1/rgbcounter
add wave -hex UUT/milestone1/Rout
add wave -hex UUT/milestone1/Gout
add wave -hex UUT/milestone1/Bout
add wave -hex UUT/milestone1/Rc
add wave -hex UUT/milestone1/Gc
add wave -hex UUT/milestone1/Bc
add wave -hex UUT/milestone1/Rbuff
add wave -hex UUT/milestone1/Gbuff
add wave -hex UUT/milestone1/Bbuff
add wave -hex UUT/milestone1/R
add wave -hex UUT/milestone1/G
add wave -hex UUT/milestone1/B
add wave -hex UUT/milestone1/mult3
add wave -hex UUT/milestone1/mult2
add wave -hex UUT/milestone1/mult1

add wave -hex UUT/milestone1/op1
add wave -hex UUT/milestone1/op2
add wave -hex UUT/milestone1/op3
add wave -hex UUT/milestone1/op4
add wave -hex UUT/milestone1/op5
add wave -hex UUT/milestone1/op6

add wave -hex UUT/milestone1/colcounter
