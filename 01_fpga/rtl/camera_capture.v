//==============================================================================
// camera_capture: DVP OV5640 像素采集, 字节拼接 RGB565
//==============================================================================
module camera_capture (
    input               pclk,
    input               rst_n,
    input               cam_vsync,
    input               cam_href,
    input      [7:0]    cam_data,
    output reg [15:0]   pixel_out,
    output reg          pixel_valid,
    output reg          frame_start,
    output reg          line_valid
);
    reg vsync_d1, vsync_d2;
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin vsync_d1 <= 0; vsync_d2 <= 0; end
        else begin vsync_d1 <= cam_vsync; vsync_d2 <= vsync_d1; end
    end
    wire vsync_rise = vsync_d1 & ~vsync_d2;

    reg        byte_toggle;
    reg [7:0]  byte_h;
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            byte_toggle <= 0; byte_h <= 0; pixel_out <= 0;
            pixel_valid <= 0; line_valid <= 0; frame_start <= 0;
        end else begin
            pixel_valid <= 0; frame_start <= 0; line_valid <= cam_href;
            if (vsync_rise) frame_start <= 1;
            if (cam_href) begin
                if (byte_toggle == 0) begin byte_h <= cam_data; byte_toggle <= 1; end
                else begin
                    pixel_out <= {byte_h, cam_data};
                    pixel_valid <= 1; byte_toggle <= 0;
                end
            end else byte_toggle <= 0;
        end
    end
endmodule
