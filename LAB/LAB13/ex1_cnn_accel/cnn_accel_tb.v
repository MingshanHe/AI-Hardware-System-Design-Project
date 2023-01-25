`timescale 1ns / 100ps
`include "amba_ahb_h.v"
`include "map.v"

module cnn_accel_tb;
parameter W_ADDR=32;
parameter W_DATA=32;
parameter IMG_PIX_W = 8;

//parameter WIDTH 	= 768,
//		HEIGHT 	= 512,
parameter   WIDTH 	= 128,
			HEIGHT 	= 128,		
			START_UP_DELAY = 200,
			HSYNC_DELAY = 160,
			FRAME_SIZE = WIDTH * HEIGHT;
localparam W_SIZE  = 12;					// Max 4K QHD (3840x1920).
localparam W_FRAME_SIZE  = 2 * W_SIZE + 1;	// Max 4K QHD (3840x1920).
localparam W_DELAY = 12;

parameter  N_LAYER = 3;
parameter Ti = 16;	// Each CONV kernel do 16 multipliers at the same time	
//parameter To = 4;	// Run 4 CONV kernels at the same time
parameter To = 16;	// Run 16 CONV kernels at the same time
parameter N  = 16;
// Inputs
reg HCLK;
reg HRESETn;

wire	[31:0]	w_RISC2AHB_mst_HRDATA      ;
wire	[1:0]	w_RISC2AHB_mst_HRESP       ;
wire			w_RISC2AHB_mst_HREADY      ;
wire	[31:0]	w_RISC2AHB_mst_HADDR       ;
wire	[31:0]	w_RISC2AHB_mst_HWDATA      ;
wire			w_RISC2AHB_mst_HWRITE      ;
wire	[2:0]	w_RISC2AHB_mst_HSIZE       ;
wire	[`W_BURST-1:0]	w_RISC2AHB_mst_HBURST;
wire	[1:0]	w_RISC2AHB_mst_HTRANS      ;


reg [W_SIZE-1 :0] 		q_width;
reg [W_SIZE-1 :0] 		q_height;
reg [W_DELAY-1:0] 		q_start_up_delay;
reg [W_DELAY-1:0] 		q_hsync_delay;
reg [W_FRAME_SIZE-1:0] 	q_frame_size;
reg 					q_layer_start;
reg [3:0]				q_layer_index;
reg 					q_layer_done;
reg [31:0]  q_layer_config;
reg [2:0] 	q_act_shift   [0:N_LAYER-1];
reg [4:0] 	q_bias_shift  [0:N_LAYER-1];
reg 	  	q_is_conv3x3  [0:N_LAYER-1];
reg [7:0] 	q_in_channels [0:N_LAYER-1];
reg [7:0] 	q_out_channels[0:N_LAYER-1];
reg 		q_is_first_layer;
reg 		q_is_last_layer;
reg 		q_conv_type;
reg         is_conv3x3;
reg [19:0] 	base_addr_weight;
reg [11:0] 	base_addr_param;

reg [W_DATA-1:0] rdata;
reg [W_ADDR-1:0] i;
reg image_load_done;
integer idx;
//---------------------------------------------------------------
// Master
//---------------------------------------------------------------

ahb_master u_riscv_dummy(      
	 .HRESETn		(HRESETn			)
	,.HCLK   		(HCLK				)
	,.i_HRDATA		(w_RISC2AHB_mst_HRDATA  	)
	,.i_HRESP 		(w_RISC2AHB_mst_HRESP   	)
	,.i_HREADY		(w_RISC2AHB_mst_HREADY  	)
	,.o_HADDR 		(w_RISC2AHB_mst_HADDR   	)
	,.o_HWDATA		(w_RISC2AHB_mst_HWDATA  	)
	,.o_HWRITE		(w_RISC2AHB_mst_HWRITE  	)
	,.o_HSIZE 		(w_RISC2AHB_mst_HSIZE   	)
	,.o_HBURST		(w_RISC2AHB_mst_HBURST  	)
	,.o_HTRANS		(w_RISC2AHB_mst_HTRANS  	)
	);
//---------------------------------------------------------------
// Slave
//---------------------------------------------------------------
cnn_accel u_cnn_accel (
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.sl_HREADY(1'b1), 
	.sl_HSEL(1'b1), 
	.sl_HTRANS(w_RISC2AHB_mst_HTRANS), 
	.sl_HBURST(w_RISC2AHB_mst_HBURST), 
	.sl_HSIZE(w_RISC2AHB_mst_HSIZE), 
	.sl_HADDR(w_RISC2AHB_mst_HADDR), 
	.sl_HWRITE(w_RISC2AHB_mst_HWRITE), 
	.sl_HWDATA(w_RISC2AHB_mst_HWDATA),
	.out_sl_HREADY(w_RISC2AHB_mst_HREADY), 
	.out_sl_HRESP(w_RISC2AHB_mst_HRESP), 
	.out_sl_HRDATA(w_RISC2AHB_mst_HRDATA) 
	);

//---------------------------------------------------------------
// Test vectors
//---------------------------------------------------------------
//---------------------------------------------------------------
// Test vectors
//---------------------------------------------------------------
// Clock
parameter p = 10;	//100MHz
initial begin
	HCLK = 1'b0;
	forever #(p/2) HCLK = ~HCLK;
end

initial begin
	// Initialize Inputs
	HRESETn = 0;
	q_width 			= WIDTH;
	q_height 			= HEIGHT;
	q_start_up_delay 	= START_UP_DELAY;
	q_hsync_delay 		= HSYNC_DELAY;
	q_frame_size 		= FRAME_SIZE;
	q_layer_index		= 4'd0;
	q_layer_done		= 1'b0;
	q_is_first_layer	= 1'b0;
	q_is_last_layer		= 1'b0;
	q_layer_config		= 32'h0;
	
	// Define Network's parameters
	q_bias_shift[0] = 9 ; q_act_shift[0] = 7; q_is_conv3x3[0] = 0;
	q_bias_shift[1] = 17; q_act_shift[1] = 7; q_is_conv3x3[1] = 1;
	q_bias_shift[2] = 17; q_act_shift[2] = 7; q_is_conv3x3[2] = 1;
	// Loop/Layer index
	idx = 0;
	
	// Weight/bias/Scale base addresses
	base_addr_weight 	= 0;
	base_addr_param		= 0;	
	
	// Initialize RISCV dummy core
	u_riscv_dummy.task_AHBinit();
	
	// Memory
	rdata = 0;
	i = 0;
	image_load_done = 0;
	
	
	#(p/2) HRESETn = 1;
	//*******************************************************************************************************
	// CNN Accelerator configuration
	//*******************************************************************************************************	
	#(100*p) 	
	#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_FRAME_SIZE		, q_frame_size 		);
	#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_WIDTH_HEIGHT 	, {q_height&16'hFFFF,q_width&16'hFFFF});
	#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_DELAY_PARAMS	, {q_hsync_delay,q_start_up_delay});	
			
	//*******************************************************************************************************
	// Loop
	//*******************************************************************************************************
	//idx = 0; 	// Layer 1
	for(idx = 0; idx <N_LAYER; idx=idx+1) begin
		q_layer_index 		= idx;
		q_is_last_layer 	= (idx == N_LAYER-1)?1'b1:1'b0;
		q_is_first_layer	= (idx == 0) ? 1'b1: 1'b0;
		is_conv3x3          = q_is_conv3x3[idx]; 
		q_layer_config 		= {q_act_shift[idx], q_bias_shift[idx], q_layer_index, q_is_last_layer, is_conv3x3, q_is_last_layer, q_is_first_layer};			
		#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_BASE_ADDRESS, {base_addr_param&12'hFFF,base_addr_weight&20'hFFFFF});		
		#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_LAYER_CONFIG, q_layer_config);				
		// Start a frame
		#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_LAYER_START	, 1'b1 );	
		#(4*p) @(posedge HCLK) 	u_riscv_dummy.task_AHBwrite(`CNN_ACCEL_LAYER_START	, 1'b0 );
		
		// Polling
		while(!q_layer_done) begin
			#(128*p) @(posedge HCLK)  u_riscv_dummy.task_AHBread(`CNN_ACCEL_LAYER_DONE,q_layer_done);
		end
		#(128*p) @(posedge HCLK) $display("T=%03t ns: Layer %0d done!!!\n", $realtime/1000, idx+1);
		// Reset q_layer_done 
		q_layer_done = 0;
		
		// Update the base addresses
		if(q_is_conv3x3[idx]) begin
			base_addr_weight 	= base_addr_weight 	+ (Ti*To*9)/N;
			base_addr_param		= base_addr_param 	+ To;			
		end
		else begin
			base_addr_weight 	= base_addr_weight 	+ To;
			base_addr_param		= base_addr_param 	+ To;		
		end
	
	end

end


endmodule