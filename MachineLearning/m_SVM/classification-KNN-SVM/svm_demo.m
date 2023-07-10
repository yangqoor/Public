classdef svm_demo < handle
  %Demonstrates the bevhaiour of an SVM.
  %To run, type: svm_demo;
  %The window displays some options and a plot of a 2-D input space
  %[-5,5]^2 with a blue weight vector and red decision boundary
  %representing the current state of a linear classifier. The weight vector
  %can be moved either by dragging the point of the arrow, or by entering
  %the vector in the text boxes on the left. Similarly, the threshold can
  %be adjusted by dragging the red line or entering in the text box.
  %Data can be added to the plot either by clicking "Random data" or
  %"Separable data", or via the Data->Load menu (Data should be in a .mat
  %file containing an Nx2 matrix 'inputs' and an Nx1 vector 'outputs').
  %Data appears on the plot as '+' signs, either red or blue depending on
  %class. Data points can be dragged around.
  %The shadow around the decision boundary represent the minimum margin on
  %the training data (the SVM algorithm finds the largest possible minumum
  %margin). Circles and green lines indicate the support vectors of the
  %classifier (when the boundary is being manipulated manually, these
  %simply denote the closest data points on either side of the boundary).
  %When training using the SVM algorithm, support vectors are equidistant
  %from the boundary.
  %To run the training algorithm on the linear classifier, press the 'Train'
  %button, or check the 'continuous training' box. While this is selected,
  %the classifier will be retrained whenever the training data changes
  %(either by loading new data, or by dragging a data point). Changing the
  %weights or threshold will disable training.
  %On the menu bar, there are graphical options; the default setting uses
  %un-smoothed lines and manual alpha-blending. Changing this option may
  %speed up the program, but on some computers causes the plot to become
  %unresponsive. The radio buttons allow a choice between training an SVM,
  %and training using the perceptron algorithm. Training an SVM requires
  %one of several toolboxes, as described below.
  %As the decision boundary moves, the error rate on the data is
  %re-evaluated. This is displayed at the left. If the data is linearly
  %separable, the SVM algorithm will always achieve 0 training error. The
  %perpendicular distance of the decision boundary from the origin is
  %-theta/|w|, where theta is the threshold and w is the weight vector.
  %The SVM algorithm does not work when the data points are not linearly
  %separable. In this case, the minimum training error is not even found,
  %as the constraints on the optimization y(x'w - t) >= 1 cannot be met.
  %The perceptron algorithm is an iterative process that won't necessarily
  %find a minima for non-separable data. During continuous training, a
  %single epoch is completed every second. Pressing the 'Train' button runs
  %for a single epoch.
  
  properties
    
    %The character code for the SVM algorithm. The bioinformatics toolbox
    %and LibSVM both have an identically named method 'svmtrain.m',
    %although they function differently. Using 's' will try 'which
    %svmtrain' in order to establish which version of svmtrain is
    %available. 'b' and 'l' assume that the default svmtrain function is
    %the right version; so if the bioinformatics toolbox AND libSVM are
    %both available, it is safest to use 's'. If neither are available, but
    %the optimization toolbox is, then 'o' will use the quadprog function to
    %compute the SVM. 's' now also detects optimization toolbox if there is
    %no svmtrain function.
    %Bioinformatics toolbox: 'b'              uses svmtrain
    %LibSVM toolbox: 'l'                      uses svmtrain
    %Optimization toolbox: 'o'                uses quadprog
    %Auto-select: 's'                         uses either
    svm_type = 's'
    
    %The figure
    fig;
    %Flag which remains true until the figure should be closed
    running = true;
    
    %The graph
    plot_area;
    %Whether the graph is being drawn
    draw_flag = true;
    cont_flag = false;
    
    %A linear classifier
    lin;
    %The weight plot handle (blue line between origin and boundary)
    weight_handle;
    w_arrow = [0.9482 0.8060; 0.8068 0.9482];
    %Text inputs for the weights
    w_input;
    t_input;
    %Parameters for the arrowhead on the weight vector
    w_arrow_angle = pi / 3;
    w_arrow_size = 0.2;
    
    %Data - inputs
    inputs;
    %Data - outputs
    outputs;
    %The colors of the data points
    colors;
    %The currently dragged data item
    data_drag;
    %Coordinates of misclassified data
    errors;
    %Error text
    error_disp;
    %Margin text
    margin_disp;
    %Support data points
    support;
    %Data plot handle
    data_handle;
    %Error plot (circles) handle
    errors_handle;
    %A vector of zeros
    z_vector;
    
    %Support vector handles
    sv_handles;
    %Circles around the SVs
    svcircle_handle;
    %Lines between the decision boundary and the SVs
    sv_data;
    
    %Coordinates for plotting classification patches
    pos_x;
    pos_y;
    pos_z
    neg_x;
    neg_y;
    neg_z;
    %Coordinates for plotting the margin tube
    tubepos_x;
    tubepos_y;
    tubepos_z;
    tubeneg_x;
    tubeneg_y;
    tubeneg_z;
    %Classification patch handles
    pos_handle;
    neg_handle;
    tubepos_handle;
    tubeneg_handle;
    
    %Current training methods. There is a cunning way of detemining how the
    %SVM should be trained. The parameter can either be [], 'b', 's' or 'o' for
    %no training, bioinformatics or optimization. do_train indicates
    %whether there should be training. train_method indicates the current
    %training method from the menu. train_method(do_train) returns the
    %required training string.
    train_method = [];
    do_train = false;
    train_group;
    %Radio buttons for selecting training method
    svm_radio;
    perc_radio;
    train_but;
    
    %The boundary end-points
    boundary = [-3 5; 5 -3]
    %Boundary line handle
    boundary_handle;
    
    %Whether the weights are being dragged
    grab_drag = false;
    %Whether the boundary is being dragged
    theta_drag = false;
    %The point where the boundary was clicked on to drag it
    theta_drag_point;
    %The original intercept of the boundary prior
    %to dragging
    theta_drag_inte;
    
    %Text boxes for weights and threshold
    w_text;
    t_text;
    train_box;
    %Buttons
    rand_weights;
    rand_but;
    sep_but;
    method_menus;
    graphics_menus;
    
  end
  
  methods
    
    function a = svm_demo()
      
      %Create the linear classifier with default weights and a callback
      %function
      a.lin = LinearClassifier([1 1], @()a.lin_change());
      a.train_method = a.svm_type;
      %The main figure window. Call the layout function on resize
      screen_size = get(0, 'ScreenSize');   
      a.fig = figure('Name', 'SVM Demo', 'Position', [(screen_size(3) - 600) / 2 (screen_size(4) - 450) / 2 600 450], 'MenuBar', 'none',...
        'ResizeFcn', @(varargin)a.do_layout);
      
      %Create the plot area to draw everything on. Add a click function for
      %finding data points.
      a.plot_area = axes('Units','Pixels','ButtonDownFcn',@(varargin)a.check_data_down());
      %Store the bg colour of the figure.
      bgc = get(a.fig,'Color');
      
      %Create a load of text components
      a.w_text = uicontrol('Style','text','String','Weight vector:','BackgroundColor',...
        bgc,'HorizontalAlignment','left', 'FontSize', 14, 'FontWeight', 'bold');
      a.w_input(1) = uicontrol('Style','edit','String',a.lin.weights(1),...
        'Callback',@(varargin)a.winput_change(), 'FontSize', 14, 'FontWeight', 'bold');
      a.w_input(2) = uicontrol('Style','edit','String',a.lin.weights(2),...
        'Callback',@(varargin)a.winput_change(), 'FontSize', 14, 'FontWeight', 'bold');  
      a.t_text = uicontrol('Style','text','String','Theta:','BackgroundColor', bgc,...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight', 'bold');
      a.t_input = uicontrol('Style','edit','String',a.lin.theta,...
        'Callback',@(varargin)a.t_input_change(), 'FontSize', 14, 'FontWeight', 'bold');
      a.error_disp = uicontrol('Style','text','String','Error rate: 0','BackgroundColor',...
        bgc, 'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight', 'bold');
      a.margin_disp = uicontrol('Style','text','String','Margin: 0','BackgroundColor',...
        bgc, 'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight', 'bold');      
      a.train_group = uibuttongroup('Parent', gcf, ...
        'SelectionChangeFcn', @(varargin)a.method_select(varargin{2}));
      a.svm_radio = uicontrol('Style', 'RadioButton', 'String', 'SVM', 'Position', [5 30 150 20],...
        'Parent', a.train_group, 'UserData', a.svm_type);
      a.perc_radio = uicontrol('Style', 'RadioButton', 'String', 'Perceptron', 'Position', ...
        [5 5 150 20], 'Parent', a.train_group, 'UserData', 'p');
      set(a.train_group, 'SelectedObject', a.svm_radio);
      a.train_box = uicontrol('Style', 'Checkbox', 'String', 'Continuous Training', 'Callback', ...
        @(varargin)a.cont_train());
      a.train_but = uicontrol('String', 'Train', 'Callback', ...
        @(varargin)a.lin.train(a.inputs, a.outputs, a.train_method));
      a.rand_weights = uicontrol('String', 'Randomize Weights', 'Callback', @(varargin)a.set_rand_weights());
      a.rand_but = uicontrol('String','Random Data',...
        'Callback',@(varargin)a.random_data(false));      
      a.sep_but = uicontrol('String','Seperable Data',...
        'Callback',@(varargin)a.random_data(true));
      
      options = uimenu('Label', 'Data');
      uimenu(options, 'Label', 'Load data', 'Callback', @(varargin)a.load_data());
      uimenu(options, 'Label', 'Save data', 'Callback', @(varargin)a.save_data());
      %Removed line-smoothing & transparency, because it spacks out on
      %matlab 2010.      
      options = uimenu('Label', 'Graphics');
      a.graphics_menus(1) = uimenu(options, 'Label', 'No line smoothing & manual alpha-blending', ...
        'Checked', 'on','Callback', @(varargin)a.use_graphics(1));      
      a.graphics_menus(2) = uimenu(options, 'Label', 'Use line-smoothing & transparency', ...
        'Checked', 'off','Callback', @(varargin)a.use_graphics(2));
      
			options = uimenu('Label', 'SVM Algorithm');
			a.method_menus(1) = uimenu(options, 'Label', 'Auto', 'Checked', 'on', 'Callback', ...
				@(varargin)a.set_svm_type(1));
			a.method_menus(2) = uimenu(options, 'Label', 'LibSVM', 'Checked', 'off', 'Callback', ...
				@(varargin)a.set_svm_type(2));
			a.method_menus(3) = uimenu(options, 'Label', 'Bioinformatics', 'Checked', 'off', 'Callback', ...
				@(varargin)a.set_svm_type(3));
			a.method_menus(4) = uimenu(options, 'Label', 'Optimization', 'Checked', 'off', 'Callback', ...
				@(varargin)a.set_svm_type(4));

      %Begin plotting stuff
      hold on;
      %The data plot
      a.data_handle = scatter([], [], [], '+', 'SizeData', 100, 'XDataSource', 'a.inputs(:, 1)',...
        'YDataSource', 'a.inputs(:, 2)', 'CDataSource', 'a.colors', 'HitTest', 'off',...
        'LineWidth', 3);
      
      %A plot of circles around support vectors
      a.svcircle_handle = scatter([], [], 'og', 'SizeData', 160, 'LineWidth', 2, 'HitTest', 'off');
      
      %Support vector data for lines between SVs and the boundary
      a.sv_data = zeros(2, 2, 10);
      %The plot of these lines (there can be up to 10 SVs)
      a.sv_handles = plot(zeros(2, 10), zeros(2, 10), 'LineWidth', 2,...
        'LineSmoothing', 'off', 'Color', [0.3 0.6 0.3], 'HitTest', 'off');
      
      %The weight vector. This includes an arrowhead. Initial values are
      %precomputed and hard coded above.
      a.weight_handle = plot([0 a.lin.weights(1) a.w_arrow(1, 1) a.w_arrow(1, 2) a.lin.weights(1)], ...
        [0 a.lin.weights(2) a.w_arrow(2, 1) a.w_arrow(2, 2) a.lin.weights(2)],...
        '-b', 'MarkerSize', 10, 'LineSmoothing', 'off', 'LineWidth', 2, 'XDataSource', ...
        '[0 a.lin.weights(1) a.w_arrow(1, :) a.lin.weights(1)]', 'YDataSource', ...
        '[0 a.lin.weights(2) a.w_arrow(2, :) a.lin.weights(2)]', 'HitTest', 'off');
      
      %The boundary line. Callback function to allow dragging.
      a.boundary_handle = plot(a.boundary(:, 1), a.boundary(:, 2), '--r', 'LineWidth', 2,...
        'LineSmoothing', 'off', 'ButtonDownFcn', @(varargin)a.boundary_down, 'XDataSource',...
        'a.boundary(:, 1)', 'YDataSource', 'a.boundary(:, 2)');
      
      %Compute the initial patches of colour
      a.compute_surf();
      %A red patch on the red side of the decision boundary
      a.pos_handle = patch(a.pos_x, a.pos_y, a.pos_z, [1 0.8 0.8], 'HitTest', 'off',...
        'FaceAlpha', 1, 'EdgeColor', 'none');
      %A blue patch on the blue side of the decision boundary
      a.neg_handle = patch(a.neg_x, a.neg_y, a.neg_z, [0.8 0.8 1], 'HitTest', 'off',...
        'FaceAlpha', 1, 'EdgeColor', 'none');
      %A dark tube to indicate the minimum margin
      a.tubepos_handle = patch(a.tubepos_x, a.tubepos_y, a.tubepos_z, [0.6 0.6 0.8], 'HitTest', 'off',...
        'FaceAlpha', 1, 'EdgeColor', 'none');
      a.tubeneg_handle = patch(a.tubeneg_x, a.tubeneg_y, a.tubeneg_z, [0.8 0.6 0.6], 'HitTest', 'off',...
        'FaceAlpha', 1, 'EdgeColor', 'none');
      
      plot([repmat(-5:0.5:5, 21, 1) repmat((-5:0.5:5)', 1, 21)], ...
        [repmat((-5:0.5:5)', 1, 21) repmat(-5:0.5:5, 21, 1)], ':k', 'HitTest', 'off');
      plot([repmat([-5 0 5], 3, 1) repmat([-5 0 5]', 1, 3)], ...
        [repmat([-5 0 5]', 1, 3) repmat([-5 0 5], 3, 1)], 'k', 'HitTest', 'off');
      grid off;
      
      %Set the graph limits
      set(a.plot_area, 'xlim', [-5 5], 'ylim', [-5 5], 'clim', [-1 1]);
      
      %Add mouse handling and figure close callbacks
      set(a.fig, 'WindowButtonMotionFcn', @(varargin)a.mouse_move,...
        'WindowButtonUpFcn', @(varargin)a.mouse_up, 'CloseRequestFcn', @(varargin)a.close);
      %Drawing complete
      hold off;
      
      %Main loop: Draw the GUI and then wait for a resume. draw_flag
      %indicates that drawing is in process to squash further input.
      while (a.running)
        a.draw_flag = true;
        drawnow;
        a.draw_flag = false;
        uiwait(gcf);
      end
      
    end
    
    function do_layout(a)
      
      %Redo the layout of the figure.
      %There is a 150 pixel wide area on the left for gui components. The
      %rest of the figure is used for the largest containable square graph.
      pos = get(a.fig, 'Position');
      fig_width = pos(3) - 210;
      fig_height = pos(4) - 60;
      fig_size = min(fig_width, fig_height);
      set(a.plot_area, 'Position', [180 (pos(4) - fig_size - 30) fig_size fig_size]);
      top = pos(4) - 40;
      set(a.w_text, 'Position',[10 top 150 20]); top = top - 30;
      set(a.w_input(1),'Position',[10 top 70 20]);
      set(a.w_input(2),'Position',[90 top 70 20]); top = top - 30;
      set(a.t_text,'Position', [10 top 150 20]); top = top - 30;
      set(a.t_input,'Position',[10 top 150 20]); top = top - 30;
      set(a.error_disp,'Position', [10 top 150 20]); top = top - 30;
      set(a.margin_disp, 'Position', [10 top 150 20]); top = top - 65;
      set(a.train_group,'Position', [5/pos(3) top/pos(4) 160/pos(3) 60/pos(4)]); top = top - 25;
      set(a.train_box,'Position',[10 top 150 20]);top = top - 30;
      set(a.train_but,'Position',[10 top 150 20]);top = top - 30;
      set(a.rand_weights,'Position',[10 top 150 20]);top = top - 30;
      set(a.rand_but,'Position',[10 top 150 20]);top = top - 30;
      set(a.sep_but,'Position',[10 top 150 20]);
      
    end
    
    function compute_surf(a)
      %Compute the surfaces on the positive/negative sides of the boundary
      %and the minimum margin tube.
      
      %Make vectors containing all the 'interesting' coordinates (i.e.
      %corners and points where the boundary meets an edge)
      x = [-5 a.boundary(((a.boundary(:, 1) > -5) .* (a.boundary(:, 1) < 5)) == 1, 1)' 5];
      y = [-5 a.boundary(((a.boundary(:, 2) > -5) .* (a.boundary(:, 2) < 5)) == 1, 2)' 5];
      %Make a grid
      [X Y] = meshgrid(x, y);
      %Predict everywhere on the grid. Since the linear classified uses a
      %lazy sign on its outputs, points that lie on the decision boundary
      %have prediction 0.
      preds = a.lin.classify([X(1:numel(X))' Y(1:numel(Y))']);
      
      %Find the positive area (include points on the boundary)
      X_pos = X(preds > -1);
      Y_pos = Y(preds > -1);
      %If it's an area (not a point/line), compute the hull
      if (size(X_pos, 1) > 2)
        hull_pos = convhull(X_pos, Y_pos);
        a.pos_x = X_pos(hull_pos);
        a.pos_y = Y_pos(hull_pos);
        a.pos_z = -ones(numel(hull_pos), 1);
      else
        a.pos_x = [0 0 0];
        a.pos_y = [0 0 0];
        a.pos_z = -[1 1 1];
      end

      %Find the negative area
      X_neg = X(preds < 1);
      Y_neg = Y(preds < 1);
      %If it's an area (not a point/line), compute the hull
      if (size(X_neg, 1) > 2)
        hull_neg = convhull(X_neg, Y_neg);
        a.neg_x = X_neg(hull_neg);
        a.neg_y = Y_neg(hull_neg);   
        a.neg_z = -ones(numel(hull_neg), 1);
      else
        a.neg_x = [0 0 0];
        a.neg_y = [0 0 0];
        a.neg_z = -[1 1 1];
      end
      
      %Now find a tube. First get the closest support vector.
      distances = sum((a.sv_data(:, 2, :) - a.sv_data(:, 1, :)) .^ 2, 1);
      [v i] = min(distances(distances > 0));
      if v
        set(a.margin_disp, 'String', strcat('Margin: ', num2str(sqrt(v))));
        %TODO: Display the minimum margin
        %Find the gradient and intercept of the line through the SV
        %parallel to the decision boundary. Then find where it meets the
        %edges of the plot.
        m = a.lin.boundary_grad;
        c = a.sv_data(2, 1, i) - m .* a.sv_data(1, 1, i);
        edges = [-5 (-5 * m) + c; (5 - c)./m 5; 5 (5 * m) + c; -(5 + c) ./ m -5];
        %Get the edges where the intersection is within the plot.
        indices = sum(abs(edges), 2) <= 100;

        %Project the SV onto the other side of the decision boundary by
        %subtracting it from double the point of perpendicular intersection
        %with the boundary. Use this to compute the gradient/intercept of
        %the parallel line that is the same distance from the boundary on
        %the other side.
        m = a.lin.boundary_grad;
        new = (2.* a.sv_data(:, 2, i)) - a.sv_data(:, 1, i);
        c = new(2) - m .* new(1);
        %Get its points of intersection with the boundary and find the ones
        %inside the plot area.
        edges2 = [-5 (-5 * m) + c; (5 - c)./m 5; 5 (5 * m) + c; -(5 + c) ./ m -5];
        indices2 = sum(abs(edges), 2) <= 100;
        %Concatinate all the points and extract x/y coordinates.
        b_all = [edges(indices, :); edges2(indices2, :); a.boundary];
        x = b_all(:, 1);
        y = b_all(:, 2);
        preds = a.lin.classify([x y]);
        x_pos = x(preds < 1);
        y_pos = y(preds < 1);
        %If it's a surface and not a point/line, get the convex hull.
        if (size(x_pos, 1) > 2)
          hull_tube = convhull(x_pos, y_pos);
          a.tubepos_x = x_pos(hull_tube);
          a.tubepos_y = y_pos(hull_tube);
          a.tubepos_z = -ones(numel(hull_tube), 1)/2;
        else
          a.tubepos_x = [0 0 0];
          a.tubepos_y = [0 0 0];
          a.tubepos_z = -[1 1 1];
        end
        x_neg = x(preds > -1);
        y_neg = y(preds > -1);
        %If it's a surface and not a point/line, get the convex hull.
        if (size(x_neg, 1) > 2)
          hull_tube = convhull(x_neg, y_neg);
          a.tubeneg_x = x_neg(hull_tube);
          a.tubeneg_y = y_neg(hull_tube);
          a.tubeneg_z = -ones(numel(hull_tube), 1)/2;
        else
          a.tubeneg_x = [0 0 0];
          a.tubeneg_y = [0 0 0];
          a.tubeneg_z = -[1 1 1];
        end        
      else
        a.tubepos_x = [0 0 0];
        a.tubepos_y = [0 0 0];
        a.tubepos_z = -[1 1 1];        
        a.tubeneg_x = [0 0 0];
        a.tubeneg_y = [0 0 0];
        a.tubeneg_z = -[1 1 1];
      end
      
    end
    
    function lin_change(a)
      %Called when the linear classifier changes
        
      %Update the weight arrow via indecipherable arrayfun.
      a.w_arrow = reshape(feval(@(beta)arrayfun(@(x)(a.lin.weights(mod(x+1, 2) + 1)) - ...
        (a.w_arrow_size .* (((a.lin.weights(1) >= 0) .* 2) - 1) .* ...
        sin(a.w_arrow_angle + ((x <= 2) .* -beta) + ((x >= 3) .* ...
        (beta - pi ./ 2)) + ((mod(x, 3) ~= 1) .* pi ./ 2))), 1:4), atan(a.lin.weights(2)./a.lin.weights(1))), 2, 2);
      refreshdata(a.weight_handle, 'caller');
      
      %Find the new boundary
      m = a.lin.boundary_grad;
      c = a.lin.boundary_inte;
      %Find where the boundary crosses every edge
      edges = [-5 (-5 * m) + c; (5 - c)./m 5; 5 (5 * m) + c; -(5 + c) ./ m -5];
      %If the intersection is outside the area, the boundary hits a
      %different edge. Since the corrdinates are (-+5, *) or (*, -+5), edge
      %hits only occur when the sum is less than 10 (which guarantees an
      %edge hit).
      a.boundary = edges(sum(abs(edges), 2) <= 10, :);
      refreshdata(a.boundary_handle, 'caller');
      
      %Update grab text boxes
      set(a.w_input(1),'String',round(a.lin.weights(1) .* 1000) ./ 1000);
      set(a.w_input(2),'String',round(a.lin.weights(2) .* 1000) ./ 1000);
      set(a.t_input,'String',round(a.lin.theta .* 1000) ./ 1000);
      
      %Do classification again
      a.update_classification();
      
      %Update the classification surface (Squash exceptions; they are very
      %hard to generate and therefore hard to diagnose/fix. Probably require
      %some configuration of colinear points and we wouldn't even notice if
      %there was no drawing in these cases.)
      try %#ok<TRYNC>
        a.compute_surf();
      end
      set(a.pos_handle, 'XData', a.pos_x, 'YData', a.pos_y, 'ZData', a.pos_z);
      set(a.neg_handle, 'XData', a.neg_x, 'YData', a.neg_y, 'ZData', a.neg_z);
      set(a.tubepos_handle, 'XData', a.tubepos_x, 'YData', a.tubepos_y, 'ZData', a.tubepos_z);
      set(a.tubeneg_handle, 'XData', a.tubeneg_x, 'YData', a.tubeneg_y, 'ZData', a.tubeneg_z);      
      
      %Draw
      uiresume(gcf);
      
    end
    
    function data_change(a)
      %Called when the data changes
      a.inputs = min(max(a.inputs, -5), 5);
      %Resize the zero vector
      a.z_vector = zeros(numel(a.outputs), 1);
      %Do classification again
      if (a.train_method == 'p')
        a.lin.train(a.inputs, a.outputs, []);
      else
        a.lin.train(a.inputs, a.outputs, a.train_method(a.do_train));
      end
      %Assign colours to the points
      a.colors = [a.outputs == 1 a.z_vector a.outputs == -1];
      refreshdata(a.data_handle, 'caller');
      %Draw
      uiresume(gcf);
      
    end
    
    function update_classification(a)
      %Redo classification and update stuff
      
      %Only if there is data
      if (numel(a.inputs) ~= 0)
        %Get predictions and SVs
        [predictions sv] = a.lin.classify(a.inputs);
        %Store the errors (maybe someone wants to do something with them)
        a.errors = a.inputs(svm_demo.ssign(predictions) ~= a.outputs, :);

        %Compute lines from SVs to the boundary
        for i=1:numel(a.sv_handles)
          if (i <= numel(sv))
            a.sv_data(:, 1, i) = a.inputs(sv(i), :);
            pm = svm_demo.threshold(-1/a.lin.boundary_grad);
            pc = a.inputs(sv(i), 2) - pm*a.inputs(sv(i), 1);
            a.sv_data(1, 2, i) = (pc - a.lin.boundary_inte) ./ (a.lin.boundary_grad - pm);
            a.sv_data(2, 2, i) = ((a.lin.boundary_grad .* pc) - (pm .* a.lin.boundary_inte)) ./ ...
              (a.lin.boundary_grad - pm);
          else
            a.sv_data(:, :, i) = zeros(2, 2);
          end
          set(a.sv_handles(i), 'XData', a.sv_data(1, :, i));
          set(a.sv_handles(i), 'YData', a.sv_data(2, :, i));
        end
        set(a.svcircle_handle, 'XData', a.sv_data(1, 1, 1:numel(sv)));
        set(a.svcircle_handle, 'YData', a.sv_data(2, 1, 1:numel(sv)));
        
        %Update the error rate
        error = size(a.errors, 1) ./ numel(a.outputs);
        set(a.error_disp, 'String', ['Error rate: ' num2str(error)]);
      end
      
    end
    
    function set_rand_weights(a)
      
      %Set some random but sensible weights and theta
      w1 = (rand .* 6) - 3;
      w2 = (rand .* 6) - 3;
      theta = sign(rand - 0.5) .* (w1 + w2);
      a.lin.set_weights([w1 w2], theta);
      %Unless a perceptron is doing continuous training, cease continuous
      %training.
      if (a.train_method(a.do_train) ~= 'p')
        set(a.train_box, 'Value', 0);
        a.cont_train();
      end
      
    end
    
    function winput_change(a)
      %Halt any training that was happening
      set(a.train_box, 'Value', 0);
      a.do_train = false;      
      %Change on the text inputs of the weights
      w1 = str2double(get(a.w_input(1),'String'));
      w2 = str2double(get(a.w_input(2),'String'));
      a.lin.set_weights([w1 w2], a.lin.theta);
      
    end
    
    function t_input_change(a)
      %Halt any SVM training that was happening
      set(a.train_box, 'Value', 0);
      a.do_train = false;    
      %Change on the text input of the threshold
      a.lin.set_weights(a.lin.weights', str2double(get(a.t_input, 'String')));
    end
    
    function close(a)
      %Called when the GUI is closed
      a.running = false;
      uiresume(gcf);
      delete(gcf);
      
    end
    
    function grab_down(a)
      
      %Starts the weight vector dragging process.
      a.grab_drag = true;

    end
    
    function boundary_down(a)
      
      %Starts the boundary dragging process
      a.theta_drag = true;
      a.theta_drag_point = a.lin.theta;
      a.theta_drag_inte = a.lin.boundary_inte;
      
    end
    
    function check_data_down(a)
      
      %First, check if it's dragging the weight vector
      point = get(a.plot_area, 'CurrentPoint');
      if min(max(abs(a.lin.weights' - point(1, 1:2)))) < 0.25
          a.grab_down();
      end
      %Drags datapoints with a 0.25 catchment area.
      if (numel(a.outputs) > 0)
        %Get the closest data point. (Get the maximum distance on either
        %dimension from a data point, and choose the point with the
        %smallest. This gives data points a square catchment area).
        [v i] = min(max(abs(a.inputs - repmat(point(1, 1:2), size(a.inputs, 1), 1)), [], 2));
        if (v < 0.25)
          a.data_drag = i;
        end
      end
      
    end
    
    function mouse_move(a)
      %If dragging and not drawing, move stuff
      if (~a.draw_flag)
        if (a.grab_drag)
          %Halt any SVM training that was happening
          set(a.train_box, 'Value', 0);
          a.do_train = false;
          set(a.train_but, 'Enable', 'on');
          %Move the weights
          point = get(a.plot_area, 'CurrentPoint');
          point(1, 1:2) = min(max(point(1, 1:2), [-4.95 -4.95]), [4.95 4.95]);          
          a.lin.set_weights(point(1, 1:2), a.lin.theta);
        elseif (a.theta_drag)
          %Halt any SVM training that was happening
          set(a.train_box, 'Value', 0);
          a.do_train = false;
          point = get(a.plot_area, 'CurrentPoint');
          point(1, 1:2) = min(max(point(1, 1:2), [-4.95 -4.95]), [4.95 4.95]);
          %Find the perpendicular distance between the mouse and the
          %boundary prior to dragging using via a perpendicular line
          [m1 c1] = deal(a.lin.boundary_grad, a.theta_drag_inte);
          m2 = svm_demo.threshold(-1 ./ m1);
          c2 = point(1, 2) - m2 .* point(1, 1);
          x3 = (c2 - c1) ./ (m1 - m2);
          y3 = (m2 .* x3) + c2;
          %Scale the distance by the magnitude of the weight vector (small
          %weights are more affected by changes in bias)
          dis = norm(point(1, 1:2) - [x3 y3]) .* norm(a.lin.weights);
          %Decide which side of the boundary prior to dragging the mouse is
          %on.
          sig = -sign((point(1, 1:2) * a.lin.weights) + a.theta_drag_point);
          %Update the bias
          a.lin.set_weights(a.lin.weights', a.theta_drag_point + sig .* dis);
        elseif (a.data_drag > 0)
          %Drag a data item
          point = get(a.plot_area, 'CurrentPoint');
          a.inputs(a.data_drag, :) = point(1, 1:2);
          a.data_change();
        end
      end
      
    end
    
    function mouse_up(a)
      %Stop dragging
      a.grab_drag = false;
      a.theta_drag = false;
      a.data_drag = 0;
      
    end
    
    function random_data(a, separable)
      %Make some random data
      if (separable)
        %Draw from two gaussian distributions in the 1st and 3rd quadrants
        a.inputs = zeros(10, 2);
        a.inputs(1:5, :) = svm_demo.normrnd(2.5, 1, 5, 2);
        a.inputs(6:10, :) = svm_demo.normrnd(-2.5, 1, 5, 2);
        a.outputs = ones(10, 1);
        a.outputs(1:5) = -1;
      else
        a.inputs = (rand(10, 2) * 10) - 5;
        a.outputs = sign(rand(10, 1) - 0.5);
      end
      a.data_change();
      
    end
    
    function load_data(a)
      %Open a file dialogue and load some data
      [file path] = uigetfile('*.mat', 'Pick a data file');
      if exist(fullfile(path,file), 'file')
        load(fullfile(path,file));
        if (exist('inputs', 'var') && exist('outputs', 'var') && size(inputs, 2) == 2 &&...
            size(inputs, 1) == numel(outputs) && size(outputs, 1) == numel(outputs)) %#ok<CPROP,PROP>
          a.inputs = inputs; %#ok<CPROP,PROP>
          a.outputs = outputs; %#ok<CPROP,PROP>        
          a.data_change();     
        else
          errordlg('Data file must contain inputs: Nx2, outputs: Nx1', 'Invalid data file', 'modal');
        end
      end
    end
    
    function save_data(a)
      if (numel(a.outputs > 0))
        [file path] = uiputfile('*.mat', 'Pick a data file');
        inputs = a.inputs; %#ok<PROP,NASGU>
        outputs = a.outputs; %#ok<PROP,NASGU>
        save(fullfile(path, file), 'inputs', 'outputs');
        msgbox(['Data saved to ' file], 'Save successful');
      else
        errordlg('Cannot save empty dataset', 'No data to save', 'modal');
      end
      
    end
    
    function cont_train(a)
      
      a.do_train = ones(get(a.train_box, 'Value'));
      a.lin.train(a.inputs, a.outputs, a.train_method(a.do_train));
      if (numel(a.do_train))
        set(a.train_but, 'Enable', 'off');
      else
        set(a.train_but, 'Enable', 'on');
      end
      
      if (~a.cont_flag)
        a.cont_flag = true;
        while (exist('a', 'var') && a.running && numel(a.do_train))
          if (a.train_method == 'p')
            a.lin.train(a.inputs, a.outputs, a.train_method(a.do_train));
          end
          pause(0.5)
        end
        if (exist('a', 'var'))
          a.cont_flag = false;
        end
      end
      
    end
    
    function method_select(a, s)
      
      %Use a different training method
      a.train_method = get(s.NewValue, 'UserData');
      a.lin.train(a.inputs, a.outputs, a.train_method(a.do_train));
      
    end

    function set_svm_type(a, type)
    	
			for index=1:4
				set(a.method_menus(index), 'Checked', 'off');
			end
			set(a.method_menus(type), 'Checked', 'on');

			strings = 'slbo';
			type_string = strings(type);
      %Use a different training method
			if (a.train_method ~= 'p')
				a.train_method = type_string;
			end
      a.svm_type = type_string;
			set(a.svm_radio, 'UserData', a.svm_type);
      
    end
    
    function use_graphics(a, type)
      
      for i=1:2
        if (i==type)
          set(a.graphics_menus(i), 'Checked', 'on');
        else
          set(a.graphics_menus(i), 'Checked', 'off');
        end
      end      
      switch (type)
        case 1
          %Opaque
          set(a.tubepos_handle, 'CData', [0.6 0.6 0.8], 'FaceAlpha', 1);
          set(a.tubeneg_handle, 'CData', [0.8 0.6 0.6], 'FaceAlpha', 1);
          set(a.sv_handles, 'LineSmoothing', 'off');
          set(a.weight_handle, 'LineSmoothing', 'off');
        case 2
          %Transparent
          set(a.tubepos_handle, 'CData', [0 0 0], 'FaceAlpha', 0.4);
          set(a.tubeneg_handle, 'CData', [0 0 0], 'FaceAlpha', 0.4);
          set(a.sv_handles, 'LineSmoothing', 'on');
          set(a.weight_handle, 'LineSmoothing', 'on');
      end
      uiresume(gcf);
      
    end
    
  end
  
  properties (Constant = true)
    
    %Generate a block (using the varargin parameter for size) of random
    %numbers with mean mu and standard deviation sigma.
    normrnd = @(mu, sigma, varargin)randn(varargin{:}) .* sigma + mu;
    
  end
  
  methods (Static = true)
    
    function output = lsign(input)
      %The default matlab implementation of sign is not ideal! Sometimes we
      %get upset that sign(0.00000000000000001) = 1. There's no real reason
      %to get upset at this, but even so, it could be convenient if numbers
      %that are really close to 0 had a sign of 0. So we introduce lazy
      %sign!
      output = sign(input);
      output(abs(input) < 0.001) = 0;
      
    end
    
    function output = ssign(input)
      %The default matlab implementation of sign is not ideal! It has the
      %awkward property that sign(0) = 0. When classifying stuff, it's much
      %much much much more convenient if sign(0) is arbitrarily -1 or 1. So
      %we introduce strict sign, such that ssign(0) = -1. This has an
      %additional awesome property! It can convert binary -> polar.
      %ssign(0) = -1, ssign(1) = 1. This is often useful.
      output = ((input > 0) * 2) - 1;
      
    end
    
    function output = threshold(input)
      %Threshold the input at 100000 because if the threshold was a
      %parameter then the call to this function would be almost as long as
      %the function.
      output = max(min(input, 100000), -100000);

    end
    
  end
  
end

