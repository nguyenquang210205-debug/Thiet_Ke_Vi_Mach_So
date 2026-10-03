/*
* TAP THANH GHI (REGISTER FILE)
*
* BRH 10/24
*
* Tap thanh ghi don gian, tuan thu chuan RISC-V.
*/

`timescale 1ns/1ps

module regfile (

    // Tin hieu co ban
    input  logic        clk,
    input  logic        rst_n,

    // Doc
    input  logic [4:0]  address1,
    input  logic [4:0]  address2,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,

    // Ghi
    input  logic        write_enable,
    input  logic [31:0] write_data,
    input  logic [4:0]  address3

);

// 32 thanh ghi, moi thanh ghi 32-bit (dung dia chi 5 bit)
reg [31:0] registers [0:31]; 

// Logic ghi (dong bo)
always @(posedge clk) begin
    // Ho tro reset, khoi tao tat ca ve 0
    if(rst_n == 1'b0) begin
        for(int i = 0; i<32; i++) begin
            registers[i] <= 32'b0;
        end
    end 
    // Ghi du lieu, ngoai tru thanh ghi 0 (luon co dinh gia tri 0 theo chuan RISC-V)
    else if(write_enable == 1'b1 && address3 != 0) begin
        registers[address3] <= write_data;
    end
end

// Logic doc (bat dong bo)
always_comb begin : readLogic
    read_data1 = registers[address1];
    read_data2 = registers[address2];
end
    
endmodule
