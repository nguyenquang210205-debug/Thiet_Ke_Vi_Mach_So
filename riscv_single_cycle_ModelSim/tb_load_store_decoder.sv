`timescale 1ns/1ps

module load_store_decoder_tb;

    // Khai bao cac tin hieu dau vao (reg) va dau ra (wire)
    logic [31:0] alu_result_address;
    logic [2:0]  f3;
    logic [31:0] reg_read;
    wire [3:0]  byte_enable;
    wire [31:0] data;

    // Khoi tao ket noi (Instantiation) voi module load_store_decoder
    load_store_decoder uut (
        .alu_result_address(alu_result_address),
        .f3(f3),
        .reg_read(reg_read),
        .byte_enable(byte_enable),
        .data(data)
    );

    // Qua trinh chay test (Stimulus)
    initial begin
        // Gia tri khoi tao ban dau
        alu_result_address = 32'h0;
        f3 = 3'b000;
        reg_read = 32'h12345678;

        // 1. Kiem tra truong hop BYTE (SB/LB) tai cac offset khac nhau
        #10;
        f3 = 3'b000; // Tuong ung F3_BYTE
        alu_result_address = 32'h1000; reg_read = 32'h000000AB; // Offset = 2'b00 -> Byte 0
        #10;
        alu_result_address = 32'h1001; reg_read = 32'h000000CD; // Offset = 2'b01 -> Byte 1
        #10;
        alu_result_address = 32'h1002; reg_read = 32'h000000EF; // Offset = 2'b10 -> Byte 2
        #10;
        alu_result_address = 32'h1003; reg_read = 32'h00000012; // Offset = 2'b11 -> Byte 3

        // 2. Kiem tra truong hop HALFWORD (SH/LH) tai cac offset khac nhau
        #10;
        f3 = 3'b001; // Tuong ung F3_HALFWORD
        alu_result_address = 32'h2000; reg_read = 32'h0000ABCD; // Offset = 2'b00 -> 2 byte thap
        #10;
        alu_result_address = 32'h2002; reg_read = 32'h00005678; // Offset = 2'b10 -> 2 byte cao

        // 3. Kiem tra truong hop WORD (SW)
        #10;
        f3 = 3'b010; // Tuong ung F3_WORD
        alu_result_address = 32'h3000; reg_read = 32'hDEADBEEF; // Dia chi can le (offset = 00) -> Cho phep ghi ca 4 byte
        #10;
        alu_result_address = 32'h3001; reg_read = 32'hCAFEBABE; // Dia chi khong can le -> Chan (byte_enable = 0)

        // Ket thuc mo phong sau khi chay xong cac truong hop
        #20;
        $finish;
    end

    // Theo doi ket qua tren cua so Transcript
    initial begin
        $monitor("Time = %0t ns | f3 = %b | Addr = %h | Reg_Read = %h ==> Byte_En = %b | Data_Out = %h", 
                 $time, f3, alu_result_address, reg_read, byte_enable, data);
    end

endmodule
