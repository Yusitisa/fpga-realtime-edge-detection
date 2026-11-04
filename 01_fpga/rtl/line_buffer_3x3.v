//==============================================================================
// line_buffer_3x3: 3 行 Block RAM, 输出 3x3 滑动窗口 p1..p9
//==============================================================================
module line_buffer_3x3 #(
    parameter COL_MAX = 640
)(
    input               clk,
    input               rst_n,
    input      [7:0]    pixel_in,
    input               in_valid,
    output reg [7:0]    p1,p2,p3, p4,p5,p6, p7,p8,p9,
    output reg          window_valid
);
    reg [9:0] col;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) col <= 0;
        else if (in_valid) col <= (col == COL_MAX-1) ? 0 : col + 1;
    end

    (* ram_style = "block" *) reg [7:0] line0 [0:COL_MAX-1];
    (* ram_style = "block" *) reg [7:0] line1 [0:COL_MAX-1];
    reg [7:0] line0_q, line1_q;
    always @(posedge clk) begin
        line0_q <= line0[col];
        line1_q <= line1[col];
        if (in_valid) begin
            line0[col] <= pixel_in;
            line1[col] <= line0_q;
        end
    end

    reg [7:0] d0,d1,d2, r0,r1,r2, rr0,rr1,rr2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {d0,d1,d2} <= 0; {r0,r1,r2} <= 0; {rr0,rr1,rr2} <= 0;
        end else if (in_valid) begin
            d2<=d1; d1<=d0; d0<=pixel_in;
            r2<=r1; r1<=r0; r0<=line0_q;
            rr2<=rr1; rr1<=rr0; rr0<=line1_q;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {p1,p2,p3}<=0; {p4,p5,p6}<=0; {p7,p8,p9}<=0;
        end else if (in_valid) begin
            p1<=rr2; p2<=rr1; p3<=rr0;
            p4<=r2;  p5<=r1;  p6<=r0;
            p7<=d2;  p8<=d1;  p9<=d0;
        end
    end

    reg v1,v2,v3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin v1<=0; v2<=0; v3<=0; window_valid<=0; end
        else begin v1<=in_valid; v2<=v1; v3<=v2; window_valid<=v3; end
    end
endmodule
