# Clocking Wizard IP 配置说明

顶层 top_edge_detection.v 中例化了一个名为 clk_wiz 的时钟管理 IP，
该 IP 需在 Vivado 中通过 Clocking Wizard 生成，否则综合会报黑盒。

## 参数

| 端口 | 方向 | 频率 | 用途 |
|---|---|---|---|
| clk_in1 | 输入 | 板载时钟（按原理图，50/100 MHz） | 参考时钟 |
| clk_out1 | 输出 | 25.175 MHz | 像素时钟 clk_pixel |
| clk_out2 | 输出 | 125.875 MHz | 5 倍像素时钟 clk_5x |
| clk_out3 | 输出 | 24 MHz | 摄像头 XCLK |
| reset | 输入 | 高有效 | 复位（接 ~rst_n） |
| locked | 输出 | - | PLL 锁定 |

## 生成步骤

1. IP Catalog -> Clocking Wizard。
2. 输入时钟频率按开发板原理图填写。
3. Output Clocks 勾选 clk_out1 / clk_out2 / clk_out3，分别设为 25.175、125.875、24 MHz。
4. Reset 改为 Active High（顶层已用 reset = ~rst_n）。
5. 输出端口名字保持默认，与顶层例化一致。
