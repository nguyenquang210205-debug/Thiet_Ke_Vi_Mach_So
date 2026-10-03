`timescale 1ns/1ps

module reader_tb;

    // Khai bao cac tin hieu dau vao (logic) va dau ra (wire)
    logic [31:0] mem_data;
    logic [3:0]  be_mask;
    logic [2:0]  f3;
    wire  [31:0] wb_data;
    wire         valid;

    // Khoi tao ket noi (Instantiation) voi module reader
    reader uut (
        .mem_data(mem_data),
        .be_mask(be_mask),
        .f3(f3),
        .wb_data(wb_data),
        .valid(valid)
    );

    // Dinh nghia cac ma f3 giong trong holy_core_pkg de test
    localparam F3_BYTE       = 3'b000;
    localparam F3_HALFWORD   = 3'b001;
    localparam F3_WORD       = 3'b010;
    localparam F3_BYTE_U     = 3'b100;
    localparam F3_HALFWORD_U = 3'b101;

    // Qua trinh chay test (Stimulus)
    initial begin
        // Gia tri khoi tao ban dau
        mem_data = 32'h0;
        be_mask  = 4'b0000;
        f3       = 3'b000;

        // 1. Kiem tra lenh LW (Word)
        #10;
        f3       = F3_WORD;
        be_mask  = 4'b1111;
        mem_data = 32'h12345678;

        // 2. Kiem tra lenh LB (Byte co dau, gia tri duong va am)
        // Truong hop byte 0 (offset 00) co bit dau = 0
        #10;
        f3       = F3_BYTE;
        be_mask  = 4'b0001;
        mem_data = 32'hAABBCC78; // Byte 0 la 78 (duong)

        #10;
        // Truong hop byte 0 co bit dau = 1 (se bi mo rong dau thanh so am)
        mem_data = 32'hAABBCC88; // Byte 0 la 88 -> mo rong thanh fffffffe8

        #10;
        // Truong hop byte 2 (be_mask = 4'b0100 -> dich phai 16 bit)
        f3       = F3_BYTE;
        be_mask  = 4'b0100;
        mem_data = 32'hAA88CCDD; // Byte 2 la 88

        // 3. Kiem tra lenh LBU (Byte khong dau)
        #10;
        f3       = F3_BYTE_U;
        be_mask  = 4'b0001;
        mem_data = 32'hAABBCC88; // Khong mo rong dau, chi lay 88

        // 4. Kiem tra lenh LH (Halfword co dau)
        #10;
        f3       = F3_HALFWORD;
        be_mask  = 4'b0011;
        mem_data = 32'h12348878; // Halfword thap la 8878 (co bit dau 8 -> am)

        // 5. Kiem tra lenh LHU (Halfword khong dau)
        #10;
        f3       = F3_HALFWORD_U;
        be_mask  = 4'b0011;
        mem_data = 32'h12348878; // Khong mo rong dau

        // Ket thuc mo phong
        #20;
        $finish;
    end

    // Theo doi ket qua qua cua so Transcript
    initial begin
        $monitor("Time = %0t ns | f3 = %b | be_mask = %b | mem_data = %h ==> wb_data = %h | valid = %b",
                 $time, f3, be_mask, mem_data, wb_data, valid);
    end

endmodule
