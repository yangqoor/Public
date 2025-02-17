function Y = vl_nnloss(X,c,dzdy,varargin)
%VL_NNLOSS CNN categorical or attribute loss.
%   Y = VL_NNLOSS(X, C) computes the loss incurred by the prediction
%   scores X given the categorical labels C.
%
%   The prediction scores X are organised as a field of prediction
%   vectors, represented by a H x W x D x N array. The first two
%   dimensions, H and W, are spatial and correspond to the height and
%   width of the field; the third dimension D is the number of
%   categories or classes; finally, the dimension N is the number of
%   data items (images) packed in the array.
%
%   While often one has H = W = 1, the case W, H > 1 is useful in
%   dense labelling problems such as image segmentation. In the latter
%   case, the loss is summed across pixels (contributions can be
%   weighed using the `InstanceWeights` option described below).
%
%   The array C contains the categorical labels. In the simplest case,
%   C is an array of integers in the range [1, D] with N elements
%   specifying one label for each of the N images. If H, W > 1, the
%   same label is implicitly applied to all spatial locations.
%
%   In the second form, C has dimension H x W x 1 x N and specifies a
%   categorical label for each spatial location.
%
%   In the third form, C has dimension H x W x D x N and specifies
%   attributes rather than categories. Here elements in C are either
%   +1 or -1 and C, where +1 denotes that an attribute is present and
%   -1 that it is not. The key difference is that multiple attributes
%   can be active at the same time, while categories are mutually
%   exclusive. By default, the loss is *summed* across attributes
%   (unless otherwise specified using the `InstanceWeights` option
%   described below).
%
%   DZDX = VL_NNLOSS(X, C, DZDY) computes the derivative of the block
%   projected onto the output derivative DZDY. DZDX and DZDY have the
%   same dimensions as X and Y respectively.
%
%   VL_NNLOSS() supports several loss functions, which can be selected
%   by using the option `type` described below. When each scalar c in
%   C is interpreted as a categorical label (first two forms above),
%   the following losses can be used:
%
%   Classification error:: `classerror`
%     L(X,c) = (argmax_q X(q) ~= c). Note that the classification
%     error derivative is flat; therefore this loss is useful for
%     assessment, but not for training a model.
%
%   Top-K classification error:: `topkerror`
%     L(X,c) = (rank X(c) in X <= K). The top rank is the one with
%     highest score. For K=1, this is the same as the
%     classification error. K is controlled by the `topK` option.
%
%   Log loss:: `log`
%     L(X,c) = - log(X(c)). This function assumes that X(c) is the
%     predicted probability of class c (hence the vector X must be non
%     negative and sum to one).
%
%   Softmax log loss (multinomial logistic loss):: `softmaxlog`
%     L(X,c) = - log(P(c)) where P(c) = exp(X(c)) / sum_q exp(X(q)).
%     This is the same as the `log` loss, but renormalizes the
%     predictions using the softmax function.
%
%   Multiclass hinge loss:: `mhinge`
%     L(X,c) = max{0, 1 - X(c)}. This function assumes that X(c) is
%     the score margin for class c against the other classes.  See
%     also the `mmhinge` loss below.
%
%   Multiclass structured hinge loss:: `mshinge`
%     L(X,c) = max{0, 1 - M(c)} where M(c) = X(c) - max_{q ~= c}
%     X(q). This is the same as the `mhinge` loss, but computes the
%     margin between the prediction scores first. This is also known
%     the Crammer-Singer loss, an example of a structured prediction
%     loss.
%
%   When C is a vector of binary attribures c in (+1,-1), each scalar
%   prediction score x is interpreted as voting for the presence or
%   absence of a particular attribute. The following losses can be
%   used:
%
%   Binary classification error:: `binaryerror`
%     L(x,c) = (sign(x - t) ~= c). t is a threshold that can be
%     specified using the `threshold` option and defaults to zero. If
%     x is a probability, it should be set to 0.5.
%
%   Binary log loss:: `binarylog`
%     L(x,c) = - log(c(x-0.5) + 0.5). x is assumed to be the
%     probability that the attribute is active (c=+1). Hence x must be
%     a number in the range [0,1]. This is the binary version of the
%     `log` loss.
%
%   Logistic log loss:: `logisticlog`
%     L(x,c) = log(1 + exp(- cx)). This is the same as the `binarylog`
%     loss, but implicitly normalizes the score x into a probability
%     using the logistic (sigmoid) function: p = sigmoid(x) = 1 / (1 +
%     exp(-x)). This is also equivalent to `softmaxlog` loss where
%     class c=+1 is assigned score x and class c=-1 is assigned score
%     0.
%
%   Hinge loss:: `hinge`
%     L(x,c) = max{0, 1 - cx}. This is the standard hinge loss for
%     binary classification. This is equivalent to the `mshinge` loss
%     if class c=+1 is assigned score x and class c=-1 is assigned
%     score 0.
%
%   VL_NNLOSS(...,'OPT', VALUE, ...) supports these additionals
%   options:
%
%   InstanceWeights:: []
%     Allows to weight the loss as L'(x,c) = WGT L(x,c), where WGT is
%     a per-instance weight extracted from the array
%     `InstanceWeights`. For categorical losses, this is either a H x
%     W x 1 or a H x W x 1 x N array. For attribute losses, this is
%     either a H x W x D or a H x W x D x N array.
%
%   TopK:: 5
%     Top-K value for the top-K error. Note that K should not
%     exceed the number of labels.
%
%   See also: VL_NNSOFTMAX().

% Copyright (C) 2014-15 Andrea Vedaldi.
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.instanceWeights = [] ;
opts.classWeights = [] ;
opts.threshold = 0 ;
opts.loss = 'softmaxlog' ;
opts.topK = 5 ;
opts = vl_argparse(opts,varargin) ;

inputSize = [size(X,1) size(X,2) size(X,3) size(X,4)] ;

% Form 1: C has one label per image. In this case, get C in form 2 or
% form 3.
c = gather(c) ;
if numel(c) == inputSize(4)
  c = reshape(c, [1 1 1 inputSize(4)]) ;
  c = repmat(c, inputSize(1:2)) ;
end

if isa(X,'gpuArray')
  dataType = classUnderlying(X) ;
else
  dataType = class(X) ;
end
switch dataType
  case 'double', toClass = @(x) double(x) ;
  case 'single', toClass = @(x) single(x) ;
end

% --------------------------------------------------------------------
% Spatial weighting
% --------------------------------------------------------------------

labelSize = [size(c,1) size(c,2) size(c,3) size(c,4)] ;
assert(isequal(labelSize(1:2), inputSize(1:2))) ;
assert(labelSize(4) == inputSize(4)) ;
switch lower(opts.loss)
  case {'classerror', 'topkerror', 'log', 'softmaxlog', 'mhinge', 'mshinge'}
    binary = false ;

    % there must be one categorical label per prediction vector
    assert(labelSize(3) == 1) ;

    % null labels denote instances that should be skipped
    instanceWeights = toClass(c(:,:,1,:) ~= 0) ;

  case {'binaryerror', 'binarylog', 'logistic', 'hinge'}
    binary = true ;

    % there must be one categorical label per prediction scalar
    assert(labelSize(3) == inputSize(3)) ;

    % null labels denote instances that should be skipped
    instanceWeights = toClass(c ~= 0) ;

  otherwise
    error('Unknown loss ''%s''.', opts.loss) ;
end

if ~isempty(opts.instanceWeights)
  instanceWeights = bsxfun(@times, instanceWeights, opts.instanceWeights) ;
end

% --------------------------------------------------------------------
% Do the work
% --------------------------------------------------------------------

switch lower(opts.loss)
  case {'log', 'softmaxlog', 'mhinge', 'mshinge'}
    % from category labels to indexes
    numPixelsPerImage = prod(inputSize(1:2)) ;
    numPixels = numPixelsPerImage * inputSize(4) ;
    imageVolume = numPixelsPerImage * inputSize(3) ;

    n = reshape(0:numPixels-1,labelSize) ;
    offset = 1 + mod(n, numPixelsPerImage) + ...
             imageVolume * fix(n / numPixelsPerImage) ;
    ci = offset + numPixelsPerImage * max(c - 1,0) ;
end

if nargin <= 2 || isempty(dzdy)
  switch lower(opts.loss)
    case 'classerror'
      [~,chat] = max(X,[],3) ;
      t = toClass(c ~= chat) ;
    case 'topkerror'
      [~,predictions] = sort(X,3,'descend') ;
      t = 1 - sum(bsxfun(@eq, c, predictions(:,:,1:opts.topK,:)), 3) ;
    case 'log'
      t = - log(X(ci)) ;
    case 'softmaxlog'
      Xmax = max(X,[],3) ;
      ex = exp(bsxfun(@minus, X, Xmax)) ;
      t = Xmax + log(sum(ex,3)) - X(ci) ;
    case 'mhinge'
      t = max(0, 1 - X(ci)) ;
    case 'mshinge'
      Q = X ;
      Q(ci) = -inf ;
      t = max(0, 1 - X(ci) + max(Q,[],3)) ;
    case 'binaryerror'
      t = toClass(sign(X - opts.threshold) ~= c) ;
    case 'binarylog'
      t = -log(c.*(X-0.5) + 0.5) ;
    case 'logistic'
      %t = log(1 + exp(-c.*X)) ;
      a = -c.*X ;
      b = max(0, a) ;
      t = b + log(exp(-b) + exp(a-b)) ;
    case 'hinge'
      t = max(0, 1 - c.*X) ;
  end
  Y = instanceWeights(:)' * t(:) ;
else
  dzdy = dzdy * instanceWeights ;
  switch lower(opts.loss)
    case {'classerror', 'topkerror'}
      Y = zerosLike(X) ;
    case 'log'
      Y = zerosLike(X) ;
      Y(ci) = - dzdy ./ max(X(ci), 1e-8) ;
    case 'softmaxlog'
      Xmax = max(X,[],3) ;
      ex = exp(bsxfun(@minus, X, Xmax)) ;
      Y = bsxfun(@rdivide, ex, sum(ex,3)) ;
      Y(ci) = Y(ci) - 1 ;
      Y = bsxfun(@times, dzdy, Y) ;
    case 'mhinge'
      Y = zerosLike(X) ;
      Y(ci) = - dzdy .* (X(ci) < 1) ;
    case 'mshinge'
      Q = X ;
      Q(ci) = -inf ;
      [~, q] = max(Q,[],3) ;
      qi = offset + numPixelsPerImage * (q - 1) ;
      W = dzdy .* (X(ci) - X(qi) < 1) ;
      Y = zerosLike(X) ;
      Y(ci) = - W ;
      Y(qi) = + W ;
    case 'binaryerror'
      Y = zerosLike(X) ;
    case 'binarylog'
      Y = - dzdy ./ (X + (c-1)*0.5) ;
    case 'logistic'
      % t = exp(-Y.*X) / (1 + exp(-Y.*X)) .* (-Y)
      % t = 1 / (1 + exp(Y.*X)) .* (-Y)
      Y = - dzdy .* c ./ (1 + exp(c.*X)) ;
    case 'hinge'
      Y = - dzdy .* c .* (c.*X < 1) ;
  end
end

% --------------------------------------------------------------------
function y = zerosLike(x)
% --------------------------------------------------------------------
if isa(x,'gpuArray')
  y = gpuArray.zeros(size(x),classUnderlying(x)) ;
else
  y = zeros(size(x),'like',x) ;
end
