`include "define_state.h"
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

module milestone(
	input logic Clock,
	input logic resetn,
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

logic[31:0] upeven;
logic[31:0] upodd;
logic[31:0] ubufferodd;
logic[31:0] ubuffereven;

logic[31:0] vpeven;
logic[31:0] vpodd;
logic[31:0] vbufferodd;
logic[31:0] vbuffereven;

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

logic [31:0]ybuff[3:0];
logic [31:0]ubuff[1:0];
logic [31:0]vbuff[1:0];

logic [31:0] R;//calcs
logic [31:0] G;
logic [31:0] B;

logic [31:0] Rbuff; //hold
logic [31:0] Gbuff;
logic [31:0] Bbuff;

logic [7:0] Rc;//clip
logic [7:0] Bc;
logic [7:0] Gc;
//GETOUT 
logic [7:0] Rout;
logic [7:0] Bout;
logic [7:0] Gout;


logic [1:0] evenodd;

logic signed [31:0] op1,op2,op3,op4,op5,op6;
logic signed [31:0] mult1,mult2,mult3;
logic signed [63:0] multlong1, multlong2, multlong3;

//logic counter 
logic [17:0] ucounter;
logic [17:0] vcounter;
logic [17:0] ycounter;
logic [17:0] rgbcounter;
//coeffs
parameter signed jn5= 32'd21;
parameter signed jn3= -32'd52;
parameter signed jn1= 32'd159;
parameter signed jp1= 32'd159;
parameter signed jp3= -32'd52;
parameter signed jp5= 32'd21;

parameter signed a00=32'd76284;
parameter signed a02=32'd104595;
parameter signed a11=-32'd25624;
parameter signed a12=-32'd53281;
parameter signed a21=32'd132251;

assign multlong1=op1*op2;
assign mult1=multlong1[31:0];

assign multlong2=op3*op4;
assign mult2=multlong2[31:0];

assign multlong3=op5*op6;
assign mult3=multlong3[31:0];

assign Rc=(Rbuff[31]==1'b1)?8'd0:((Rbuff[31:24]>=8'd1)?8'd255:Rbuff[23:16]);
assign Bc=(Bbuff[31]==1'b1)?8'd0:((Bbuff[31:24]>=8'd1)?8'd255:Bbuff[23:16]);
assign Gc=(Gbuff[31]==1'b1)?8'd0:((Gbuff[31:24]>=8'd1)?8'd255:Gbuff[23:16]);

always @(posedge Clock or negedge resetn) begin
	if(~resetn)begin
		SRAM_address<=18'd0;
		SRAM_write_data<=18'd0;
		SRAM_we_n<=1'b1;
		m1end<=1'b0;
		upeven<=32'd0;
		upodd<=32'd0;
      ubufferodd<=32'd0;
		ubuffereven<=32'd0;
		ucounter<=18'd0;
		vcounter<=18'd0;
		ycounter<=18'd0;
		vpeven<=32'd0;
		vpodd<=32'd0;
		vbufferodd<=32'd0;
		vbuffereven<=32'd0;

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

		ybuff[0]<=32'd0;
		ybuff[1]<=32'd0;
		ybuff[2]<=32'd0;
		ybuff[3]<=32'd0;
		ubuff[0]<=32'd0;
		ubuff[1]<=32'd0;
		vbuff[0]<=32'd0;
		vbuff[1]<=32'd0;
		

		R<=32'd0;
		G<=32'd0;
		B<=32'd0;

		Rbuff<=32'd0;
		Gbuff<=32'd0;
		Bbuff<=32'd0;

		Rout<=8'd0;
		Bout<=8'd0;
		Gout<=8'd0;
		
		evenodd<=1'b0;//0 is even

		op1<=32'd0;
		op2<=32'd0;
		op3<=32'd0;
		op4<=32'd0;
		op5<=32'd0;
		op6<=32'd0;
		rgbcounter<=18'd0;
		m1state<=M1S_IDLE;
	end else begin
		case(m1state)
			M1S_IDLE:begin
					if (m1start==1'b1) begin
					//address set to u0u1
					SRAM_address <= uaddy;
					ucounter<= 18'd0;
					m1state <= li0;
					SRAM_write_data<=18'd0;
					SRAM_we_n<=1'b1;
					m1end<=1'b0;
					upeven<=32'd0;
					upodd<=32'd0;
					ucounter<=18'd0;
					vcounter<=18'd0;
					ycounter<=18'd0;
					ubufferodd<=32'd0;
					ubuffereven<=32'd0;
					
					vpeven<=32'd0;
					vpodd<=32'd0;
					vbufferodd<=32'd0;
					vbuffereven<=32'd0;
					
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
					
					ybuff[0]<=32'd0;
					ybuff[1]<=32'd0;
					ybuff[2]<=32'd0;
					ybuff[3]<=32'd0;
					
					R<=32'd0;
					G<=32'd0;
					B<=32'd0;
					
					Rbuff<=32'd0;
					Gbuff<=32'd0;
					Bbuff<=32'd0;

					Rout<=8'd0;
					Bout<=8'd0;
					Gout<=8'd0;					
					
					evenodd<=1'b0;//0 is even
					
					op1<=32'd0;
					op2<=32'd0;
					op3<=32'd0;
					op4<=32'd0;
					op5<=32'd0;
					op6<=32'd0;
					rgbcounter<=18'd0;
					m1state <= li0;
					end
			end
			li0:begin
				//address set to v0v1
				SRAM_we_n <= 1'b1;
				SRAM_address <= vaddy; 
				vcounter <= vcounter + 18'd1;
				ucounter<= ucounter + 18'd1;
				m1state <= li1;
			end
			li1:begin 
				SRAM_address <= uaddy + ucounter; //u2u3
				//reading u0u1
				un5<=SRAM_read_data[15:8];
				un3<=SRAM_read_data[15:8];
				un1<=SRAM_read_data[15:8];
				up1<=SRAM_read_data[15:8];
				up3<=SRAM_read_data[15:8];
				up5<=SRAM_read_data[7:0];
				upeven <= SRAM_read_data[15:8] - 32'd128;
				op1<= {24'd0,SRAM_read_data[15:8]}; 
				op2 <= jn5;
				m1state <= li2;
			end 
			li2:begin
				//reading v0v1
				SRAM_address <= vaddy + vcounter;
				vcounter <= vcounter + 18'd1;
				ucounter<= ucounter + 18'd1;
				vn5<=SRAM_read_data[15:8]; 
				vn3<=SRAM_read_data[15:8]; 
				vn1<=SRAM_read_data[15:8]; 
				vp1<=SRAM_read_data[15:8]; 
				vp3<=SRAM_read_data[15:8]; 
				vp5<=SRAM_read_data[7:0];
				vpeven <= SRAM_read_data[15:8] - 32'd128;
				ubuffereven <= upeven;
				upodd <= mult1; //jn5
				op1<= {24'd0,un3};
				op2 <= jn3;
				op3<= {24'd0,SRAM_read_data[15:8]}; 
				op4<=jn5;
				m1state <= li3;
			end
			li3:begin
				//address set to y0y1
				//reading u2u3
				SRAM_address <= yaddy;
				ycounter<= ycounter + 18'd1;
				upodd <= upodd+mult1; //jn5, jn3
				vpodd<=vpodd+mult2; //jn5
				up1<=up5;
				up3<=SRAM_read_data[15:8];
				up5<=SRAM_read_data[7:0];
				op1<= {24'd0,un1}; 
				op2 <= jn1;
				op3 <= {24'd0,vn3};
				op4 <= jn3;
				vbuffereven<=vpeven;
				m1state <= li4;				
			end
			li4:begin	
				//reading v2v3
				upodd <= upodd + mult1; //jn5, jn3, jn1
				vpodd <= vpodd + mult2; //jn5, jn3
				vp1<=vp5;
				vp3<=SRAM_read_data[15:8];
				vp5<=SRAM_read_data[7:0];
				op1<={24'd0,up1};
				op2<=jp1;
				op3<={24'd0,vn1};
				op4<=jn1;
				
				m1state <= li5;
			end
			li5:begin
				//reading y0y1
				upodd <= upodd + mult1; //jn5, jn3, jn1, jp1
				vpodd <= vpodd + mult2; //jn5, jn3, jn1
				ybuff[0]<=SRAM_read_data[15:8] - 32'd16;
				ybuff[1]<=SRAM_read_data[7:0] - 32'd16;
				op1<={24'd0,up3};
				op2<=jp3;
				op3<={24'd0,vp1};
				op4<=jp1;
				m1state <= li6;
			end
			li6:begin
				upodd <= upodd + mult1; //jn5, jn3, jn1, jp1, jp3
				vpodd <= vpodd + mult2; //jn5, jn3, jn1, jp1
				op1<={24'd0,up5};
				op2<=jp5;
				op3<={24'd0,vp3};
				op4<=jp3;
				op5 <= a00; 
				op6<=	ybuff[0]; //y0
				m1state <= li7;
			end
			li7:begin
				upodd <= ((upodd + mult1 + 32'd128)>>>32'd8) - 32'd128; //jn5, jn3, jn1, jp1, jp3, jp5
				vpodd <= vpodd + mult2; //jn5, jn3, jn1, jp1, jp3
				op3<={24'd0,vp5};
				op4<=jp5;
				R<=mult3; //aooy0
				G<=mult3; //aooy0
				B<=mult3; //aooy0
				op5 <= a02; 
				op6<=	vbuffereven;
				m1state <= li8;
			end
			li8:begin
				vpodd <= ((vpodd + mult2 + 32'd128)>>>32'd8) - 32'd128; //jn5, jn3, jn1, jp1, jp3, jp5
				ubufferodd <= upodd;
				Rbuff<=R+mult3; //aooy0, a02ubuffereven
				op5 <= a21; 
				op6<=ubuffereven;
				m1state <= li9;
			end
			li9:begin
				Bbuff<=B+mult3; //aooy0, a21ubuffereven
				op5 <= a11; 
				vbufferodd <= vpodd;
				m1state <= li10;
			end
			li10:begin
				SRAM_address <= uaddy + ucounter; //u4u5
				ucounter<= ucounter + 18'd1;
				G<= G + mult3;
				Rout<=Rc;
				op5 <= a12; 
				op6<=	vbuffereven;
				m1state <= li11;
			end
			li11:begin
				SRAM_address <= vaddy + vcounter; //v4v5
				vcounter<= vcounter + 18'd1;
				Gbuff<=G+mult3;//END OF CALC
				Bout<=Bc;
				op5 <= a12; 
				un5 <= un3;
				un3 <= un1;
				un1 <= up3;
				up3 <= up5;
				op5 <= a00;
				op6 <= ybuff[1];
				evenodd<=1'b1;
				m1state <= cc1;
			end
			cc1:begin
				up5 <= SRAM_read_data[15:8];
				ubuff[0] <= SRAM_read_data[7:0];
				SRAM_we_n <= 1'b1;
				op1 <= {24'd0,un5};
				op2 <= jn5;
				op5 <= a02;
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp3;
				vp3 <= vp5;
				Gout<=Gc;//SHOULD HAVE CLIPPED VALUE
				if(evenodd==1'b1) begin
					vbufferodd <= vpodd;
					op6 <= ubufferodd;
					
				end else begin
					vbuffereven <= vpeven;
					op6 <= ubuffereven;
				end
				R <= mult3;
				G <= mult3;
				B <= mult3;
				
				m1state <= cc2;				
			end
			
			cc2:begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGBaddy + rgbcounter;
				rgbcounter <= rgbcounter + 18'd1;
				upeven <= un1;
				upodd <= mult1;
				vp5 <= SRAM_read_data[7:0];
				vbuff[0] <= SRAM_read_data[15:8];
				
				op1 <= jn3;
				op2 <= {24'd0,un3};
				op3 <= jn5;
				op4 <= {24'd0,vn5};
				op5 <= a21;
				if(evenodd == 1'b0) begin //EVEN
					Rbuff<=R+mult3;
					SRAM_write_data<={Gout, Bout};
				end else begin
					R<=R+mult3;
					SRAM_write_data<={Rout, Gout};
				end
				m1state <= cc3;
			end
			
			
			cc3:begin
				vpeven <= vn1;
				op1 <= jn1;
				op2 <= {24'd0,un1};
				op3 <= jn3;
				op4 <= {24'd0,vn3};
				op5 <= a11;
				SRAM_we_n <= 1'b1;
				//clippers
				if(evenodd == 1'b1)begin 
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 32'd1;
					Rout<=Rc;
				end
				B<= B+mult3;
				upodd <= mult1 + upodd;
				vpodd <= mult2;
			m1state <= cc4;
			end
			
			cc4:begin
				op1 <= jp1;
				op2 <= up1;
				op3 <= jn1;
				op4 <= vn1;
				op5 <= a12;
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;	
				Bbuff<=B;			
				if(evenodd == 1'b1)begin
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 32'd1;
					op6 <= vbufferodd;
					SRAM_write_data<={Bout,Rout};
				end else begin
					op6 <= vbuffereven;
					SRAM_we_n <= 1'b1;
				end
				G<=G+mult3;
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;			
				m1state <= cc5;
			end
			
			
			cc5:begin
				op1 <= jp3;
				op2 <= up3;
				op3 <= jp1;
				op4 <= vp1;
				op5 <= a00;
				Gbuff<=G+mult3;
				if(evenodd == 1'b1)begin
					ybuff[0]<=SRAM_read_data[7:0] - 8'd16;
					ybuff[1]<=SRAM_read_data[15:8] - 8'd16;
					op6 <= SRAM_read_data[7:0] - 8'd16;//potential issue changed from ybuff[0]
					SRAM_we_n <= 1'b1;
					Bout<=Bc;
				end else begin
					op6 <= ybuff[3];
					SRAM_we_n <= 1'b1;
					Gout<=Gc;
					Rout<=Rc;
					Bout<=Bc;
				end	
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;		
				m1state <= cc6;
			end
			
			cc6:begin
				op1 <= jp5;
				op2 <= up5;
				op3 <= jp3;
				op4 <= vp3;
				op5 <= a02;
					
				if(evenodd == 1'b1) begin
					op6 <= ubuffereven;
					Gout<=Gc;
				end else begin
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					op6 <= ubufferodd;
					SRAM_write_data<={Rout,Gout};
				end
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;	
				R <= mult3;
				G <= mult3;
				B <= mult3;
				m1state <= cc7;
			end
			
			cc7:begin
				upodd <= ((upodd + mult1 + 18'd128)>>>32'd8) - 32'd128;
				
				vpodd <= mult2 + vpodd;
				un5 <= un3;
				un3 <= un1;
				un1 <= up3;
				up3 <= up5;
				op3 <= jp5;
				op4 <= vp5;
				op5 <= a21;
				if(evenodd == 1'b1) begin
					SRAM_we_n <= 1'b0;
					R<= mult3 + R;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					SRAM_write_data<={Gout,Bout};
				end else begin
					SRAM_we_n <= 1'b1;
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 18'd1;
					Rbuff<= mult3 + R;
					Rout<=Rc;
					op5 <= a21;					
				end	
				m1state <= cc8;
			end
			cc8:begin
				ubufferodd <= upodd;
				vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
				vbufferodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp3;
				vp3 <= vp5;
				op1<= un5;
				op2<= jn5;
				op5 <= a11;
				Bbuff <= mult3 + B;
				if(evenodd == 1'b1) begin
					SRAM_we_n <= 1'b1;
					Rbuff<=R;
				end else begin
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 18'd1;
					SRAM_we_n <= 1'b0;
					SRAM_write_data<={Bout, Rout};
				end	
				m1state <= cc9;
			end
			cc9:begin
				
				upeven <= un1;
				op1 <= un3;
				op2 <= jn3;
				op3 <= jn5;
				op4 <= vn5;
				op5 <= a12;
				if(evenodd == 1'b1) begin
					op6 <= vbuffereven;
					Bout<=Bc;
					Rout<=Rc;
				end else begin
					op6 <= vbufferodd;
					SRAM_we_n <= 1'b1;
					Bout<=Bc;
					ybuff[0] <= SRAM_read_data[7:0];
					ybuff[1] <= SRAM_read_data[17:8];
				end	
				upodd <= mult1;
				G<= mult3 + G;
			m1state <= cc10;		
			end
			cc10:begin
					op1 <= un1;
					op2 <= jn1;
					op3 <= jn3;
					op4 <= un3;
					op5 <= a00;
					Gbuff <= mult3 + G;
					Gout<=Gc;//mb
				if(evenodd == 1'b1) begin
					op6<= ybuff[1];					
				end else begin
					op6 <= ybuff[0];
					SRAM_we_n <= 1'b1;
				end					
				upodd <= upodd + mult1;
				vpodd <= mult2;
			m1state <= cc11;				
			end
			cc11:begin
				op1 <= up1;
				op2 <= jp1;
				op3 <= jn1;
				op4 <= vn1;
				op5 <= a02;
				if(evenodd == 1'b1) begin
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					op6 <= ubufferodd;
					SRAM_write_data<={Rout,Gout};
				end else begin
					op6 <= ubuffereven;
					SRAM_we_n <= 1'b1;
				end	
			upodd <= upodd + mult1;
			vpodd <= vpodd + mult2;
			R<= mult3;
			G<= mult3;
			B <= mult3;		
			m1state <= cc12;				
			end
			cc12:begin				
				upodd <= upodd + mult1;
				vpodd <= vpodd + mult2;
				op1 <= up3;
				op2 <= jp3;
				op3 <= up1;
				op4 <= vp1;
				op5 <= a21;
				Rbuff <= R + mult3;
				if(evenodd == 1'b1) begin	
					SRAM_we_n <= 1'b1;			
					SRAM_address <= yaddy + ycounter;
					ycounter<=ycounter+1'd1;
					Rout<=Rc;
				end else begin
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					SRAM_write_data <= {Gout,Bout};					
				end	
			m1state <= cc13;			
			end	
			cc13:begin
				op1 <= up5;
				op2 <= jp5;
				op3 <= jp3;
				op4 <= vp3;
				op5 <= a11;
				Bbuff <= B + mult3;
				if(evenodd == 1'b1) begin
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					SRAM_write_data<={Bout,Rout};
				end else begin
					SRAM_we_n <= 1'b1;
					op5 <= a11;
				end				
				upodd <= upodd + mult1;
				vpodd <= vpodd + mult2;				
			m1state <= cc14;				
			end
			cc14:begin
				SRAM_address <= uaddy + ucounter;
				ucounter = ucounter + 18'd1;
				un5 <= un3;
				un3 <= un1;
				un1 <= up3;
				up3 <= up5;
				op3 <= jp5;
				op4 <= vp5;
				op5 <= a12;
				Bout<=Bc;
				if(evenodd == 1'b1) begin
					SRAM_we_n <= 1'b1;
					op6 <= vbufferodd;
					ybuff[2]<= SRAM_read_data[7:0];
					ybuff[3]<= SRAM_read_data[17:8];
				end else begin
					SRAM_we_n <= 1'b1;
					op6 <= vbuffereven;
				end
				Gbuff <= G + mult3;
				upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
				vpodd <= vpodd + mult2;
			m1state <= cc15;				
			end	
			cc15:begin				
				ubufferodd <= upodd;
				SRAM_address <= vaddy + vcounter;
				vcounter = vcounter + 18'd1;
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp3;
				vp3 <= vp5;
				op1 <= un3;
				op2 <= jp5;
				op5 <= a00;
				Gout<=Gc;
				if(evenodd == 1'b1) begin
					SRAM_we_n <= 1'b1;
					op6 <= ybuff[2];
					SRAM_we_n <= 1'b1;
				end else begin
					SRAM_we_n <= 1'b1;
					op6 <= ybuff[1];
				end
				vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
				evenodd<=~evenodd;
				if (ucounter<18'd160) begin
				m1state<=cc1;
				end else begin
				m1end<=1'b1;
				end
				end
//				end else begin
//				m1state<=lo0;
//				end
//			end
//	lo0: begin
//			vbufferodd <= vpodd;
//			op1 <= un5;
//			op2 <= jn5;
//			op5 <= a02;
//			op6 <= ubufferodd;
//			upeven <= un1;
//			R<= mult3;
//			B<= mult3;
//			G <= mult3;
//			
//			
//		end
//	lo1: begin
//			upodd <=upodd + mult1;
//			op1 <= un3;
//			op2 <= jn3;
//			op3 <= vn5;
//			op4 <= jn5;
//			op5 <= a21;
//			upeven <= un1;
//			upodd <= mult1;
//			R<= R + mult3;
//		end
//	lo2: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= un1;
//			op2 <= jn1;
//			op3 <= vn3;
//			op4 <= jn3;
//			op5 <= a11;
//			vpeven <= vn1;
//			B <= mult3;
//		end
//	lo3: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up1;
//			op2 <= jp1;
//			op3 <= vn1;
//			op4 <= jn1;
//			op5 <= a12;
//			op6 <= vbufferodd;
//			ubufferodd <= upodd;
//			
//			G <= mult3;
//		end
//	lo4: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up3;
//			op2 <= jp3;
//			op3 <= vp1;
//			op4 <= jp1;
//			op5 <= a00;
//			op6 <= ybuff[1];
//			G <= G + mult3;
//		end
//	lo5: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up5;
//			op2 <= jp5;
//			op3 <= vp3;
//			op4 <= jp3;
//			op5 <= a02;
//			op6 <= ubuffereven;
//			R <= R + mult3;
//			G <= G + mult3;
//			B <= B + mult3;
//		end
//	lo6: begin
//			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
//			vpodd <=vpodd + mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1 <= up3;
//			up3 <= up5;
//			op3 <= vp5;
//			op4 <= jp5;
//			op5 <= a21;
//			R <= R + mult3;
//		end
//	lo7: begin
//			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
//			SRAM_address <= yaddy + ycounter;
//			ycounter <= ycounter + 18'd1;
//			vn5 <= vn3;
//			vn3 <= vn1;
//			vn1 <= vp1;
//			vp1 <= vp3;
//			vp3 <= vp5;
//			op1 <= un5;
//			op2 <= jn5;
//			
//			op5 <= a11;
//			B <= B + mult3;
//			
//		end
//	lo8: begin
//			upodd <=upodd + mult1;
//			op1 <= un3;
//			op2 <= jn3;
//			op3 <= vn5;
//			op4 <= jn5;
//			upeven <= un1;
//			R<= R + mult3;
//			G<= G + mult3;
//			op5 <= a12;
//			op6<= vbuffereven;
//		end
//	lo9: begin
//			ybuff[0] <= SRAM_read_data[7:0];
//			ybuff[1] <= SRAM_read_data[17:8];
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= un1;
//			op2 <= jn1;
//			op3 <= vn3;
//			op4 <= jn3;
//			vpeven <= vn1;
//			G <= G + mult3;
//			op5 <= a00;
//			op6<= SRAM_read_data[7:0];
//			
//		end
//	lo10: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up1;
//			op2 <= jp1;
//			op3 <= vn1;
//			op4 <= jn1;
//			R <= R + mult3;
//			G <= G + mult3;
//			B <= B + mult3;
//			op5 <= a02;
//			op6 <= ubufferodd;
//		end
//	lo11: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up3;
//			op2 <= jp3;
//			op3 <= vp1;
//			op4 <= jp1;
//			R <= R + mult3;
//			op5 <= a21;
//		end
//	lo12: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up5;
//			op2 <= jp5;
//			op3 <= vp3;
//			op4 <= jp3;
//			B <= B + mult3;
//			op5 <= a11;
//		end
//	lo13: begin
//			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
//			vpodd <=vpodd + mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1 <= up3;
//			up3 <= up5;
//			op3 <= vp5;
//			op4 <= jp5;
//			G <= G + mult3;
//			op5 <= a12;
//		end
//	lo14: begin
//			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
//			G <= G + mult3;
//			vn5 <= vn3;
//			vn3 <= vn1;
//			vn1 <= vp1;
//			vp1 <= vp3;
//			vp3 <= vp5;
//			op1 <= un5;
//			op2 <= jn5;
//			op5 <= a00;
//			op6 <= ybuff[1];
//		end
//	lo15: begin
//			upodd <=upodd + mult1;
//			op1 <= un3;
//			op2 <= jn3;
//			op3 <= un5;
//			op4 <= jn5;
//			R <= R + mult3;
//			G <= G + mult3;
//			B <= B + mult3;
//			op5 <= a02;
//			op6 <= ubuffereven;
//		end
//	lo16: begin
//			op1 <= un1;
//			op2 <= jn1;
//			op3 <= un3;
//			op4 <= jn3;
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			R <= R + mult3;
//			op5 <= a21;
//		end
//	lo17: begin
//			SRAM_address <= yaddy + ycounter;
//			ycounter <= ycounter + 18'd1;
//			op1 <= up1;
//			op2 <= jp1;
//			op3 <= un1;
//			op4 <= jn1;
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			B <= B + mult3;
//			op5 <= a11;
//		end
//	lo18: begin
//			op1 <= up3;
//			op2 <= jp3;
//			op3 <= up1;
//			op4 <= jp1;
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			G <= G + mult3;
//			op5 <= a12;
//		end
//	lo19: begin
//			ybuff[0] <= SRAM_read_data[7:0];
//			ybuff[1] <= SRAM_read_data[17:8];
//			op1 <= up5;
//			op2 <= jp5;
//			op3 <= up3;
//			op4 <= jp3;
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			G <= G + mult3;
//			op5 <= a00;
//			op6 <= SRAM_read_data[7:0];
//		end
//	lo20: begin
//			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
//			vpodd <= vpodd + mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1 <= up3;
//			up3 <= up5;
//			op3 <= up5;
//			op4 <= jp5;
//			R <= R + mult3;
//			G <= G + mult3;
//			B <= B + mult3;
//			op5 <= a02;
//			op6 <= ubufferodd;
//		end
//	lo21: begin
//			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
//			R <= R + mult3;
//			vn5 <= vn3;
//			vn3 <= vn1;
//			vn1 <= vp1;
//			vp1 <= vp3;
//			vp3 <= vp5;
//			op1 <= un5;
//			op2 <= jn5;
//			op5 <= a21;
//		end
//	lo22: begin
//			op1 <= un3;
//			op2 <= jn3;
//			op3 <= un5;
//			op4 <= jn5;
//			upodd <=upodd + mult1;
//			B <= B + mult3;
//			op5 <= a11;
//		end
//	lo23: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= un1;
//			op2 <= jn1;
//			op3 <= un3;
//			op4 <= jn3;
//			G <= G + mult3;
//			op5 <= a12;
//		end
//	lo24: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up1;
//			op2 <= jp1;
//			op3 <= un1;
//			op4 <= jn1;
//			G <= G + mult3;
//			op5 <= a00;
//			op6 <= ybuff[1];
//		end
//	lo25: begin
//			upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up3;
//			op2 <= jp3;
//			op3 <= up1;
//			op4 <= jp1;
//			R <= R + mult3;
//			G <= G + mult3;
//			B <= B + mult3;
//			op5 <= a02;
//			op6 <= ubuffereven;
//		end
//	lo26: begin
//				upodd <=upodd + mult1;
//			vpodd <=vpodd + mult2;
//			op1 <= up5;
//			op2 <= jp5;
//			op3 <= up3;
//			op4 <= jp3;
//			R <= R + mult3;
//			op5 <= a21;
//		end
//	lo27: begin
//			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
//			vpodd <=vpodd + mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1 <= up3;
//			up3 <= up5;
//			op3 <= up5;
//			op4 <= jp5;
//			B <= B + mult3;
//			op5 <= a11;
//		end
//	lo28: begin
//			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
//			vn5 <= vn3;
//			vn3 <= vn1;
//			vn1 <= vp1;
//			vp1 <= vp3;
//			vp3 <= vp5;
//			G <= G + mult3;
//			op5 <= a12;
//		end
//	lo29: begin
//			G <= G + mult3;
//			m1end<=1'd1;
//		end	
		endcase
end
end
endmodule
