import re

# re.match(正则表达式, 要处理的字符串)

'''print(re.match(r"[hH]ello", "hello world"))
print(re.match(r"[hH]ello", "Hello world"))

print(re.match(r"[hH]ello", "Hello world").group())'''


def variable_name():
    names = ["name1", "_name", "2_name", "__name__", "name!", "n#ame"]

    for name in names:
        # res = re.match(r"[a-zA-Z_]+[a-zA-Z_0-9]*", name)
        res = re.match(r"^[a-zA-Z_]+[a-zA-Z_0-9]*$", name)

        if res:
            print("变量名 %s 符合规则" % name)
        else:
            print("变量名 %s 不符合规则" % name)


def email_path():
    Paths = ["12345@163.com", "12345@qq.com", "1234_de@126.com", "1234_de!@163.com"]

    for pat in Paths:
        # 若正则表达式中要用到 . ? 等符号，需要用 \ 转义
        # () 分组
        res = re.match(r"[a-zA-Z0-9_]{4,20}@(163|126|qq)\.com$", pat)

        if res:
            print("邮箱地址 %s 符合要求" % pat)
        else:
            print("邮箱地址 %s 不符合要求" % pat)


def html_string():
    html_str = "<body><h1>hahahaha</h1></body>"

    # res = re.match(r"<(\w*)><(\w*)>.*</\2></\1>", html_str)
    # 了解别名
    res = re.match(r"<(?P<p1>\w*)><(?P<p2>\w*)>.*</(?P=p2)></(?P=p1)>", html_str)
    if res:
        print(res.group())

    # 贪婪与非贪婪
    html_path = '''<img data-original="https://rpic.douyucdn.cn/appCovers/2016/11/13/1213973_201611131917_small.jpg" 
    src="https://rpic.douyucdn.cn/appCovers/2016/11/13/1213973_201611131917_small.jpg" style="display: inline;"> '''
    ret = re.findall(r"https://.*?\.jpg", html_path)
    print(ret)
    # ret = re.match(r'''https://.*?\.jpg''', html_path).group()
    # print(ret)


def add(temp):
    # temp sub 匹配到的正则字符串
    strNum = temp.group()
    num = int(strNum) + 1
    return str(num)


def search_findall_sub():
    string = "阅读次数 9999，点赞数 888"

    # search 不从头开始，且只匹配第一个符合要求的字符串
    res = re.search(r"\d+", string)
    # findall 不从头开始，且匹配所有
    ret = re.findall(r"\d+", string)
    # sub 替换，替换所有
    rest = re.sub(r"\d+", "111", string)
    # sub 支持函数(python独有)
    result = re.sub(r"\d+", add, string)

    if res:
        print(res.group())
    if ret:
        print(ret)   # 不用group，直接返回结果
    if rest:
        print(rest)  # 直接返回结果字符串
    if result:
        print(result)

    string2 = """<div class="job-detail">
            <p>岗位职责：</p>
    <p>1，日常产品需求的开发和产品维护（主要是将算法组产出的实验结果转化为线上服务）<br>2，流式调度框架开发<br>3，优化机器学习框架<br><br></p>
    <p>任职条件：</p>
    <p>1，三年以上后端/算法工程/系统工程相关开发经验,<br>2，工作语⾔言以python为主，部分业务⽤用到C++（熟悉以下语言中至少一种，Java/C++/Golang/Python；）<br><br>加分项（任一项均可）：<br>1，基本功：<br>数据结构和算法<br>linux系统<br>网络协议<br>C语言/C++<br>设计模式<br><br>2，专业领域：<br>opencv和图像算法<br>大规模分布式服务器架构经验</p>
            </div>"""
    re_sub = re.sub(r"(<\w*>)(</\1>)", "", string2)

    if re_sub:
        print(re_sub)



def _split():
    string = "info:lu 18 US"
    ret = re.split(r":| ", string)
    if ret:
        print(ret)   # 返回一个列表


def main():
    variable_name()
    email_path()
    html_string()
    search_findall_sub()
    _split()


if __name__ == '__main__':
    main()
