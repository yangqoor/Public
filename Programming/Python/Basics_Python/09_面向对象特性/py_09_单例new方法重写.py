class MusicPlayer(object):

    def __new__(cls, *args, **kwargs):

        # 1. 创建对象时， new 方法会被自动调用
        print("创建对象，分配空间")

        # 2. 为对象分配空间
        instance = super().__new__(cls)

        # 3. 返回对象的引用
        return instance

    def __init__(self):

        print("播放器初始化")


# 创建多个播放器对象
player1 = MusicPlayer()
print(player1)

player2 = MusicPlayer()
print(player2)
