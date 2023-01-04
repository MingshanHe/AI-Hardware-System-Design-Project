`include "amba_ahb_h.v"
`include "map.v"	
module top_system(
// Inputs
input HCLK,
input HRESETn
//// Select signals
//input sl_HSEL_alu,
//input sl_HSEL_multiplier
);

reg sl_HSEL_alu;
reg sl_HSEL_multiplier;

reg sl_HSEL_alu_d;
reg sl_HSEL_multiplier_d;

wire	[31:0]	w_RISC2AHB_mst_HADDR       ;
wire	[31:0]	w_RISC2AHB_mst_HWDATA      ;
wire		w_RISC2AHB_mst_HWRITE      ;
wire	[2:0]	w_RISC2AHB_mst_HSIZE       ;
wire	[`W_BURST-1:0]	w_RISC2AHB_mst_HBURST      ;
wire	[1:0]	w_RISC2AHB_mst_HTRANS      ;

// Inputs for Master
reg 	[31:0]	w_RISC2AHB_mst_HRDATA      ;
reg 	[1:0]	w_RISC2AHB_mst_HRESP       ;
reg 		    w_RISC2AHB_mst_HREADY      ;

// ALU
wire	[31:0]	w_RISC2AHB_alu_HRDATA      ;
wire	[1:0]	w_RISC2AHB_alu_HRESP       ;
wire		    w_RISC2AHB_alu_HREADY      ;
// Multiplier
wire	[31:0]	w_RISC2AHB_mul_HRDATA      ;
wire	[1:0]	w_RISC2AHB_mul_HRESP       ;
wire		    w_RISC2AHB_mul_HREADY      ;
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
// ALU
riscv_alu_if u_riscv_alu_if (
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.sl_HREADY(1'b1), 
	.sl_HSEL(sl_HSEL_alu), 
	.sl_HTRANS(w_RISC2AHB_mst_HTRANS), 
	.sl_HBURST(w_RISC2AHB_mst_HBURST), 
	.sl_HSIZE(w_RISC2AHB_mst_HSIZE), 
	.sl_HADDR(w_RISC2AHB_mst_HADDR), 
	.sl_HWRITE(w_RISC2AHB_mst_HWRITE), 
	.sl_HWDATA(w_RISC2AHB_mst_HWDATA),
	.out_sl_HREADY(w_RISC2AHB_alu_HREADY), 
	.out_sl_HRESP( w_RISC2AHB_alu_HRESP), 
	.out_sl_HRDATA(w_RISC2AHB_alu_HRDATA) 
	);
	
// Multiplier
riscv_multiplier_if u_riscv_multiplier_if (
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.sl_HREADY(1'b1), 
	.sl_HSEL(sl_HSEL_multiplier), 
	.sl_HTRANS(w_RISC2AHB_mst_HTRANS), 
	.sl_HBURST(w_RISC2AHB_mst_HBURST), 
	.sl_HSIZE(w_RISC2AHB_mst_HSIZE), 
	.sl_HADDR(w_RISC2AHB_mst_HADDR), 
	.sl_HWRITE(w_RISC2AHB_mst_HWRITE), 
	.sl_HWDATA(w_RISC2AHB_mst_HWDATA),
	.out_sl_HREADY(w_RISC2AHB_mul_HREADY), 
	.out_sl_HRESP( w_RISC2AHB_mul_HRESP), 
	.out_sl_HRDATA(w_RISC2AHB_mul_HRDATA) 
	);
	
//---------------------------------------------------------------
// Select
//---------------------------------------------------------------
always@(*) begin
	sl_HSEL_alu = 1'b0;
	sl_HSEL_multiplier =1'b0;
	//Insert your code
	//{{{
	if(w_RISC2AHB_mst_HADDR>=`RISCV_ALU_BASE_ADDR && w_RISC2AHB_mst_HADDR < `RISCV_MULTIPLIER_BASE_ADDR)
	begin
		sl_HSEL_alu <= 1'b1;
		sl_HSEL_multiplier <= 1'b0;
	end
	else if(w_RISC2AHB_mst_HADDR>=`RISCV_MULTIPLIER_BASE_ADDR)
	begin
		sl_HSEL_alu <= 1'b0;
		sl_HSEL_multiplier <= 1'b1;
	end
	//}}}
end

// Assume a readout data is available after one cycle
always @(posedge HCLK or negedge HRESETn)
begin
	if(~HRESETn)
	begin
		sl_HSEL_alu_d <= 1'b0;
		sl_HSEL_multiplier_d <= 1'b0;
	end	
	else begin
		sl_HSEL_alu_d <= sl_HSEL_alu;
		sl_HSEL_multiplier_d <= sl_HSEL_multiplier;	
	end
end

always@(*) begin
	// WARNINGS: Assume a read data is available after one cycle
	// => sl_HSEL_alu_d is used instead of sl_HSEL_alu. 
	// Master accesses ALU
	if(sl_HSEL_alu_d == 1'b1) begin
		w_RISC2AHB_mst_HRDATA   = w_RISC2AHB_alu_HRDATA      ;
		w_RISC2AHB_mst_HRESP    = w_RISC2AHB_alu_HRESP       ;
		w_RISC2AHB_mst_HREADY   = w_RISC2AHB_alu_HREADY      ;	
	end
	// Master accesses Multiplier 
	else begin
		w_RISC2AHB_mst_HRDATA   = w_RISC2AHB_mul_HRDATA/*Insert your code*/  ;
		w_RISC2AHB_mst_HRESP    = w_RISC2AHB_mul_HRESP       ;
		w_RISC2AHB_mst_HREADY   = w_RISC2AHB_mul_HREADY      ;		
	end
end
endmodule