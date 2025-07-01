import os
from data import srdata

class eval15(srdata.SRData):
    def __init__(self, args, name='eval15', train=True, benchmark=False):
        super(eval15, self).__init__(
            args, name=name, train=train, benchmark=benchmark
        )

    def _scan(self):
        names_hr, names_lr = super(eval15, self)._scan()
        #print('read eval')
        names_hr = names_hr[self.begin - 1:self.end]
        names_lr = [n[self.begin - 1:self.end] for n in names_lr]

        return names_hr, names_lr

    def _set_filesystem(self, dir_data):
        super(eval15, self)._set_filesystem(dir_data)
        # self.apath = '/home/qian/Lxy/LLIE1004/data/LOL-v2/Synthetic/Test/'#在这里重新定义了路径
        self.apath = 'E:/DL_Model/test/RAUNA_2023-yxxxl_rauna/data/LOL/eval15/'
        print(self.apath)
        # self.dir_hr = os.path.join(self.apath, 'Normal')
        # self.dir_lr = os.path.join(self.apath, 'Low')
        self.dir_hr = os.path.join(self.apath, 'high')
        self.dir_lr = os.path.join(self.apath, 'low')

