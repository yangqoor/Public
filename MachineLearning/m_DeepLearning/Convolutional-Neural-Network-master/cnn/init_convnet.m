function params = init_convnet(layers)

% Initialize the parameters of all layers
h = layers{1}.height;
w = layers{1}.width;
c = layers{1}.channel;
for i = 2:length(layers)
    switch layers{i}.type
        case 'CONV'
            % Initialize the parameter of conv layers
            scale = sqrt(3/(h*w*c)); % (kxkc/group, num)
            params{i-1}.w = 2*scale*rand(layers{i}.k*layers{i}.k*c/layers{i}.group, layers{i}.num) - scale;
            params{i-1}.b = zeros(1, layers{i}.num);
            h = (h + 2*layers{i}.pad - layers{i}.k) / layers{i}.stride + 1;
            w = (w + 2*layers{i}.pad - layers{i}.k) / layers{i}.stride + 1;
            c = layers{i}.num;
        case 'POOLING'
            % NO parameters
            h = (h - layers{i}.k) / layers{i}.stride + 1;
            w = (w - layers{i}.k) / layers{i}.stride + 1;
            params{i-1}.w = [];
            params{i-1}.b = [];
        case 'IP'
            % Initialize the parameter of inner product layer 
            switch layers{i}.init_type
                % Gaussian initialization
                case 'gaussian'
                    scale = sqrt(3/(h*w*c)); % (h*w*c, num)
                    params{i-1}.w = scale*randn(h*w*c, layers{i}.num);
                    params{i-1}.b = zeros(1, layers{i}.num);
                % Uniform initialization
                case 'uniform'
                    scale = sqrt(3/(h*w*c));
                    params{i-1}.w = 2*scale*rand(h*w*c, layers{i}.num) - scale;
                    params{i-1}.b = zeros(1, layers{i}.num);
            end
            h = 1;
            w = 1;
            c = layers{i}.num;
        case 'RELU'
            % No parameters
            params{i-1}.w = [];
            params{i-1}.b = [];
        case 'LOSS'
            % Initialize the parameter of inner product layer
            scale = sqrt(3/(h*w*c)); % (h*w*c, num)
            % last layer is K-1
            params{i-1}.w = 2*scale*rand(h*w*c, layers{i}.num - 1) - scale;
            params{i-1}.w = params{i-1}.w';
            params{i-1}.b = zeros(1, layers{i}.num - 1);
            params{i-1}.b = params{i-1}.b';
            h = 1;
            w = 1;
            c = layers{i}.num;
    end
end
end