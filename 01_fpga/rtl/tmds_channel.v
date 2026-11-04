//==============================================================================
// tmds_channel: 8b/10b 编码 + OSERDESE2 + OBUFDS (Xilinx 7 系列)
//==============================================================================
module tmds_channel (
    input               clk,
    input               clk_5x,
    input               rst_n,
    input      [7:0]    din,
    input      [1:0]    ctrl,
    input               de,
    output              tmds_p,
    output              tmds_n
);
    reg [9:0] ctrl_word;
    always @(*) begin
        case (ctrl)
            2'b00: ctrl_word = 10'b1101010100;
            2'b01: ctrl_word = 10'b0010101011;
            2'b10: ctrl_word = 10'b0101010100;
            default: ctrl_word = 10'b1010101011;
        endcase
    end

    wire [3:0] ones_d = din[0]+din[1]+din[2]+din[3]+din[4]+din[5]+din[6]+din[7];
    wire use_xnor = (ones_d > 4) || (ones_d == 4 && din[0]==0);

    reg [8:0] q_m;
    always @(*) begin
        q_m[0] = din[0];
        q_m[1] = use_xnor ? ~(q_m[0]^din[1]) : (q_m[0]^din[1]);
        q_m[2] = use_xnor ? ~(q_m[1]^din[2]) : (q_m[1]^din[2]);
        q_m[3] = use_xnor ? ~(q_m[2]^din[3]) : (q_m[2]^din[3]);
        q_m[4] = use_xnor ? ~(q_m[3]^din[4]) : (q_m[3]^din[4]);
        q_m[5] = use_xnor ? ~(q_m[4]^din[5]) : (q_m[4]^din[5]);
        q_m[6] = use_xnor ? ~(q_m[5]^din[6]) : (q_m[5]^din[6]);
        q_m[7] = use_xnor ? ~(q_m[6]^din[7]) : (q_m[6]^din[7]);
        q_m[8] = ~use_xnor;
    end

    wire [3:0] ones_m = q_m[0]+q_m[1]+q_m[2]+q_m[3]+q_m[4]+q_m[5]+q_m[6]+q_m[7];
    reg [4:0] bias;
    reg [9:0] q_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin bias<=0; q_out<=0; end
        else if (!de) begin bias<=0; q_out<=ctrl_word; end
        else begin
            if ((bias==0) || (ones_m==4)) begin
                if (q_m[8]==0) begin
                    q_out <= {2'b10, ~q_m[7:0]};
                    bias <= bias + (4'd4 - ones_m);
                end else begin
                    q_out <= {2'b11, q_m[7:0]};
                    bias <= bias + (ones_m - 4'd4);
                end
            end else begin
                if ((bias[4]==0 && ones_m>4) || (bias[4]==1 && ones_m<4)) begin
                    q_out <= {1'b1, ~q_m[8], ~q_m[7:0]};
                    bias <= bias + {1'b0,q_m[8],1'b0} + (4'd4-ones_m);
                end else begin
                    q_out <= {1'b0, q_m[8], q_m[7:0]};
                    bias <= bias - {1'b0,~q_m[8],1'b0} + (ones_m-4'd4);
                end
            end
        end
    end

    wire ser_data;
    OSERDESE2 #(
        .DATA_WIDTH(10), .TRISTATE_WIDTH(1),
        .SERDES_MODE("MASTER"),
        .DATA_RATE_OQ("DDR"), .DATA_RATE_TQ("SDR")
    ) u_oserdes (
        .OQ(ser_data), .CLK(clk_5x), .CLKB(~clk_5x),
        .OCLK(clk_5x), .OCLKB(~clk_5x),
        .OCE(1'b1), .TCE(1'b0), .RST(~rst_n),
        .D1(q_out[0]), .D2(q_out[1]), .D3(q_out[2]), .D4(q_out[3]),
        .D5(q_out[4]), .D6(q_out[5]), .D7(q_out[6]), .D8(q_out[7]),
        .T1(0),.T2(0),.T3(0),.T4(0),
        .OFB(),.TFB(),.TBYTEIN(0),.TBYTEOUT(),
        .SHIFTIN1(0),.SHIFTIN2(0),.SHIFTOUT1(),.SHIFTOUT2()
    );
    OBUFDS #(.IOSTANDARD("TMDS_33")) u_obuf (
        .O(tmds_p), .OB(tmds_n), .I(ser_data)
    );
endmodule
