module dengt(
out ,//Counter output
//datatemp , //Parallel load
//load , //Parallel load enable
//enable,  // enable counting
CLOCK_50,  // clock input
SW,HEX1, HEX0,  LEDR , KEY, LEDG, HEX5, HEX4,
Q,	// Output LED
 );
 //---------- Output Ports-------
 output [7:0] out;		// to 7 segment
 output [2:0] Q;			// to 3 lights
 output [17:0] LEDR;		
  output [8:0] LEDG;
 output [0:6] HEX1, HEX0, HEX5,HEX4;

 //---------- Input Ports-------
 //input [7:0] datatemp;
 input  CLOCK_50;	// raw clock input
 input [0:3] KEY;
  //---------- Internal Variables-------
  input [17:0] SW;
  reg [2:0] Q;
  reg [9:0] out;
  reg [3:0] base;		// base = 0001 for countdown
  reg [7:0] dataR;	// value of RED
  wire [7:0] datatemp;	// temporary data for Load
  reg [7:0] dataY;	//value of Yellow
  reg [7:0] dataG;	//value of Green
  reg tempG8,Qstand;		// tempg8 for invalid in Configure mod, Qstand for standby mod
wire loadr,loadg,loady,enable,reset,skip,standby;	// loadr, loadg, loady for Loadmod, enable to switch between 2 mods, reset mod, skip mod, standby mod
wire [1:0] emergency; //emergency mod
  initial 	// operate 1 time before main block
  begin 
	base = 4'b0001;		// for countdown = countdown -1 
	
	dataR[7:0] = 8'b00110101;  //35s in BCD
	dataG[7:0] = 8'b00100101;	//25s in BCD
    dataY[7:0] = 8'b00000100; //4s in BCD
	 Q[2] = 1;						// Green to Red fisrt
			Q[1] = 0; 				//
				 Q[0] = 0; 		// Q[0] , Q[1], Q[2] : Red, Yellow, Green, respectively
					
	
	end
  //--------Main Block-----
 
  
   

	
	
 reg [25:0] accum = 0;	// for 1s clock pulse
wire pps = (accum == 0);
 reg [25:0] accum2 = 0;// for acsync clock pulse
wire acs = (accum2 == 0);
 assign datatemp[7:0]=SW[7:0];	// Load data Mod
  assign enable =SW[8] ;		// Enable Switch
	assign standby = SW[15] ;	
		assign loadr = SW[9];
			assign	loady = SW[10];
				assign loadg = SW[11];
					assign LEDR[16:3] = 14'b0;	// These LEDs are not used
						assign reset = KEY[3];	
							assign skip = KEY[2];
								assign emergency[0] = KEY[1];
						
	
	assign LEDR[2:0] = Q[2:0];
	assign LEDG[8] = tempG8;
b2d_7seg A (out[4:0], HEX0);	// output timer to Led7Seg
b2d_7seg B (out[9:5], HEX1);
emG G (emergency, HEX5);// output emergency to Led7Seg
emo o (emergency, HEX4);


always  @(posedge CLOCK_50)	// raw clock
begin

	accum <= (pps ? 50_000_000 : accum) - 1;	// for 1s clock pulse
	accum2 <= (acs ? 00_001_000 : accum2) - 1;  // for acsync clock pulse
                                             
    if (pps) begin
       // … things to do once per second …
		 
					
	if (~skip) 
				begin
					out[3:0] = 0; out[8:5]=0;
				end
    if (~reset) 
				begin
					Q[2]=1;Q[0] =0;Q[1]=0; dataR[7:0] = 8'b00110101; dataG[7:0] = 8'b00100101; dataY[7:0] = 8'b00000100;
					out[3:0] = 0; out[8:5]=0;
				end

	//else 
 if (enable)
	
		
			begin
				if (standby) begin  Q[1] = Qstand;Qstand <= ~Qstand;out[4]<=1'b0;Q[2] = 0; Q[0] = 0; out[9]<=1'b0;
							 end
					else 
					begin 
					out[4]<=1'b1;	//turn on Led7segment
					out[9]<=1'b1;		
					if ((Q[1] == 0) && (Q[0] ==0)&&(Q[2] == 0)) begin Q[2] = 1;Q[1] = 0;  Q[0] = 0; end //in case there is no lights initially
					else if ((out[8:5]==4'b0000) && (out[3:0]==4'b0000))
					begin 
						
						if ((Q[1] == 0) && (Q[0] == 0)&&(Q[2] == 1)) begin Q[2]=0;Q[0]=1; out[8:5] <= dataR[7:4]; out[3:0] <= dataR[3:0];end		//Green to Red
							else if ((Q[1] == 1) && (Q[0] ==0)&&(Q[2] == 0)) begin Q[2]=1;Q[1]=0; out[8:5] <= dataG[7:4]; out[3:0] <= dataG[3:0]; end   //Red to Amber
								else if ((Q[1] == 0) && (Q[0] ==1)&&(Q[2] == 0) ) begin Q[1]=1;Q[0] =0; out[8:5] <= dataY[7:4]; out[3:0] <= dataY[3:0]; end	  //Amber to Green
					end
					else if (out[3:0]==4'b0000) begin out[8:5]<=(out[8:5]-base); out[3:0]=4'b1001; end	
					else out[3:0]<=(out[3:0]-base);		// countdown = countdown - 1 ;
					end
			
	
			end//end enable
	
	
    end //endposclock1s
	
if (acs) 
	begin
		
			
			if (~enable) //things to do when no enble/ confuge mod
				begin
				
		 if ((SW[12]==1 && SW[13]==1 )||(SW[12]==1 && SW[14]==1 )||(SW[13]==1 && SW[14]==1 )) 	//invalid Configure mod
						begin 
								tempG8 = 1;Q[1] = 0;	Q[0] =0 ;	Q[2] = 0;
						end
				else begin 
				out[4]<=1'b0;
				out[9]<=1'b0;
				Q[0] = SW[12];
				
				Q[1] = SW[13];
				
				Q[2] = SW[14];
				
				tempG8 = 0;
				end
			 if (loadr) 
		 
				begin
					
					dataR[7:4] <= datatemp[7:4];
  				   dataR[3:0] <= datatemp[3:0];
					//out[3:0]<=(out[3:0]-base);
				end
			else  if (loady) 
		 
				begin
					
					dataY[7:4] <= datatemp[7:4];
  				   dataY[3:0] <= datatemp[3:0];
					//out[3:0]<=(out[3:0]-base);
				end
			else  if (loadg) 
		 
				begin
					
					dataG[7:4] <= datatemp[7:4];
  				   dataG[3:0] <= datatemp[3:0];
					//out[3:0]<=(out[3:0]-base);
				end
		//	else if (~emergency) 
		//			begin
						//HEX3[6]=1;HEX3[5]=1;HEX3[4]=1;HEX3[3]=1;HEX3[2]=1;HEX3[0]=1;
						//HEX4[6]=1; HEX4[4]=1;HEX4[3]=1;HEX4[2]=1;
						
			//		end
		
			 
				
				end
			end  //end acsync
end //endrawclock
	
 endmodule
   

module b2d_7seg (X, SSD);
  input [4:0] X;
  output [0:6] SSD;
	
  assign SSD[0]  = (~X[4])|((~X[3] & ~X[2] & ~X[1] &  X[0]) | (~X[3] &  X[2] & ~X[1] & ~X[0]))  ;
  assign SSD[1] = (~X[4])|((~X[3] &  X[2] & ~X[1] &  X[0]) | (~X[3] &  X[2] &  X[1] & ~X[0]));
  assign SSD[2] = (~X[4])|(~X[3] & ~X[2] &  X[1] & ~X[0] );
  assign SSD[3] = (~X[4])|((~X[3] & ~X[2] & ~X[1] &  X[0]) | (~X[3] &  X[2] & ~X[1] & ~X[0]) | (~X[3] &  X[2] & X[1] & X[0]) | (X[3] & ~X[2] & ~X[1] & X[0]));
  assign SSD[4] = (~X[4])|(~((~X[2] & ~X[0]) | (X[1] & ~X[0])));
  assign SSD[5] = (~X[4])|((~X[3] & ~X[2] & ~X[1] &  X[0]) | (~X[3] & ~X[2] &  X[1] & ~X[0]) | (~X[3] & ~X[2] & X[1] & X[0]) | (~X[3] & X[2] & X[1] & X[0]));
  assign SSD[6] = (~X[4])|((~X[3] & ~X[2] & ~X[1] &  X[0]) | (~X[3] & ~X[2] & ~X[1] & ~X[0]) | (~X[3] &  X[2] & X[1] & X[0]));
endmodule

module emG(X,SSD);
input [1:0] X;
output [0:6] SSD;
assign	SSD[6]=X[0];
assign	SSD[5]=X[0];
assign	SSD[4]=X[0];
assign	SSD[3]=X[0];
assign	SSD[2]=X[0];
assign	SSD[0]=X[0];
assign	SSD[1]=~X[1];
						
endmodule
module emo(X,SSD);
input [1:0]X;
output [0:6] SSD;
assign	SSD[6]=(X[0]);
assign	SSD[5]=(~X[1]);
assign	SSD[1]=(~X[1]);
assign	SSD[0]=(~X[1]);
assign	SSD[2]=(X[0]);
assign	SSD[3]=(X[0]);
assign	SSD[4]=(X[0]);
endmodule
 
	