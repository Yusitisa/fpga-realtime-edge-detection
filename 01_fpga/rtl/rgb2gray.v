//==============================================================================
// rgb2gray: RGB565 -> 8bit gray, 移位加法实现 77/150/29 加权
//==============================================================================
module rgb2gray (
    input               clk,
    input               rst_n,
    input      [15:0]   pixel_in,
    input               in_valid,
    output reg [7:0]    gray_out,
    output reg          out_valid
);
    wire [7:0] r = {pixel_in[15:11], 3'b000};
    wire [7:0] g = {pixel_in[10:5],  2'b00};
    wire [7:0] b = {pixel_in[4:0],   3'b000};

    wire [17:0] r_term = ({1'b0,r,6'b0}) + ({2'b0,r,3'b0}) + ({3'b0,r,2'b0}) + ({10'b0,r});
    wire [17:0] g_term = ({1'b0,g,7'b0}) + ({2'b0,g,4'b0}) + ({3'b0,g,2'b0}) + ({3'b0,g,1'b0});
    wire [17:0] b_term = ({3'b0,b,4'b0}) + ({3'b0,b,3'b0}) + ({3'b0,b,2'b0}) + ({10'b0,b});
    wire [17:0] sum = r_term + g_term + b_term;
    wire [7:0] gray_next = sum[15:8];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin gray_out <= 0; out_valid <= 0; end
        else begin gray_out <= gray_next; out_valid <= in_valid; end
    end
endmodule
