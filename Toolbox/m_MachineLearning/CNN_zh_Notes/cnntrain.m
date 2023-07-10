function net = cnntrain(net, x, y, opts)  
    m = size(x, 3);   %% ͼƬһ�������� 60000  
    %numbatches = m / 50 = 1200��
    % һ��m��������ÿ�����ѡ����batchsize������ѵ��
    numbatches = m / opts.batchsize;    % ѭ���Ĵ��� ��1200�Σ�ÿ��ʹ��50����������  
    if rem(numbatches, 1) ~= 0  
        error('numbatches not integer');  
    end  
    
    %�������ֵ  
    net.rL = [];  
    % �����õĵ����������е���
    for i = 1 : opts.numepochs      
        %��ʾ�ڼ��ε���/�ܵ�������
        disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);  
        %��ʱ
        tic;  
        % ����1:m��һ���������
        kk = randperm(m);  % �������m���ڵĲ��ظ���m����  
        
        net.ffcnt = 0;
        for l = 1 : numbatches    % ѭ��1200�Σ�ÿ��ѡȡ50���������и���  
            
            net.ffcnt = net.ffcnt + 1;     %ǰ�򴫲�����
            
            disp(['doing' num2str(l) 'iterator']); 
            % ȡ1:50��51:100,101:150.����������ȡ��ȥ
            batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));    %50��������ѵ������  
            batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));    %50����������Ӧ�ı�ǩ  
          
            % �ڵ�ǰ������Ȩֵ�����������¼����������� 
            net = cnnff(net, batch_x);        %����ǰ�򴫲�  
            % �õ���������������ͨ����Ӧ��������ǩ��bp�㷨���õ���������Ȩֵ��Ҳ������Щ����˵�Ԫ�أ��ĵ���
            net = cnnbp(net, batch_y);        %bp�㷨���²���  
            
            opts.i = i;  
            opts.l = l;  
            net = cnnapplygrads(net, opts);   % �����ݶȵ������²���  
            %rL����С��������ƽ������
            if isempty(net.rL)%Ϊ��
                net.rL(1) = net.L; %loss function��ֵ
            end
            net.rL(end + 1) = 0.99 * net.rL(end) + 0.01 * net.L; 
            %�൱�ڶ�ÿһ��batch���������ۻ�����Ȩƽ����  
        end  
        toc;  
    end  

end  
