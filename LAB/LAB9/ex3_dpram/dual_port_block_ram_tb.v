`timescale 1ns / 100ps

module dual_port_block_ram_tb;

parameter IN_PIXEL_W = 8;
parameter IN_PIXEL_NUM = 16;

parameter W_DATA = 128;
parameter N_CELL = 2192;
parameter W_CELL = $clog2(N_CELL);
parameter FILENAME = "simSR.hex";
parameter N_DELAY = 1;

reg clk;   				// clock input
reg ena; 				// primary enable
reg wea   ; 			// primary synchronous write enable
reg [W_CELL-1:0] addra;	// address for read/write
reg enb;				// read port enable
reg [W_CELL-1:0] addrb;	// address for read
reg [W_DATA-1:0] dia;	// primary data input
wire [W_DATA-1:0] dob;	// primary data output

reg [IN_PIXEL_W-1:0] weight_store [0:IN_PIXEL_NUM-1];
reg [IN_PIXEL_W:0]	 weight [0:IN_PIXEL_NUM-1];

//-----------------------------------------------------
// Component
//-----------------------------------------------------
dual_port_block_ram #(.FILENAME(FILENAME), .W_DATA(W_DATA), .W_CELL(W_CELL),.N_CELL(N_CELL))
u_dual_port_block_ram(
   .clk   (clk   ),
   .ena   (ena   ), 
   .wea   (wea   ), 
   .addra (addra ), 
   .enb   (enb   ),	
   .addrb (addrb ), 
   .dia   (dia   ), 
   .dob   (dob   )  
);

// Clock
parameter CLOCK_PERIOD = 10; 	//100MHz
initial begin
	clk = 1'b0;
	forever #(CLOCK_PERIOD/2) clk = ~clk;
end

integer i;

// load 16 conv. filters of layer 1 from dual_port_block_ram
initial begin
	
	// initialization
	ena = 0; 			
	wea = 0  ; 			
	addra = 0;
	enb = 0; 				
	addrb  = 0;
	dia   = 0;
	
	// set signal for dual_port_block_ram access
	for(i = 0; i < 16; i = i+1/* Insert your code */) begin
		#(4*CLOCK_PERIOD) 	enb = 1'b1;
							/* Insert your code */
							addrb = i;
		#(CLOCK_PERIOD) 	enb = 1'b0;		
							//addrb <= addrb + 'd1;			
	end

end

//-----------------------------------------------------
// Visualize stored weights and weights
//-----------------------------------------------------
integer j;

always@(posedge clk) begin
	if(enb) begin
		// TODO: set 'weight_store' and 'weight'
		/* Insert your code */

		/********************/
		weight_store[0]= dob[0+:IN_PIXEL_W];
		weight_store[1]= dob[8+:IN_PIXEL_W];
		weight_store[2]= dob[16+:IN_PIXEL_W];
		weight_store[3]= dob[24+:IN_PIXEL_W];
		weight_store[4]= dob[32+:IN_PIXEL_W];
		weight_store[5]= dob[40+:IN_PIXEL_W];
		weight_store[6]= dob[48+:IN_PIXEL_W];
		weight_store[7]= dob[56+:IN_PIXEL_W];
		weight_store[8]= dob[64+:IN_PIXEL_W];
		weight_store[9]= dob[72+:IN_PIXEL_W];
		weight_store[10]= dob[80+:IN_PIXEL_W];
		weight_store[11]= dob[88+:IN_PIXEL_W];
		weight_store[12]= dob[96+:IN_PIXEL_W];
		weight_store[13]= dob[104+:IN_PIXEL_W];
		weight_store[14]= dob[112+:IN_PIXEL_W];
		weight_store[15]= dob[120+:IN_PIXEL_W];

		weight[0]= weight_store[0] *2 +1;
		weight[1]= weight_store[1] *2 +1;
		weight[2]= weight_store[2] *2 +1;
		weight[3]= weight_store[3] *2 +1;
		weight[4]= weight_store[4] *2 +1;
		weight[5]= weight_store[5] *2 +1;
		weight[6]= weight_store[6] *2 +1;
		weight[7]= weight_store[7] *2 +1;
		weight[8]= weight_store[8] *2 +1;
		weight[9]= weight_store[9] *2 +1;
		weight[10]= weight_store[10] *2 +1;
		weight[11]= weight_store[11] *2 +1;
		weight[12]= weight_store[12] *2 +1;
		weight[13]= weight_store[13] *2 +1;
		weight[14]= weight_store[14] *2 +1;
		weight[15]= weight_store[15] *2 +1;	
	end
end

endmodule
