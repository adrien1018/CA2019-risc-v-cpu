module IF_ID (
	      clk,
	      now_pc_i,
	      inst_i,
	      advance_pc_i,
	      now_pc_o,
	      inst_o,
	      advance_pc_o
	      );

   input clk;
   input [31:0] now_pc_i, inst_i, advance_pc_i;
   output [31:0] now_pc_o, inst_o, advance_pc_o;
   reg [31:0] 	 now_pc_o, inst_o, advance_pc_o;

   always @(posedge clk) begin
      now_pc_o <= now_pc_i;
      inst_o <= inst_i;
      advance_pc_o <= advance_pc_i;
   end

endmodule
