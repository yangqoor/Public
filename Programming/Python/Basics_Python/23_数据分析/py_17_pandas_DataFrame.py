# coding=utf-8
from pymongo import MongoClient
import pandas as pd


client = MongoClient()
collection = client["douban"]["tv1"]
data = collection.find()
data_list = []
for i in data:
    temp = {"info": i["info"], "rating_count": i["rating"]["count"], "rating_value": i["rating"]["value"],
            "title": i["title"], "country": i["tv_category"], "directors": i["directors"], "actors": i['actors']}
    data_list.append(temp)
# t1 = data[0]
# t1 = pd.Series(t1)
# print(t1)

df = pd.DataFrame(data_list)
# print(df)

#显示头几行
print(df.head(1))
# print("*"*100)
# print(df.tail(2))

#展示df的概览
# print(df.info())
# print(df.describe())
print(df["info"].str.split("/").tolist())


