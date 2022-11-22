`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	Milestone1
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [6:0] {
	M1S_IDLE,
	li0, 
	li1,
	li2,
	li3,
	li4,
	li5,
	li6,
	li7,
	li8,
	li9,
	li10,
	li11,
	cc0,
	cc1,
	cc2,
	cc3,
	cc4,
	cc5,
	cc6,
	cc7,
	cc8,
	cc9,
	cc10,
	cc11,
	cc12,
	cc13,
	cc14,
	cc15,
	lo0,
	lo1,
	lo2,
	lo3,
	lo4,
	lo5,
	lo6,
	lo7,
	lo8,
	lo9,
	lo10,
	lo11,
	lo12,
	lo13,
	lo14,
	lo15,
	lo16,
	lo17,
	lo18,
	lo19,
	lo20,
	lo21,
	lo22,
	lo23,
	lo24,
	lo25,
	lo26,
	lo27,
	lo28,
	lo29,
	lo30
} milestone1_state_type;


parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
