%% Images
mkdir kitData
% read images
load('/Users/hoho/Documents/CourseSpring17/CS543_CV/cs543/hw5/computer_vision_MP/code/cifar_data/cifar-baseline/imdb.mat')
im_0 = images.data(:,:,:,find(images.labels == 80));
im_1 = images.data(:,:,:,find(images.labels == 1));
im_2 = images.data(:,:,:,find(images.labels == 20));


%% split train set and val set
n = floor(size(im_1,4) * 0.8); % number of training data
set_0 =  zeros(1,size(im_0,4));   % 1: train 2:val 3:test uint8
set_0(1:n) = uint8(1);
set_0(n+1:end) = uint8(2);
set_1 = uint8(zeros(1,size(im_1,4)));     % 1: train 2:val 3:test uint8
set_1(1:n) = uint8(1);
set_1(n+1:end) = uint8(2);
set_2 =  zeros(1,size(im_2,4));   % 1: train 2:val 3:test uint8
set_2(1:n) = uint8(1);
set_2(n+1:end) = uint8(2);

%% set labels
label_0 = single(0 * ones(1,size(im_0,4))); %
label_1 = single(1 * ones(1,size(im_1,4)));
label_2 = single(2 * ones(1,size(im_2,4))); %


%% concat 
data = cat(4, im_1, im_2);
data = cat(4, data, im_0);
data_mean = mean(data,4);
set = cat(2,set_1,set_2);
set = cat(2,set,set_0);
labels = cat(2,label_1,label_2);
labels = cat(2,labels,label_0);

%% save imdb
% images
images = struct('data',{data},'data_mean',{data_mean},'set',{set},'labels',{labels});
% Meta
sets = {'train'  'val'  'test'};
classes = {'1 cat';'2 cat'};
meta = struct('sets',{sets},'classes',{classes});
save(fullfile('kitData','imdb.mat'),'images','meta');
