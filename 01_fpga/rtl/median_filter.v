//==============================================================================
// median_filter: 3x3 中值滤波 (行中值再中值快速近似)
//==============================================================================
module median_filter (
    input               clk,
    input               rst_n,
    input      [7:0]    p1,p2,p3, p4,p5,p6, p7,p8,p9,
    input               window_valid,
    output reg [7:0]    med_out,
    output reg          out_valid
);
    function [7:0] median3;
        input [7:0] a,b,c;
        reg [8:0] s; reg [7:0] mn,mx;
        begin
            s = a+b+c;
            mn = a<b ? (a<c?a:c) : (b<c?b:c);
            mx = a>b ? (a>c?a:c) : (b>c?b:c);
            median3 = s[8:0] - mn - mx;
        end
    endfunction
    wire [7:0] m1 = median3(p1,p2,p3);
    wire [7:0] m2 = median3(p4,p5,p6);
    wire [7:0] m3 = median3(p7,p8,p9);
    wire [7:0] med_next = median3(m1,m2,m3);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin med_out<=0; out_valid<=0; end
        else begin med_out<=med_next; out_valid<=window_valid; end
    end
endmodule
