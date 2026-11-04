"""gen_test_image.py: 棋盘格测试图 + Python golden model
依赖: pip install pillow numpy
运行: python gen_test_image.py
"""
import numpy as np
from PIL import Image

WIDTH, HEIGHT = 640, 480
THRESHOLD = 100
BLOCK = 40

def make_checkerboard(w, h, block):
    img = np.zeros((h, w), dtype=np.uint8)
    for y in range(h):
        for x in range(w):
            if ((x // block) + (y // block)) % 2 == 0:
                img[y, x] = 255
    return img

def sobel_edge(gray, threshold):
    h, w = gray.shape
    edge = np.zeros_like(gray)
    grad = np.zeros_like(gray)
    g = gray.astype(np.int16)
    for y in range(1, h-1):
        for x in range(1, w-1):
            p1=g[y-1,x-1]; p2=g[y-1,x]; p3=g[y-1,x+1]
            p4=g[y,x-1];                       p6=g[y,x+1]
            p7=g[y+1,x-1]; p8=g[y+1,x]; p9=g[y+1,x+1]
            gx = (p3+2*p6+p9) - (p1+2*p4+p7)
            gy = (p7+2*p8+p9) - (p1+2*p2+p3)
            mag = abs(gx) + abs(gy)
            grad[y,x] = (mag >> 4) & 0xFF
            edge[y,x] = 255 if mag > threshold else 0
    return edge, grad

def main():
    gray = make_checkerboard(WIDTH, HEIGHT, BLOCK)
    Image.fromarray(gray).save("test_pattern.png")
    edge, grad = sobel_edge(gray, THRESHOLD)
    Image.fromarray(edge).save("edge_result.png")
    Image.fromarray(grad).save("grad_result.png")
    split = np.zeros((HEIGHT, WIDTH), dtype=np.uint8)
    split[:, :320] = gray[:, :320]
    split[:, 320:] = edge[:, :320]
    Image.fromarray(split).save("split_preview.png")
    print("[OK] test_pattern.png / edge_result.png / grad_result.png / split_preview.png")

if __name__ == "__main__":
    main()
