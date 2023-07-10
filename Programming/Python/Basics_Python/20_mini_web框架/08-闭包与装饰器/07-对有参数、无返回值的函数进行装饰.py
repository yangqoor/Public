def set_func(func):
	def call_func(a):
		print("---这是权限验证1----")
		print("---这是权限验证2----")
		func(a)
	return call_func


@set_func  # 相当于 test1 = set_func(test1)
def test1(num):
	print("-----test1----%d" % num)


test1(100)
test1(200)

# xx = set_func(test1)

