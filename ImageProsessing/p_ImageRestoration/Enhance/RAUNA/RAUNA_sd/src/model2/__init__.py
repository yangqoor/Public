import os
from importlib import import_module

import torch
import torch.nn as nn
from torch.autograd import Variable

class Model(nn.Module):
    def __init__(self, args, ckp):
        super(Model, self).__init__()
        print('Making model2...')

        self.scale = args.scale
        # self.idx_scale = 0
        self.self_ensemble = args.self_ensemble
        #通过旋转不同角度得到多个LR 图像作为输入，得到多个旋转角度不同的HR 图像，将它们集成起来作为最终结果
        self.chop = args.chop  #enable memory-efficient forward
        self.precision = args.precision
        self.cpu = args.cpu
        self.device = torch.device('cpu' if args.cpu else 'cuda')
        self.n_GPUs = args.n_GPUs
        self.save_models = args.save_models

        module = import_module('model2.' + args.model2.lower())
        self.model = module.make_model(args).to(self.device)
        if args.precision == 'half':
            self.model.half()

        if not args.cpu and args.n_GPUs > 1:
            self.model = nn.DataParallel(self.model, range(args.n_GPUs))

        self.load(
            ckp.dir,
            pre_train=args.pre_train_re,
            resume=args.resume,
            cpu=args.cpu
        )
        print(self.model, file=ckp.log_file)

    def forward(self, x1, x2, alpha,x): #x是input图片 idx_scale是 en: enhance or not

        # if self.self_ensemble and not self.training:
        #     if self.chop:
        #         forward_function = self.forward_chop
        #     else:
        #         forward_function = self.model.forward
        #
        #     return self.forward_x8(x1, forward_function)
        # elif self.chop and not self.training:
        #     return self.forward_chop(x1)
        # else:
        return self.model(x1, x2, alpha,x)

    def get_model(self):
        if self.n_GPUs == 1:
            return self.model
        else:
            return self.model.module

    def state_dict(self, **kwargs):
        target = self.get_model()
        return target.state_dict(**kwargs)

    def save(self, apath, epoch, is_best=False):
        target = self.get_model()
        print('model2_run_latest')
        torch.save(
            target.state_dict(), 
            os.path.join(apath, 'model2', 'model_latest.pt')
        )
        if is_best:
            print('model2_run is_best')
            torch.save(
                target.state_dict(),
                os.path.join(apath, 'model2', 'model_best.pt')
            )
        
        if self.save_models:
            torch.save(
                target.state_dict(),
                os.path.join(apath, 'model2', 'model_{}.pt'.format(epoch))
            )

    def load(self, apath, pre_train='.', resume=-1, cpu=False):
        if cpu:
            kwargs = {'map_location': lambda storage, loc: storage}
        else:
            kwargs = {}

        if resume == -1:
            print('-1')
            self.get_model().load_state_dict(
                torch.load(
                    os.path.join(apath, 'model2', 'model_latest.pt'),
                    **kwargs
                ),
                strict=False
            )
        elif resume == 0:
            print('rest')
            if pre_train != '.':
                print('pre_train!=.')
                print('Loading model from {}'.format(pre_train))
                self.get_model().load_state_dict(
                    torch.load(pre_train, **kwargs),
                    strict=False
                )
        else:
            print('specific')
            self.get_model().load_state_dict(
                torch.load(
                    os.path.join(apath, 'model2', 'model_{}.pt'.format(resume)),
                    **kwargs
                ),
                strict=False
            )

    def forward_chop(self, x, shave=10, min_size=160000): #超分辨过程 应该可以删除
        # scale = self.scale[self.idx_scale]
        n_GPUs = min(self.n_GPUs, 4)
        b, c, h, w = x.size()
        h_half, w_half = h // 2, w // 2
        h_size, w_size = h_half + shave, w_half + shave
        ll_list = [
            x[:, :, 0:h_size, 0:w_size],
            x[:, :, 0:h_size, (w - w_size):w],
            x[:, :, (h - h_size):h, 0:w_size],
            x[:, :, (h - h_size):h, (w - w_size):w]]

        if w_size * h_size < min_size:
            sl_list = []
            for i in range(0, 4, n_GPUs):
                ll_batch = torch.cat(ll_list[i:(i + n_GPUs)], dim=0)
                sl_batch = self.model(ll_batch)
                sl_list.extend(sl_batch.chunk(n_GPUs, dim=0))
        else:
            sl_list = [
                self.forward_chop(patch, shave=shave, min_size=min_size) \
                for patch in ll_list
            ]

        # h, w = scale * h, scale * w
        # h_half, w_half = scale * h_half, scale * w_half
        # h_size, w_size = scale * h_size, scale * w_size
        # shave *= scale

        output = x.new(b, c, h, w)
        output[:, :, 0:h_half, 0:w_half] \
            = sl_list[0][:, :, 0:h_half, 0:w_half]
        output[:, :, 0:h_half, w_half:w] \
            = sl_list[1][:, :, 0:h_half, (w_size - w + w_half):w_size]
        output[:, :, h_half:h, 0:w_half] \
            = sl_list[2][:, :, (h_size - h + h_half):h_size, 0:w_half]
        output[:, :, h_half:h, w_half:w] \
            = sl_list[3][:, :, (h_size - h + h_half):h_size, (w_size - w + w_half):w_size]

        return output

    def forward_x8(self, x, forward_function):
        def _transform(v, op):
            if self.precision != 'single': v = v.float()

            v2np = v.data.cpu().numpy()
            if op == 'v':
                tfnp = v2np[:, :, :, ::-1].copy()
            elif op == 'h':
                tfnp = v2np[:, :, ::-1, :].copy()
            elif op == 't':
                tfnp = v2np.transpose((0, 1, 3, 2)).copy()

            ret = torch.Tensor(tfnp).to(self.device)
            if self.precision == 'half': ret = ret.half()

            return ret

        lr_list = [x]
        for tf in 'v', 'h', 't':
            lr_list.extend([_transform(t, tf) for t in lr_list])

        sr_list = [forward_function(aug) for aug in lr_list]
        for i in range(len(sr_list)):
            if i > 3:
                sr_list[i] = _transform(sr_list[i], 't')
            if i % 4 > 1:
                sr_list[i] = _transform(sr_list[i], 'h')
            if (i % 4) % 2 == 1:
                sr_list[i] = _transform(sr_list[i], 'v')

        output_cat = torch.cat(sr_list, dim=0)
        output = output_cat.mean(dim=0, keepdim=True)

        return output

