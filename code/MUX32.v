module MUX32_2 (
  in0,
  in1,
  control,
  result
);

  input  [31:0] in0;
  input  [31:0] in1;
  input         control;
  output [31:0] result;

  assign result = control ? in1 : in0;

endmodule

module MUX32_4 (
  in0,
  in1,
  in2,
  in3,
  control,
  result
);

  input  [31:0] in0;
  input  [31:0] in1;
  input  [31:0] in2;
  input  [31:0] in3;
  input  [1:0]  control;
  output [31:0] result;

  assign result = control[1] ? (control[0] ? in3 : in2) : (control[0] ? in1 : in0);

endmodule
