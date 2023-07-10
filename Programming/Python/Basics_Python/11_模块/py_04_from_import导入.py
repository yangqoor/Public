from py_01_测试模块1 import Dog
from py_01_测试模块1 import say_hello as module1_say_hello
from py_02_测试模块2 import say_hello

# 一次性导入所有工具
# import 模块名  ######   from 模块名 import *
# 后者导入后不需要模块名，就可直接使用工具名
from py_01_测试模块1 import *

# from...import 方法导入模块
# 导入后不需要模块名，就可直接使用工具名
say_hello()
# dog = Dog

# 同名工具包采用 as 别名方式调用
module1_say_hello()
