import os
from data import srdata

class our485(srdata.SRData):
    #print('run our485')

    def __init__(self, args, name='LOL', train=True, benchmark=False):
        super(our485, self).__init__(
            args, name=name, train=train, benchmark=benchmark
        )

    def _scan(self):
        #print('read our')
        names_hr, names_lr = super(our485, self)._scan()
        names_hr = names_hr[self.begin - 1:self.end]
        names_lr = [n[self.begin - 1:self.end] for n in names_lr]
        #print('len hr',len(names_hr))
        #print('len lr',len(names_lr))

        return names_hr, names_lr

    def _set_filesystem(self, dir_data):  #这里已经override了文件路径  和 前面关系不大
        super(our485, self)._set_filesystem(dir_data)
        self.apath = 'E:/DL_Model/test/RAUNA_2023-yxxxl_rauna/data/LOL/our485/'
        # self.apath='/home/qian/Lxy/LLIE1004/data/LOL-v2/Synthetic/Train/'

        print(self.apath)
        self.dir_hr = os.path.join(self.apath, 'high')
        self.dir_lr = os.path.join(self.apath, 'low')
        # self.dir_hr = os.path.join(self.apath, 'Normal')
        # self.dir_lr = os.path.join(self.apath, 'Low')

