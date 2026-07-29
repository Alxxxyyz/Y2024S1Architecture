module ternary_min(a, b, out);
  input  [1:0] a;
  input  [1:0] b;
  output [1:0] out;

  wire and_gate_1_out;
  wire and_gate_2_out;
  wire  or_gate_1_out;
  // out[0] = ((a[0] && (b[1] || b[0])) || (a[1] && b[0]))
  // out[1] = (a[1] && b[1])

  // out[0]
  // b[1] || b[0]
  or_gate or_gate_1(
      .in1(b[0]),
      .in2(b[1]),
      .out(or_gate_1_out)
  );

  // a[0] && (b[1] || b[0])
  and_gate and_gate_1(
      .in1(a[0]),
      .in2(or_gate_1_out),
      .out(and_gate_1_out)
  );

  // a[1] && b[0]
  and_gate and_gate_2(
      .in1(a[1]),
      .in2(b[0]),
      .out(and_gate_2_out)
  );

  // a[0] && (b[1] || b[0])) || (a[1] && b[0])
  or_gate or_gate2(
      .in1(and_gate_1_out),
      .in2(and_gate_2_out),
      .out(out[0])
  );

  // out[1]
  // a[1] && b[1]
  and_gate and_gate_3(
      .in1(a[1]),
      .in2(b[1]),
      .out(out[1])
  );
endmodule

module ternary_max(a, b, out);
  input  [1:0] a;
  input  [1:0] b;
  output [1:0] out;

  wire nor_gate_1_out;
  wire  or_gate_1_out;
  // o[0] = ((a[1] nor b[1]) && (a[0] || b[0]))
  // o[1] = (a[1] || b[1])

  // o[0]
  // a[1] nor b[1]
  nor_gate nor_gate_1(
      .in1(a[1]),
      .in2(b[1]),
      .out(nor_gate_1_out)
  );

  // a[0] || b[0]
  or_gate or_gate_1(
      .in1(a[0]),
      .in2(b[0]),
      .out(or_gate_1_out)
  );

  // (a[1] nor b[1]) && (a[0] || b[0])
  and_gate and_gate_1(
      .in1(nor_gate_1_out),
      .in2(or_gate_1_out),
      .out(out[0])
  );

  // o[1]
  // a[1] || b[1]
  or_gate or_gate_2(
      .in1(a[1]),
      .in2(b[1]),
      .out(out[1])
  );
endmodule

module ternary_any(a, b, out);
  input  [1:0] a;
  input  [1:0] b;
  output [1:0] out;

  wire nor_gate_1_out;
  wire and_gate_1_out;
  wire not_gate_1_out;
  wire and_gate_2_out;
  wire and_gate_3_out;
  wire  or_gate_1_out;
  wire nor_gate_2_out;
  wire and_gate_4_out;
  wire  or_gate_3_out;
  wire and_gate_5_out;
  wire and_gate_6_out;
  // o[0] = ((a[0] NOR a[1]) && b[1])  ||
  //        (a[0] && not(a[1]) && b[0])  ||
  //        (a[1] && (b[0] NOR b[1]))
  // o[1] = (a[1] && (b[0] || b[1])) ||
  //        (a[0] && b[1])

  // out[0]
  // a[0] NOR a[1]
  nor_gate nor_gate_1(
      .in1(a[0]),
      .in2(a[1]),
      .out(nor_gate_1_out)
  );

  // (a[0] NOR a[1]) && b[1]
  and_gate and_gate_1(
      .in1(nor_gate_1_out),
      .in2(b[1]),
      .out(and_gate_1_out)
  );

  // not(a[1])
  not_gate not_gate_1(
      .in(a[1]),
      .out(not_gate_1_out)
  );

  // a[0] && not(a[1])
  and_gate and_gate_2(
      .in1(a[0]),
      .in2(not_gate_1_out),
      .out(and_gate_2_out)
  );

  // (a[0] && not(a[1])) && b[0]
  and_gate and_gate_3(
      .in1(and_gate_2_out),
      .in2(b[0]),
      .out(and_gate_3_out)
  );

  // ((a[0] NOR a[1]) && b[1])  ||  (a[0] && not(a[1]) && b[0])
  or_gate or_gate_1(
      .in1(and_gate_1_out),
      .in2(and_gate_3_out),
      .out(or_gate_1_out)
  );

  // b[0] NOR b[1]
  nor_gate nor_gate_2(
      .in1(b[0]),
      .in2(b[1]),
      .out(nor_gate_2_out)
  );

  // a[1] && (b[0] ^ b[1])
  and_gate and_gate_4(
      .in1(a[1]),
      .in2(nor_gate_2_out),
      .out(and_gate_4_out)
  );

  // ((a[0] NOR a[1]) && b[1])  ||
  // (a[0] && not(a[1]) && b[0])  ||
  // (a[1] && (b[0] NOR b[1]))
  or_gate or_gate_2(
      .in1(or_gate_1_out),
      .in2(and_gate_4_out),
      .out(out[0])
  );

  // o[1]
  // b[0] || b[1]
  or_gate or_gate_3(
      .in1(b[0]),
      .in2(b[1]),
      .out(or_gate_3_out)
  );

  // a[1] && (b[0] || b[1])
  and_gate and_gate_5(
      .in1(a[1]),
      .in2(or_gate_3_out),
      .out(and_gate_5_out)
  );

  // a[0] && b[1]
  and_gate and_gate_6(
      .in1(a[0]),
      .in2(b[1]),
      .out(and_gate_6_out)
  );

  // a[1] && (b[0] || b[1])  ||  (a[0] && b[1])
  or_gate or_gate_4(
      .in1(and_gate_5_out),
      .in2(and_gate_6_out),
      .out(out[1])
  );

endmodule

module ternary_consensus(a, b, out);
  input  [1:0] a;
  input  [1:0] b;
  output [1:0] out;

  wire  or_gate_1_out;
  wire  or_gate_2_out;
  wire  or_gate_3_out;
  wire and_gate_1_out;
  wire not_gate_1_out;
  wire and_gate_2_out;
  // o[0] = ((a[0] || a[1] || b[0] || b[1]) && not((a[1] && b[1])))
  // o[1] = (a1 && b1)

  // o[0]
  // a[0] || a[1]
  or_gate or_gate_1(
      .in1(a[0]),
      .in2(a[1]),
      .out(or_gate_1_out)
  );

  // b[0] || b[1]
  or_gate or_gate_2(
      .in1(b[0]),
      .in2(b[1]),
      .out(or_gate_2_out)
  );

  // a[0] || a[1] || b[0] || b[1]
  or_gate or_gate_3(
      .in1(or_gate_1_out),
      .in2(or_gate_2_out),
      .out(or_gate_3_out)
  );

  // a[1] && b[1]
  and_gate and_gate_1(
      .in1(a[1]),
      .in2(b[1]),
      .out(and_gate_1_out)
  );

  // not(a[1] && b[1])
  not_gate not_gate_1(
      .in(and_gate_1_out),
      .out(not_gate_1_out)
  );

  // (a[0] || a[1] || b[0] || b[1]) && not((a[1] && b[1]))
  and_gate and_gate_2(
      .in1(or_gate_3_out),
      .in2(not_gate_1_out),
      .out(out[0])
  );

  // o[1]
  // a1 && b1
  and_gate and_gate_3(
      .in1(a[1]),
      .in2(b[1]),
      .out(out[1])
  );
endmodule


module xor_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  wire and_gate_1_out;
  wire and_gate_2_out;
  wire not_gate_1_out;
  wire not_gate_2_out;

  not_gate not_gate_1(
      .in(in1),
      .out(not_gate_1_out)
  );

  not_gate not_gate_2(
      .in(in2),
      .out(not_gate_2_out)
  );

  and_gate and_gate_1(
      .in1(in1),
      .in2(not_gate_2_out),
      .out(and_gate_1_out
  )
  );

  and_gate and_gate_2(
      .in1(not_gate_1_out),
      .in2(in2),
      .out(and_gate_2_out)
  );

  or_gate or_gate_1(
      .in1(and_gate_1_out),
      .in2(and_gate_2_out),
      .out(out)
  );
endmodule

module or_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  wire nor_gate_1_out;

  nor_gate nor_gate_1(
      .in1(in1),
      .in2(in2),
      .out(nor_gate_1_out)
  );
  not_gate not_gate_1(
      .in(nor_gate_1_out),
      .out(out)
  );
endmodule

module and_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  wire nand_gate_1_out;

  nand_gate nand_gate_1(
      .in1(in1),
      .in2(in2),
      .out(nand_gate_1_out)
  );
  not_gate not_gate_1(
      .in(nand_gate_1_out),
      .out(out)
  );
endmodule

module nand_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  supply1 pwr;
  supply0 gnd;
  wire n1_out;

  pmos p1(out, pwr, in1);
  pmos p2(out, pwr, in2);
  nmos n1(out, n1_out, in1);
  nmos n2(n1_out, gnd, in2);
endmodule

module nor_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  supply0 gnd;
  supply1 pwr;
  wire w;

  pmos p1(w, pwr, in1);
  pmos p2(out, w, in2);
  nmos n1(out, gnd, in1);
  nmos n2(out, gnd, in2);
endmodule

module not_gate(
    input  wire in,
    output wire out
);
  supply1 pwr;
  supply0 gnd;

  pmos p1 (out, pwr, in);
  nmos n1 (out, gnd, in);
endmodule
