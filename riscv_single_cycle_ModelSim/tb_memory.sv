`timescale 1ns/1ps

module memory_tb;

    // Khai bao cac tin hieu dieu khien va ket noi
    logic        clk;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [3:0]  byte_enable;
    logic        write_enable;
    logic        rst_n;
    wire  [31:0] read_data;

    // Khoi tao module memory (su dung thong so mac dinh)
    memory #(
        .WORDS(128),
        .mem_init("") // Khong dung file init de test ghi/doc truc quan
    ) uut (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .byte_enable(byte_enable),
        .write_enable(write_enable),
        .rst_n(rst_n),
        .read_data(read_data)
    );

    // Tao xung clock (Chu ki 10ns)
    always begin
        #5 clk = ~clk;
    end

    // Qua trinh chay test (Stimulus)
    initial begin
        // Khoi tao gia tri ban dau
        clk = 0;
        rst_n = 0;
        address = 32'h0;
        write_data = 32'h0;
        byte_enable = 4'b0000;
        write_enable = 0;

        // 1. Thuc hien Reset bo nho trong 20ns
        #20;
        rst_n = 1;
        #10;

        // 2. Ghi nguyen tu 32-bit (Word) vao dia ch? 32'h00 (Index 0)
        @(posedge clk);
        address = 32'h00;
        write_data = 32'h12345678;
        byte_enable = 4'b1111; // Cho phep ghi ca 4 byte
        write_enable = 1'b1;

        // 3. Ghi vao dia chi 32'h04 (Index 1) nhung chi ghi chon loc 2 byte thap (Halfword)
        @(posedge clk);
        address = 32'h04;
        write_data = 32'h87654321;
        byte_enable = 4'b0011; // Chi cho phep ghi 2 byte thap

        // 4. Tat che do ghi de chuyen sang doc kiem tra du lieu
        @(posedge clk);
        write_enable = 1'b0;
        byte_enable = 4'b0000;

        // 5. Doc du lieu tu dia chi 32'h00
        @(posedge clk);
        address = 32'h00;

        // 6. Doc du lieu tu dia chi 32'h04
        @(posedge clk);
        address = 32'h04;

        // 7. Cho chay them vai chu ky clock roi ket thuc
        #20;
        $finish;
    end

    // Theo doi gia tri qua cua so Transcript
    initial begin
        $monitor("Time = %0t ns | rst_n = %b | wr_en = %b | addr = %h | wr_data = %h | be = %b | rd_data = %h",
                 $time, rst_n, write_enable, address, write_data, byte_enable, read_data);
    end

endmodule
