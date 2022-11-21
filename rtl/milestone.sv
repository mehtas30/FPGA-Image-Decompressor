`include "define_state.h"

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

logic[7:0] upeven;
logic[7:0] upodd;
logic[7:0] ubufferodd;
logic[7:0] ubuffereven;

logic[7:0] vpeven;
logic[7:0] vpodd;
logic[7:0] vbufferodd;
logic[7:0] vbuffereven;

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
logic [7:0]ubuff[1:0];
logic [7:0]vbuff[1:0];

logic [1:0] fixed;

logic [31:0] R;
logic [31:0] G;
logic [31:0] B;

logic [31:0] Rbuff;
logic [31:0] Gbuff;
logic [31:0] Bbuff;

logic [1:0] evenodd;

logic [31:0] op1,op2,op3,op4,op5,op6;
logic [31:0] mult1,mult2,mult3;
logic [63:0] multlong1, multlong2, multlong3;

//logic counter 
logic [17:0] ucounter;
logic [17:0] vcounter;
logic [17:0] ycounter;
logic [17:0] rgbcounter;
//coeffs
parameter signed jn5= 18'd21;
parameter signed jn3= -18'd52;
parameter signed jn1= 18'd159;
parameter signed jp1= 18'd159;
parameter signed jp3= -18'd52;
parameter signed jp5= 18'd21;

parameter signed a00=18'd76284;
parameter signed a02=18'd104595;
parameter signed a11=-18'd25624;
parameter signed a12=-18'd53281;
parameter signed a21=18'd132251;

always_comb
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
		vbufferodd<=8'd0;
		vbuffereven<=8'd0;

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
		ubuff[0]<=8'd0;
		ubuff[1]<=8'd0;
		vbuff[0]<=8'd0;
		vbuff[1]<=8'd0;
		

		R<=32'd0;
		G<=32'd0;
		B<=32'd0;

		Rbuff<=32'd0;
		Gbuff<=32'd0;
		Bbuff<=32'd0;
		
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
					SRAM_address <= uaddy;//uou1
					ucounter<= 18'd0;
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
					vbufferodd<=8'd0;
					vbuffereven<=8'd0;
					
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
					
					Rbuff<=32'd0;
					Gbuff<=32'd0;
					Bbuff<=32'd0;					
					
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
				SRAM_address <= vaddy; //v0v1
				vcounter <= vcounter + 18'd1;
				ucounter<= ucounter + 18'd1;
				m1state <= li1;
			end
			li1:begin 
				SRAM_address <= uaddy + ucounter; //u2u3
				m1state <= li2;
			end 
			li2:begin
				SRAM_address <= vaddy + vcounter; //v2v3
				vcounter <= vcounter + 18'd1;
				ucounter<= ucounter + 18'd1;
				//reading u0u1
				un5<=SRAM_read_data[7:0];
				un3<=SRAM_read_data[7:0];
				un1<=SRAM_read_data[7:0];
				up1<=SRAM_read_data[7:0];
				up3<=SRAM_read_data[7:0];
				up5<=SRAM_read_data[15:8];
				upeven <= SRAM_read_data[7:0]- 8'd128;//u0
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
				vpeven <= SRAM_read_data[7:0] - 8'd128;//v0
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
				ybuff[0]<=SRAM_read_data[7:0] - 8'd16;
				ybuff[1]<=SRAM_read_data[15:8] - 8'd16;
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
				upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;//j5+j3+j1+j1+j3+j5
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
				vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;//j5+j3+j1+j1+j3+j5
				ubufferodd <= upodd;
				Rbuff<=R+mult3;//A02
				op5 <= a21; 
				op6<=	ubuffereven;
				m1state <= li10;
			end
			li10:begin
				SRAM_address <= uaddy + ucounter; //u4u5
				vbufferodd <= vpodd;
				ucounter<= ucounter + 18'd1;
				Bbuff<=B+mult3;
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
				Gbuff<=G+mult3;
				evenodd <= 1'b1;
				m1end<=1'b1;
				op5 <= a00;
				op6 <= ybuff[1];
				un5 <= un3;
				un3 <= un1;
				un1 <= up3;
				up3 <= up5;
					
			end
			cc1:begin
				up5 <= SRAM_read_data[7:0];
				ubuff[0] <= SRAM_read_data[15:8];
				op1 <= un5;
				op2 <= jn5;
				op5 <= a02;
				vn5 <= vn3;
				vn3 <= vn1;
				vn1 <= vp3;
				vp3 <= vp5;
				if(evenodd) begin
					vbufferodd <= vpodd;
					op6 <= ubufferodd;
				end else begin
					vbuffereven <= vpeven;
					op6 <= ubuffereven;
				end
				R<= mult3;
				G <= mult3;
				B <= mult3;
				m1state <= cc2;
			end
			
			cc2:begin
				upeven <= un1;
				upodd <= mult1;
				vp5 <= SRAM_read_data[7:0];
				vbuff[0] <= SRAM_read_data[15:8];
				op1 <= jn3;
				op2 <= un3;
				op3 <= jn5;
				op4 <= vn5;
				op5 <= a21;
				if(evenodd == 1'b0) begin
					Rbuff<=R+mult3;
				end else begin
					R<=R+mult3;
				end
				m1state <= cc3;
			end
			
			
			cc3:begin
				vpeven <= vn1;
				op1 <= jn1;
				op2 <= un1;
				op3 <= jn3;
				op4 <= vn3;
				op5 <= a11;
				if(evenodd == 1'b1)begin
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 18'd1;
					SRAM_write_data<= {Rbuff,Gbuff};
					Rbuff<=R;
				end else begin
					SRAM_write_data<={Gbuff, Bbuff};
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
					op6 <= vbufferodd;
					SRAM_write_data<={Bbuff,Rbuff};
				end else begin
					op6 <= vbuffereven;
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
					op6 <= ybuff[0];
				end else begin
					op6 <= ybuff[1];
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
					SRAM_write_data<={Gbuff,Bbuff};
				end else begin
					op6 <= ubufferodd;
					SRAM_write_data<={Rbuff,Gbuff};
				end
				upodd <= mult1 + upodd;
				vpodd <= mult2 + vpodd;	
				R <= mult3;
				G <= mult3;
				B <= mult3;
				m1state <= cc7;
			end
			
			cc7:begin
				upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
				
				vpodd <= mult2 + vpodd;
				un5 <= un3;
				un3 <= un1;
				un1 <= up3;
				up3 <= up5;
				op3 <= jp5;
				op4 <= vp5;
				op5 <= a21;
				if(evenodd == 1'b1) begin
					R<= mult3 + R;														
				end else begin
					Rbuff<= mult3 + R;
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
					Rbuff<=R;
				end else begin
					SRAM_write_data<={Bbuff, Rbuff};
					SRAM_address <= yaddy + ycounter;
					ycounter <= ycounter + 18'd1;
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
				end else begin
					op6 <= vbufferodd;
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
				if(evenodd == 1'b1) begin
					op6<= ybuff[1];					
				end else begin
					ybuff[0] <= SRAM_read_data[7:0];
					ybuff[1] <= SRAM_read_data[17:8];
					op6 <= SRAM_read_data[7:0];
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
					op6 <= ubufferodd;
					SRAM_write_data<={Rbuff,Gbuff};
				end else begin
					op6 <= ubuffereven;
					SRAM_write_data <= {Gbuff,Bbuff};
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
					
				end else begin
					R <= R + mult3;
				end			
			end	
			cc13:begin
				op1 <= up5;
				op2 <= jp5;
				op3 <= jp3;
				op4 <= vp3;
				op5 <= a11;
				B <= B + mult3;
				if(evenodd == 1'b1) begin
					SRAM_address <= yaddy + ycounter;
					SRAM_write_data<={Bbuff,Rbuff};
				end else begin
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
				Bbuff<=B;
				if(evenodd == 1'b1) begin
					op6 <= vbufferodd;
				end else begin
					op6 <= vbuffereven;
				end
				G <= G + mult3;
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
				Gbuff<=G;
				if(evenodd == 1'b1) begin
					op6 <= SRAM_read_data[7:0];
					ybuff[0] <= SRAM_read_data[7:0];
					ybuff[1] <= SRAM_read_data[17:8];
				end else begin
					op6 <= ybuff[1];
				end
				vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
				evenodd<=~evenodd;
				if (ucounter<18'd160) begin
				m1state<=cc1;
				end else begin
				m1state<=lo0;
				end
			end
	lo0: begin
			vbufferodd <= vpodd;
			op1 <= un5;
			op2 <= jn5;
			op5 <= a02;
			op6 <= ubufferodd;
			upeven <= un1;
			R<= mult3;
			B<= mult3;
			G <= mult3;
			
			
		end
	lo1: begin
			upodd <=upodd + mult1;
			op1 <= un3;
			op2 <= jn3;
			op3 <= vn5;
			op4 <= jn5;
			op5 <= a21;
			upeven <= un1;
			upodd <= mult1;
			R<= R + mult3;
		end
	lo2: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= un1;
			op2 <= jn1;
			op3 <= vn3;
			op4 <= jn3;
			op5 <= a11;
			vpeven <= vn1;
			B <= mult3;
		end
	lo3: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up1;
			op2 <= jp1;
			op3 <= vn1;
			op4 <= jn1;
			op5 <= a12;
			op6 <= vbufferodd;
			ubufferodd <= upodd;
			
			G <= mult3;
		end
	lo4: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up3;
			op2 <= jp3;
			op3 <= vp1;
			op4 <= jp1;
			op5 <= a00;
			op6 <= ybuff[1];
			G <= G + mult3;
		end
	lo5: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up5;
			op2 <= jp5;
			op3 <= vp3;
			op4 <= jp3;
			op5 <= a02;
			op6 <= ubuffereven;
			R <= R + mult3;
			G <= G + mult3;
			B <= B + mult3;
		end
	lo6: begin
			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
			vpodd <=vpodd + mult2;
			un5 <= un3;
			un3 <= un1;
			un1 <= up1;
			up1 <= up3;
			up3 <= up5;
			op3 <= vp5;
			op4 <= jp5;
			op5 <= a21;
			R <= R + mult3;
		end
	lo7: begin
			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
			SRAM_address <= yaddy + ycounter;
			ycounter <= ycounter + 18'd1;
			vn5 <= vn3;
			vn3 <= vn1;
			vn1 <= vp1;
			vp1 <= vp3;
			vp3 <= vp5;
			op1 <= un5;
			op2 <= jn5;
			
			op5 <= a11;
			B <= B + mult3;
			
		end
	lo8: begin
			upodd <=upodd + mult1;
			op1 <= un3;
			op2 <= jn3;
			op3 <= vn5;
			op4 <= jn5;
			upeven <= un1;
			R<= R + mult3;
			G<= G + mult3;
			op5 <= a12;
			op6<= vbuffereven;
		end
	lo9: begin
			ybuff[0] <= SRAM_read_data[7:0];
			ybuff[1] <= SRAM_read_data[17:8];
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= un1;
			op2 <= jn1;
			op3 <= vn3;
			op4 <= jn3;
			vpeven <= vn1;
			G <= G + mult3;
			op5 <= a00;
			op6<= SRAM_read_data[7:0];
			
		end
	lo10: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up1;
			op2 <= jp1;
			op3 <= vn1;
			op4 <= jn1;
			R <= R + mult3;
			G <= G + mult3;
			B <= B + mult3;
			op5 <= a02;
			op6 <= ubufferodd;
		end
	lo11: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up3;
			op2 <= jp3;
			op3 <= vp1;
			op4 <= jp1;
			R <= R + mult3;
			op5 <= a21;
		end
	lo12: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up5;
			op2 <= jp5;
			op3 <= vp3;
			op4 <= jp3;
			B <= B + mult3;
			op5 <= a11;
		end
	lo13: begin
			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
			vpodd <=vpodd + mult2;
			un5 <= un3;
			un3 <= un1;
			un1 <= up1;
			up1 <= up3;
			up3 <= up5;
			op3 <= vp5;
			op4 <= jp5;
			G <= G + mult3;
			op5 <= a12;
		end
	lo14: begin
			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
			G <= G + mult3;
			vn5 <= vn3;
			vn3 <= vn1;
			vn1 <= vp1;
			vp1 <= vp3;
			vp3 <= vp5;
			op1 <= un5;
			op2 <= jn5;
			op5 <= a00;
			op6 <= ybuff[1];
		end
	lo15: begin
			upodd <=upodd + mult1;
			op1 <= un3;
			op2 <= jn3;
			op3 <= un5;
			op4 <= jn5;
			R <= R + mult3;
			G <= G + mult3;
			B <= B + mult3;
			op5 <= a02;
			op6 <= ubuffereven;
		end
	lo16: begin
			op1 <= un1;
			op2 <= jn1;
			op3 <= un3;
			op4 <= jn3;
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			R <= R + mult3;
			op5 <= a21;
		end
	lo17: begin
			SRAM_address <= yaddy + ycounter;
			ycounter <= ycounter + 18'd1;
			op1 <= up1;
			op2 <= jp1;
			op3 <= un1;
			op4 <= jn1;
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			B <= B + mult3;
			op5 <= a11;
		end
	lo18: begin
			op1 <= up3;
			op2 <= jp3;
			op3 <= up1;
			op4 <= jp1;
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			G <= G + mult3;
			op5 <= a12;
		end
	lo19: begin
			ybuff[0] <= SRAM_read_data[7:0];
			ybuff[1] <= SRAM_read_data[17:8];
			op1 <= up5;
			op2 <= jp5;
			op3 <= up3;
			op4 <= jp3;
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			G <= G + mult3;
			op5 <= a00;
			op6 <= SRAM_read_data[7:0];
		end
	lo20: begin
			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
			vpodd <= vpodd + mult2;
			un5 <= un3;
			un3 <= un1;
			un1 <= up1;
			up1 <= up3;
			up3 <= up5;
			op3 <= up5;
			op4 <= jp5;
			R <= R + mult3;
			G <= G + mult3;
			B <= B + mult3;
			op5 <= a02;
			op6 <= ubufferodd;
		end
	lo21: begin
			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
			R <= R + mult3;
			vn5 <= vn3;
			vn3 <= vn1;
			vn1 <= vp1;
			vp1 <= vp3;
			vp3 <= vp5;
			op1 <= un5;
			op2 <= jn5;
			op5 <= a21;
		end
	lo22: begin
			op1 <= un3;
			op2 <= jn3;
			op3 <= un5;
			op4 <= jn5;
			upodd <=upodd + mult1;
			B <= B + mult3;
			op5 <= a11;
		end
	lo23: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= un1;
			op2 <= jn1;
			op3 <= un3;
			op4 <= jn3;
			G <= G + mult3;
			op5 <= a12;
		end
	lo24: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up1;
			op2 <= jp1;
			op3 <= un1;
			op4 <= jn1;
			G <= G + mult3;
			op5 <= a00;
			op6 <= ybuff[1];
		end
	lo25: begin
			upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up3;
			op2 <= jp3;
			op3 <= up1;
			op4 <= jp1;
			R <= R + mult3;
			G <= G + mult3;
			B <= B + mult3;
			op5 <= a02;
			op6 <= ubuffereven;
		end
	lo26: begin
				upodd <=upodd + mult1;
			vpodd <=vpodd + mult2;
			op1 <= up5;
			op2 <= jp5;
			op3 <= up3;
			op4 <= jp3;
			R <= R + mult3;
			op5 <= a21;
		end
	lo27: begin
			upodd <= ((upodd + mult1 + 18'd128)>>>8) - 8'd128;
			vpodd <=vpodd + mult2;
			un5 <= un3;
			un3 <= un1;
			un1 <= up1;
			up1 <= up3;
			up3 <= up5;
			op3 <= up5;
			op4 <= jp5;
			B <= B + mult3;
			op5 <= a11;
		end
	lo28: begin
			vpodd <= ((vpodd + mult2 + 18'd128)>>>8) - 8'd128;
			vn5 <= vn3;
			vn3 <= vn1;
			vn1 <= vp1;
			vp1 <= vp3;
			vp3 <= vp5;
			G <= G + mult3;
			op5 <= a12;
		end
	lo29: begin
			G <= G + mult3;
		end	
		endcase
end
end
endmodule
