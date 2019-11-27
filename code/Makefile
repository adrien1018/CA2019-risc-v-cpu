MODULES = CPU.v Adder.v PC.v Instruction_Memory.v Registers.v Control.v Sign_Extend.v MUX32.v ALU.v Data_Memory.v Branch_Decision.v
VVP = testbench.vvp mytest.vvp

all: $(VVP)

$(VVP): %.vvp: %.v $(MODULES)
	iverilog -Wall -o $@ $^

clean:
	rm -f $(VVP)
