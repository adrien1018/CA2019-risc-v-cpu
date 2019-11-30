module EX_MEM (
	       clk,
	       advance_pc_i,
	       alu_result_i,
	       reg_2_data_i,
	       reg_write_i,
	       mem_width_i,
	       mem_sign_extend_i,
	       reg_src_i,
	       mem_write_i,
	       advance_pc_o,
	       alu_result_o,
	       reg_2_data_o,
	       reg_write_o,
	       mem_width_o,
	       mem_sign_extend_o,
	       reg_src_o,
	       mem_write_o
	       );

   input clk;
   input [31:0] advance_pc_i;
   input [31:0] alu_result_i;
   input [31:0] reg_2_data_i;
   input        reg_write_i;
   input [1:0] 	mem_width_i;
   input        mem_sign_extend_i;
   input [1:0] 	reg_src_i;
   input        mem_write_i;

   output [31:0] advance_pc_o;
   output [31:0] alu_result_o;
   output [31:0] reg_2_data_o;
   output        reg_write_o;
   output [1:0]  mem_width_o;
   output        mem_sign_extend_o;
   output [1:0]  reg_src_o;
   output        mem_write_o;

   reg [31:0] 	 advance_pc_o;
   reg [31:0] 	 alu_result_o;
   reg [31:0] 	 reg_2_data_o;
   reg 		 reg_write_o;
   reg [1:0] 	 mem_width_o;
   reg 		 mem_sign_extend_o;
   reg [1:0] 	 reg_src_o;
   reg 		 mem_write_o;

   always @(posedge clk) begin
      advance_pc_o <= advance_pc_i;
      alu_result_o <= alu_result_i;
      reg_2_data_o <= reg_2_data_i;
      reg_write_o <= reg_write_i;
      mem_width_o <= mem_width_i;
      mem_sign_extend_o <= mem_sign_extend_i;
      reg_src_o <= reg_src_i;
      mem_write_o <= mem_write_i;
   end

endmodule
