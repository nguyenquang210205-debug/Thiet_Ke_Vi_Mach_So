/*
* LOAD STORE DECODER
*
* BRH 10/24
*
* Sits before the data memory and allows to feed the right signals into the memory's cpu interface.
*/

`timescale 1ns/1ps

module load_store_decoder (
    input  logic [31:0] alu_result_address, // Dia chi tinh toan tu ALU (dung de xac dinh offset)
    input  logic [2:0]  f3,                 // Truong func3 trong tap lenh RISC-V (phan biet Byte, Halfword, Word)
    input  logic [31:0] reg_read,           // Du lieu doc tu thanh ghi (nguon ghi vao bo nho)
    output logic [3:0]  byte_enable,        // Tin hieu cho phép ghi theo byte (4-bit mask cho 4 byte cua tu 32-bit)
    output logic [31:0] data                // Du lieu sau khi dich bit tuong ung de dua vao bo nho
);

import holy_core_pkg::*; // Import thu vien chua cac hang so f3

logic [1:0] offset;

// Lay 2 bit thap cua dia chi ALU de xac dinh vi tri byte/halfword can thao tac trong tu 32-bit
assign offset = alu_result_address[1:0];

always_comb begin
    case (f3)
        F3_BYTE, F3_BYTE_U : begin // Xu ly cac lenh SB (Store Byte), LB, LBU
            case (offset)
                2'b00: begin
                    byte_enable = 4'b0001; // Ghi byte thap nhat (offset 0)
                    data = (reg_read & 32'h000000FF);
                end
                2'b01: begin 
                    byte_enable = 4'b0010; // Ghi byte thu 2 (offset 1)
                    data = (reg_read & 32'h000000FF) << 8;
                end
                2'b10: begin 
                    byte_enable = 4'b0100; // Ghi byte thu 3 (offset 2)
                    data = (reg_read & 32'h000000FF) << 16;
                end
                2'b11: begin 
                    byte_enable = 4'b1000; // Ghi byte thu 4 (offset 3)
                    data = (reg_read & 32'h000000FF) << 24;
                end
                default: byte_enable = 4'b0000;
            endcase
        end
        
        F3_WORD: begin // Xu ly lenh SW (Store Word - ghi nguyen mot tu 32-bit)
            // Chi cho phep ghi khi dia chi can le (offset = 00)
            byte_enable = (offset == 2'b00) ? 4'b1111 : 4'b0000;
            data = reg_read;
        end

        F3_HALFWORD, F3_HALFWORD_U : begin // Xu ly cac lenh SH (Store Halfword), LH, LHU
            case (offset)
                2'b00: begin 
                    byte_enable = 4'b0011; // Ghi nua tu thap (2 byte dau: offset 0 va 1)
                    data = (reg_read & 32'h0000FFFF);
                end
                2'b10: begin
                    byte_enable = 4'b1100; // Ghi nua tu cao (2 byte sau: offset 2 va 3)
                    data = (reg_read & 32'h0000FFFF) << 16;
                end
                default: byte_enable = 4'b0000;
            endcase
        end

        default: begin
            byte_enable = 4'b0000; // Mac dinh khong thuc hien thao tac nao cho cac loai khong ho tro
        end
    endcase
end

endmodule
