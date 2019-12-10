`define CYCLE_TIME 50

module TestBench;

reg          Clk;
reg          Start;
reg          Reset;
reg [1023:0] file;
integer      i, outfile, counter;
integer      n_stall, n_flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;

CPU CPU(
  .clk_i  (Clk),
  .rst_i  (Reset),
  .start_i(Start)
);

initial begin
  $dumpfile("CPU.vcd");
  $dumpvars;

  counter = 0;
  n_stall = 0;
  n_flush = 0;

  // initialize instruction memory
  for(i=0; i<256; i=i+1) begin
      CPU.Instruction_Memory.memory[i] = 32'b0;
  end
  // initialize data memory
  CPU.data_mem.memory[0] = 32'h5;
  for(i=1; i<1024; i=i+1) begin
      CPU.data_mem.memory[i] = 32'b0;
  end
  // initialize Register File
  for(i=0; i<32; i=i+1) begin
      CPU.Registers.register[i] = 32'b0;
  end

  // initialize pipeline registers
  CPU.if_id.now_pc_o = 32'b0;
  CPU.if_id.inst_o = 32'b10011; // NOP
  CPU.if_id.prev_jalr_o = 1'b0;
  CPU.id_ex.reg_addr_o = 5'b0;
  CPU.id_ex.mem_write_o = 1'b0;
  CPU.ex_mem.reg_addr_o = 5'b0;
  CPU.ex_mem.mem_write_o = 1'b0;
  CPU.mem_wb.write_addr_o = 5'b0;

  // Load instructions into instruction memory
  if ($value$plusargs("file=%s", file))
    $readmemb(file, CPU.Instruction_Memory.memory);
  else
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);
  // Open output file
  outfile = $fopen("output.txt") | 1;

  Clk = 0;
  Reset = 0;
  Start = 0;

  #(`CYCLE_TIME/4)
  Reset = 1;
  Start = 1;
end

always@(posedge Clk) begin
  if (counter == 64)    // stop after 64 cycles
    $finish;

  if (CPU.hazard_detect.hazard_stall == 1 && CPU.control.is_branch == 0)
    n_stall = n_stall + 1;
  if (CPU.stall_control.next_nop == 1)
    n_flush = n_flush + 1;

  // print PC
  $fdisplay(outfile, "cycle = %d, Start = %0d, Stall = %0d, Flush = %0d", counter, Start, n_stall, n_flush);
  $fdisplay(outfile, "PC = %d", CPU.PC.pc_o);

  // print Registers
  $fdisplay(outfile, "Registers");
  $fdisplay(outfile, "x0 = %d, x8  = %d, x16 = %d, x24 = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
  $fdisplay(outfile, "x1 = %d, x9  = %d, x17 = %d, x25 = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
  $fdisplay(outfile, "x2 = %d, x10 = %d, x18 = %d, x26 = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
  $fdisplay(outfile, "x3 = %d, x11 = %d, x19 = %d, x27 = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
  $fdisplay(outfile, "x4 = %d, x12 = %d, x20 = %d, x28 = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
  $fdisplay(outfile, "x5 = %d, x13 = %d, x21 = %d, x29 = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
  $fdisplay(outfile, "x6 = %d, x14 = %d, x22 = %d, x30 = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
  $fdisplay(outfile, "x7 = %d, x15 = %d, x23 = %d, x31 = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

  // print Data Memory
  $fdisplay(outfile, "Data Memory: 0x00 = %10d", CPU.data_mem.memory[0]);
  $fdisplay(outfile, "Data Memory: 0x04 = %10d", CPU.data_mem.memory[1]);
  $fdisplay(outfile, "Data Memory: 0x08 = %10d", CPU.data_mem.memory[2]);
  $fdisplay(outfile, "Data Memory: 0x0c = %10d", CPU.data_mem.memory[3]);
  $fdisplay(outfile, "Data Memory: 0x10 = %10d", CPU.data_mem.memory[4]);
  $fdisplay(outfile, "Data Memory: 0x14 = %10d", CPU.data_mem.memory[5]);
  $fdisplay(outfile, "Data Memory: 0x18 = %10d", CPU.data_mem.memory[6]);
  $fdisplay(outfile, "Data Memory: 0x1c = %10d", CPU.data_mem.memory[7]);
  $fdisplay(outfile, "\n");
  counter = counter + 1;
end

endmodule
