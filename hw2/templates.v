module alu(a, b, control, res);
  input [3:0] a, b; // Операнды
  input [2:0] control; // Управляющие сигналы для выбора операции

  output [3:0] res; // Результат
  // TODO: implementation
endmodule

module d_latch(clk, d, we, q);
  input clk; // Сигнал синхронизации
  input d; // Бит для записи в ячейку
  input we; // Необходимо ли перезаписать содержимое ячейки

  output reg q; // Сама ячейка
  // Изначально в ячейке хранится 0
  initial begin
    q <= 0;
  end
  // Значение изменяется на переданное на спаде сигнала синхронизации
  always @ (negedge clk) begin
    // Запись происходит при we = 1
    if (we) begin
      q <= d;
    end
  end
endmodule

module register_file(clk, rd_addr, we_addr, we_data, rd_data, we);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr, we_addr; // Номера регистров для чтения и записи
  input [3:0] we_data; // Данные для записи в регистровый файл
  input we; // Необходимо ли перезаписать содержимое регистра

  output [3:0] rd_data; // Данные, полученные в результате чтения из регистрового файла
  // TODO: implementation
endmodule

module counter(clk, addr, control, immediate, data);
  input clk; // Сигнал синхронизации
  input [1:0] addr; // Номер значения счетчика которое читается или изменяется
  input [3:0] immediate; // Целочисленная константа, на которую увеличивается/уменьшается значение счетчика
  input control; // 0 - операция инкремента, 1 - операция декремента

  output [3:0] data; // Данные из значения под номером addr, подающиеся на выход
  // TODO: implementation
endmodule

module full_adder(
    input  wire in1,  // A
    input  wire in2,  // B
    input  wire carry_in,
    output wire carry_out,
    output wire sum
);
  wire AB;
  wire ACin;
  wire BCin;
  wire ACin_or_BCin;
  wire A_XOR_B;

  and_gate AB_gate(
      .in1(in1),
      .in2(in2),
      .out(AB)
  );

  and_gate ACin_gate(
      .in1(in1),
      .in2(carry_in),
      .out(ACin)
  );

  and_gate BCin_gate(
      .in1(in2),
      .in2(carry_in),
      .out(BCin)
  );

  or_gate ACin_or_BCin_gate(
      .in1(ACin),
      .in2(BCin),
      .out(ACin_or_BCin)
  );

  or_gate carry_out_gate(
      .in1(AB),
      .in2(ACin_or_BCin),
      .out(carry_out)
  );

  xor_gate A_XOR_B_gate(
    .in1(in1),
    .in2(in2),
    .out(A_XOR_B)
  );

  xor_gate sum_gate(
      .in1(A_XOR_B),
      .in2(carry_in),
      .out(sum)
  );
endmodule

module half_adder(
    input  wire in1,
    input  wire in2,
    output wire carry_out,
    output wire sum
);

  and_gate carry_out_gate(
      .in1(in1),
      .in2(in2),
      .out(carry_out)
  );

  xor_gate sum_gate(
      .in1(in1),
      .in2(in2),
      .out(sum)
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

  pmos p1(out, pwr, in);
  nmos n1(out, gnd, in);
endmodule
