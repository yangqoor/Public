# 顺序并居中对齐输出文本
poem = ["浣溪沙•一曲新词酒一杯",
        "晏殊",
        "一曲新词酒一杯，\t",
        "去年天气旧亭台。",
        "夕阳西下几时回？\n",
        "    无可奈何花落去，",
        "似曾相识燕归来。\t",
        "小园香径独徘徊。"]

for poem_str in poem:
    # print("%d" % poem.index(poem_str))
    # print("|%s|" % poem_str.center(13, "　"))
    # 先使用 strip 方法去除字符串首尾的空白字符
    # 再使用 center 方法居中显示
    print("|%s|" % poem_str.strip().center(13, "　"))
    # print("|%s|" % poem_str.ljust(10))
