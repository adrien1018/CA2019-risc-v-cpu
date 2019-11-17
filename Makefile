MODULES = CPU.v Adder.v ALU_Control.v PC.v Instruction_Memory.v Registers.v Control.v Sign_Extend.v MUX32.v ALU.v
VVP = testbench.vvp mytest.vvp

all: $(VVP)

$(VVP): %.vvp: %.v $(MODULES)
	iverilog -o $@ $^

clean:
	rm -f $(VVP)
