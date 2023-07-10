import contextlib

with contextlib.redirect_stdout(None):  # 禁用版本输出
    import pygame
from plane_sprites import *


class PlaneGame(object):
    """飞机大战主游戏"""

    def __init__(self):
        print("游戏初始化")

        # 1. 设置游戏窗口 --> 窗口尺寸不要在这儿写死
        self.screen = pygame.display.set_mode(SCREEN_RECT.size)
        # 2. 创建游戏时钟
        self.clock = pygame.time.Clock()
        # 3. 调用私有方法，创建精灵和精灵组
        self.__create_sprites()

        # 4. 设置定时器事件 - 创建敌机  1000ms
        pygame.time.set_timer(CRATE_ENEMY_EVENT, 1000)

        # 5. 设置定时器事件 - 发射子弹  500ms
        pygame.time.set_timer(HERO_FIRE_EVENT, 500)

    def __create_sprites(self):
        # 1. 创建背景精灵和精灵组
        # Background 类 初始化优化
        # bg1 = Background("./images/background.png")
        # bg2 = Background("./images/background.png")
        # bg2.rect.y = -SCREEN_RECT.height     # 初始位置在窗口之上
        bg1 = Background()
        bg2 = Background(True)
        self.back_group = pygame.sprite.Group(bg1, bg2)

        # 创建敌机精灵组
        self.enemy_group = pygame.sprite.Group()

        # 创建英雄的精灵和精灵组
        self.hero = Hero()
        self.hero_group = pygame.sprite.Group(self.hero)

    def start_game(self):
        print("游戏开始...")

        while True:
            # 1. 设置刷新帧率
            self.clock.tick(FRAME_PER_SEC)
            # 2. 事件监听
            self.__event_handler()
            # 3. 碰撞检测
            self.__check_collid()
            # 4. 更新/绘制精灵组
            self.__update_sprites()
            # 5. 更新显示
            pygame.display.update()

    def __event_handler(self):
        """私有方法：事件监听

        """
        event_list = pygame.event.get()
        for event in event_list:

            # 判段是否退出游戏
            if event.type == pygame.QUIT:
                PlaneGame.__game_over()

            # 判断敌机定时器事件
            elif event.type == CRATE_ENEMY_EVENT:
                # print("敌机出场...")
                # 1. 创建敌机精灵
                enemy = Enemy()

                # 2. 将敌机精灵添加至敌机精灵组
                self.enemy_group.add(enemy)

            # 判断子弹发射 定时器事件
            elif event.type == HERO_FIRE_EVENT:
                self.hero.fire()

            # 判断按键事件
            # elif event.type == pygame.KEYDOWN and event.key == pygame.K_RIGHT:
            #     print("向右移动...")    # 需要键盘再次按下才能触发下次事件
        # 使用键盘提供的方法获取键盘按键 - 按键元组
        key_pressed = pygame.key.get_pressed()  # 可以按下键不动
        # 判断元组中对应的按键索引值
        if key_pressed[pygame.K_RIGHT]:
            # print("向右移动...")
            self.hero.speed = 2
        elif key_pressed[pygame.K_LEFT]:
            # print("向左移动...")
            self.hero.speed = -2
        else:
            self.hero.speed = 0

    def __check_collid(self):
        """私有方法：碰撞检测

        """
        # 子弹摧毁敌机
        pygame.sprite.groupcollide(self.hero.bullets_g,
                                   self.enemy_group,
                                   True, True)

        # 敌机撞毁英雄
        enemies = pygame.sprite.spritecollide(self.hero,
                                              self.enemy_group,
                                              True)
        # 判断列表是否有内容
        if len(enemies) > 0:

            # 让英雄牺牲
            self.hero.kill()
            # 结束游戏
            PlaneGame.__game_over()

    def __update_sprites(self):
        """私有方法：更新/绘制精灵组

        """
        self.back_group.update()
        self.back_group.draw(self.screen)

        self.enemy_group.update()
        self.enemy_group.draw(self.screen)

        self.hero.update()
        self.hero_group.draw(self.screen)

        self.hero.bullets_g.update()
        self.hero.bullets_g.draw(self.screen)

    @staticmethod
    def __game_over():
        """私有方法：退出游戏

        """
        print("游戏结束")

        pygame.quit()
        exit()


if __name__ == '__main__':
    # 创建游戏对象
    game = PlaneGame()

    # 启动游戏
    game.start_game()
