module ALU_Control (
  ins,
  control,
  alu_op,
  flag,
  eq
);

  input  [4:0] ins;     // instruction[30|25|14:12]
  input  [1:0] control; // 2'b01 if opcode = b0?10011 (arithmetic)
                        // 2'b10 if opcode = b1100011 (branch)
  output [3:0] alu_op;
  output       flag;
  output       eq;

  assign alu_op = control == 2'b01 ? ins[3:0] :
                  control == 2'b10 ? {2'b0, ins[2:1]} : 4'b0;
  assign flag = (control == 2'b01 && (ins[2:0] == 3'b000 || ins[2:0] == 3'b101)
                 && ins[4]) || // SRA/SRAI/SUB
                (control == 2'b10 && !ins[2]); // BEQ/BNE
  assign eq = ins[2] ^ ins[0];

endmodule
