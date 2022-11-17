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
logic[7:0] vpbuffereven;

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
logic [17:0] ucounter;
logic [17:0] vcounter;
logic [17:0] ycounter;
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
		SRAM_address<=18'd0;
		SRAM_write_data<=18'd0;
		SRAM_we_n<=1'b1;
		m1end<=1'b0;
		upeven<=8'd0;
		upodd<=8'd0;
      ubufferodd<=8'd0;
		ubuffereven<=8'd0;
		ucounter<=18'd0;
		vcounter<=18'd0;
		ycounter<=18'd0;
		vpeven<=8'd0;
		vpodd<=8'd0;
		vpbufferodd<=8'd0;
		vpbuffereven<=8'd0;

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
		m1state<=S_IDLE;
	end else begin
		case(m1state)
			S_IDLE:begin
					SRAM_address <= uaddy;//uou1
					ucounter<= 18'd1;
					m1state <= li0;
					SRAM_write_data<=18'd0;
					SRAM_we_n<=1'b1;
					m1end<=1'b0;
					upeven<=8'd0;
					upodd<=8'd0;
					ucounter<=18'd0;
					vcounter<=18'd0;
					ycounter<=18'd0;
					ubufferodd<=8'd0;
					ubuffereven<=8'd0;
					
					vpeven<=8'd0;
					vpodd<=8'd0;
					vpbufferodd<=8'd0;
					vpbuffereven<=8'd0;
					
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
					m1state <= li0;
			end
			li0:begin
				SRAM_address <= vaddy; //v0v1
				vcounter <= vcounter + 18'd1;
				m1state <= li1;
			end
			li1:begin 
				SRAM_address <= uaddy + ucounter; //u2u3
				ucounter<= ucounter + 18'd1;
				m1state <= li2;
			end 
			li2:begin
				SRAM_address <= vaddy + vcounter; //v2v3
				vcounter <= vcounter + 18'd1;
				//reading u0u1
				un5<=SRAM_read_data[7:0];
				un3<=SRAM_read_data[7:0];
				un1<=SRAM_read_data[7:0];
				up1<=SRAM_read_data[7:0];
				up3<=SRAM_read_data[7:0];
				up5<=SRAM_read_data[15:8];
				upeven <= SRAM_read_data[7:0];//u0
				op1<= SRAM_read_data[7:0]; //u0
				op2 <= jn5;
				m1state <= li3;
			end
			li3:begin
				SRAM_address <= yaddy;//y0y1
				//reading v0v1
				ycounter<= ycounter + 18'd1;
				vn5<=SRAM_read_data[7:0];
				vn3<=SRAM_read_data[7:0];
				vn1<=SRAM_read_data[7:0];
				vp1<=SRAM_read_data[7:0];
				vp3<=SRAM_read_data[7:0];
				vp5<=SRAM_read_data[15:8];
				vpeven <= SRAM_read_data[7:0];//v0
				upodd <= upodd+mult1; //jn5
				op1<= un3; //u0
				op2 <= jn3;
				op3<= SRAM_read_data[7:0];//v0
				op4<=jn5;
				m1state <= li4;				
			end
			li4:begin
				//reading u2u3
				up1<=up5;
				up3<=SRAM_read_data[7:0];
				up5<=SRAM_read_data[15:8];
				upodd <= upodd+mult1;//jn5+jn3
				vpodd<=vpodd+mult2;//jn5
				ubuffereven <= upeven;//u0
				op1<=un1;//u0
				op2<=jn1;
				op3<=vn3;//v0
				op4<=jn3;
				m1state <= li5;
			end
			li5:begin
				upodd <= upodd + mult1;//j5+j3+j1
				vpodd <= vpodd + mult2;//j5+j3
				vp1<=vp5;//v1
				vp3<=SRAM_read_data[7:0];//v2v3
				vp5<=SRAM_read_data[15:8];
				op1<=up1;//u1
				op2<=jp1;
				op3<=vn1;//v0
				op4<=jn1;
				vbuffereven<=vpeven;
				m1state <= li6;
			end
			li6:begin
				upodd <= upodd + mult1;//j5+j3+j1+j1
				vpodd <= vpodd + mult2;//j5+j3+j1
				SRAM_read_data[15:8];
				ybuff[0]<=SRAM_read_data[7:0];
				ybuff[1]<=SRAM_read_data[15:8];
				op1<=up3;//u2
				op2<=jp3;
				op3<=vp1;//v1
				op4<=jp1;
				m1state <= li7;
			end
			li7:begin
				upodd <= upodd + mult1;//j5+j3+j1+j1+j3
				vpodd <= vpodd + mult2;//j5+j3+j1+j1
				op1<=up5;//u2
				op2<=jp5;
				op3<=vp3;//v3
				op4<=jp3;
				op5 <= a00; 
				op6<=	ybuff[0];
				m1state <= li8;
			end
			li8:begin
				upodd <= (upodd + mult1 + 18'd128)>>>8;//j5+j3+j1+j1+j3+j5
				vpodd <= vpodd + mult2;//j5+j3+j1+j1+j3
				op3<=vp5;//v5
				op4<=jp5;
				R<=mult3;//A00
				G<=mult3;
				B<=mult3;
				op5 <= a02; 
				op6<=	ubuffereven;
				m1state <= li9;
			end
			li9:begin
				vpodd <= (vpodd + mult2 + 18'd128) >>> 8;//j5+j3+j1+j1+j3+j5
				R<=R+mult3;//A02
				op5 <= a21; 
				op6<=	ubuffereven;
				m1state <= li10;
			end
			li10:begin
				SRAM_address <= uaddy + ucounter; //u4u5
				ucounter<= ucounter + 18'd1;
				B<=B+mult3;
				op5 <= a11; 
				op6<=	ubuffereven;
				m1state <= li11;
			end
			li11:begin
				SRAM_address <= vaddy + vcounter; //u4u5
				vcounter<= vcounter + 18'd1;
				G<=G+mult3;
				op5 <= a12; 
				op6<=	vbuffereven;
				m1state <= li12;
			end
			li12:begin
				G<=G+mult3;
				op1 <= a12; 
				op6<=	vbuffereven;
			end

			
		endcase
end

endmodule
