//==============================================================================
// display_split: 左半屏灰度, 右半屏边缘 (320深 Block RAM 缓存边缘)
//==============================================================================
module display_split (
    input               clk,
    input               rst_n,
    input      [10:0]   h_cnt,
    input      [9:0]    v_cnt,
    input               data_valid,
    input      [7:0]    gray_pixel,
    input      [7:0]    edge_pixel,
    input               pipe_valid,
    output reg [7:0]    disp_r,
    output reg [7:0]    disp_g,
    output reg [7:0]    disp_b
);
    (* ram_style = "block" *) reg [7:0] edge_ram [0:319];
    reg [7:0] edge_rd_q;

    always @(posedge clk) begin
        if (pipe_valid && (h_cnt < 11'd320))
            edge_ram[h_cnt[8:0]] <= edge_pixel;
    end
    wire [8:0] rd_addr = h_cnt[8:0] - 9'd320;
    always @(posedge clk) edge_rd_q <= edge_ram[rd_addr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin disp_r<=0; disp_g<=0; disp_b<=0; end
        else if (data_valid) begin
            if (h_cnt < 11'd320) begin
                disp_r <= gray_pixel; disp_g <= gray_pixel; disp_b <= gray_pixel;
            end else begin
                disp_r <= edge_rd_q; disp_g <= edge_rd_q; disp_b <= edge_rd_q;
            end
        end else begin
            disp_r<=0; disp_g<=0; disp_b<=0;
        end
    end
endmodule
