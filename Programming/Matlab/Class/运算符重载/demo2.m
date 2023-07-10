fprintf('\n创建：a(x)=')
a=polynom([3,4,1,0]);
disp(a)

fprintf('\n创建：b(x)=')
b=polynom([3,2]);
disp(b)

fprintf('\n加法：a(x)+b(x)=')
disp(a+b)

fprintf('\n加法：a(x)+5x+6=')
disp(a+[5,6])

fprintf('\n减法：a(x)-b(x)=')
disp(a-b)

fprintf('\n相反数：-a(x)=')
disp(-a)

fprintf('\n乘法：a(x)*b(x)=')
disp(a*b)

fprintf('\n除法：a(x)/b(x)')
[c,d]=a/b;
fprintf('\n商=')
disp(c)
fprintf('余数=')
disp(d)

fprintf('\n积分：int(a(x))=')
disp(int(a))

fprintf('\n求导：diff(a(x))=')
disp(diff(a))

fprintf('\n数值计算：a(5)=')
disp(val(a,5))

fprintf('数值积分：int(a(x),0,1)=')
disp(int(a,0,1))

fprintf('比较：a(x)==b(x)=')
disp(a==b)

fprintf('比较：a(x)~=b(x)=')
disp(a~=b)

