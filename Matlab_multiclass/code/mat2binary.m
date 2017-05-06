%% Images
mkdir kitData
% read images
load('./cifarData/imdb.mat')
im_male = images.data(:,:,:,find(images.labels == 1));
im_female = images.data(:,:,:,find(images.labels == 2));

%im_male = im_male(:,:,:,1:250);
%im_female = im_female(:,:,:,1:250);
%% split train set and val set
n = floor(size(im_male,4) * 0.8); % number of training data
set_male = uint8(zeros(1,size(im_male,4)));     % 1: train 2:val 3:test uint8
indexRan = randperm(size(im_male,4));
set_male(1:n) = uint8(1);
set_male(n+1:end) = uint8(2);
%% set labels
label_male = single(2 * ones(1,size(im_male,4)));
%% split train set and val set
set_female =  zeros(1,size(im_female,4));   % 1: train 2:val 3:test uint8
indexRan = randperm(size(im_female,4));
set_female(1:n) = uint8(1);
set_female(n+1:end) = uint8(2);
%% set labels
label_female = single(ones(1,size(im_female,4))); %
% concat 
data = cat(4, im_male, im_female);
data_mean = mean(data,4);
runTset = cat(2,set_male,set_female);
labels = cat(2,label_male,label_female);
%% randomly place the imgs
% indexRan = randperm(size(data,4));
% data = data(:,:,:,indexRan);
% set = set(indexRan);
% labels = labels(indexRan);
%% save imdb
% images
images = struct('data',{data},'set',{set},'labels',{labels});
% Meta
sets = {'train'  'val'  'test'};
classes = {'male cat';'female cat'};
meta = struct('sets',{sets},'classes',{classes});
save(fullfile('kitData','imdb.mat'),'images','meta');
