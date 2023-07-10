class Gun:
    """枪类"""
    def __init__(self, model):

        # 1. 枪的型号
        self.model = model

        # 2. 子弹的数量
        self.bullet_count = 0

    def add_bullet(self, count):

        self.bullet_count += count
        print("[%s]现有[%d]颗子弹" % (self.model, self.bullet_count))

    def shoot(self):

        # 1. 判断子弹数量
        if self.bullet_count <= 0:
            print("[%s]没有子弹了" % self.model)

            return

        # 2. 发射子弹 子弹-1
        self.bullet_count -= 1

        # 3. 提示发射
        print("[%s] 突突突.... [剩余%d颗子弹]" % (self.model, self.bullet_count))


class Soldier:
    """士兵类"""
    def __init__(self, name):

        # 1. 姓名
        self.name = name

        # 2. 枪 - 假设新兵没有枪
        # 未知属性可以设置为 None
        self.gun = None

    def fire(self):

        # 1. 判断士兵是否有枪
        # if self.gun == None:
        if self.gun is None:
            print("[%s]还没有枪" % self.name)
            return

        # 2. 开枪
        print("冲啊[%s]" % self.name)

        # 3. 装填子弹
        self.gun.add_bullet(50)

        # 4. 发射子弹
        self.gun.shoot()


# 1. 创建 Gun 对象
ak47 = Gun("AK47")


# 2. 创建士兵
xsd = Soldier("许三多")

xsd.gun = ak47               # 调用 Gun 对象
xsd.fire()

print(xsd.gun)
