import contextlib
with contextlib.redirect_stdout(None):     # 禁用版本输出
    import pygame

hero_rect = pygame.Rect(100, 500, 120, 125)


print("英雄的原点(%d,%d)" % (hero_rect.x, hero_rect.y))
print("英雄的尺寸 %d×%d" % (hero_rect.width, hero_rect.height))
print("英雄的尺寸 %d×%d" % hero_rect.size)
