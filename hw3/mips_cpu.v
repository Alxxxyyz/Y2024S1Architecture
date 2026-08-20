`include "util.v"

module alu(a, b, control, res, zero);
  input [31:0] a, b;
  input [ 2:0] control;

  output reg [31:0] res;
  output zero;

  localparam ALU_AND = 3'b000;
  localparam ALU_OR  = 3'b001;
  localparam ALU_ADD = 3'b010;
  localparam ALU_SUB = 3'b011;
  localparam ALU_SLT = 3'b100;

  assign zero = (res == 32'b0);

  always @(*) begin
    case (control)
      ALU_AND: res = a & b;
      ALU_OR:  res = a | b;
      ALU_ADD: res = a + b;
      ALU_SUB: res = a - b;
      ALU_SLT: res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
      default: res = 32'b0;
    endcase
  end
endmodule

module mips_cpu(clk, pc, pc_new,
                instruction_memory_a, instruction_memory_rd,
                data_memory_a, data_memory_rd, data_memory_we, data_memory_wd,
                register_a1, register_a2, register_a3,
                register_we3, register_wd3, register_rd1, register_rd2);
  input         clk;
  inout  [31:0] pc;
  output [31:0] pc_new;
  output        data_memory_we;
  output [31:0] instruction_memory_a, data_memory_a, data_memory_wd;
  inout  [31:0] instruction_memory_rd, data_memory_rd;
  output        register_we3;
  output [ 4:0] register_a1, register_a2, register_a3;
  output [31:0] register_wd3;
  inout  [31:0] register_rd1, register_rd2;

  // opcodes and adresses
  localparam OP_RTYPE  = 6'b000000;
  localparam OP_J      = 6'b000010;
  localparam OP_JAL    = 6'b000011;
  localparam OP_BEQ    = 6'b000100;
  localparam OP_BNE    = 6'b000101;
  localparam OP_ADDI   = 6'b001000;
  localparam OP_ANDI   = 6'b001100;
  localparam OP_LW     = 6'b100011;
  localparam OP_SW     = 6'b101011;

  localparam FUNCT_JR  = 6'b001000;
  localparam FUNCT_ADD = 6'b100000;
  localparam FUNCT_SUB = 6'b100010;
  localparam FUNCT_AND = 6'b100100;
  localparam FUNCT_OR  = 6'b100101;
  localparam FUNCT_SLT = 6'b101010;

  localparam ALU_AND   = 3'b000;
  localparam ALU_OR    = 3'b001;
  localparam ALU_ADD   = 3'b010;
  localparam ALU_SUB   = 3'b011;
  localparam ALU_SLT   = 3'b100;

  localparam DST_RT    = 2'd0;
  localparam DST_RD    = 2'd1;
  localparam DST_RA    = 2'd2;

  localparam WD_ALU = 2'd0;
  localparam WD_MEMORY = 2'd1;
  localparam WD_PC_PLUS_4 = 2'd2;

  localparam NEXT_SEQUENTIAL = 2'd0;
  localparam NEXT_JUMP = 2'd1;
  localparam NEXT_REGISTER = 2'd2;

  // instruction parse
  wire [ 5:0] opcode = instruction_memory_rd[31:26];
  wire [ 4:0] rs = instruction_memory_rd[25:21];
  wire [ 4:0] rt = instruction_memory_rd[20:16];
  wire [ 4:0] rd = instruction_memory_rd[15:11];
  wire [ 5:0] funct = instruction_memory_rd[5:0];
  wire [15:0] immediate = instruction_memory_rd[15:0];
  wire [25:0] jump_address = instruction_memory_rd[25:0];

  // control unit
  reg       control_reg_write;
  reg [1:0] control_reg_dst;
  reg       control_alu_src;
  reg [2:0] control_alu;
  reg       control_mem_write;
  reg [1:0] control_wd_source;
  reg       control_branch_eq;
  reg       control_branch_ne;
  reg [1:0] control_next_pc;
  reg       control_zero_extend;

  always @(*) begin
    control_reg_write   = 1'b0;
    control_reg_dst     = DST_RT;
    control_alu_src     = 1'b0;
    control_alu         = ALU_ADD;
    control_mem_write   = 1'b0;
    control_wd_source   = WD_ALU;
    control_branch_eq   = 1'b0;
    control_branch_ne   = 1'b0;
    control_next_pc     = NEXT_SEQUENTIAL;
    control_zero_extend = 1'b0;

    case (opcode)
      OP_RTYPE: begin
        if (funct == FUNCT_JR) begin
          control_next_pc = NEXT_REGISTER;
        end else begin
          control_reg_write = 1'b1;
          control_reg_dst   = DST_RD;
          case (funct)
            FUNCT_ADD: control_alu = ALU_ADD;
            FUNCT_SUB: control_alu = ALU_SUB;
            FUNCT_AND: control_alu = ALU_AND;
            FUNCT_OR:  control_alu = ALU_OR;
            FUNCT_SLT: control_alu = ALU_SLT;
            default:   control_alu = ALU_ADD;
          endcase
        end
      end

      OP_LW: begin
        control_reg_write   = 1'b1;
        control_alu_src     = 1'b1;
        control_wd_source   = WD_MEMORY;
      end

      OP_SW: begin
        control_alu_src     = 1'b1;
        control_mem_write   = 1'b1;
      end

      OP_BEQ: begin
        control_alu         = ALU_SUB;
        control_branch_eq   = 1'b1;
      end

      OP_BNE: begin
        control_alu         = ALU_SUB;
        control_branch_ne   = 1'b1;
      end

      OP_ADDI: begin
        control_reg_write   = 1'b1;
        control_alu_src     = 1'b1;
      end

      OP_ANDI: begin
        control_reg_write   = 1'b1;
        control_alu_src     = 1'b1;
        control_alu         = ALU_AND;
        control_zero_extend = 1'b1;
      end

      OP_J: begin
        control_next_pc     = NEXT_JUMP;
      end

      OP_JAL: begin
        control_reg_write   = 1'b1;
        control_reg_dst     = DST_RA;
        control_wd_source   = WD_PC_PLUS_4;
        control_next_pc     = NEXT_JUMP;
      end

      default: begin
        // unknown instruction does nothing
      end
    endcase
  end

  // adresses evaluation
  wire [31:0] pc_plus_4;
  adder pc_incrementer (
      .a  (pc),
      .b  (32'd4),
      .out(pc_plus_4)
  );

  wire [31:0] immediate_signed;
  sign_extend immediate_extender (
      .in (immediate),
      .out(immediate_signed)
  );

  wire [31:0] immediate_extended = control_zero_extend ? {16'b0, immediate} : immediate_signed;

  wire [31:0] branch_offset;
  shl_2 branch_offset_shifter (
      .in (immediate_signed),
      .out(branch_offset)
  );

  wire [31:0] branch_target;
  adder branch_adder (
      .a  (pc_plus_4),
      .b  (branch_offset),
      .out(branch_target)
  );

  wire [31:0] jump_target = {pc_plus_4[31:28], jump_address, 2'b00};

  // ALU
  wire [31:0] alu_operand_b = control_alu_src ? immediate_extended : register_rd2;
  wire [31:0] alu_result;
  wire        alu_zero;

  alu main_alu (
      .a      (register_rd1),
      .b      (alu_operand_b),
      .control(control_alu),
      .res    (alu_result),
      .zero   (alu_zero)
  );

  // next pc, memory, registers
  wire take_branch = (control_branch_eq & alu_zero) | (control_branch_ne & ~alu_zero);
  wire [31:0] sequential_next = take_branch ? branch_target : pc_plus_4;

  assign pc_new = (control_next_pc == NEXT_JUMP) ? jump_target :
                  (control_next_pc == NEXT_REGISTER) ? register_rd1 :
                  sequential_next;

  assign instruction_memory_a = pc;

  assign data_memory_a = alu_result;
  assign data_memory_wd = register_rd2;
  assign data_memory_we = control_mem_write;

  assign register_a1 = rs;
  assign register_a2 = rt;
  assign register_a3 = (control_reg_dst == DST_RD) ? rd :
                       (control_reg_dst == DST_RA) ? 5'd31 :
                       rt;
  assign register_we3 = control_reg_write;
  assign register_wd3 = (control_wd_source == WD_MEMORY) ? data_memory_rd :
                        (control_wd_source == WD_PC_PLUS_4) ? pc_plus_4 :
                        alu_result;
endmodule
