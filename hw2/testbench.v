`include "templates.v"

module ripple_adder_tb();
  reg  [3:0] a, b;
  reg        carry_in;
  wire [3:0] sum;
  wire       carry_out;
  reg  [4:0] expected;

  integer i, j, k, errors;

  ripple_adder dut(
      .addend1(a),
      .addend2(b),
      .carry_in(carry_in),
      .carry_out(carry_out),
      .sum(sum)
  );

  initial begin
    errors = 0;
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        for (k = 0; k < 2; k = k + 1) begin
          a = i;
          b = j;
          carry_in = k;
          #1;
          expected = i + j + k;
          if ({carry_out, sum} !== expected) begin
            $display("ERROR. i = %d, j = %d, k = %d, expected = %d, got = %d",
                    i, j, k, expected, {carry_out, sum});
            errors = errors + 1;
          end
        end
      end
    end
    if (errors == 0) $display("Pass!");
    else $display("Fail with %d errors.", errors);
    $finish;
  end
endmodule
