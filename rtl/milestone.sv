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

logic [31:0]ybuff[1:0];
logic [7:0]ubuff;
logic [7:0]vbuff;

logic [31:0] R;//calcs
logic [31:0] G;
logic [31:0] B;

logic [31:0] Rbuff[0:1]; //hold
logic [31:0] Gbuff[0:1];
logic [31:0] Bbuff[0:1];

logic [7:0] Rc[1:0];//clip
logic [7:0] Bc[1:0];
logic [7:0] Gc[1:0];

//GETOUT 
logic [7:0] Rout[0:1];
logic [7:0] Bout[0:1];
logic [7:0] Gout[0:1];

logic signed [31:0] op1,op2,op3,op4,op5,op6;
logic signed [31:0] mult1,mult2,mult3;
logic signed [63:0] multlong1, multlong2, multlong3;

//logic counter 
logic [17:0] ucounter;
logic [17:0] vcounter;
logic [17:0] ycounter;
logic [17:0] rgbcounter;

logic select;
//coeffs
parameter signed jn5= 32'h15;
parameter signed jn3= 32'hFFFFFFCC;
parameter signed jn1= 32'h9F;
parameter signed jp1= 32'h9F;
parameter signed jp3= 32'hFFFFFFCC;
parameter signed jp5= 32'h15;

parameter signed a00=32'h129FC;
parameter signed a02=32'h19893;
parameter signed a11=32'hffff9BE8;
parameter signed a12=32'hffff2fdf;
parameter signed a21=32'h2049B;


assign multlong1=$signed(op1)*$signed(op2);
assign mult1=multlong1[31:0];

assign multlong2=$signed(op3)*$signed(op4);
assign mult2=multlong2[31:0];

assign multlong3=$signed(op5)*$signed(op6);
assign mult3=multlong3[31:0];
always_comb begin
//if (select==1'b0) begin
 Rc[0]=(Rbuff[0][31]==1'b1)?8'd0:((Rbuff[0][31:24]>=8'd1)?8'd255:Rbuff[0][23:16]);
 Bc[0]=(Bbuff[0][31]==1'b1)?8'd0:((Bbuff[0][31:24]>=8'd1)?8'd255:Bbuff[0][23:16]);
Gc[0]=(Gbuff[0][31]==1'b1)?8'd0:((Gbuff[0][31:24]>=8'd1)?8'd255:Gbuff[0][23:16]);
//end else begin
 Rc[1]=(Rbuff[1][31]==1'b1)?8'd0:((Rbuff[1][31:24]>=8'd1)?8'd255:Rbuff[1][23:16]);
 Bc[1]=(Bbuff[1][31]==1'b1)?8'd0:((Bbuff[1][31:24]>=8'd1)?8'd255:Bbuff[1][23:16]);
 Gc[1]=(Gbuff[1][31]==1'b1)?8'd0:((Gbuff[1][31:24]>=8'd1)?8'd255:Gbuff[1][23:16]);
//end
end

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
		
		ubuff<=8'd0;

		vbuff<=8'd0;
		

		R<=32'd0;
		G<=32'd0;
		B<=32'd0;

		Rbuff[0]<=32'd0;
		Gbuff[0]<=32'd0;
		Bbuff[0]<=32'd0;
		
		Rbuff[1]<=32'd0;
		Gbuff[1]<=32'd0;
		Bbuff[1]<=32'd0;
select<=1'b0;
		Rout[0]<=8'd0;
		Bout[0]<=8'd0;
		Gout[0]<=8'd0;
		Rout[1]<=8'd0;
		Bout[1]<=8'd0;
		Gout[1]<=8'd0;

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
					ubuff<=8'd0;
					vbuff<=8'd0;
					
					R<=32'd0;
					G<=32'd0;
					B<=32'd0;
					
		Rbuff[0]<=32'd0;
		Gbuff[0]<=32'd0;
		Bbuff[0]<=32'd0;
		
		Rbuff[1]<=32'd0;
		Gbuff[1]<=32'd0;
		Bbuff[1]<=32'd0;

				select<=1'b0;
		Rout[0]<=8'd0;
		Bout[0]<=8'd0;
		Gout[0]<=8'd0;
		Rout[1]<=8'd0;
		Bout[1]<=8'd0;
		Gout[1]<=8'd0;					
					
					
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
				m1state <= li2;
			end 
			li2:begin
				//reading u0u1
				un5<=SRAM_read_data[15:8];
				un3<=SRAM_read_data[15:8];
				un1<=SRAM_read_data[15:8];
				up1<=SRAM_read_data[15:8];
				up3<=SRAM_read_data[15:8];
				up5<=SRAM_read_data[7:0];
				upeven <= {24'd0,SRAM_read_data[15:8]};
				op1<= {24'd0,SRAM_read_data[15:8]}; 
				op2 <= jn5;
				//
				//reading v0v1
				SRAM_address <= vaddy + vcounter;
				vcounter <= vcounter + 18'd1;
				ucounter<= ucounter + 18'd1;
				m1state <= li3;
			end
			li3:begin
				vn5<=SRAM_read_data[15:8]; 
				vn3<=SRAM_read_data[15:8]; 
				vn1<=SRAM_read_data[15:8]; 
				vp1<=SRAM_read_data[15:8]; 
				vp3<=SRAM_read_data[15:8]; 
				vp5<=SRAM_read_data[7:0];
				vpeven <= {24'd0,SRAM_read_data[15:8]};
				ubuffereven <= upeven-32'd128;
				upodd <= mult1; //jn5
				op1<= {24'd0,un3};
				op2 <= jn3;
				op3<= {24'd0,SRAM_read_data[15:8]}; 
				op4<=jn5;
				//
				//address set to y0y1
				//reading u2u3
				SRAM_address <= yaddy;
				ycounter<= ycounter + 18'd1;
				m1state <= li4;				
			end
			li4:begin	
				upodd <= upodd+mult1; //jn5, jn3
				vpodd<=vpodd+mult2; //jn5
				up1<=up5;
				up3<=SRAM_read_data[15:8];
				up5<=SRAM_read_data[7:0];
				op1<= {24'd0,un1}; 
				op2 <= jn1;
				op3 <= {24'd0,vn3};
				op4 <= jn3;
				vbuffereven<=vpeven-32'd128;
				//
				m1state <= li5;
			end
			li5:begin
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
				//
				//reading y0y1
				m1state <= li6;
			end
			li6:begin
				upodd <= upodd + mult1; //jn5, jn3, jn1, jp1
				vpodd <= vpodd + mult2; //jn5, jn3, jn1
				ybuff[0]<={24'd0,SRAM_read_data[15:8]} - 32'd16;
				ybuff[1]<={24'd0,SRAM_read_data[7:0]} - 32'd16;
				op1<={24'd0,up3};
				op2<=jp3;
				op3<={24'd0,vp1};
				op4<=jp1;
				//

				op5 <= a00; 
				op6<=	{24'd0,SRAM_read_data[15:8]} - 32'd16; //y0
				m1state <= li7;
			end
			li7:begin
				upodd <= upodd + mult1; //jn5, jn3, jn1, jp1, jp3
				vpodd <= vpodd + mult2; //jn5, jn3, jn1, jp1
				op1<={24'd0,up5};
				op2<=jp5;
				op3<={24'd0,vp3};
				op4<=jp3;
			
				R<=mult3; //aooy0
				G<=mult3; //aooy0
				B<=mult3; //aooy0
				op5 <= a02; 
				op6<=	vbuffereven;
				m1state <= li8;
			end
			li8:begin
				upodd <= ((upodd + mult1 + 32'd128)>>>8) - 32'd128; //jn5, jn3, jn1, jp1, jp3, jp5
				vpodd <= vpodd + mult2; //jn5, jn3, jn1, jp1, jp3
				op3<={24'd0,vp5};
				op4<=jp5;
				
				Rbuff[0]<=R+mult3; //aooy0, a02ubuffereven
				op5 <= a21; 
				op6<=ubuffereven;
				m1state <= li9;
			end
			li9:begin
				vpodd <= ((vpodd + mult2 + 32'd128)>>>8) - 32'd128; //jn5, jn3, jn1, jp1, jp3, jp5
				ubufferodd <= upodd;
				Bbuff[0]<=B+mult3; //aooy0, a21ubuffereven
				op5 <= a11; 
				m1state <= li10;
			end
			li10:begin
				vbufferodd <= vpodd;
				SRAM_address <= uaddy + ucounter; //u4u5
				ucounter<= ucounter + 18'd1;
				G<= G + mult3;
				Rout[0]<=Rc[0];
				op5 <= a12; 
				op6<=	vbuffereven;
				m1state <= li11;
			end
			li11:begin
				SRAM_address <= vaddy + vcounter; //v4v5
				vcounter<= vcounter + 18'd1;
				Gbuff[0]<=G+mult3;//END OF CALC
				Bout[0]<=Bc[0];
				//shift u regs
				un5 <= un3;
				un3 <= un1;
				un1 <= up1;
				up1 <= up3;
				up3 <= up5;
				m1state <= li12;
			end
			li12:begin
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 32'd1;
					op5<=a00;
					op6<=ybuff[1];
					m1state <= li13;
			end
			li13:begin
				SRAM_we_n <= 1'b1;
				R <= mult3;
				G <= mult3;
				B <= mult3;
				op1 <= {24'd0,un5};
				op2 <= jn5;
				op5 <= a02;
				//shift
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp1;
				vp1 <= vp3;
				vp3 <= vp5;
				op5 <= a02;
				Gout[0]<=Gc[0];//SHOULD HAVE CLIPPED VALUE
				vbufferodd <= vpodd;
					op6 <= {24'd0,vbufferodd};
					up5 <= SRAM_read_data[15:8];
					ubuff <= {24'd0,SRAM_read_data[7:0]};
				
				m1state <= li14;				
			end
			
			li14:begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGBaddy + rgbcounter;//146944
				rgbcounter <= rgbcounter + 18'd1;
				upeven <= {24'd0,un1};
				upodd <= mult1;
				vp5 <= SRAM_read_data[15:8];
				vbuff<= {24'd0,SRAM_read_data[7:0]};
				
				op1 <= jn3;
				op2 <= {24'd0,un3};
				op3 <= jn5;
				op4 <= {24'd0,vn5};
				
					op6<=ubufferodd;
					Rbuff[0]<=R+mult3;
					SRAM_write_data<={Rout[0], Gout[0]};
				op5 <= a21;
				m1state <= li15;
			end
			
			
			li15:begin
			B<= B+mult3;
				vpeven <= {24'd0,vn1};
				op1 <= jn1;
				op2 <= {24'd0,un1};
				op3 <= jn3;
				op4 <= {24'd0,vn3};
				op5 <= a11;
				SRAM_we_n <= 1'b1;
				ubuffereven<=upeven-32'd128;
				//clippers
					Rout[0]<=Rc[0];
					ybuff[0]<={24'd0,SRAM_read_data[15:8]} - 32'd16;
					ybuff[1]<={24'd0,SRAM_read_data[7:0]} - 32'd16;

				
				upodd <= mult1 + upodd;
				vpodd <= mult2;
			m1state <= li16;
			end
			
			li16:begin
				op1 <= jp1;
				op2 <= {24'd0,up1};
				op3 <= jn1;
				op4 <= {24'd0,vn1};
				op5 <= a12;
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;	
				Bbuff[0]<=B;			
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;//146945
					rgbcounter <= rgbcounter + 32'd1;
					op6 <= vbufferodd;
					SRAM_write_data<={Bout[0],Rout[0]};
				G<=G+mult3;
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;			
				m1state <= li17;
			end
			
			
			li17:begin
				op1 <= jp3;
				op2 <= {24'd0,up3};
				op3 <= jp1;
				op4 <= {24'd0,vp1};
				op5 <= a00;
				Gbuff[0]<=G+mult3;
					SRAM_we_n <= 1'b1;
					op6 <= ybuff[0];
					Bout[0]<=Bc[0];
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;		
				m1state <= li18;
			end
			
			li18:begin
				R <= mult3;
				G <= mult3;
				B <= mult3;
				op1 <= jp5;
				op2 <= {24'd0,up5};
				op3 <= jp3;
				op4 <= {24'd0,vp3};
				op5 <= a02;
				vbuffereven<=vpeven-32'd128;	
					op6 <= vbuffereven;
					Gout[0]<=Gc[0];
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;	

				m1state <= li19;
			end
			
			li19:begin
				upodd <= ((upodd + mult1 + 32'd128)>>>8) - 32'd128;				
				vpodd <= mult2 + vpodd;
				//shift
				un5 <= un3;
				un3 <= un1;
				un1 <= up1;
				up1 <= up3;
				up3<=up5;
				up5<=ubuff[7:0];
				
				op3 <= jp5;
				op4 <= {24'd0,vp5};
				op5 <= a21;
					SRAM_we_n <= 1'b0;
					R<= mult3 + R;
					SRAM_address <= RGBaddy + rgbcounter;//146947
					rgbcounter <= rgbcounter + 18'd1;
					SRAM_write_data<={Gout[0],Bout[0]};
					op6<=ubuffereven;	
				m1state <= li20;
			end
			li20:begin
				//ubufferodd <= upodd;
				vpodd <= ((vpodd + mult2 + 32'd128)>>>8) - 32'd128;
				Bbuff[0] <= mult3 + B;
				//shift
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp1;
				vp1 <= vp3;
				vp3<=vp5;
				
				op1<= {24'd0,un5};
				op2<= jn5;
				op5 <= a11;
				

					SRAM_we_n <= 1'b1;
					Rbuff[0]<=R;
					op6<=ubuffereven;	
				m1state <= li21;
			end
			li21:begin
				G<= mult3 + G;
				vp5<=vbuff[7:0];
				upeven <= {24'd0,un1};
				op1 <= {24'd0,un3};
				op2 <= jn3;
				op3 <= jn5;
				op4 <= {24'd0,vn5};
				op5 <= a12;
				vbufferodd <= vpodd;
				
					op6 <= vbuffereven;
					Bout[0]<=Bc[0];
					Rout[0]<=Rc[0];
		
				upodd <= mult1;
				
			m1state <= li22;		
			end
			li22:begin
					op1 <= {24'd0,un1};
					op2 <= jn1;
					op3 <= jn3;
					op4 <= {24'd0,vn3};
					op5 <= a00;
					Gbuff[0] <= mult3 + G;
					ubuffereven<=upeven-32'd128;
					vpeven<={24'd0,vn1};
					op6<= ybuff[1];
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 18'd1;				
				upodd <= upodd + mult1;
				vpodd <= mult2;
			m1state <= li23;				
			end
			li23:begin
				R <= mult3;
				G <= mult3;
				B <= mult3;
				op1 <= {24'd0,up1};
				op2 <= jp1;
				op3 <= jn1;
				op4 <= {24'd0,vn1};
				op5 <= a02;
				vbuffereven<=vpeven-32'd128;
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					op6 <= vbufferodd;
					//Gout<=Gc;//mb
					SRAM_write_data<={Rout[0],Gc[0]};
			upodd <= upodd + mult1;
			vpodd <= vpodd + mult2;		
			m1state <= li24;				
			end
			li24:begin				
				upodd <= upodd + mult1;
				vpodd <= vpodd + mult2;
				op1 <= {24'd0,up3};
				op2 <= jp3;
				op3 <= jp1;
				op4 <= {24'd0,vp1};
				op5 <= a21;
				Rbuff[0] <= R + mult3;
				SRAM_we_n <= 1'b1;			
				op6<=ubufferodd;
					//Rout<=Rc;
			m1state <= li25;			
			end	
			li25:begin
				op1 <= {24'd0,up5};
				op2 <= jp5;
				op3 <= jp3;
				op4 <= {24'd0,vp3};
				op5 <= a11;
				Bbuff[0] <= B + mult3;
					SRAM_we_n <= 1'b0;
					SRAM_address <= RGBaddy + rgbcounter;
					rgbcounter <= rgbcounter + 18'd1;
					SRAM_write_data<={Bout[0],Rc[0]};
					ybuff[0] <= {24'd0,SRAM_read_data[15:8]}-32'd16;
					ybuff[1] <= {24'd0,SRAM_read_data[7:0]}-32'd16;
					op6<=ubufferodd;			
				upodd <= upodd + mult1;
				vpodd <= vpodd + mult2;				
			m1state <= li26;				
			end
			
			li26:begin
				SRAM_we_n <= 1'b1;
				G<=G+mult3;
				op3 <= jp5;
				op4 <= {24'd0,vp5};
				op5 <= a12;
				Bout[0]<=Bc[0];			
				op6 <= vbufferodd;
				upodd <= ((upodd + mult1 + 32'd128)>>>8) - 32'd128;
				vpodd <= vpodd + mult2;
			m1state <= li27;				
			end	
			li27:begin			
				ubufferodd <= upodd;
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp1;
				vp1 <= vp3;
				vp3<=vp5;
				Gbuff[0] <= G + mult3;
				op1 <= {24'd0,un3};
				op2 <= jp5;
				op5 <= a00;
				SRAM_we_n <= 1'b1;
				op6 <= ybuff[0];
				SRAM_we_n <= 1'b1;
				un5 <= un3;
				un3 <= un1;
				un1 <= up1;
				up1<=up3;
				up3 <= up5;
				ubufferodd<=upodd;
				vpodd <= ((vpodd + mult2 + 32'd128)>>>8) - 32'd128;
				m1state<=li28;
				end				
			li28:begin
				Gout[0]<=Gc[0];
				
				op1<=a00;
				op2<=ybuff[0];
				
				op3<=a02;//red
				op4<=vbuffereven;
				
				op5<=a21;//blue
				op6<=ubuffereven;
				m1state<=li29;
			end
			li29: begin
				Rbuff[0]<=mult1+mult2;
				Bbuff[0]<=mult1+mult3;
				G<=mult1;
				op1<=a11;
				op2<=ubuffereven;
				
				op3<=a12;
				op4<=vbuffereven;
				
				SRAM_we_n <= 1'b0;
				SRAM_address <= RGBaddy + rgbcounter;
				rgbcounter <= rgbcounter + 18'd1;
				SRAM_write_data<={Gout[0],Bout[0]};
				
				m1state<=li30;
			end
			
			li30: begin
			SRAM_we_n <= 1'b1;
			Gbuff[0]<=G+mult1+mult2;
			Rout[0]<=Rc[0];
			Bout[0]<=Bc[0];
			
			op1<=a00;
				op2<=ybuff[1];
				
				op3<=a02;//red
				op4<=vbufferodd;
				
				op5<=a21;//blue
				op6<=ubufferodd;
			
			m1state<=li31;
			end
			
			li31: begin
								SRAM_address <= uaddy + ucounter;
					ucounter <= ucounter + 18'd1;	
					select<=1'b1;
			Rbuff[1]<=mult1+mult2;
			Bbuff[1]<=mult1+mult3;
			Gout[0]<=Gc[0];
			G<=mult1;
			op1<=a11;
				op2<=ubufferodd;
				
				op3<=a12;
				op4<=vbufferodd;
			m1state<=li32;
			end
			
			li32: begin
			SRAM_address <= vaddy + vcounter;
			vcounter <= vcounter + 18'd1;
			Rout[1]<=Rc[1];
			Bout[1]<=Bc[1];
			Gbuff[1]<=G+mult1+mult2;
			m1state<=li33;
			end
			
			li33: begin
			SRAM_address <= yaddy + ycounter;
			ycounter <= ycounter + 18'd1;	
			Gout[1]<=Gc[1];
			select<=1'b0;
			m1state<=cc1;
//				if (ucounter<18'd160) begin
//				m1state<=cc1;
//				end else begin
//				m1end<=1'b1;
//				end
			end
			
		cc1:begin
		SRAM_we_n <= 18'b0;
			SRAM_address <= RGBaddy + rgbcounter;
			rgbcounter <= rgbcounter + 18'd1;
			SRAM_write_data <= {Rout[0],Gout[0]};
			Gout[1]<=Gc[1];
			op1 <= {24'd0,un5};
			op2 <= jn5;
			op3 <= {24'd0,un3};
			op4 <= jn3;
			op5 <= {24'd0,un1};
			op6 <= jn1;
			
			up5 <= SRAM_read_data[15:8];
			ubuff <= SRAM_read_data[7:0];
			m1state<=cc2;
			end
		cc2:begin
				SRAM_address <= RGBaddy + rgbcounter;//146944
				rgbcounter <= rgbcounter + 18'd1;
			SRAM_write_data <= {Bout[0],Rout[1]};
			upodd<=mult1+mult2+mult3;
			ubuffereven<={24'd0,un3}-32'd128;
			vp5 <= SRAM_read_data[15:8];
			vbuff <= SRAM_read_data[7:0];
			op1 <= {24'd0,up5};
			op2 <= jp5;
			op3 <= {24'd0,up3};
			op4 <= jp3;
			op5 <= {24'd0,up1};
			op6 <= jp1;
			m1state<=cc3;
			end
		cc3:begin
				SRAM_address <= RGBaddy + rgbcounter;//146944
				rgbcounter <= rgbcounter + 18'd1;
			SRAM_write_data <= {Gout[1],Bout[1]};
			ubufferodd<=((upodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
			ubuffereven<={24'd0,un3}-32'd128;
			ybuff[0] <= {24'd0,SRAM_read_data[15:8]}-32'd16;
			ybuff[1] <= {24'd0,SRAM_read_data[7:0]}-32'd16;
			op1 <= {24'd0,vn5};
			op2 <= jn5;
			op3 <= {24'd0,vn3};
			op4 <= jn3;
			op5 <= {24'd0,vn1};
			op6 <= jn1;
			vbuffereven<={24'd0,vn3}-32'd128;
		m1state<=cc4;
			end
			
		cc4:begin
		vpodd<=mult1+mult2+mult3;
		SRAM_we_n <= 18'b1;
			op1 <= {24'd0,vp5};
			op2 <= jp5;
			op3 <= {24'd0,vp3};
			op4 <= jp3;
			op5 <= {24'd0,vp1};
			op6 <= jp1;
		m1state<=cc5;	
				end
				
		cc5:begin
		vbufferodd<=((vpodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
		op1<=a00;
		op2<=ybuff[0];			
		op3<=a02;//red
		op4<=vbuffereven;		
		op5<=a21;//blue
		op6<=ubuffereven;
		
		m1state<=cc6;
			end
			
		cc6:begin
		Rbuff[0]<=mult1+mult2;
		Bbuff[0]<=mult1+mult3;
		G<=mult1;
		op1<=a11;
		op2<=ubuffereven;				
		op3<=a12;
		op4<=vbuffereven;
		m1state<=cc7;
				end
				
		cc7:begin
		Gbuff[0]<=G+mult1+mult2;
		Rout[0]<=Rc[0];
		Bout[0]<=Bc[0];
		op1<=a00;
		op2<=ybuff[1];
		op3<=a02;//red
		op4<=vbufferodd;
		op5<=a21;//blue
		op6<=ubufferodd;
		m1state<=cc8;
			end
			
		cc8:begin
			Rbuff[1]<=mult1+mult2;
			Bbuff[1]<=mult1+mult3;
			Gout[0]<=Gc[0];
			G<=mult1;
			op1<=a11;
				op2<=ubufferodd;
				
				op3<=a12;
				op4<=vbufferodd;
		m1state<=cc9;
			end
			
		cc9:begin
		SRAM_address <= yaddy + ycounter;
			ycounter <= ycounter + 18'd1;
			Rout[1]<=Rc[1];
			Bout[1]<=Bc[1];
			Gbuff[1]<=G+mult1+mult2;
			un5 <= un3;
				un3 <= un1;
				un1 <= up1;
				up1<=up3;
				up3 <= up5;
				up5<=ubuff;
		m1state<=cc10;
			end
			
		cc10:begin
		Gout[1]<=Gc[1];
		select<=1'b0;
		SRAM_we_n <= 18'b0;
			SRAM_address <= RGBaddy + rgbcounter;
			rgbcounter <= rgbcounter + 18'd1;
			SRAM_write_data <= {Rout[0],Gout[0]};
			
			
			op1 <= {24'd0,un5};
			op2 <= jn5;
			op3 <= {24'd0,un3};
			op4 <= jn3;
			op5 <= {24'd0,un1};
			op6 <= jn1;
			vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp1;
				vp1 <= vp3;
				vp3<=vp5;
				vp5<=vbuff;
		m1state<=cc11;
			end
			
		cc11:begin
		SRAM_address <= RGBaddy + rgbcounter;//146944
				rgbcounter <= rgbcounter + 18'd1;
			SRAM_write_data <= {Bout[0],Rout[1]};
			upodd<=mult1+mult2+mult3;
			op1 <= {24'd0,up5};
			op2 <= jp5;
			op3 <= {24'd0,up3};
			op4 <= jp3;
			op5 <= {24'd0,up1};
			op6 <= jp1;
		m1state<=cc12;
			end
			
		cc12:begin
		SRAM_address <= RGBaddy + rgbcounter;//146944
				rgbcounter <= rgbcounter + 18'd1;
			SRAM_write_data <= {Gout[1],Bout[1]};
			ubufferodd<=((upodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
			ubuffereven<={24'd0,un3}-32'd128;
			ybuff[0] <= {24'd0,SRAM_read_data[15:8]}-32'd16;
			ybuff[1] <= {24'd0,SRAM_read_data[7:0]}-32'd16;
			op1 <= {24'd0,vn5};
			op2 <= jn5;
			op3 <= {24'd0,vn3};
			op4 <= jn3;
			op5 <= {24'd0,vn1};
			op6 <= jn1;	
		vbuffereven<={24'd0,vn3}-32'd128;	
		m1state<=cc13;
			end
			
		cc13:begin
			SRAM_we_n <= 18'b1;
			vpodd<=mult1+mult2+mult3;
			op1 <= {24'd0,vp5};
			op2 <= jp5;
			op3 <= {24'd0,vp3};
			op4 <= jp3;
			op5 <= {24'd0,vp1};
			op6 <= jp1;
			
			
		m1state<=cc14;
			end
			
		cc14:begin
		op1<=a00;
		op2<=ybuff[0];			
		op3<=a02;//red
		op4<=vbuffereven;		
		op5<=a21;//blue
		op6<=ubuffereven;
		vbufferodd<=((vpodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
		m1state<=cc15;
			end
			
		cc15:begin
		Rbuff[0]<=mult1+mult2;
		Bbuff[0]<=mult1+mult3;
		G<=mult1;
		op1<=a11;
		op2<=ubuffereven;				
		op3<=a12;
		op4<=vbuffereven;
		m1state<=cc16;
			end
			
		cc16:begin
		SRAM_address <= uaddy + ucounter;
		
		Gbuff[0]<=G+mult1+mult2;
		Rout[0]<=Rc[0];
		Bout[0]<=Bc[0];
		op1<=a00;
		op2<=ybuff[1];
		op3<=a02;//red
		op4<=vbufferodd;
		op5<=a21;//blue
		op6<=ubufferodd;
		m1state<=cc17;
			end
			
		cc17:begin
		SRAM_address <= vaddy + vcounter;
		vcounter <= vcounter + 18'd1;	
		ucounter <= ucounter + 18'd1;	
		Rbuff[1]<=mult1+mult2;
		Bbuff[1]<=mult1+mult3;
		Gout[0]<=Gc[0];
		G<=mult1;
		op1<=a11;
		op2<=ubufferodd;				
				op3<=a12;
				op4<=vbufferodd;
		m1state<=cc18;
			end
			
		cc18:begin
		SRAM_address <= yaddy + ycounter;
			ycounter <= ycounter + 18'd1;
			Rout[1]<=Rc[1];
			Bout[1]<=Bc[1];
			Gbuff[1]<=G+mult1+mult2;
			un5 <= un3;
				un3 <= un1;
				un1 <= up1;
				up1<=up3;
				up3 <= up5;
				
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp1;
				vp1 <= vp3;
				vp3<=vp5;
		if (ucounter<18'd160) begin
			m1state<=cc1;
		end else begin
		m1end<=1'b1;
		end
			end		
			
			
//		lo0:begin
//			SRAM_we_n <= 18'b0;
//			SRAM_address <= RGBaddy + rgbcounter;
//			rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Rout[0],Gout[0]};
//			Gout[1]<=Gc[1];
//			
//			op1 <= {24'd0,un5};
//			op2 <= jn5;
//			op3 <= {24'd0,un3};
//			op4 <= jn3;
//			op5 <= {24'd0,un1};
//			op6 <= jn1;
//			m1state<=lo1;
//			end
//		lo1:begin
//			SRAM_address <= RGBaddy + rgbcounter;//146944
//			rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Bout[0],Rout[1]};
//			upodd<=mult1+mult2+mult3;
//			ubuffereven<={24'd0,un3}-32'd128;
//			op1 <= {24'd0,up5};
//			op2 <= jp5;
//			op3 <= {24'd0,up3};
//			op4 <= jp3;
//			op5 <= {24'd0,up1};
//			op6 <= jp1;
//			m1state<=lo2;
//			end
//		lo2:begin
//				SRAM_address <= RGBaddy + rgbcounter;//146944
//				rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Gout[1],Bout[1]};
//			ubufferodd<=((upodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
//			ubuffereven<={24'd0,un3}-32'd128;
//			ybuff[0] <= {24'd0,SRAM_read_data[15:8]}-32'd16;
//			ybuff[1] <= {24'd0,SRAM_read_data[7:0]}-32'd16;
//			op1 <= {24'd0,vn5};
//			op2 <= jn5;
//			op3 <= {24'd0,vn3};
//			op4 <= jn3;
//			op5 <= {24'd0,vn1};
//			op6 <= jn1;
//			vbuffereven<={24'd0,vn3}-32'd128;
//		m1state<=lo3;
//			end
//			
//		lo3:begin
//		vpodd<=mult1+mult2+mult3;
//		SRAM_we_n <= 18'b1;
//			op1 <= {24'd0,vp5};
//			op2 <= jp5;
//			op3 <= {24'd0,vp3};
//			op4 <= jp3;
//			op5 <= {24'd0,vp1};
//			op6 <= jp1;
//			
//			
//			
//		m1state<=lo4;
//		
//				end
//				
//		lo4:begin
//		vbufferodd<=((vpodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
//		op1<=a00;
//		op2<=ybuff[0];			
//		op3<=a02;//red
//		op4<=vbuffereven;		
//		op5<=a21;//blue
//		op6<=ubuffereven;
//		
//		m1state<=lo5;
//			end
//			
//		lo5:begin
//		Rbuff[0]<=mult1+mult2;
//		Bbuff[0]<=mult1+mult3;
//		G<=mult1;
//		op1<=a11;
//		op2<=ubuffereven;				
//		op3<=a12;
//		op4<=vbuffereven;
//		m1state<=lo6;
//				end
//				
//		lo6:begin
//		Gbuff[0]<=G+mult1+mult2;
//		Rout[0]<=Rc[0];
//		Bout[0]<=Bc[0];
//		op1<=a00;
//		op2<=ybuff[1];
//		op3<=a02;//red
//		op4<=vbufferodd;
//		op5<=a21;//blue
//		op6<=ubufferodd;
//		m1state<=lo7;
//			end
//			
//		lo7:begin
//			Rbuff[1]<=mult1+mult2;
//			Bbuff[1]<=mult1+mult3;
//			Gout[0]<=Gc[0];
//			G<=mult1;
//			op1<=a11;
//				op2<=ubufferodd;
//				
//				op3<=a12;
//				op4<=vbufferodd;
//		m1state<=lo8;
//			end
//			
//		lo8:begin
//		SRAM_address <= yaddy + ycounter;
//			ycounter <= ycounter + 18'd1;
//			Rout[1]<=Rc[1];
//			Bout[1]<=Bc[1];
//			Gbuff[1]<=G+mult1+mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1<=up3;
//			up3 <= up5;
//
//		m1state<=lo9;
//			end
//			
//		lo9:begin
//		Gout[1]<=Gc[1];
//		select<=1'b0;
//		SRAM_we_n <= 18'b0;
//			SRAM_address <= RGBaddy + rgbcounter;
//			rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Rout[0],Gout[0]};
//			
//			
//			op1 <= {24'd0,un5};
//			op2 <= jn5;
//			op3 <= {24'd0,un3};
//			op4 <= jn3;
//			op5 <= {24'd0,un1};
//			op6 <= jn1;
//			vn5 <= vn3;
//			vn3 <= vn1;
//			vn1 <= vp1;
//			vp1 <= vp3;
//			vp3<=vp5;
//		m1state<=lo10;
//			end
//			
//		lo10:begin
//		SRAM_address <= RGBaddy + rgbcounter;//146944
//				rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Bout[0],Rout[1]};
//			upodd<=mult1+mult2+mult3;
//			ubuffereven<={24'd0,un3}-32'd128;
//			op1 <= {24'd0,up5};
//			op2 <= jp5;
//			op3 <= {24'd0,up3};
//			op4 <= jp3;
//			op5 <= {24'd0,up1};
//			op6 <= jp1;
//		m1state<=lo11;
//			end
//			
//		lo11:begin
//		SRAM_address <= RGBaddy + rgbcounter;//146944
//				rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Gout[1],Bout[1]};
//			ubufferodd<=((upodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
//			ubuffereven<={24'd0,un3}-32'd128;
//			ybuff[0] <= {24'd0,SRAM_read_data[15:8]}-32'd16;
//			ybuff[1] <= {24'd0,SRAM_read_data[7:0]}-32'd16;
//			op1 <= {24'd0,vn5};
//			op2 <= jn5;
//			op3 <= {24'd0,vn3};
//			op4 <= jn3;
//			op5 <= {24'd0,vn1};
//			op6 <= jn1;	
//		vbuffereven<={24'd0,vn3}-32'd128;	
//		m1state<=lo12;
//			end
//			
//		lo12:begin
//				SRAM_we_n <= 18'b1;
//			op1 <= {24'd0,vp5};
//			op2 <= jp5;
//			op3 <= {24'd0,vp3};
//			op4 <= jp3;
//			op5 <= {24'd0,vp1};
//			op6 <= jp1;
//			vpodd<=mult1+mult2+mult3;
//			
//		m1state<=lo13;
//			end
//			
//		lo13:begin
//				op1<=a00;
//		op2<=ybuff[0];			
//		op3<=a02;//red
//		op4<=vbuffereven;		
//		op5<=a21;//blue
//		op6<=ubuffereven;
//		vbufferodd<=((vpodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
//		m1state<=lo14;
//			end
//			
//		lo14:begin
//		Rbuff[0]<=mult1+mult2;
//		Bbuff[0]<=mult1+mult3;
//		G<=mult1;
//		op1<=a11;
//		op2<=ubuffereven;				
//		op3<=a12;
//		op4<=vbuffereven;
//		m1state<=lo15;
//			end
//			
//		lo15:begin
//		ucounter <= ucounter + 18'd1;	
//		Gbuff[0]<=G+mult1+mult2;
//		Rout[0]<=Rc[0];
//		Bout[0]<=Bc[0];
//		op1<=a00;
//		op2<=ybuff[1];
//		op3<=a02;//red
//		op4<=vbufferodd;
//		op5<=a21;//blue
//		op6<=ubufferodd;
//		m1state<=lo16;
//			end
//			
//		lo16:begin
//			vcounter <= vcounter + 18'd1;	
//			select<=1'b1;
//			Rbuff[1]<=mult1+mult2;
//			Bbuff[1]<=mult1+mult3;
//			Gout[0]<=Gc[0];
//			G<=mult1;
//			op1<=a11;
//				op2<=ubufferodd;
//				op3<=a12;
//				op4<=vbufferodd;
//		m1state<=lo17;
//			end
//			
//		lo17:begin
//		SRAM_address <= yaddy + ycounter;
//			ycounter <= ycounter + 18'd1;
//			Rout[1]<=Rc[1];
//			Bout[1]<=Bc[1];
//			Gbuff[1]<=G+mult1+mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1 <= up3;
//			up3 <= up5;
//			end
//			
//		lo18:begin
//			SRAM_we_n <= 18'b0;
//			SRAM_address <= RGBaddy + rgbcounter;
//			rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Rout[0],Gout[0]};
//			Gout[1]<=Gc[1];
//			
//			op1 <= {24'd0,un5};
//			op2 <= jn5;
//			op3 <= {24'd0,un3};
//			op4 <= jn3;
//			op5 <= {24'd0,un1};
//			op6 <= jn1;
//			m1state<=lo19;
//			end
//		lo19:begin
//			SRAM_address <= RGBaddy + rgbcounter;//146944
//			rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Bout[0],Rout[1]};
//			upodd<=mult1+mult2+mult3;
//			ubuffereven<={24'd0,un3}-32'd128;
//			op1 <= {24'd0,up5};
//			op2 <= jp5;
//			op3 <= {24'd0,up3};
//			op4 <= jp3;
//			op5 <= {24'd0,up1};
//			op6 <= jp1;
//			m1state<=lo20;
//			end
//		lo20:begin
//				SRAM_address <= RGBaddy + rgbcounter;//146944
//				rgbcounter <= rgbcounter + 18'd1;
//			SRAM_write_data <= {Gout[1],Bout[1]};
//			ubufferodd<=((upodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
//			ubuffereven<={24'd0,un3}-32'd128;
//			ybuff[0] <= {24'd0,SRAM_read_data[15:8]}-32'd16;
//			ybuff[1] <= {24'd0,SRAM_read_data[7:0]}-32'd16;
//			op1 <= {24'd0,vn5};
//			op2 <= jn5;
//			op3 <= {24'd0,vn3};
//			op4 <= jn3;
//			op5 <= {24'd0,vn1};
//			op6 <= jn1;
//			vbuffereven<={24'd0,vn3}-32'd128;
//		m1state<=lo21;
//			end
//			
//		lo21:begin
//		vpodd<=mult1+mult2+mult3;
//		SRAM_we_n <= 18'b1;
//			op1 <= {24'd0,vp5};
//			op2 <= jp5;
//			op3 <= {24'd0,vp3};
//			op4 <= jp3;
//			op5 <= {24'd0,vp1};
//			op6 <= jp1;
//			
//			
//			
//		m1state<=lo22;
//		
//				end
//				
//		lo22:begin
//		vbufferodd<=((vpodd+mult1+mult2+mult3+ 32'd128)>>>8)-32'd128;
//		op1<=a00;
//		op2<=ybuff[0];			
//		op3<=a02;//red
//		op4<=vbuffereven;		
//		op5<=a21;//blue
//		op6<=ubuffereven;
//		
//		m1state<=lo23;
//			end
//			
//		lo23:begin
//		Rbuff[0]<=mult1+mult2;
//		Bbuff[0]<=mult1+mult3;
//		G<=mult1;
//		op1<=a11;
//		op2<=ubuffereven;				
//		op3<=a12;
//		op4<=vbuffereven;
//		m1state<=lo24;
//				end
//				
//		lo24:begin
//		Gbuff[0]<=G+mult1+mult2;
//		Rout[0]<=Rc[0];
//		Bout[0]<=Bc[0];
//		op1<=a00;
//		op2<=ybuff[1];
//		op3<=a02;//red
//		op4<=vbufferodd;
//		op5<=a21;//blue
//		op6<=ubufferodd;
//		m1state<=lo25;
//			end
//			
//		lo25:begin
//			Rbuff[1]<=mult1+mult2;
//			Bbuff[1]<=mult1+mult3;
//			Gout[0]<=Gc[0];
//			G<=mult1;
//			op1<=a11;
//				op2<=ubufferodd;
//				
//				op3<=a12;
//				op4<=vbufferodd;
//		m1state<=lo26;
//			end
//			
//		lo26:begin
//		SRAM_address <= yaddy + ycounter;
//			ycounter <= ycounter + 18'd1;
//			Rout[1]<=Rc[1];
//			Bout[1]<=Bc[1];
//			Gbuff[1]<=G+mult1+mult2;
//			un5 <= un3;
//			un3 <= un1;
//			un1 <= up1;
//			up1<=up3;
//			up3 <= up5;
//			m1end <= 1'b1;
//		
//			end
		endcase
end
end
endmodule
