//==============================================================================
// hdmi_driver: 640x480@60Hz VGA 时序生成 (像素时钟 25.175MHz)
//==============================================================================
module hdmi_driver (
    input               clk_pixel,
    input               rst_n,
    output reg [10:0]   h_cnt,
    output reg [9:0]    v_cnt,
    output reg          hsync,
    output reg          vsync,
    output reg          data_valid
);
    localparam H_VISIBLE=11'd640, H_FP=11'd16, H_SYNC=11'd96, H_BP=11'd48;
    localparam H_TOTAL = H_VISIBLE + H_FP + H_SYNC + H_BP;
    localparam V_VISIBLE=10'd480, V_FP=10'd10, V_SYNC=10'd2, V_BP=10'd33;
    localparam V_TOTAL = V_VISIBLE + V_FP + V_SYNC + V_BP;

    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) h_cnt <= 0;
        else if (h_cnt == H_TOTAL-1) h_cnt <= 0;
        else h_cnt <= h_cnt + 1;
    end
    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) v_cnt <= 0;
        else if (h_cnt == H_TOTAL-1)
            v_cnt <= (v_cnt == V_TOTAL-1) ? 0 : v_cnt + 1;
    end

    wire hsync_active = (h_cnt >= H_VISIBLE+H_FP) && (h_cnt < H_VISIBLE+H_FP+H_SYNC);
    wire vsync_active = (v_cnt >= V_VISIBLE+V_FP) && (v_cnt < V_VISIBLE+V_FP+V_SYNC);

    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) begin hsync<=1; vsync<=1; end
        else begin hsync <= ~hsync_active; vsync <= ~vsync_active; end
    end
    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) data_valid <= 0;
        else data_valid <= (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);
    end
endmodule
