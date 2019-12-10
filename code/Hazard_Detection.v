`include "Opcode.v"

module Hazard_Detection (
  input        clk,
  input [31:0] id_insr,
  input [4:0]  rd_3,
  input [1:0]  reg_src_3,
  input        mem_write_3,
  input [4:0]  rd_4,
  output       hazard_stall,
  output reg   fw_dm_alu,
  output       fw_alu_reg1,
  output       fw_alu_reg2,
  output       fw_dm_reg1,
  output       fw_dm_reg2
);

  wire [6:0] id_opcode = id_insr[6:0];
  assign hazard_stall = reg_src_3 == 2'b01 && rd_3 != 5'b0 && // load
      (((id_opcode == `OP_LOAD || id_opcode == `OP_JALR ||
         id_opcode == `OP_IMMARI || id_opcode == `OP_STORE) &&
        rd_3 == id_insr[19:15]) ||
        // note: rd2 hazard of load-store can be resolved by forwarding,
        //       while rd1 hazard needs to stall
       ((id_opcode == `OP_BRANCH || id_opcode == `OP_REGARI) &&
        (rd_3 == id_insr[19:15] || rd_3 == id_insr[24:20])));

  wire reg1_might_forward =
      id_opcode == `OP_LOAD   || id_opcode == `OP_STORE ||
      id_opcode == `OP_IMMARI || id_opcode == `OP_REGARI ||
      id_opcode == `OP_BRANCH || id_opcode == `OP_JALR;
  wire reg2_might_forward =
      id_opcode == `OP_LOAD   || id_opcode == `OP_REGARI ||
      id_opcode == `OP_BRANCH;
  // Source of 3->2 forwarding is always ALU result, since JAL/JALR will stall
  assign fw_alu_reg1 = rd_3 != 5'b0 && rd_3 == id_insr[19:15] &&
      reg_src_3 != 2'b01 && reg1_might_forward;
  assign fw_alu_reg2 = rd_3 != 5'b0 && rd_3 == id_insr[24:20] &&
      reg_src_3 != 2'b01 && reg2_might_forward;
  // 3->2 forwarding will override 4->2 forwarding
  // note that 4->2 forwarding is necessary on regwrite-*-store
  assign fw_dm_reg1 = rd_4 != 5'b0 && rd_4 == id_insr[19:15] &&
      reg1_might_forward && !fw_alu_reg1;
  assign fw_dm_reg2 = rd_4 != 5'b0 && rd_4 == id_insr[24:20] &&
      (reg2_might_forward || id_opcode == `OP_STORE) && !fw_alu_reg2;

  // Detect 4->3 forwarding at stage 3/2, so a register is needed to delay the
  //   signal for 1 cycle
  wire fw_dm_alu_next = rd_3 != 5'b0 && rd_3 == id_insr[24:20] &&
      id_opcode == `OP_STORE;
  always @(posedge clk) begin
    fw_dm_alu <= fw_dm_alu_next;
  end

endmodule

module Stall_Control(
  input taken,
  input is_branch,
  input is_jal,
  input is_jalr,
  input prev_jalr,
  input hazard,
  output [1:0] next_pc_control, // 00: PC+4, 01: PC, 10: jump, 11: jalr
  output       next_nop
);
  wire jump = ((taken & is_branch) | is_jal) & ~hazard;
  assign next_pc_control =
      prev_jalr ? 2'b11 : jump ? 2'b10 : (hazard | is_jalr) ? 2'b01 : 2'b00;
  assign next_nop = is_jalr | prev_jalr | jump;
endmodule
