from setuptools import setup, find_packages
# https://docs.python.org/2/distutils/apiref.html

setup(
    name="test",                            # 包名
    version="1.0",                          # 版本
    keywords=("test", "xxx"),               # 程序的关键字列表
    description="eds sdk",                  # 描述信息
    long_description="eds sdk for python",  # 完整的描述信息
    license="MIT Licence",

    url="http://test.com",                  # 主页
    author="test",                          # 程序的作者
    author_email="test@gmail.com",          # 程序的作者的邮箱地址

    packages=find_packages(),               # 需要处理的包目录（包含__init__.py的文件夹）
    include_package_data=True,
    platforms="any",                        # 程序适用的软件平台列表
    install_requires=[],                    # 需要安装的依赖包

    scripts=[],                             # 安装时需要执行的脚本列表
    entry_points={
        'console_scripts': [
            'test = test.help:main'
        ]
    }
)
