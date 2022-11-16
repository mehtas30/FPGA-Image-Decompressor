`include "define_state.h"

module milestone(
	input logic Clock,
	input logic Resetn,
	input logic [15:0] SRAM_read_data,
	input logic m1start,
//outputs
	output logic [17:0] SRAM_address,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n,
	output logic m1end); 

milestone1_state_type m1state;
parameter uaddy= 18'd38400;
parameter yaddy=18'd0;
parameter vaddy=18'd57600;
parameter RGBaddy=18'd146944;

logic[7:0] upeven;
logic[7:0] upodd;
logic[7:0] ubufferodd;
logic[7:0] ubuffereven;

logic[7:0] vpeven;
logic[7:0] vpodd;
logic[7:0] vpbufferodd;
logic[7:0] vpbufferodd;

logic [7:0] un5;
logic [7:0] un3;
logic [7:0] un1;
logic [7:0] up1;
logic [7:0] up3;
logic [7:0] up5;
//math value registers
logic [7:0] vn5;
logic [7:0] vn3;
logic [7:0] vn1;
logic [7:0] vp1;
logic [7:0] vp3;
logic [7:0] vp5;

logic [7:0]ybuff[1:0];

logic [31:0] R;
logic [31:0] G;
logic [31:0] B;

logic [1:0] evenodd;

logic [31:0] op1,op2,op3,op4,op5,op6;
logic [31:0] mult1,mult2,mult3;
logic [63:0] multlong1, multlong2, multlong3;

//logic counter 
//coeffs
parameter signed jnfive= 18'd21;
parameter signed jnthree= -18'd52;
parameter signed jnone= 18'd159;
parameter signed jpone= 18'd159;
parameter signed jpthree= -18'd52;
parameter signed jpfive= 18'd21;

parameter signed a00=18'd76284;
parameter signed a02=18'd104595;
parameter signed a11=-18'd25624;
parameter signed a12=-18'd53281;
parameter signed a21=18'd132251;

assign multlong1=op1*op2;
assign mult1=multlong1[31:0];

assign multlong2=op3*op4;
assign mult2=multlong2[31:0];

assign multlong3=op5*op6;
assign mult3=multlong3[31:0];

always @(posedge Clock or negedge resetn) begin
	if(~resetn)begin
		m1state<=S_IDLE;
		SRAM_address<=18'd0;
		SRAM_write_data<=18'd0;
		SRAM_we_n<=1'b1;
		m1end<=1'b0;
		upeven<=8'd0;
		upodd<=8'd0;
      ubufferodd<=8'd0;
		ubuffereven<=8'd0;

		vpeven<=8'd0;
		vpodd<=8'd0;
		vpbufferodd<=8'd0;
		vpbufferodd<=8'd0;

		un5<=8'd0;
		un3<=8'd0;
		un1<=8'd0;
		up1<=8'd0;
		up3<=8'd0;
		up5<=8'd0;

		vn5<=8'd0;
		vn3<=8'd0;
		vn1<=8'd0;
		vp1<=8'd0;
		vp3<=8'd0;
		vp5<=8'd0;

		ybuff[0]<=8'd0;
		ybuff[1]<=8'd0;

		R<=32'd0;
		G<=32'd0;
		B<=32'd0;

		evenodd<1'b0;//0 is even

		op1<=32'd0;
		op2<=32'd0;
		op3<=32'd0;
		op4<=32'd0;
		op5<=32'd0;
		op6<=32'd0;
	end else begin
end

endmodule
