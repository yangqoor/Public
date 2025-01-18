import torch.optim as optim


class CustomLR:
    def __init__(self, optimizer, lr_scheduler=None, warmup_step=None, warmup_method=None):
        """

        """
        self._cur_step = 1
        self._epoch = 1
        self._warmup_step = warmup_step
        self.optimizer = optimizer
        self.lr_scheduler = lr_scheduler
        self.warmup_method = warmup_method

    def step(self):
        self.lr_scheduler.step()

    def batch_step(self):
        lr_rate = self.warmup_step(self._warmup_step, self._cur_step)
        self._cur_step += 1
        if lr_rate < 1:
            for param_group in self.optimizer.param_groups:
                param_group['lr'] = param_group['lr'] * lr_rate


def linear_warmup(warmup_step, cur_step):
    if cur_step < warmup_step:
        return float(cur_step / max(1, warmup_step))
    return 1


def constant_warmup(warmup_step, cur_step, constant=0.5):
    if cur_step < warmup_step:
        return constant * cur_step
    return 1


