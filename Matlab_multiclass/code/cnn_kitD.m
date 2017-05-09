% function are called with two types
% either cnn_kitD('coarse') or cnn_kitD('fine')
% coarse will classify the image into 20 catagories
% fine will classify the image into 100 catagories
function cnn_kitD(type, varargin)

if ~(strcmp(type, 'fine') || strcmp(type, 'coarse')) 
    error('The argument has to be either fine or coarse');
end




% record the time
tic
%% --------------------------------------------------------------------
%                                                         Set parameters
% --------------------------------------------------------------------
%
% data directory
opts.dataDir = fullfile('kitData') ;
% experiment result directory
opts.expDir = fullfile('kitData') ;
% image database
opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
% set up the batch size (split the data into batches)
opts.train.batchSize = 50;
% number of Epoch (iterations)
opts.train.numEpochs = 55 ;
% resume the train
opts.train.continue = true ;
% use the GPU to train
opts.train.useGpu = false ;
% set the learning rate
opts.train.learningRate = [0.001 * ones(1, 10) 0.0005*ones(1,10), 0.0001*ones(1,15), 0.00005*ones(1,10), 0.00001*ones(1,10)] ;
%0.02, 0.001, 0.005*ones(1,5), 0.0005*ones(1,5), 0.0001*ones(1,10), 0.00005*ones(1,10)
% set weight decay
opts.train.weightDecay = 0.0005 ;
% set momentum
opts.train.momentum = 0.5 ;
% experiment result directory
opts.train.expDir = opts.expDir ;
% parse the varargin to opts. 
% If varargin is empty, opts argument will be set as above
opts = vl_argparse(opts, varargin);

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

imdb = load(opts.imdbPath) ;


%% Define network 
% The part you have to modify
net.layers = {} ;

% 1 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{1e-4*randn(3,3,3,32, 'single'), zeros(1, 32, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 2,...
                           'opts',{{}}) ;

% 2 pool1 (max pool)
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [3 3], ...
                           'stride', 2, ...
                           'pad', [0 1 0 1],...
                           'opts',{{}}) ;
% 3 relu2
net.layers{end+1} = struct('type', 'relu','leak',0) ;


% 4 conv2
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.001*randn(5,5,32,32, 'single'), zeros(1, 32, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 0,...
                           'opts',{{}}) ;

% 5 pool2 (avg pool)
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [7 7], ...
                           'stride', 2, ...
                           'pad', [0 1 0 1],...
                           'opts',{{}}) ; 
% 6 relu2
net.layers{end+1} = struct('type', 'relu','leak',0) ;                     

% 7 dropout layer
net.layers{end+1} = struct('type', 'dropout', 'rate', 0.5);

% 4 conv2
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.001*randn(4,4,32,2, 'single'), zeros(1, 2, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 0,...
                           'opts',{{}}) ;

% 8 loss
net.layers{end+1} = struct('type', 'softmaxloss') ;


% --------------------------------------------------------------------
%                                                                Train
% --------------------------------------------------------------------

% Take the mean out and make GPU if needed
imdb.images.data = bsxfun(@minus, imdb.images.data, mean(imdb.images.data,4)) ;
if opts.train.useGpu
  imdb.images.data = gpuArray(imdb.images.data) ;
end
%% display the net
vl_simplenn_display(net, 'inputSize', [size(imdb.images.data,1) size(imdb.images.data,2) size(imdb.images.data,3) opts.train.batchSize]);    % orig 385 385
%% start training
[net,info] = cnn_train_kitD(net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2) , 'test', find(imdb.images.set == 3)) ;
%% Record the result into csv and draw confusion matrix
load(['kitData/net-epoch-' int2str(opts.train.numEpochs) '.mat']);
load(['kitData/imdb' '.mat']);
fid = fopen('kitD_prediction.csv', 'w');
strings = {'ID','Label'};
for row = 1:size(strings,1)
    fprintf(fid, repmat('%s,',1,size(strings,2)-1), strings{row,1:end-1});
    fprintf(fid, '%s\n', strings{row,end});
end
fclose(fid);
ID = 1:numel(info.test.prediction_class);
dlmwrite('kitD_prediction.csv',[ID', info.test.prediction_class], '-append');

val_groundtruth = images.labels(find(images.set == 2));  %images.labels(45001:end);
val_prediction = info.val.prediction_class;
val_confusionMatrix = confusion_matrix(val_groundtruth , val_prediction);
cmp = jet(50);
figure ;
imshow(ind2rgb(uint8(val_confusionMatrix),cmp));
imwrite(ind2rgb(uint8(val_confusionMatrix),cmp) , 'kitD_confusion_matrix.png');
toc

% --------------------------------------------------------------------
%% crop function
function [imo] = ranCrop(im)
    [x, y, ~, fig] = size(im);
    imr = imresize(im, 1.5);
    imo = zeros(x,y,3,fig);
    for m = 1:fig
        xs = ceil(x/2*rand);
        ys = ceil(y/2*rand);
        imo(:,:,:,m) = imr(xs:xs+x-1,ys:ys+y-1,:,m);
    end
    imo = single(imo);

 
%% call back function get the part of the batch
function [im, labels] = getBatch(imdb, batch , set)
% --------------------------------------------------------------------
im = imdb.images.data(:,:,:,batch) ;
% data augmentation
if set == 1 % training
    % fliplr
    for t = 1:size(im,4)
        randnum = rand();
        if randnum > 0.5
            if rand() > 0.7
                im(:,:,:,t) = fliplr(im(:,:,:,t));
            else
                im(:,:,:,t) = flipud(im(:,:,:,t));
            end
        end
    end
    % noise
%     im = imnoise(im,'gaussian',0,5);
    % random crop
    if rand > 0.5
    	%im = ranCrop(im);
    end 
    % and other data augmentation
end


if set ~= 3
    labels = imdb.images.labels(1,batch) ;
end



