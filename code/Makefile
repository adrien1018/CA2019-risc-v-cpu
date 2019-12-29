MODULES = CPU.v Adder.v PC.v Instruction_Memory.v Registers.v Control.v \
          Sign_Extend.v MUX32.v ALU.v Data_Memory.v Branch_Decision.v \
          Pipeline_Reg.v Hazard_Detection.v DCache_Top.v DCache_SRAM.v
VVP = testbench.vvp # ../testcase/mytest.vvp

all: $(VVP)

$(VVP): %.vvp: $(MODULES) %.v Opcode.v
	iverilog -Wall -o $@ $^

clean:
	rm -f $(VVP)
