classdef LinearClassifier < handle
  %A linear classifier that is defined by a 2-dimensional weight vector and
  %a threshold value. The decision boundary is perpendicular to the weight
  %vector, offset from the origin by an amount proportional to -theta/|w|^2.
  %由二维权向量和阈值定义的线性分类器。 决策边界垂直于权重矢量，从原点偏移与-theta / | w | ^ 2成正比的量。
  properties
    %The weight vector and threshold value
    weights;
    theta;
    %The decision boundary in terms of gradient/intercept (i.e. y=mx+c)
    boundary_grad;
    boundary_inte;
    %Callback function for invoke on weight change
    callback;
    %Indices of support vectors
    sv_indices;
    %Whether the classifier has been trained (i.e. an SVM), or has been
    %manually positioned
    trained = false;
  end
  
  methods
    
    function a = LinearClassifier(weights, callback)
      a.weights = weights';
      %Initial threshold is arbitrarily defined by the squared L2 norm of
      %the weight vector (meaning that the boundary is offset from the
      %origin by 1.
      a.theta = -sum(a.weights .^ 2);
      %Compute the boundary gradient
      a.calc_boundary_grad();
      a.callback = callback;
    end
    
    function set_weights(a, weights, theta, sv_indices)
      %If the classifier has been trained, the the SVs are passed in as a
      %parameter
      if (nargin == 4)
        a.sv_indices = sv_indices;
        a.trained = true;
      else
        a.sv_indices = [];
        a.trained = false;
      end
      %Ensure that the threshold and at least one of the weights are
      %non-zero.
      if (sum(abs(weights)) == 0)
        weights = [0.01 0.01];
      end
      if (theta == 0)
        theta = 0.00000001;
      else
        %Don't put an upper threshold on theta for now.
        %theta = min(max(theta, -10), 10);
      end
      %Update parameters
      a.theta = theta;      
      a.weights = weights';
      %Recomputer the boundary gradient and invoke callback
      a.calc_boundary_grad();
      a.callback();
    end
    
    function calc_boundary_grad(a)
      %Scale the weights by -theta / |w|^2, thereby giving a vector
      %with a magnitude that defines a point on the decision boundary.
      scaled_weights = -(a.theta .* a.weights) ./ (norm(a.weights)^2);
      %Get a gradient (prevent it from being infinity) m = y/x
      a.boundary_grad = svm_demo.threshold(-scaled_weights(1) ./ scaled_weights(2));
      %Compute intercept c = y - mx
      a.boundary_inte = scaled_weights(2) - (scaled_weights(1) .* a.boundary_grad);
    end
    
    function [outputs sv] = classify(a, inputs)
      %Classify some data
      %Compute its offset from the decision boundary
      offset = (inputs * a.weights) + a.theta;
      %Find the support vectors
      if (a.trained)
        sv = a.sv_indices;
      else
        lt_indices = offset < 0;
        %Because we require the indices of SVs, we can't take the minimum
        %of the offset vector indexed by the required sign. Therefore,
        %we'll just do a cheeky hack to ensure that offsets with the wrong
        %sign won't become support vectors.
        [v1 sv1] = min(offset + lt_indices .* 100000);
        [v2 sv2] = max(offset + ~lt_indices .* -100000);
        %In case there are no data points on one side of the line, ensure
        %we don't pick the most distant point on the other side of the line
        if (v1 > 50)
          sv = sv2;
        elseif (v2 < -50)
          sv = sv1;
        else
          sv = [sv1; sv2];
        end
      end
      %Take a lazy sign of the offset to classify. This ensures that points
      %very close to the boundary are labelled 0. This makes it super-easy
      %to compute classification patches.
      outputs = -svm_demo.lsign(offset);
      
    end
    
    function train(a, inputs, outputs, mode)
      
      if (size(inputs, 1) > 0)
        if (mode)
					%Automatically choose the best SVM training mode.
					svm_location = which('svmtrain');
					if strfind(svm_location, 'libsvm')
						if (mode == 's')
							mode = 'l';
						elseif (mode == 'b')
							error('Bioinformatics mode is selected, but LibSVM is further up the path. Please select LibSVM or change your path.');
						end
					elseif ~isempty(svm_location)
						if (mode == 's')
							mode = 'b';
						elseif (mode == 'l')
							error('LibSVM is selected, but the bioinformatics toolbox is further up the path. Please select BioInformatics or change your path.');
						end
					elseif exist('quadprog', 'file')
						mode = 'o';
					else
						error('Unable to find svmtrain or quadprog; make sure you have libsvm, bioinformatics toolbox, or optimization toolbox');
					end
          switch (mode)
            case 'b'
              %Bioinformatics SVM solution
              %svmtrain is a bioinformatics toolbox function that magically
              %traing an svm. Uses least-squares by default, but can be made
              %to use SMO or QP if that floats your boat. It doesn't return
              %weights, but these can be derived. Using a linear kernal,
              %the prediction is made by (inputs' * SV * Alpha) + Bias.
              %Hence the weights are simply Alpha * SV'.
              %SVM also has a parameter for soft-margins. Setting this to
              %infinity causes the same behaviour as the other solutions.
              struct = svmtrain(inputs, outputs, 'AutoScale', false, 'BoxConstraint', 50, 'Method', 'SMO');
              w = (struct.Alpha' * struct.SupportVectors);
              a.set_weights(w, struct.Bias, struct.SupportVectorIndices);
            case 'l'
              %LibSVM solution
              %Same as the bioinformatics solution, slightly different
              %syntax. Set the largest long possible in C as the
              %soft-margin parameter, since we want a hard margin.
              %The SV indices aren't obviously available, but the SV values
              %(i.e. inputs) are. It's another obfuscated arrayfun to
              %extract the indices from the input matrix.
              model = svmtrain(outputs, inputs, '-t 0 -c 50');
              w = (model.sv_coef' * full(model.SVs));
              sv_count = size(model.SVs, 1);
              d_count = size(inputs, 1);
              a.set_weights(w, -model.rho, ...
                mod(find(cell2mat(arrayfun(@(i, j)sum(inputs(i, :) == full(model.SVs(j, :))), ...
                repmat((1:d_count)', sv_count, 1), reshape(repmat(1:sv_count, d_count, 1), sv_count.*d_count, 1), ...
                'UniformOutput', false))) - 1, d_count) + 1);
            case 'o'
              %Quadratic programming SVM solution.
              %quadprog solves: min 0.5x'Hx + f'x s.t. Ax <= b
              %An SVM requires us to minimise 0.5||w||^2 (i.e. the L2
              %magnitude of the weight vector) subject to perfect
              %classification: y(x'w) >= 1
              %So the first parameter, H, needs to allow us to square the
              %x/y components of the weight vector (which looks like
              %[wx wy bias]). Hence we use an identity matrix with the
              %third column nullified, giving us [wx wy].^2.
              %f is zero, since the optimization has no linear component.
              %The constraint is a greater than/equal, so we negate both
              %sides giving -y(x'w) <= -1. We augment the input data to
              %include a column corresponding to the bias, containing only
              %ones (so [x1 x2] becomes [x1 x2 1]. Since the combination
              %rule is (x1w1 + x2w2 + bias), multiplying x1, x2 and 1 by
              %the label will make the combination positive or negative
              %depending on whether it was correct or wrong. Finally, this
              %gives something that can be optimized in the form Ax <= b.
              [w fval ex op l] = quadprog([1 0 0; 0 1 0; 0 0 0], zeros(3, 1), ...
                -([inputs ones(size(inputs, 1), 1)] .* repmat(outputs, 1, 3)), ...
                -ones(size(inputs, 1), 1), [], [], [], [], [], ...
                optimset('LargeScale', 'off', 'MaxIter', 10000, 'Display', 'off'));
              %The interesting output values are w and l. w is the
              %optimized vector of weights - [w1 w2 bias] - and l contains
              %the lapacian multipliers required to solve the qp problem.
              %Non-zero lapacian multipliers indicate support vectors, so
              %we extract their indices with find.
              a.set_weights(-w(1:2)', -w(3), find(l.ineqlin)); %#ok<FNDSB>
            case 'p'
              %Perceptron solution
              %The perceptron training algorithm iteratively adjusts the
              %decision boundary, reacting to misclassified examples. The
              %weights and bias are moved to approach correct
              %classification of any misclassified data by a small amount
              %(the learning rate, in this case 0.05), and this is computed
              %iteratively over the training set, and typically for some
              %number of epochs (in this case, once for every call to the
              %'train' method). There aren't 'Support Vectors' in a
              %perceptron, but circle the errors, since these detmine the
              %path taken by the perceptron (correct predictions have no
              %impact on the decision boundary).
              w = a.weights';
              bias = a.theta;
              for i=1:numel(outputs)
                if (a.classify(inputs(i, :)) ~= outputs(i))
                  w = w - 0.01 .* (outputs(i) .* inputs(i, :));
                  bias = bias - 0.01 .* outputs(i);
                end
              end
              a.set_weights(w, bias);
              %a.set_weights(a.weights', a.theta, find(a.classify(inputs) ~= outputs)); %#ok<FNDSB>
          end
        else
          a.set_weights(a.weights', a.theta, a.sv_indices); 
        end
      end
    end
  end
  
end

