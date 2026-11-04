`timescale 1ns/1ps
// tb_image_pipeline: 验证 rgb2gray -> line_buffer -> median -> sobel 流水线
module tb_image_pipeline;
    reg clk = 0; reg rst_n = 0;
    always #20 clk = ~clk;

    reg [15:0] pixel_in = 0; reg in_valid = 0;
    wire [7:0] gray; wire gray_valid;
    wire [7:0] p1,p2,p3,p4,p5,p6,p7,p8,p9; wire win_valid;
    wire [7:0] med; wire med_valid;
    wire [7:0] q1,q2,q3,q4,q5,q6,q7,q8,q9; wire win2_valid;
    wire [7:0] edge_bin; wire [7:0] grad; wire edge_valid;

    rgb2gray u_rgb2gray (.clk(clk),.rst_n(rst_n),.pixel_in(pixel_in),.in_valid(in_valid),
        .gray_out(gray),.out_valid(gray_valid));
    line_buffer_3x3 #(.COL_MAX(640)) u_lb1 (
        .clk(clk),.rst_n(rst_n),.pixel_in(gray),.in_valid(gray_valid),
        .p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),
        .p7(p7),.p8(p8),.p9(p9),.window_valid(win_valid));
    median_filter u_med (
        .clk(clk),.rst_n(rst_n),.p1(p1),.p2(p2),.p3(p3),
        .p4(p4),.p5(p5),.p6(p6),.p7(p7),.p8(p8),.p9(p9),
        .window_valid(win_valid),.med_out(med),.out_valid(med_valid));
    line_buffer_3x3 #(.COL_MAX(640)) u_lb2 (
        .clk(clk),.rst_n(rst_n),.pixel_in(med),.in_valid(med_valid),
        .p1(q1),.p2(q2),.p3(q3),.p4(q4),.p5(q5),.p6(q6),
        .p7(q7),.p8(q8),.p9(q9),.window_valid(win2_valid));
    sobel_edge u_sobel (
        .clk(clk),.rst_n(rst_n),.p1(q1),.p2(q2),.p3(q3),
        .p4(q4),.p5(q5),.p6(q6),.p7(q7),.p8(q8),.p9(q9),
        .window_valid(win2_valid),.threshold(8'd100),
        .edge_out(edge_bin),.grad_out(grad),.out_valid(edge_valid));

    integer x, y;
    initial begin
        rst_n = 0; repeat(5) @(posedge clk); rst_n = 1; repeat(5) @(posedge clk);
        for (y=0; y<6; y=y+1) begin
            @(posedge clk); in_valid = 1;
            for (x=0; x<640; x=x+1) begin
                pixel_in = (x < 320) ? 16'h0000 : 16'hFFFF;
                @(posedge clk);
            end
            in_valid = 0; repeat(10) @(posedge clk);
        end
        $display("=== done ==="); $finish;
    end

    always @(posedge clk) begin
        if (edge_valid && grad > 8'd20)
            $display("t=%0t edge=0x%02h grad=0x%02h", $time, edge_bin, grad);
    end
endmodule
