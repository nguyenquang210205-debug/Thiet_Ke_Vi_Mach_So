`timescale 1ns/1ps

module memory #(
    parameter int WORDS = 128,
    parameter string mem_init = ""
) (
    input  logic        clk,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    input  logic [3:0]  byte_enable,
    input  logic        write_enable,
    input  logic        rst_n,
    output logic [31:0] read_data
);

// Mang bo nho 32-bit
reg [31:0] mem [WORDS];

// Bien chay cho vong lap
integer i;

// Khoi tao du lieu tu file hex neu co
initial begin
    if (mem_init != "") begin
        $readmemh(mem_init, mem);
    end
end

// Qua trinh ghi du lieu theo xung clock
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        for (i = 0; i < WORDS; i = i + 1) begin
            mem[i] <= 32'd0;
        end
    end else begin
        if (write_enable) begin
            if (address[1:0] != 2'b00) begin
                $display("STOPPING SIMULATION: Misaligned write at address %h.", address);
                $stop;
            end else begin
                for (i = 0; i < 4; i = i + 1) begin
                    if (byte_enable[i]) begin
                        /* verilator lint_off WIDTHTRUNC */
                        mem[address[31:2]][(i*8)+:8] <= write_data[(i*8)+:8];
                        /* verilator lint_on WIDTHTRUNC */
                    end
                end
            end
        end
    end
end

// Qua trinh doc du lieu to hop
always_comb begin
    read_data = 32'h00000000;
    if (address[1:0] != 2'b00) begin
        // Dung mo phong an toan thay cho $fatal neu tool cu khong ho tro
        read_data = 32'h00000000;
    end else begin
        /* verilator lint_off WIDTHTRUNC */
        read_data = mem[address[31:2]];
        /* verilator lint_on WIDTHTRUNC */
    end
end

endmodule
