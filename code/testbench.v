`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, outfile, counter;
integer            n_stall, n_flush;

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

    
    // Load instructions into instruction memory
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
    if(counter == 64)    // stop after 64 cycles
        $finish;

    if (CPU.hazard_detect.hazard_stall == 1 && CPU.control.is_branch == 0)
        n_stall = n_stall + 1;

    if (CPU.stall_control.next_nop == 1)
        n_flush = n_flush + 1;

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %0d, Stall = %0d, Flush = %0d\nPC = %d", counter, Start, n_stall, n_flush, CPU.PC.pc_o);

    // print Registers
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "R0( 0) = %d, R8 (s0) = %d, R16(a6) = %d, R24(s8) = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "R1(ra) = %d, R9 (s1) = %d, R17(a7) = %d, R25(s9) = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "R2(sp) = %d, R10(a0) = %d, R18(s2) = %d, R26(s10)= %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "R3(gp) = %d, R11(a1) = %d, R19(s3) = %d, R27(s11)= %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "R4(tp) = %d, R12(a2) = %d, R20(s4) = %d, R28(t3) = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "R5(t0) = %d, R13(a3) = %d, R21(s5) = %d, R29(t4) = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "R6(t1) = %d, R14(a4) = %d, R22(s6) = %d, R30(t5) = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "R7(t2) = %d, R15(a5) = %d, R23(s7) = %d, R31(t6) = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %10d", {CPU.data_mem.memory[3] , CPU.data_mem.memory[2] , CPU.data_mem.memory[1] , CPU.data_mem.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %10d", {CPU.data_mem.memory[7] , CPU.data_mem.memory[6] , CPU.data_mem.memory[5] , CPU.data_mem.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %10d", {CPU.data_mem.memory[11], CPU.data_mem.memory[10], CPU.data_mem.memory[9] , CPU.data_mem.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %10d", {CPU.data_mem.memory[15], CPU.data_mem.memory[14], CPU.data_mem.memory[13], CPU.data_mem.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %10d", {CPU.data_mem.memory[19], CPU.data_mem.memory[18], CPU.data_mem.memory[17], CPU.data_mem.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %10d", {CPU.data_mem.memory[23], CPU.data_mem.memory[22], CPU.data_mem.memory[21], CPU.data_mem.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %10d", {CPU.data_mem.memory[27], CPU.data_mem.memory[26], CPU.data_mem.memory[25], CPU.data_mem.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %10d", {CPU.data_mem.memory[31], CPU.data_mem.memory[30], CPU.data_mem.memory[29], CPU.data_mem.memory[28]});

    $fdisplay(outfile, "\n");

    counter = counter + 1;

end


endmodule
