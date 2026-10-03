`timescale 1ns/1ps

module cpu_tb;

    // Khai bao tin hieu cho TB
    logic clk;
    logic rst_n;

    // Khoi tao ket n?i vao module CPU
    cpu u_cpu (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Tao xung clock (Chu ki 10ns -> Tan so 100MHz)
    always begin
        #5 clk = ~clk;
    end

    // Qua trinh chay test (Stimulus)
    initial begin
        // Khoi tao gia tri ban dau
        clk = 0;
        rst_n = 0; // Kich hoat reset muc thap

        // Giu reset trong 20ns
        #20;
        rst_n = 1; // Tha reset, cho phep CPU hoat dong

        // Cho chay mo phong trong mot khoang thoi gian (vi du: 500ns)
        #500;
        
        // Ket thuc mo phong
        $finish;
    end

    // Theo dõi qua trình ch?y qua c?a s? Console (Log)
    initial begin
        $monitor("Time = %0t ns | PC = %h | Instruction = %h", $time, u_cpu.pc, u_cpu.instruction);
    end

endmodule
