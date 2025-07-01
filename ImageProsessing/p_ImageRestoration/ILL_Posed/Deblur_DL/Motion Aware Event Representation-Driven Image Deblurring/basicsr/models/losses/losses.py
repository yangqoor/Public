import torch
from torch import nn as nn
from torch.nn import functional as F
import numpy as np
import cv2

from basicsr.models.losses.loss_util import weighted_loss
from transformers import CLIPModel, CLIPProcessor
from einops import rearrange
from . import pytorch_ssim


_reduction_modes = ['none', 'mean', 'sum']


@weighted_loss
def l1_loss(pred, target):
    return F.l1_loss(pred, target, reduction='none')


@weighted_loss
def mse_loss(pred, target):
    return F.mse_loss(pred, target, reduction='none')


# AT loss
def at(x):
    return F.normalize(x.pow(2).mean(1).view(x.size(0), -1))

def at_loss(x, y):
    return (at(x) - at(y)).pow(2).mean()

@weighted_loss
def charbonnier_loss(pred, target, eps=1e-12):
    return torch.sqrt((pred - target)**2 + eps)
    
# @weighted_loss
# def charbonnier_loss(pred, target, eps=1e-12):
#     return torch.sqrt((pred - target)**2 + eps)


class L1Loss(nn.Module):
    """L1 (mean absolute error, MAE) loss.

    Args:
        loss_weight (float): Loss weight for L1 loss. Default: 1.0.
        reduction (str): Specifies the reduction to apply to the output.
            Supported choices are 'none' | 'mean' | 'sum'. Default: 'mean'.
    """

    def __init__(self, loss_weight=1.0, reduction='mean'):
        super(L1Loss, self).__init__()
        if reduction not in ['none', 'mean', 'sum']:
            raise ValueError(f'Unsupported reduction mode: {reduction}. '
                             f'Supported ones are: {_reduction_modes}')

        self.loss_weight = loss_weight
        self.reduction = reduction

    def forward(self, pred, target, weight=None, **kwargs):
        """
        Args:
            pred (Tensor): of shape (N, C, H, W). Predicted tensor.
            target (Tensor): of shape (N, C, H, W). Ground truth tensor.
            weight (Tensor, optional): of shape (N, C, H, W). Element-wise
                weights. Default: None.
        """
        return self.loss_weight * l1_loss(
            pred, target, weight, reduction=self.reduction)

class MSELoss(nn.Module):
    """MSE (L2) loss.

    Args:
        loss_weight (float): Loss weight for MSE loss. Default: 1.0.
        reduction (str): Specifies the reduction to apply to the output.
            Supported choices are 'none' | 'mean' | 'sum'. Default: 'mean'.
    """

    def __init__(self, loss_weight=1.0, reduction='mean'):
        super(MSELoss, self).__init__()
        if reduction not in ['none', 'mean', 'sum']:
            raise ValueError(f'Unsupported reduction mode: {reduction}. '
                             f'Supported ones are: {_reduction_modes}')

        self.loss_weight = loss_weight
        self.reduction = reduction

    def forward(self, pred, target, weight=None, **kwargs):
        """
        Args:
            pred (Tensor): of shape (N, C, H, W). Predicted tensor.
            target (Tensor): of shape (N, C, H, W). Ground truth tensor.
            weight (Tensor, optional): of shape (N, C, H, W). Element-wise
                weights. Default: None.
        """
        return self.loss_weight * mse_loss(
            pred, target, weight, reduction=self.reduction)

class PSNRLoss(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(PSNRLoss, self).__init__()
        assert reduction == 'mean'
        self.loss_weight = loss_weight
        self.scale = 10 / np.log(10)
        self.toY = toY
        self.coef = torch.tensor([65.481, 128.553, 24.966]).reshape(1, 3, 1, 1)
        self.first = True

    def forward(self, pred, target):
        assert len(pred.size()) == 4
        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred.device)
                self.first = False

            pred = (pred * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred, target = pred / 255., target / 255.
            pass
        assert len(pred.size()) == 4

        return self.loss_weight * self.scale * torch.log(((pred - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()


class SRNLoss(nn.Module):

    def __init__(self):
        super(SRNLoss, self).__init__()  

    def forward(self, preds, target):

        gt1 = target
        B,C,H,W = gt1.shape
        gt2 = F.interpolate(gt1, size=(H // 2, W // 2), mode='bilinear', align_corners=False)
        gt3 = F.interpolate(gt1, size=(H // 4, W // 4), mode='bilinear', align_corners=False)

        l1 = mse_loss(preds[0] , gt3)
        l2 = mse_loss(preds[1] , gt2)
        l3 = mse_loss(preds[2] , gt1)

        return l1+l2+l3



class CharbonnierLoss(nn.Module):
    """Charbonnier loss (one variant of Robust L1Loss, a differentiable
    variant of L1Loss).
    Described in "Deep Laplacian Pyramid Networks for Fast and Accurate
        Super-Resolution".
    Args:
        loss_weight (float): Loss weight for L1 loss. Default: 1.0.
        reduction (str): Specifies the reduction to apply to the output.
            Supported choices are 'none' | 'mean' | 'sum'. Default: 'mean'.
        eps (float): A value used to control the curvature near zero.
            Default: 1e-12.
    """

    def __init__(self, loss_weight=1.0, reduction='mean', eps=1e-12):
        super(CharbonnierLoss, self).__init__()
        if reduction not in ['none', 'mean', 'sum']:
            raise ValueError(f'Unsupported reduction mode: {reduction}. Supported ones are: {_reduction_modes}')

        self.loss_weight = loss_weight
        self.reduction = reduction
        self.eps = eps

    def forward(self, pred, target, weight=None, **kwargs):
        """
        Args:
            pred (Tensor): of shape (N, C, H, W). Predicted tensor.
            target (Tensor): of shape (N, C, H, W). Ground truth tensor.
            weight (Tensor, optional): of shape (N, C, H, W). Element-wise
                weights. Default: None.
        """
        return self.loss_weight * charbonnier_loss(pred, target, weight, eps=self.eps, reduction=self.reduction)


class WeightedTVLoss(L1Loss):
    """Weighted TV loss.
        Args:
            loss_weight (float): Loss weight. Default: 1.0.
    """

    def __init__(self, loss_weight=1.0):
        super(WeightedTVLoss, self).__init__(loss_weight=loss_weight)

    def forward(self, pred, weight=None):
        if weight is None:
            y_weight = None
            x_weight = None
        else:
            y_weight = weight[:, :, :-1, :]
            x_weight = weight[:, :, :, :-1]

        y_diff = super(WeightedTVLoss, self).forward(pred[:, :, :-1, :], pred[:, :, 1:, :], weight=y_weight)
        x_diff = super(WeightedTVLoss, self).forward(pred[:, :, :, :-1], pred[:, :, :, 1:], weight=x_weight)

        loss = x_diff + y_diff

        return loss

class CLIP_PSNRLoss(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(CLIP_PSNRLoss, self).__init__()
        assert reduction == 'mean'
        self.loss_weight = loss_weight
        self.scale = 10 / np.log(10)
        self.toY = toY
        self.coef = torch.tensor([65.481, 128.553, 24.966]).reshape(1, 3, 1, 1)
        self.first = True
        # self.model = CLIPModel.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_model")
        self.model = CLIPModel.from_pretrained("D:/EFNet/CLIPbase_model")
        # self.processor = CLIPProcessor.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_processor")
        self.processor = CLIPProcessor.from_pretrained("D:/EFNet/CLIPbase_processor")
        for para in self.model.parameters():
            para.requires_grad = False

    def forward(self, pred, target):
        assert len(pred.size()) == 4
        B,C,H,W = pred.size()
        pred_input = pred.cpu().permute(0,2,3,1).detach().numpy()*255
        pred_input = np.clip(pred_input,0,255).astype(np.uint8)
        pred_input = torch.from_numpy(pred_input).cuda()
        inputs = self.processor(text=["a clear photo", "a blurry photo"], images=pred_input, return_tensors="pt", padding=True)
        inputs["input_ids"] = inputs["input_ids"].cuda()
        inputs["attention_mask"] = inputs["attention_mask"].cuda()
        inputs["pixel_values"] = inputs["pixel_values"].cuda()
        outputs = self.model(**inputs)
        text = outputs.text_embeds.cpu().numpy()
        img = outputs.image_embeds.cpu().numpy()
        cos = text @ img.T
        clip_loss = np.exp(np.mean(cos[1] - cos[0]))

        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred.device)
                self.first = False

            pred = (pred * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred, target = pred / 255., target / 255.
            pass
        assert len(pred.size()) == 4
        losspsnr = self.loss_weight * self.scale * torch.log(((pred - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()
        loss = losspsnr + 0.1*clip_loss

        return loss

class CLIP_PSNRLoss2(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(CLIP_PSNRLoss2, self).__init__()
        assert reduction == 'mean'
        self.loss_weight = loss_weight
        self.scale = 10 / np.log(10)
        self.toY = toY
        self.coef = torch.tensor([65.481, 128.553, 24.966]).reshape(1, 3, 1, 1)
        self.first = True
        self.model = CLIPModel.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_model")
        self.processor = CLIPProcessor.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_processor")
        for para in self.model.parameters():
            para.requires_grad = False
        self.l1 = nn.L1Loss()

    def forward(self, pred, target):
        assert len(pred.size()) == 4
        B,C,H,W = pred.size()
        pred_input = pred.cpu().permute(0,2,3,1).detach().numpy()*255
        pred_input = np.clip(pred_input,0,255).astype(np.uint8)
        pred_input = torch.from_numpy(pred_input).cuda()
        inputs = self.processor(text=["a clear photo", "a blurry photo"], images=pred_input, return_tensors="pt", padding=True)
        outputs = self.model(**inputs)
        text = outputs.text_embeds.numpy()
        img = outputs.image_embeds.numpy()
        pred_img = outputs.image_embeds
        cos = text @ img.T
        clip_semantic_loss = np.exp(np.mean(cos[1] - cos[0]))
        target_input = target.cpu().permute(0,2,3,1).detach().numpy()*255
        target_input = np.clip(target_input,0,255).astype(np.uint8)
        target_inputs = self.processor(text=["a clear photo", "a blurry photo"], images=target_input, return_tensors="pt", padding=True)
        print(target_input.device)
        target_outputs = self.model(**target_inputs)
        target_img = target_outputs.image_embeds
        clip_co_loss = self.l1(pred_img,target_img)
        

        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred.device)
                self.first = False

            pred = (pred * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred, target = pred / 255., target / 255.
            pass
        assert len(pred.size()) == 4
        losspsnr = self.loss_weight * self.scale * torch.log(((pred - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()
        loss = losspsnr + clip_semantic_loss + clip_co_loss
        
        return loss

class CLIP_SSIMLoss(nn.Module):

    def __init__(self, reduction='mean'):
        super(CLIP_SSIMLoss, self).__init__()
        assert reduction == 'mean'
        self.first = True
        self.model = CLIPModel.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_model")
        self.processor = CLIPProcessor.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_processor")
        for para in self.model.parameters():
            para.requires_grad = False
        self.ssim_loss = pytorch_ssim.SSIM(window_size = 11)

    def forward(self, pred, target):
        lossssim = 1 - self.ssim_loss(pred, target)

        assert len(pred.size()) == 4
        B,C,H,W = pred.size()
        pred_input = pred.cpu().permute(0,2,3,1).detach().numpy()*255
        pred_input = np.clip(pred_input,0,255).astype(np.uint8)
        inputs = self.processor(text=["a clear photo", "a blurry photo"], images=pred_input, return_tensors="pt", padding=True)
        outputs = self.model(**inputs)
        text = outputs.text_embeds.numpy()
        img = outputs.image_embeds.numpy()
        cos = text @ img.T
        clip_loss = np.exp(np.mean(cos[1] - cos[0]))

        loss = lossssim + 0.1*clip_loss

        return loss

class CLIP_SSIMLoss2(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(CLIP_PSNRLoss2, self).__init__()
        assert reduction == 'mean'
        self.model = CLIPModel.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_model")
        self.processor = CLIPProcessor.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_processor")
        for para in self.model.parameters():
            para.requires_grad = False
        self.l1 = nn.L1Loss()

    def forward(self, pred, target):
        assert len(pred.size()) == 4
        B,C,H,W = pred.size()
        pred_input = pred.cpu().permute(0,2,3,1).detach().numpy()*255
        pred_input = np.clip(pred_input,0,255).astype(np.uint8)
        pred_input = torch.from_numpy(pred_input).cuda()
        inputs = self.processor(text=["a clear photo", "a blurry photo"], images=pred_input, return_tensors="pt", padding=True)
        outputs = self.model(**inputs)
        text = outputs.text_embeds.numpy()
        img = outputs.image_embeds.numpy()
        pred_img = outputs.image_embeds
        cos = text @ img.T
        clip_semantic_loss = np.exp(np.mean(cos[1] - cos[0]))
        target_input = target.cpu().permute(0,2,3,1).detach().numpy()*255
        target_input = np.clip(target_input,0,255).astype(np.uint8)
        target_inputs = self.processor(text=["a clear photo", "a blurry photo"], images=target_input, return_tensors="pt", padding=True)
        print(target_input.device)
        target_outputs = self.model(**target_inputs)
        target_img = target_outputs.image_embeds
        clip_co_loss = self.l1(pred_img,target_img)
        

        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred.device)
                self.first = False

            pred = (pred * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred, target = pred / 255., target / 255.
            pass
        assert len(pred.size()) == 4
        losspsnr = self.loss_weight * self.scale * torch.log(((pred - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()
        loss = losspsnr + clip_semantic_loss + clip_co_loss
        
        return loss

class F_CLIP_PSNRLoss(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(F_CLIP_PSNRLoss, self).__init__()
        assert reduction == 'mean'
        self.loss_weight = loss_weight
        self.scale = 10 / np.log(10)
        self.toY = toY
        self.coef = torch.tensor([65.481, 128.553, 24.966]).reshape(1, 3, 1, 1)
        self.first = True
        self.model = CLIPModel.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_model")
        self.processor = CLIPProcessor.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_processor")
        for para in self.model.parameters():
            para.requires_grad = False
        self.l1 = nn.L1Loss()

    def forward(self, pred, target):
        assert len(pred.size()) == 4
        B,C,H,W = pred.size()
        pred_input = pred.cpu().permute(0,2,3,1).detach().numpy()*255
        pred_input = np.clip(pred_input,0,255)
        target_input = target.cpu().permute(0,2,3,1).detach().numpy()*255
        target_input = np.clip(target_input,0,255)
        floss = 0
        for i in range(B):
            imgray = cv2.cvtColor(pred_input[i],cv2.COLOR_RGB2GRAY)
            timgray = cv2.cvtColor(target_input[i],cv2.COLOR_RGB2GRAY)
            dst = cv2.dft(imgray, flags=cv2.DFT_COMPLEX_OUTPUT)
            tdst = cv2.dft(timgray, flags=cv2.DFT_COMPLEX_OUTPUT)
            floss += self.l1(dst,tdst)
        floss = floss/3
        pred_input_i = pred_input.astype(np.uint8)
        inputs = self.processor(text=["a clear photo", "a blurry photo"], images=pred_input_i, return_tensors="pt", padding=True)
        outputs = self.model(**inputs)
        text = outputs.text_embeds.numpy()
        img = outputs.image_embeds.numpy()
        cos = text @ img.T
        clip_loss = np.exp(np.mean(cos[1] - cos[0]))

        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred.device)
                self.first = False

            pred = (pred * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred, target = pred / 255., target / 255.
            pass
        assert len(pred.size()) == 4
        losspsnr = self.loss_weight * self.scale * torch.log(((pred - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()
        loss = losspsnr + 0.05 * clip_loss + 0.05 * floss

        return loss

class SSIMLoss(nn.Module):

    def __init__(self, reduction='mean'):
        super(SSIMLoss, self).__init__()
        assert reduction == 'mean'
        self.first = True
        # self.model = CLIPModel.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_model")
        # self.processor = CLIPProcessor.from_pretrained("/data/zhijing/GOPRO_rawevent/CLIPbase_processor")
        # for para in self.model.parameters():
        #     para.requires_grad = False
        self.ssim_loss = pytorch_ssim.SSIM(window_size = 11)

    def forward(self, pred, target):
        lossssim = 1 - self.ssim_loss(pred, target)

        # assert len(pred.size()) == 4
        # B,C,H,W = pred.size()
        # pred_input = pred.cpu().permute(0,2,3,1).detach().numpy()*255
        # pred_input = np.clip(pred_input,0,255).astype(np.uint8)
        # inputs = self.processor(text=["a clear photo", "a blurry photo"], images=pred_input, return_tensors="pt", padding=True)
        # outputs = self.model(**inputs)
        # text = outputs.text_embeds.numpy()
        # img = outputs.image_embeds.numpy()
        # cos = text @ img.T
        # clip_loss = np.exp(np.mean(cos[1] - cos[0]))

        loss = lossssim

        return loss
    
class Charbonnier_SSIMLoss(nn.Module):
    def __init__(self, loss_weight=1.0, reduction='mean', eps=1e-12):
        super(Charbonnier_SSIMLoss, self).__init__()
        if reduction not in ['none', 'mean', 'sum']:
            raise ValueError(f'Unsupported reduction mode: {reduction}. Supported ones are: {_reduction_modes}')

        self.loss_weight = loss_weight
        self.reduction = reduction
        self.eps = eps
        self.ssim_loss = pytorch_ssim.SSIM(window_size = 11)

    def forward(self, pred, target, weight=None, **kwargs):
        """
        Args:
            pred (Tensor): of shape (N, C, H, W). Predicted tensor.
            target (Tensor): of shape (N, C, H, W). Ground truth tensor.
            weight (Tensor, optional): of shape (N, C, H, W). Element-wise
                weights. Default: None.
        """
        lossssim = 1 - self.ssim_loss(pred, target)
        losschar = self.loss_weight * charbonnier_loss(pred, target, weight, eps=self.eps, reduction=self.reduction)
        loss = losschar + 0.1*lossssim
        return loss
    
class PSNR_tri_Loss(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(PSNR_tri_Loss, self).__init__()
        assert reduction == 'mean'
        self.loss_weight = loss_weight
        self.scale = 10 / np.log(10)
        self.toY = toY
        self.coef = torch.tensor([65.481, 128.553, 24.966]).reshape(1, 3, 1, 1)
        self.first = True

    def forward(self, pred, target):
        # assert len(pred.size()) == 4
        pred_img = pred[0]
        tr_ev = pred[1]
        tr_ig = pred[2]
        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred_img.device)
                self.first = False

            pred_img = (pred_img * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred_img, target = pred_img / 255., target / 255.
            pass
        assert len(pred_img.size()) == 4
        psnrloss = self.loss_weight * self.scale * torch.log(((pred_img - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()
        tr_ev = rearrange(tr_ev, 'b c h w -> b c (h w)')
        tr_ig = rearrange(tr_ig, 'b c h w -> b c (h w)')
        norm_tr_ev = F.normalize(tr_ev,dim=-1)
        norm_tr_ig = F.normalize(tr_ig,dim=-1)
        cos_sim = (norm_tr_ev @ norm_tr_ig.transpose(-2,-1)).mean()
        triloss = 1-cos_sim
    
        return psnrloss + 0.1*triloss
    
class PSNR_trils_Loss(nn.Module):

    def __init__(self, loss_weight=1.0, reduction='mean', toY=False):
        super(PSNR_trils_Loss, self).__init__()
        assert reduction == 'mean'
        self.loss_weight = loss_weight
        self.scale = 10 / np.log(10)
        self.toY = toY
        self.coef = torch.tensor([65.481, 128.553, 24.966]).reshape(1, 3, 1, 1)
        self.first = True

    def forward(self, pred, target):
        # assert len(pred.size()) == 4
        pred_img = pred[0]
        tr_ev = pred[1]
        tr_ig = pred[2]
        if self.toY:
            if self.first:
                self.coef = self.coef.to(pred_img.device)
                self.first = False

            pred_img = (pred_img * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.
            target = (target * self.coef).sum(dim=1).unsqueeze(dim=1) + 16.

            pred_img, target = pred_img / 255., target / 255.
            pass
        assert len(pred_img.size()) == 4
        psnrloss = self.loss_weight * self.scale * torch.log(((pred_img - target) ** 2).mean(dim=(1, 2, 3)) + 1e-8).mean()
        triloss = 0
        for i in range(len(tr_ev)):
            tr_ev_ = rearrange(tr_ev[i], 'b c h w -> b c (h w)')
            tr_ig_ = rearrange(tr_ig[i], 'b c h w -> b c (h w)')
            norm_tr_ev = F.normalize(tr_ev_,dim=-1)
            norm_tr_ig = F.normalize(tr_ig_,dim=-1)
            cos_sim = (norm_tr_ev @ norm_tr_ig.transpose(-2,-1)).mean()
            triloss += (1-cos_sim)
    
        return psnrloss + 0.1*triloss