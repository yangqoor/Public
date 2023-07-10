import random
import contextlib
with contextlib.redirect_stdout(None):     # 禁用版本输出
    import pygame

# 定义屏幕大小的常量
SCREEN_RECT = pygame.Rect(0, 0, 480, 700)
# 刷新帧率
FRAME_PER_SEC = 60
# 创建 敌机定时器常量
CRATE_ENEMY_EVENT = pygame.USEREVENT
# 创建英雄发射子弹事件 (eventid + 1)
HERO_FIRE_EVENT = pygame.USEREVENT + 1


class GameSprites(pygame.sprite.Sprite):
    """飞机大战游戏精灵"""
    def __init__(self, image_name, speed=1):

        # 调用父类的初始化方法(重要：务必主动调用)
        super().__init__()

        # 定义对象的属性
        self.image = pygame.image.load(image_name)
        self.rect = self.image.get_rect()
        self.speed = speed

    def update(self):

        # 在屏幕的垂直方向上移动
        self.rect.y += self.speed


class Background(GameSprites):
    """游戏背景精灵"""
    def __init__(self, is_alt=False):
        # 1. 调用父类方法实现精灵的创建(image/rect/speed)
        super().__init__("./images/background.png")
        # 2. 判断是否是交替图像，如果是，需要设置初始位置
        if is_alt:
            self.rect.y = -SCREEN_RECT.height

    def update(self):
        # 1. 调用父类方法实现
        super().update()
        # 2. 判断是否出屏幕，如果移出屏幕，将图像设置到屏幕上方
        if self.rect.y >= SCREEN_RECT.height:
            self.rect.y = -self.rect.height


class Enemy(GameSprites):
    """敌机精灵"""
    def __init__(self):

        # 1. 调用父类方法创建敌机精灵，指定敌机图片
        super().__init__("./images/enemy1.png")
        # 2. 指定敌机 初始随机速度 1-3
        self.speed = random.randint(1, 3)
        # 3. 指定敌机 初始随机位置 y = bottom - height
        self.rect.bottom = 0
        max_x = SCREEN_RECT.width - self.rect.width
        self.rect.x = random.randint(0, max_x)

    def update(self):

        # 1. 调用父类方法保持垂直方向的飞行
        super().update()

        # 2. 判断是否飞出屏幕，如果是，从精灵组中删除敌机
        if self.rect.y >= SCREEN_RECT.height:
            # print("飞出屏幕")
            # kill 方法可以将精灵从所有精灵组中移出，精灵会自动销毁
            self.kill()
        pass

    # def __del__(self):
    #
    #     print("敌机挂了 %s" % self.rect)


class Hero(GameSprites):
    """英雄精灵"""
    def __init__(self):

        # 1. 调用父类方法，设置image、speed
        super().__init__("./images/me1.png", 0)

        # 2. 设置英雄初始位置
        self.rect.centerx = SCREEN_RECT.centerx
        self.rect.bottom = SCREEN_RECT.bottom - 120

        # 3. 创建子弹的精灵组
        self.bullets_g = pygame.sprite.Group()

    def update(self):

        # 英雄在水平方向移动
        self.rect.x += self.speed

        # 控制英雄不能离开屏幕
        if self.rect.x < 0:
            self.rect.x = 0
        elif self.rect.right > SCREEN_RECT.right:
            self.rect.right = SCREEN_RECT.right

    def fire(self):
        # print("发射子弹...")
        for i in (0, 1, 2):
            # 1. 创建子弹精灵
            bullet = Bullet()

            # 2. 设置精灵的位置
            bullet.rect.bottom = self.rect.y - 20 * i
            bullet.rect.x = self.rect.centerx

            # 3. 将精灵添加至精灵组
            self.bullets_g.add(bullet)


class Bullet(GameSprites):
    """子弹精灵"""
    def __init__(self):

        # 调用父类方法，设置子弹图片、速度
        super().__init__("./images/bullet1.png", -2)

    def update(self):

        # 调用父类方法，让子弹沿垂直方向飞行
        super().update()

        # 判断子弹是否飞出屏幕
        if self.rect.bottom < 0:
            self.kill()

    # def __del__(self):
        # print("子弹销毁。。。")
