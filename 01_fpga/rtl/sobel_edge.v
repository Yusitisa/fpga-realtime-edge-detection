//==============================================================================
// sobel_edge: Gx/Gy -> |Gx|+|Gy| -> 阈值二值化
//==============================================================================
module sobel_edge #(
    parameter THRESHOLD = 8'd128
)(
    input               clk,
    input               rst_n,
    input      [7:0]    p1,p2,p3, p4,p5,p6, p7,p8,p9,
    input               window_valid,
    input      [7:0]    threshold,
    output reg [7:0]    edge_out,
    output reg [7:0]    grad_out,
    output reg          out_valid
);
    wire [10:0] gx_pos = p3 + {p6,1'b0} + p9;
    wire [10:0] gx_neg = p1 + {p4,1'b0} + p7;
    wire signed [11:0] gx = $signed({1'b0,gx_pos}) - $signed({1'b0,gx_neg});

    wire [10:0] gy_pos = p7 + {p8,1'b0} + p9;
    wire [10:0] gy_neg = p1 + {p2,1'b0} + p3;
    wire signed [11:0] gy = $signed({1'b0,gy_pos}) - $signed({1'b0,gy_neg});

    wire [11:0] abs_gx = gx[11] ? -gx : gx;
    wire [11:0] abs_gy = gy[11] ? -gy : gy;
    wire [11:0] mag = abs_gx + abs_gy;

    wire edge_next = (mag > {4'd0, threshold});
    wire [7:0] grad_next = mag[11:4];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin edge_out<=0; grad_out<=0; out_valid<=0; end
        else begin
            edge_out <= edge_next ? 8'hFF : 8'h00;
            grad_out <= grad_next;
            out_valid <= window_valid;
        end
    end
endmodule
