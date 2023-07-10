import contextlib
with contextlib.redirect_stdout(None):     # 禁用版本输出
    import pygame

pygame.init()

# 创建游戏窗口
screen = pygame.display.set_mode((480, 700))

# 绘制背景图像
# 1> image模块 load方法 加载图像数据
bg_img = pygame.image.load("./images/background.png")
# 2> 屏幕对象surface 的 blit 绘制图像
screen.blit(bg_img, (0, 0))
# 3> 窗口模块 display 的 update 更新屏幕显示
pygame.display.update()

while True:

    pass

pygame.quit()
