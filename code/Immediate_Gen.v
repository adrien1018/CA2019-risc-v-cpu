module Immediate_Gen (
  input  [`INSR_LEN-1:0] insr,
  output [`INSR_LEN-1:0] result
);
  assign result = insr[4:2] == 3'b101 ? {insr[31:12], 12'b0} : // U-type
                  insr[3:2] == 2'b11 ? // J-type
                      {{12{insr[31]}}, insr[19:12], insr[20], insr[30:21], 1'b0} :
                  insr[4:2] == 3'b001 || {insr[6:5], insr[3:2]} == 4'b0000 ?
                      {{20{insr[31]}}, insr[31:20]} : // I-type
                  insr[6:2] == 5'b01000 ? // S-type
                      {{20{insr[31]}}, insr[31:25], insr[11:7]} :
                  insr[6:2] == 5'b11000 ? // B-type
                      {{20{insr[31]}}, insr[7], insr[30:25], insr[11:8], 1'b0} :
                  32'b0; // R-type
endmodule
