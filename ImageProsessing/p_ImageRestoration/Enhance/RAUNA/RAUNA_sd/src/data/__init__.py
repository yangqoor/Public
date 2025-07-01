from importlib import import_module

#from dataloader import MSDataLoader
from torch.utils.data.dataloader import default_collate
from torch.utils.data import dataloader

class Data: #useless
    def __init__(self, args):
        self.loader_train = None

        if args.finetune:
            module_finetune = import_module('data.' + args.data_finetune.lower())
            finetune_set = getattr(module_finetune, args.data_finetune)(args)
            self.loader_ft = dataloader.DataLoader(
                # args,
                finetune_set,
                batch_size=args.ft_batch,
                shuffle=False,
                pin_memory=not args.cpu
            )
            module_validation = import_module('data.' + args.data_validation.lower())
            validation_set = getattr(module_validation, args.data_validation)(args, train=False)
            self.loader_val = dataloader.DataLoader(
                # args,
                validation_set,
                batch_size=args.ft_batch,
                shuffle=False,
                pin_memory=not args.cpu
            )

        else:
            if not args.test_only:
                module_train = import_module('data.' + args.data_train.lower())
                trainset = getattr(module_train, args.data_train)(args)
                self.loader_train = dataloader.DataLoader(
                    #args,
                    trainset,
                    batch_size=args.batch_size,
                    shuffle=True,
                    pin_memory=not args.cpu
                )

            if args.data_test in ['our485']:
                #print('run args.data_test')
                module_test = import_module('data.benchmark')
                testset = getattr(module_test, 'Benchmark')(args, train=False)
                #print('testset:',testset)
            else:
                module_test = import_module('data.' + args.data_test.lower())
                testset = getattr(module_test, args.data_test)(args, train=False)

            self.loader_test = dataloader.DataLoader(
                #args,
                testset,
                batch_size=1,
                shuffle=False,
                pin_memory=not args.cpu
            )





        #
        # self.loader_valid = dataloader.DataLoader(
        #     #args,
        #     testset,
        #     batch_size=1,
        #     shuffle=False,
        #     pin_memory=not args.cpu
        # )



