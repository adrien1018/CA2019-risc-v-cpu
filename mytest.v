`define CYCLE_TIME 50

module TestBench;

reg                Clk;
reg                Reset;
reg                Start;
integer            i;
reg     [1023:0]   file;

always #(`CYCLE_TIME/2) Clk = ~Clk;

CPU CPU(
    .clk_i  (Clk),
    .rst_i  (Reset),
    .start_i(Start)
);

initial begin
  // initialize instruction memory
  for (i=0; i<256; i=i+1)
    CPU.Instruction_Memory.memory[i] = 32'b0;
  // initialize Register File
  for (i=0; i<32; i=i+1)
    CPU.Registers.register[i] = 32'b0;

  // Load instructions into instruction memory
  if ($value$plusargs("file=%s", file))
    $readmemb(file, CPU.Instruction_Memory.memory);
  else
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);

  // rotate instruction memory to the correct position
  for (i=0; i<256; i=i+1)
    CPU.Instruction_Memory.memory[(i+2)&255] <= CPU.Instruction_Memory.memory[i];

  Clk = 0;
  Reset = 0;
  Start = 0;

  #(`CYCLE_TIME/4)
  Reset = 1;
  Start = 1;
  // set PC & registers to match `jupiter` results
  CPU.PC.pc_o = 65544;
  CPU.Registers.register[2] = 32'hbffffff0;
  CPU.Registers.register[3] = 32'h10008000;
  CPU.Registers.register[6] = 32'h10000;
end

always@(posedge Clk) begin
    if (0) // used for debugging
      $display("imm=%d flag=%d alu_op=%b alu_opr=%d,%d branch=%b ins=%b eq=%b taken=%b alu_result=%d",
        $signed(CPU.imm_3),
        CPU.flag_2,
        CPU.alu_op_3,
        CPU.alu_1_opr_3,
        CPU.alu_2_opr_3,
        CPU.is_branch_3,
        CPU.instruction_2[14:12],
        CPU.eq_2,
        CPU.taken,
        $signed(CPU.alu_result_3)
      );
    $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d 0x%x",
      $signed(CPU.Registers.register[ 0]),
      $signed(CPU.Registers.register[ 1]),
      $signed(CPU.Registers.register[ 2]),
      $signed(CPU.Registers.register[ 3]),
      $signed(CPU.Registers.register[ 4]),
      $signed(CPU.Registers.register[ 5]),
      $signed(CPU.Registers.register[ 6]),
      $signed(CPU.Registers.register[ 7]),
      $signed(CPU.Registers.register[ 8]),
      $signed(CPU.Registers.register[ 9]),
      $signed(CPU.Registers.register[10]),
      $signed(CPU.Registers.register[11]),
      $signed(CPU.Registers.register[12]),
      $signed(CPU.Registers.register[13]),
      $signed(CPU.Registers.register[14]),
      $signed(CPU.Registers.register[15]),
      $signed(CPU.Registers.register[16]),
      $signed(CPU.Registers.register[17]),
      $signed(CPU.Registers.register[18]),
      $signed(CPU.Registers.register[19]),
      $signed(CPU.Registers.register[20]),
      $signed(CPU.Registers.register[21]),
      $signed(CPU.Registers.register[22]),
      $signed(CPU.Registers.register[23]),
      $signed(CPU.Registers.register[24]),
      $signed(CPU.Registers.register[25]),
      $signed(CPU.Registers.register[26]),
      $signed(CPU.Registers.register[27]),
      $signed(CPU.Registers.register[28]),
      $signed(CPU.Registers.register[29]),
      $signed(CPU.Registers.register[30]),
      $signed(CPU.Registers.register[31]),
      CPU.PC.pc_o,
      CPU.instruction_2,
    );
    if (CPU.instruction_2 == 32'b0) // instruction end
      $finish;
end


endmodule
