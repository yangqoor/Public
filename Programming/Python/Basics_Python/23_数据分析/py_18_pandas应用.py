# coding=utf-8
import pandas as pd

df = pd.read_csv("./database/dogNames2.csv")
# print(df.head())
# print(df.info())

# dataFrame中排序的方法
df = df.sort_values(by="Count_AnimalName", ascending=False)
# print(df.head(5))

# pandas取行或者列的注意点
# - 方括号写数组,表示取行,对行进行操作
# - 写字符串,表示的去列索引,对列进行操作
print(df[19:20])
print(df["Row_Labels"])
print(type(df["Row_Labels"]))
