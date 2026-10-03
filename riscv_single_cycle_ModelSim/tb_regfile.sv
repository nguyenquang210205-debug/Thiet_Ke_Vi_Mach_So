`timescale 1ns/1ps

module tb_regfile;

    // Khai bao cac tin hieu ket noi voi module regfile
    logic        clk;
    logic        rst_n;
    logic [4:0]  address1;
    logic [4:0]  address2;
    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic        write_enable;
    logic [31:0] write_data;
    logic [4:0]  address3;

    // Khoi tao (instantiate) module regfile can kiem tra
    regfile uut (
        .clk(clk),
        .rst_n(rst_n),
        .address1(address1),
        .address2(address2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .write_enable(write_enable),
        .write_data(write_data),
        .address3(address3)
    );

    // Tao xung nhip clock (chu ky 10ns -> tan so 100MHz)
    always #5 clk = ~clk;

    // Qua trinh kiem tra (stimulus)
    initial begin
        // Khoi tao cac gia tri ban dau
        clk          = 1'b0;
        rst_n        = 1'b0;
        write_enable = 1'b0;
        write_data   = 32'h0;
        address1     = 5'd0;
        address2     = 5'd0;
        address3     = 5'd0;

        // Cho 20ns de kiem tra qua trinh reset
        #20;
        rst_n = 1'b1;
        #10;

        $display("=== Bat dau kiem tra Register File ===");

        // 1. Thu ghi vao thanh ghi x0 (theo chuan RISC-V, x0 luon phai bang 0)
        @(posedge clk);
        write_enable = 1'b1;
        address3     = 5'd0;
        write_data   = 32'hDEADBEEF;
        
        // 2. Thu ghi vao thanh ghi x1
        @(posedge clk);
        address3     = 5'd1;
        write_data   = 32'h12345678;

        // 3. Thu ghi vao thanh ghi x2
        @(posedge clk);
        address3     = 5'd2;
        write_data   = 32'h87654321;

        // Tat tin hieu ghi
        @(posedge clk);
        write_enable = 1'b0;
        address3     = 5'd0;

        // 4. Doc du lieu tu cac thanh ghi x0, x1, x2 (doc bat dong bo)
        #5;
        address1 = 5'd0;
        address2 = 5'd1;
        #5;
        $display("Doc x0 (Mong doi: 0x00000000) = 0x%08h", read_data1);
        $display("Doc x1 (Mong doi: 0x12345678) = 0x%08h", read_data2);

        #5;
        address1 = 5'd2;
        address2 = 5'd1;
        #5;
        $display("Doc x2 (Mong doi: 0x87654321) = 0x%08h", read_data1);
        $display("Doc x1 (Mong doi: 0x12345678) = 0x%08h", read_data2);

        // Ket thuc mo phong
        #20;
        $display("=== Hoan thanh kiem tra ===");
        $finish;
    end

endmodule
