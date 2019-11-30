module MEM_WB (
	       clk,
	       reg_write_data_i,
	       reg_write_i,
	       reg_write_data_addr_i,
	       reg_write_data_o,
	       reg_write_o,
	       reg_write_data_addr_o,
	       );

   input clk;
   
   input [31:0] reg_write_data_i;
   input        reg_write_i;
   input [4:0]  reg_write_data_addr_i;

   output [31:0] reg_write_data_o;
   output        reg_write_o;
   output [4:0]  reg_write_data_addr_o;

   reg [31:0] 	 reg_write_data_o;
   reg 		 reg_write_o;
   reg [4:0] 	 reg_write_data_addr_o;

   always @(posedge clk) begin
      reg_write_data_o <= reg_write_data_i;
      reg_write_o <= reg_write_i;
      reg_write_data_addr_o <= reg_write_data_addr_i;
   end

endmodule




