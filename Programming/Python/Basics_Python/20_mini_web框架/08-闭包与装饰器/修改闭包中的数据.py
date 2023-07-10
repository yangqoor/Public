x = 300
def test1():
	x = 200
	def test2():
		nonlocal x
		print("----1----x=%d" % x)
		x = 100
		print("----2----x=%d" % x)

	return test2

t1 = test1()
t1()
