# 综合应用——石头剪刀布
# 导入随机工具包
# 导入的工具包应在文件的顶部
import random
# 输入 石头 1 ，剪刀 2 ，布 3
player = int(input("请输入您要出的拳，石头 1 ，剪刀 2 ，布 3："))

# 电脑随机出拳，假定只会出拳
computer = random.randint(1, 3)  # randint(min, max)

print("玩家出拳为：%d，电脑出拳为：%d" % (player, computer))

# 判断胜负
# 1 石头 胜 剪刀
# 2 剪刀 胜 布
# 3 布   胜 石头
# 先写框架，
# if（（）
# or（）
# or（））
# elif
# else
if ((player == 1 and computer == 2) or (player == 2 and computer == 3) or (player == 3 and computer == 1)):
    print("玩家胜利！")
# 平局
elif player == computer:
    print("平局")
# 其他情况电脑胜
else:
    print("玩家惜败！")
