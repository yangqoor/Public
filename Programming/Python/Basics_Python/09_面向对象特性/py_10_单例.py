class MusicPlayer(object):

    # 定义类属性，记录第一个被创建对象的引用
    instance = None

    # 记录是否执行过初始化动作
    init_flag = False

    def __new__(cls, *args, **kwargs):

        # 1. 判断类属性是否是空对象
        if cls.instance is None:

            # 2. 调用父类方法为第一个对象分配空间
            cls.instance = super().__new__(cls)

        # 3. 返回类属性保存的对象引用
        return cls.instance

    def __init__(self):

        # 1. 判断是否执行过初始化动作
        if MusicPlayer.init_flag:

            return
        # 2. 如果没有执行过，再执行初始化动作
        print("播放器初始化")

        # 3. 修改是否初始化标记
        MusicPlayer.init_flag = True


# 创建多个播放器对象
player1 = MusicPlayer()
print(player1)

player2 = MusicPlayer()
print(player2)
