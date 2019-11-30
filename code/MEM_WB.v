module MEM_WB (
	       clk,
	       reg_write_data_i,
	       reg_write_i,
	       reg_write_data_o,
	       reg_write_o
	       );

   input clk;
   
   input [31:0] reg_write_data_i;
   input        reg_write_i;

   output [31:0] reg_write_data_o;
   output        reg_write_o;

   reg [31:0] 	 reg_write_data_o;
   reg 		 reg_write_o;

   always @(posedge clk) begin
      reg_write_data_o <= reg_write_data_i;
      reg_write_o <= reg_write_i;
   end

endmodule




