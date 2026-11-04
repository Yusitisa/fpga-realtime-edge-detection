# 基于 FPGA 的实时图像边缘检测系统 — 源码说明

## 1. 平台与工具链

| 项目 | 规格 |
|---|---|
| FPGA 芯片 | Xilinx Zynq-7010（XC7Z010clg400-1） |
| 开发板 | 博宸精芯 ZYNQ_MINI |
| 摄像头 | OV5640（DVP 接口，640×480 RGB565） |
| 显示输出 | HDMI（640×480@60Hz） |
| EDA 工具 | Xilinx Vivado 2021.1 或更高 |
| 仿真工具 | Vivado 内置仿真器 |
| Python | 3.10+，Pillow / numpy（仅 golden model） |

## 2. 目录结构

```
├── README.md
├── 版本与工具链.txt
├── 01_fpga/
│   ├── rtl/        9 个 Verilog 模块
│   ├── constrs/    XDC 管脚与时序约束
│   └── ip_config.md
├── 02_software/   纯 PL 设计，无 PS 软件
└── 03_test/
    ├── tb/         流水线 testbench
    └── python/     golden model + 测试图
```

## 3. 编译与运行

1. Vivado 新建工程，器件 xc7z010clg400-1。
2. 把 01_fpga/rtl/*.v 加入 Sources，01_fpga/constrs/*.xdc 加入 Constraints。
3. IP Catalog 生成 Clocking Wizard，名字必须为 clk_wiz，三路输出：
   clk_out1=25.175MHz（像素时钟）、clk_out2=125.875MHz（5 倍时钟）、clk_out3=24MHz（摄像头 XCLK）。
4. 按开发板原理图修改 XDC 中每个 PACKAGE_PIN。
5. Generate Bitstream，下载到板子。
6. 上电后左半屏为灰度图，右半屏为 Sobel 二值化边缘，拨码开关调节阈值。

## 4. 注意事项

- 摄像头 PCLK 需配置为与像素时钟同频（约 25 MHz）。
- 当前版本未实现 SCCB/I2C 摄像头配置，依赖 OV5640 默认寄存器。
- 代码不含任何学校、姓名、学号信息。
