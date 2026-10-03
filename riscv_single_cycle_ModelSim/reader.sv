/*
* READER
*
* BRH 10/24
*
* Doc du lieu dau vao tu bo nho va dinh dang lai tuy theo ma lenh f3 
* va mat na byte_enable.
*/

`timescale 1ns/1ps

module reader (
    input  logic [31:0] mem_data,     // Du lieu tho doc tu bo nho
    input  logic [3:0]  be_mask,      // Mat na byte_enable
    input  logic [2:0]  f3,           // Ma func3 cua lenh Load trong RISC-V
    output logic [31:0] wb_data,      // Du lieu sau khi xu ly de ghi ve thanh ghi (Write Back)
    output logic        valid         // Tin hieu bao du lieu hop le
); 

import holy_core_pkg::*;

logic sign_extend;
// Xac dinh co can mo rong dau (sign extend) hay khong dua vao bit thu 3 cua f3
assign sign_extend = ~f3[2];

logic [31:0] masked_data; // Du lieu sau khi ap dung mat na be_mask
logic [31:0] raw_data;    // Du lieu duoc dich bit theo vi trí byte/halfword

// Khoi ap dung mat na len du lieu doc tu bo nho
always_comb begin : mask_apply
    for (int i = 0; i < 4; i++) begin
        if (be_mask[i]) begin
            masked_data[(i*8)+:8] = mem_data[(i*8)+:8];
        end else begin
            masked_data[(i*8)+:8] = 8'h00;
        end
    end
end

// Khoi dich chuyen du lieu phu thuoc vao loai lenh Load (Word, Byte, Halfword)
always_comb begin : shift_data
    case (f3)
        F3_WORD : raw_data = masked_data; // Truong hop doc Word (LW): giu nguyen

        F3_BYTE, F3_BYTE_U: begin // Truong hop doc Byte (LB, LBU)
            case (be_mask)
                4'b0001: raw_data = masked_data;
                4'b0010: raw_data = masked_data >> 8;
                4'b0100: raw_data = masked_data >> 16;
                4'b1000: raw_data = masked_data >> 24;
                default: raw_data = 32'd0;
            endcase
        end

        F3_HALFWORD, F3_HALFWORD_U: begin // Truong hop doc Halfword (LH, LHU)
            case (be_mask)
                4'b0011: raw_data = masked_data;
                4'b1100: raw_data = masked_data >> 16;
                default: raw_data = 32'd0;
            endcase
        end

        default: raw_data = 32'd0;
    endcase
end

// Khoi xu ly mo rong dau va xuat ket qua cuoi cung
always_comb begin : sign_extend_logic
    case (f3)
        // LW: Khong can mo rong dau
        F3_WORD : wb_data = raw_data;

        // LB, LBU: Mo rong dau 24 bit hoac giu nguyen (khong dau)
        F3_BYTE, F3_BYTE_U: wb_data = sign_extend ? {{24{raw_data[7]}},raw_data[7:0]} : raw_data;

        // LH, LHU: Mo rong dau 16 bit hoac giu nguyen (khong dau)
        F3_HALFWORD, F3_HALFWORD_U: wb_data = sign_extend ? {{16{raw_data[15]}},raw_data[15:0]} : raw_data;

        default: wb_data = 32'd0;
    endcase

    // Tinh hop le cua du lieu (co it nhat 1 bit trong be_mask duoc bat)
    valid = |be_mask;
end
    
endmodule
