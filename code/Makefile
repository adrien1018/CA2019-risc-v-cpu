MODULES = CPU.v Adder.v PC.v Instruction_Memory.v Registers.v Control.v \
          Sign_Extend.v MUX32.v ALU.v Data_Memory.v Branch_Decision.v \
          Pipeline_Reg.v Hazard_Detection.v dcache_top.v dcache_tag_sram.v dcache_data_sram.v
VVP = testbench.vvp # ../testcase/mytest.vvp

all: $(VVP)

$(VVP): %.vvp: $(MODULES) %.v Opcode.v
	iverilog -Wall -o $@ $^

clean:
	rm -f $(VVP)
