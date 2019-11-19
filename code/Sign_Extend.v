module Immediate_Gen (
  insr,
  result
);

  input  [31:0] insr;
  output [31:0] result;

  assign result = insr[4:2] == 3'b001 || {insr[6:5], insr[3:2]} == 4'b0000 ?
                      {{20{insr[31]}}, insr[31:20]} : // I-type
                  32'b0; // R-type

endmodule
