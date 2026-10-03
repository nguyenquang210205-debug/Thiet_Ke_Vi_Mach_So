/**
* HOLY CORE CONTROL UNIT TESTBENCH
* 
* Dùng ?? ki?m tra các tín hi?u ?i?u khi?n c?a kh?i control.
*/

`timescale 1ns/1ps

module tb_control;

    // Khai báo các tín hi?u k?t n?i v?i DUT (Device Under Test)
    logic [6:0] op;
    logic [2:0] func3;
    logic [6:0] func7;
    logic       alu_zero;
    logic       alu_last_bit;

    // Các tín hi?u ??u ra t? kh?i control
    logic [3:0] alu_control;
    logic [2:0] imm_source;
    logic       mem_write;
    logic       reg_write;
    logic       alu_source;
    logic [1:0] write_back_source;
    logic       pc_source;
    logic [1:0] second_add_source;

    // Kh?i t?o module control (DUT)
    control uut (
        .op(op),
        .func3(func3),
        .func7(func7),
        .alu_zero(alu_zero),
        .alu_last_bit(alu_last_bit),
        .alu_control(alu_control),
        .imm_source(imm_source),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .alu_source(alu_source),
        .write_back_source(write_back_source),
        .pc_source(pc_source),
        .second_add_source(second_add_source)
    );

    // Kh?i t?o stimulus (k?ch b?n ki?m tra)
    initial begin
        // Hi?n th? tiêu ?? trên c?a s? console mô ph?ng
        $display("==================================================");
        $display("B?T ??U MÔ PH?NG KH?I CONTROL UNIT");
        $display("==================================================");

        // Kh?i t?o giá tr? ban ??u
        op = 7'b0;
        func3 = 3'b0;
        func7 = 7'b0;
        alu_zero = 1'b0;
        alu_last_bit = 1'b0;
        #10;

        // 1. Test l?nh R-type (Ví d?: ADD -> op = 0110011, func3 = 000, func7 = 0000000)
        op = 7'b0110011; 
        func3 = 3'b000; 
        func7 = 7'b0000000;
        #10;
        $display("[R-Type ADD] reg_write = %b, alu_control = %b (Mong ??i: ADD)", reg_write, alu_control);

        // 2. Test l?nh R-type SUB (func7 = 0100000)
        func7 = 7'b0100000;
        #10;
        $display("[R-Type SUB] reg_write = %b, alu_control = %b (Mong ??i: SUB)", reg_write, alu_control);

        // 3. Test l?nh I-type Load (LW -> op = 0000011)
        op = 7'b0000011;
        func3 = 3'b010; // F3_WORD
        #10;
        $display("[I-Type LOAD] reg_write = %b, mem_write = %b, write_back_source = %b", reg_write, mem_write, write_back_source);

        // 4. Test l?nh S-type (SW -> op = 0100011)
        op = 7'b0100011;
        func3 = 3'b010;
        #10;
        $display("[S-Type STORE] reg_write = %b, mem_write = %b (Mong ??i mem_write=1)", reg_write, mem_write);

        // 5. Test l?nh B-type (BEQ -> op = 1100011, func3 = 000)
        op = 7'b1100011;
        func3 = 3'b000; // F3_BEQ
        alu_zero = 1'b1; // Gi? l?p ALU báo k?t qu? b?ng 0 (?i?u ki?n BEQ th?a mãn)
        #10;
        $display("[B-Type BEQ] branch_assert = %b, pc_source = %b (Mong ??i pc_source=1)", pc_source, pc_source);

        // K?t thúc mô ph?ng
        $display("==================================================");
        $display("HOÀN T?T KI?M TRA MÔ PH?NG");
        $display("==================================================");
        $finish;
    end

endmodule
