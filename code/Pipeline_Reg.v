module IF_ID (
  input        clk,
  input [31:0] now_pc_i,
  input [31:0] inst_i,
  input [31:0] advance_pc_i,
  input        is_jalr_i,
  input        nop_i,
  input        stall,
  output reg [31:0] now_pc_o,
  output reg [31:0] inst_o,
  output reg [31:0] advance_pc_o,
  output reg        prev_jalr_o
);
  always @(posedge clk) begin
    if (!stall) begin
      now_pc_o <= now_pc_i;
      inst_o <= nop_i ? 32'b10011 : inst_i;
      advance_pc_o <= advance_pc_i;
      prev_jalr_o <= is_jalr_i;
    end
  end
endmodule

module ID_EX (
  input        clk,
  input [31:0] alu_1_opr_i,
  input [31:0] alu_2_opr_i,
  input [3:0]  alu_op_i,
  input        alu_flag_i,
  input [31:0] advance_pc_i,
  input [31:0] reg_2_data_i,
  input [4:0]  reg_write_data_addr_i,
  input        mem_write_i,
  input [1:0]  mem_width_i,
  input        mem_sign_extend_i,
  input [1:0]  reg_src_i,
  input        nop_i,
  output reg [31:0] alu_1_opr_o,
  output reg [31:0] alu_2_opr_o,
  output reg [3:0]  alu_op_o,
  output reg        alu_flag_o,
  output reg [31:0] advance_pc_o,
  output reg [31:0] reg_2_data_o,
  output reg [4:0]  reg_write_data_addr_o,
  output reg        mem_write_o,
  output reg [1:0]  mem_width_o,
  output reg        mem_sign_extend_o,
  output reg [1:0]  reg_src_o
);
  always @(posedge clk) begin
    alu_1_opr_o <= alu_1_opr_i;
    alu_2_opr_o <= alu_2_opr_i;
    alu_op_o <= alu_op_i;
    alu_flag_o <= alu_flag_i;
    advance_pc_o <= advance_pc_i;
    reg_2_data_o <= reg_2_data_i;
    reg_write_data_addr_o <= nop_i ? 5'b0 : reg_write_data_addr_i;
    mem_write_o <= nop_i ? 1'b0 : mem_write_i;
    mem_width_o <= mem_width_i;
    mem_sign_extend_o <= mem_sign_extend_i;
    reg_src_o <= reg_src_i;
  end
endmodule

module EX_MEM (
  input        clk,
  input [31:0] advance_pc_i,
  input [31:0] alu_result_i,
  input [31:0] reg_2_data_i,
  input [4:0]  reg_write_data_addr_i,
  input [1:0]  mem_width_i,
  input        mem_sign_extend_i,
  input [1:0]  reg_src_i,
  input        mem_write_i,
  output reg [31:0] advance_pc_o,
  output reg [31:0] alu_result_o,
  output reg [31:0] reg_2_data_o,
  output reg [4:0]  reg_write_data_addr_o,
  output reg [1:0]  mem_width_o,
  output reg        mem_sign_extend_o,
  output reg [1:0]  reg_src_o,
  output reg        mem_write_o
);
  always @(posedge clk) begin
    advance_pc_o <= advance_pc_i;
    alu_result_o <= alu_result_i;
    reg_2_data_o <= reg_2_data_i;
    reg_write_data_addr_o <= reg_write_data_addr_i;
    mem_width_o <= mem_width_i;
    mem_sign_extend_o <= mem_sign_extend_i;
    reg_src_o <= reg_src_i;
    mem_write_o <= mem_write_i;
  end
endmodule
