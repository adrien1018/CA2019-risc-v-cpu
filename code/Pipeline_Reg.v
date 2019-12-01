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
  input [31:0]  now_pc_i, inst_i, advance_pc_i;
  output [31:0] now_pc_o, inst_o, advance_pc_o;
  reg [31:0]    now_pc_o, inst_o, advance_pc_o;

  always @(posedge clk) begin
    now_pc_o <= now_pc_i;
    inst_o <= inst_i;
    advance_pc_o <= advance_pc_i;
  end

endmodule

module ID_EX (
  clk,
  alu_1_opr_i,
  alu_2_opr_i,
  alu_op_i,
  alu_flag_i,
  advance_pc_i,
  reg_2_data_i,
  reg_write_data_addr_i,
  mem_write_i,
  mem_width_i,
  mem_sign_extend_i,
  reg_src_i,
  alu_1_opr_o,
  alu_2_opr_o,
  alu_op_o,
  alu_flag_o,
  advance_pc_o,
  reg_2_data_o,
  reg_write_data_addr_o,
  mem_write_o,
  mem_width_o,
  mem_sign_extend_o,
  reg_src_o
);

  input      clk;

  input [31:0] alu_1_opr_i;
  input [31:0] alu_2_opr_i;
  input [3:0]  alu_op_i;
  input        alu_flag_i;
  input [31:0] advance_pc_i;
  input [31:0] reg_2_data_i;
  input [4:0]  reg_write_data_addr_i;
  input        mem_write_i;
  input [1:0]  mem_width_i;
  input        mem_sign_extend_i;
  input [1:0]  reg_src_i;

  output [31:0] alu_1_opr_o;
  output [31:0] alu_2_opr_o;
  output [3:0]  alu_op_o;
  output        alu_flag_o;
  output [31:0] advance_pc_o;
  output [31:0] reg_2_data_o;
  output [4:0]  reg_write_data_addr_o;
  output        mem_write_o;
  output [1:0]  mem_width_o;
  output        mem_sign_extend_o;
  output [1:0]  reg_src_o;

  reg [31:0] alu_1_opr_o;
  reg [31:0] alu_2_opr_o;
  reg [3:0]  alu_op_o;
  reg        alu_flag_o;
  reg [31:0] advance_pc_o;
  reg [31:0] reg_2_data_o;
  reg [4:0]  reg_write_data_addr_o;
  reg        mem_write_o;
  reg [1:0]  mem_width_o;
  reg        mem_sign_extend_o;
  reg [1:0]  reg_src_o;

  always @(posedge clk) begin
    alu_1_opr_o <= alu_1_opr_i;
    alu_2_opr_o <= alu_2_opr_i;
    alu_op_o <= alu_op_i;
    alu_flag_o <= alu_flag_i;
    advance_pc_o <= advance_pc_i;
    reg_2_data_o <= reg_2_data_i;
    reg_write_data_addr_o <= reg_write_data_addr_i;
    mem_write_o <= mem_write_i;
    mem_width_o <= mem_width_i;
    mem_sign_extend_o <= mem_sign_extend_i;
    reg_src_o <= reg_src_i;
  end

endmodule

module EX_MEM (
  clk,
  advance_pc_i,
  alu_result_i,
  reg_2_data_i,
  reg_write_data_addr_i,
  mem_width_i,
  mem_sign_extend_i,
  reg_src_i,
  mem_write_i,
  alu_1_src_i,
  alu_2_src_i,
  advance_pc_o,
  alu_result_o,
  reg_2_data_o,
  reg_write_data_addr_o,
  mem_width_o,
  mem_sign_extend_o,
  reg_src_o,
  mem_write_o,
  is_reg1_o,
  alu_2_src_o,
);

  input clk;

  input [31:0] advance_pc_i;
  input [31:0] alu_result_i;
  input [31:0] reg_2_data_i;
  input [4:0]  reg_write_data_addr_i;
  input [1:0]  mem_width_i;
  input        mem_sign_extend_i;
  input [1:0]  reg_src_i;
  input        mem_write_i;
  input [1:0]  alu_1_src_i;
  input        alu_2_src_i;

  output [31:0] advance_pc_o;
  output [31:0] alu_result_o;
  output [31:0] reg_2_data_o;
  output [4:0]  reg_write_data_addr_o;
  output [1:0]  mem_width_o;
  output        mem_sign_extend_o;
  output [1:0]  reg_src_o;
  output        mem_write_o;
  output        is_reg1_o;
  output        alu_2_src_o;

  reg [31:0] advance_pc_o;
  reg [31:0] alu_result_o;
  reg [31:0] reg_2_data_o;
  reg [4:0]  reg_write_data_addr_o;
  reg [1:0]  mem_width_o;
  reg        mem_sign_extend_o;
  reg [1:0]  reg_src_o;
  reg        mem_write_o;
  reg        is_reg1_o;
  reg        alu_2_src_o;

  always @(posedge clk) begin
    advance_pc_o <= advance_pc_i;
    alu_result_o <= alu_result_i;
    reg_2_data_o <= reg_2_data_i;
    reg_write_data_addr_o <= reg_write_data_addr_i;
    mem_width_o <= mem_width_i;
    mem_sign_extend_o <= mem_sign_extend_i;
    reg_src_o <= reg_src_i;
    mem_write_o <= mem_write_i;
    is_reg1_o <= alu_1_src_i == 2'b00;
  end

endmodule
