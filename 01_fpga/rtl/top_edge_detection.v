//==============================================================================
// top_edge_detection: 实时图像边缘检测系统顶层
// 流水线: 摄像头 -> rgb2gray -> line_buffer -> median -> line_buffer
//         -> sobel -> display_split -> tmds x4
//==============================================================================
module top_edge_detection (
    input               clk_board,
    input               rst_n,
    input               cam_pclk,
    input               cam_vsync,
    input               cam_href,
    input      [7:0]    cam_data,
    output              cam_xclk,
    inout               cam_scl,
    inout               cam_sda,
    output              hdmi_clk_p, hdmi_clk_n,
    output              hdmi_d0_p, hdmi_d0_n,
    output              hdmi_d1_p, hdmi_d1_n,
    output              hdmi_d2_p, hdmi_d2_n,
    input      [7:0]    threshold_sw
);

    wire clk_pixel, clk_5x, clk_cam, locked;
    clk_wiz u_clk_wiz (
        .clk_in1(clk_board),
        .clk_out1(clk_pixel), .clk_out2(clk_5x), .clk_out3(clk_cam),
        .reset(~rst_n), .locked(locked)
    );
    assign cam_xclk = clk_cam;
    wire sys_rst_n = rst_n & locked;

    // 1. 摄像头采集
    wire [15:0] cam_pixel; wire cam_pixel_valid, cam_frame_start, cam_line_valid;
    camera_capture u_cam (
        .pclk(cam_pclk), .rst_n(sys_rst_n),
        .cam_vsync(cam_vsync), .cam_href(cam_href), .cam_data(cam_data),
        .pixel_out(cam_pixel), .pixel_valid(cam_pixel_valid),
        .frame_start(cam_frame_start), .line_valid(cam_line_valid)
    );

    // 2. RGB565 -> gray
    wire [7:0] gray; wire gray_valid;
    rgb2gray u_rgb2gray (
        .clk(clk_pixel), .rst_n(sys_rst_n),
        .pixel_in(cam_pixel), .in_valid(cam_pixel_valid),
        .gray_out(gray), .out_valid(gray_valid)
    );

    // 3. 第一级 3 行缓存
    wire [7:0] p1,p2,p3,p4,p5,p6,p7,p8,p9; wire win1_valid;
    line_buffer_3x3 #(.COL_MAX(640)) u_lb1 (
        .clk(clk_pixel), .rst_n(sys_rst_n),
        .pixel_in(gray), .in_valid(gray_valid),
        .p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),
        .p7(p7),.p8(p8),.p9(p9), .window_valid(win1_valid)
    );

    // 4. 中值滤波
    wire [7:0] med; wire med_valid;
    median_filter u_med (
        .clk(clk_pixel), .rst_n(sys_rst_n),
        .p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),
        .p7(p7),.p8(p8),.p9(p9), .window_valid(win1_valid),
        .med_out(med), .out_valid(med_valid)
    );

    // 5. 第二级 3 行缓存
    wire [7:0] q1,q2,q3,q4,q5,q6,q7,q8,q9; wire win2_valid;
    line_buffer_3x3 #(.COL_MAX(640)) u_lb2 (
        .clk(clk_pixel), .rst_n(sys_rst_n),
        .pixel_in(med), .in_valid(med_valid),
        .p1(q1),.p2(q2),.p3(q3),.p4(q4),.p5(q5),.p6(q6),
        .p7(q7),.p8(q8),.p9(q9), .window_valid(win2_valid)
    );

    // 6. Sobel
    wire [7:0] edge_bin, grad; wire edge_valid;
    sobel_edge #(.THRESHOLD(8'd128)) u_sobel (
        .clk(clk_pixel), .rst_n(sys_rst_n),
        .p1(q1),.p2(q2),.p3(q3),.p4(q4),.p5(q5),.p6(q6),
        .p7(q7),.p8(q8),.p9(q9), .window_valid(win2_valid),
        .threshold(threshold_sw),
        .edge_out(edge_bin), .grad_out(grad), .out_valid(edge_valid)
    );

    // 7. HDMI 时序
    wire [10:0] h_cnt; wire [9:0] v_cnt; wire hsync, vsync, de;
    hdmi_driver u_hdmi (
        .clk_pixel(clk_pixel), .rst_n(sys_rst_n),
        .h_cnt(h_cnt), .v_cnt(v_cnt),
        .hsync(hsync), .vsync(vsync), .data_valid(de)
    );

    // 8. 分屏显示
    wire [7:0] disp_r, disp_g, disp_b;
    display_split u_split (
        .clk(clk_pixel), .rst_n(sys_rst_n),
        .h_cnt(h_cnt), .v_cnt(v_cnt), .data_valid(de),
        .gray_pixel(gray), .edge_pixel(edge_bin), .pipe_valid(de),
        .disp_r(disp_r), .disp_g(disp_g), .disp_b(disp_b)
    );

    // 9. TMDS 通道
    wire [1:0] ctrl0 = {vsync, hsync};
    tmds_channel u_ch0 (.clk(clk_pixel),.clk_5x(clk_5x),.rst_n(sys_rst_n),
        .din(disp_b),.ctrl(ctrl0),.de(de),.tmds_p(hdmi_d0_p),.tmds_n(hdmi_d0_n));
    tmds_channel u_ch1 (.clk(clk_pixel),.clk_5x(clk_5x),.rst_n(sys_rst_n),
        .din(disp_g),.ctrl(2'b00),.de(de),.tmds_p(hdmi_d1_p),.tmds_n(hdmi_d1_n));
    tmds_channel u_ch2 (.clk(clk_pixel),.clk_5x(clk_5x),.rst_n(sys_rst_n),
        .din(disp_r),.ctrl(2'b00),.de(de),.tmds_p(hdmi_d2_p),.tmds_n(hdmi_d2_n));
    tmds_channel u_chclk (.clk(clk_pixel),.clk_5x(clk_5x),.rst_n(sys_rst_n),
        .din(8'd0),.ctrl(2'b00),.de(1'b0),.tmds_p(hdmi_clk_p),.tmds_n(hdmi_clk_n));

endmodule
