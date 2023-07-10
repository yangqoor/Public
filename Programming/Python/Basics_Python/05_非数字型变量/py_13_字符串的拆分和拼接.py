# 从网络上抓取内容构成字符串
poem = "浣溪沙·一曲新词酒一杯\n作者：晏殊\t一曲新词酒一杯，\n去年天气旧亭台。 夕阳西下几时回？ \n无可奈何花落去，\t\n似曾相识燕归来。 小园香径独徘徊。"
print(poem)

# 1. 去掉空白字符(以空白字符为界拆分)
poem_list = poem.split()
print(poem_list)

# 2.使用空格分隔符“ ”，拼接为一个整齐的字符串
result = " ".join(poem_list)
print(result)
