import contextlib
with contextlib.redirect_stdout(None):     # 禁用版本输出
    import pygame

"""游戏初始化"""
pygame.init()

# 创建游戏窗口
screen = pygame.display.set_mode((480, 700))

# 绘制背景图像
# 1> image模块 load方法 加载图像数据
bg_img = pygame.image.load("./images/background.png")
# 2> 屏幕对象surface 的 blit 绘制图像
screen.blit(bg_img, (0, 0))
# 3> 窗口模块 display 的 update 更新屏幕显示
# pygame.display.update()

# 绘制英雄的飞机
hero = pygame.image.load("./images/me1.png")
screen.blit(hero, (190, 500))
# 可以在所有的绘制工作完成之后，统一调用 update 方法
pygame.display.update()

# 创建时钟对象
clock = pygame.time.Clock()

"""游戏正式开始"""
while True:
    # 指定循环体内部的代码执行频率
    clock.tick(60)
    # pass

pygame.quit()
