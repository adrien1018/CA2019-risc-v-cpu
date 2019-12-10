module Data_Memory
(
    clk_i, 

    addr_i, 
    MemWrite_i,
    data_i,
    data_o
);

// Interface
input               clk_i;
input   [31:0]      addr_i;
input               MemWrite_i;
input   [31:0]      data_i;
output  [31:0]      data_o;

// data memory
reg     [31:0]     memory  [0:1023];

assign  data_o = MemWrite_i? data_i : memory[addr_i];  

always @ (posedge clk_i) begin
    if (MemWrite_i) begin
        memory[addr_i] <= data_i;
    end
end

endmodule

