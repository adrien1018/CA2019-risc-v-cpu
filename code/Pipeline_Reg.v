module IF_ID (
  input                 clk,
  input                 mem_stall,
  input [`REG_LEN-1:0]  now_pc_i,
  input [`INSR_LEN-1:0] inst_i,
  input                 is_jalr_i,
  input                 nop_i,
  input                 stall,
  output reg [`REG_LEN-1:0]  now_pc_o,
  output reg [`INSR_LEN-1:0] inst_o,
  output reg                 prev_jalr_o
);
  always @(posedge clk) begin
    if (!stall && !mem_stall) begin
      now_pc_o <= now_pc_i;
      inst_o <= nop_i ? 32'b10011 : inst_i;
      prev_jalr_o <= is_jalr_i;
    end
  end
endmodule

module ID_EX (
  input                     clk,
  input                     mem_stall,
  input [`REG_LEN-1:0]      alu_1_opr_i,
  input [`REG_LEN-1:0]      alu_2_opr_i,
  input [3:0]               alu_op_i,
  input                     alu_flag_i,
  input [`REG_LEN-1:0]      advance_pc_i,
  input [`REG_LEN-1:0]      reg_2_data_i,
  input [`REG_NUM_BITS-1:0] reg_addr_i,
  input                     mem_read_i,
  input                     mem_write_i,
  input [1:0]               mem_width_i,
  input                     mem_sign_extend_i,
  input [1:0]               reg_src_i,
  input                     nop_i,
  output reg [`REG_LEN-1:0]      alu_1_opr_o,
  output reg [`REG_LEN-1:0]      alu_2_opr_o,
  output reg [3:0]               alu_op_o,
  output reg                     alu_flag_o,
  output reg [`REG_LEN-1:0]      advance_pc_o,
  output reg [`REG_LEN-1:0]      reg_2_data_o,
  output reg [`REG_NUM_BITS-1:0] reg_addr_o,
  output reg                     mem_read_o,
  output reg                     mem_write_o,
  output reg [1:0]               mem_width_o,
  output reg                     mem_sign_extend_o,
  output reg [1:0]               reg_src_o
);
  always @(posedge clk) begin
    if (!mem_stall) begin
      alu_1_opr_o <= alu_1_opr_i;
      alu_2_opr_o <= alu_2_opr_i;
      alu_op_o <= alu_op_i;
      alu_flag_o <= alu_flag_i;
      advance_pc_o <= advance_pc_i;
      reg_2_data_o <= reg_2_data_i;
      reg_addr_o <= nop_i ? 5'b0 : reg_addr_i;
      mem_read_o <= nop_i ? 1'b0 : mem_read_i;
      mem_write_o <= nop_i ? 1'b0 : mem_write_i;
      mem_width_o <= mem_width_i;
      mem_sign_extend_o <= mem_sign_extend_i;
      reg_src_o <= reg_src_i;
    end
  end
endmodule

module EX_MEM (
  input                     clk,
  input                     mem_stall,
  input [`REG_LEN-1:0]      advance_pc_i,
  input [`REG_LEN-1:0]      alu_result_i,
  input [`REG_LEN-1:0]      reg_2_data_i,
  input [`REG_NUM_BITS-1:0] reg_addr_i,
  input [1:0]               mem_width_i,
  input                     mem_sign_extend_i,
  input [1:0]               reg_src_i,
  input                     mem_read_i,
  input                     mem_write_i,
  output reg [`REG_LEN-1:0]      advance_pc_o,
  output reg [`REG_LEN-1:0]      alu_result_o,
  output reg [`REG_LEN-1:0]      reg_2_data_o,
  output reg [`REG_NUM_BITS-1:0] reg_addr_o,
  output reg [1:0]               mem_width_o,
  output reg                     mem_sign_extend_o,
  output reg [1:0]               reg_src_o,
  output reg                     mem_read_o,
  output reg                     mem_write_o
);
  always @(posedge clk) begin
    if (!mem_stall) begin
      advance_pc_o <= advance_pc_i;
      alu_result_o <= alu_result_i;
      reg_2_data_o <= reg_2_data_i;
      reg_addr_o <= reg_addr_i;
      mem_width_o <= mem_width_i;
      mem_sign_extend_o <= mem_sign_extend_i;
      reg_src_o <= reg_src_i;
      mem_read_o <= mem_read_i;
      mem_write_o <= mem_write_i;
    end
  end
endmodule

module MEM_WB (
  input                     clk,
  input                     mem_stall,
  input [`REG_LEN-1:0]      write_back_i,
  input [`REG_NUM_BITS-1:0] write_addr_i,
  output reg [`REG_LEN-1:0]      write_back_o,
  output reg [`REG_NUM_BITS-1:0] write_addr_o
);
  always @(posedge clk) begin
    if (!mem_stall) begin
      write_back_o <= write_back_i;
      write_addr_o <= write_addr_i;
    end
  end
endmodule
