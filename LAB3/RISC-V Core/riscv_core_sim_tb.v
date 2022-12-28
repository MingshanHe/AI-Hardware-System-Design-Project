`timescale 1ns/1ps


module riscv_core_sim_tb ();

	reg reset_i;
	reg clk_i;

	// Input instruction
	reg  [31:0] iaddr_i;
	reg  	       ird_i;
	reg [31:0] daddr_i;
	reg [31:0] dwdata_i;
	reg [1:0]   dsize_i;
	reg	      drd_i;
	reg 	      dwr_i;
	// Outputs
	wire [31:0] irdata_o;
	wire [31:0] drdata_o;

	// Input instruction
	reg  [31:0] if_opcode_w;
	// Outputs
	wire [31:0] id_imm_w;
	wire [4:0] id_rd_index_w;
	wire [4:0] id_ra_index_w;
	wire [4:0] id_rb_index_w;
	wire [3:0] id_alu_op_w;
	wire [2:0] id_branch_w;
	wire [1:0] id_mem_size_w;
	//Flags
	wire mulh_w;
	wire mulhsu_w;
	wire div_w;
	wire rem_w;
	wire sra_w;
	wire srai_w;
	wire alu_imm_w;
	wire jal_w;
	wire load_w;
	wire store_w;
	wire lbu_w;
	wire lhu_w;
	wire jalr_w;
	wire id_illegal_w;

	localparam
	  SIZE_BYTE = 2'd0,
	  SIZE_HALF = 2'd1,
	  SIZE_WORD = 2'd2;
  
	//----------------------------------------------------------------
	// Your Memory module
	//----------------------------------------------------------------
	// Memory
	riscv_memory 
	u_memory (
		.clk_i(clk_i),
		.reset_i(reset_i),
		.iaddr_i(iaddr_i),
		.ird_i(ird_i),
		.daddr_i(daddr_i),
		.dwdata_i(dwdata_i),
		.dsize_i(dsize_i),
		.drd_i(drd_i),
		.dwr_i(dwr_i),
		.irdata_o(irdata_o),
		.drdata_o(drdata_o)
	);

	// Decoder
	riscv_decoder
	u_decoder
	(
	./*input  [31:0]*/ if_opcode_w(irdata_o),
	./*output [31:0]*/ id_imm_w(id_imm_w),
	./*output [4:0] */id_rd_index_w(id_rd_index_w),
	./*output [4:0] */id_ra_index_w(id_ra_index_w),
	./*output [4:0] */id_rb_index_w(id_rb_index_w),
	./*output [3:0] */id_alu_op_w(id_alu_op_w),
	./*output [2:0] */id_branch_w(id_branch_w),
	./*output [1:0] */id_mem_size_w(id_mem_size_w),
	//Flags
	./*output */mulh_w(mulh_w),
	./*output */mulhsu_w(mulhsu_w),
	./*output */div_w(div_w),
	./*output */rem_w(rem_w),
	./*output */sra_w(sra_w),
	./*output */srai_w(srai_w),
	./*output */alu_imm_w(alu_imm_w),
	./*output */jal_w(jal_w),
	./*output */load_w(load_w),
	./*output */store_w(store_w),
	./*output */lbu_w(lbu_w),
	./*output */lhu_w(lhu_w),
	./*output */jalr_w(jalr_w),
	./*output */id_illegal_w(id_illegal_w)
	);

	//----------------------------------------------------------------
	// Test bench
	//----------------------------------------------------------------
   // Clock and Reset
   parameter p=10;
   initial begin
   	clk_i = 1'b0;
   	forever #(p/2) clk_i = !clk_i;
   end

   // Test cases	
   initial
   begin:stimuli
		reset_i = 1'b0;	
		iaddr_i = 0;
		ird_i = 0;
		dsize_i=SIZE_WORD;
		#(4*p) reset_i = 1'b1;	

		#(4*p) 	iaddr_i = 32'h0;	
				ird_i = 1'b1;
		#(p)	ird_i = 1'b0;	
				$display("T=%03t ns: %h : %h\n",$realtime/1000, iaddr_i, irdata_o);
		#(4*p) 	iaddr_i = 32'h4;	
				ird_i = 1'b1;
		#(p)	ird_i = 1'b0;	
				$display("T=%03t ns: %h : %h\n",$realtime/1000, iaddr_i, irdata_o);
		#(4*p) 	iaddr_i = 32'h8;	
				ird_i = 1'b1;
		#(p)	ird_i = 1'b0;	
				$display("T=%03t ns: %h : %h\n",$realtime/1000, iaddr_i, irdata_o);
		#(4*p) 	iaddr_i = 32'hd;
				ird_i = 1'b1;
		#(p)	ird_i = 1'b0;	
				$display("T=%03t ns: %h : %h\n",$realtime/1000, iaddr_i, irdata_o);
		#(4*p) 	iaddr_i = 32'h10;
				ird_i = 1'b1;
		#(p)	ird_i = 1'b0;	
				$display("T=%03t ns: %h : %h\n",$realtime/1000, iaddr_i, irdata_o);
		
		//#(4*p) if_opcode_w = 32'h000404b3;
	
		//#(4*p) if_opcode_w = 32'h00000533;
	
		//#(4*p) if_opcode_w = 32'h000005b3;
	
		//#(4*p) if_opcode_w = 32'h0004a603;
		
		//#(4*p) if_opcode_w = 32'h00c50533;

		//#(4*p) if_opcode_w = 32'h00040483;
   end
endmodule

