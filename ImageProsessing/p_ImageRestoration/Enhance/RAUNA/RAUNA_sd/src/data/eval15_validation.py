import os
from data import srdata

class eval15_validation(srdata.SRData):
    def __init__(self, args, name='eval15_validation', train=False, benchmark=False):
        super(eval15_validation, self).__init__(
            args, name=name, train=train, benchmark=benchmark
        )
        self.finetune = False

    def _scan(self):#use this
        # print('use _scan_gamma')
        names_hr, names_lr = super(eval15_validation, self)._scan()
        #print('read eval')
        names_hr = names_hr[self.begin - 1:self.end]
        names_lr = [n[self.begin - 1:self.end] for n in names_lr]
        # names_ga = [n[self.begin - 1:self.end] for n in names_ga]

        return names_hr, names_lr

    def _set_filesystem(self, dir_data): #use this
        # print('use _set_filesystem_gamma')
        super(eval15_validation, self)._set_filesystem(dir_data)
        self.apath = '../data/LOL/eval15/' #在这里重新定义了路径
        print(self.apath)
        self.dir_hr = os.path.join(self.apath, 'high')
        self.dir_lr = os.path.join(self.apath, 'low')
        # self.dir_ga = os.path.join(self.apath, 'gamma')

