%% Images
mkdir kitData
% read images
im_male = readFaceImages(fullfile('..','..','images','output-male'));
im_female = readFaceImages(fullfile('..','..','images','output-female'));
n = floor(size(im_male,4) * 0.8); % number of training data
% set labels
set_male = uint8(zeros(1,size(im_male,4)));     % 1: train 2:val 3:test uint8
indexRan = randperm(size(im_male,4));
set_male(indexRan(1:n)) = uint8(1);
set_male(indexRan(n+1:end)) = uint8(2);
label_male = single(-1 * ones(1,size(im_male,4)));
% set labels
set_female =  zeros(1,size(im_female,4));   % 1: train 2:val 3:test uint8
indexRan = randperm(size(im_female,4));
set_female(indexRan(1:n)) = uint8(1);
set_female(indexRan(n+1:end)) = uint8(2);
label_female = single(ones(1,size(im_female,4))); %
% concat 
data = cat(4, im_male, im_female);
data_mean = mean(data,4);
set = cat(2,set_male,set_female);
labels = cat(2,label_male,label_female);
% random 
indexRan = randperm(size(data,4));
data = data(:,:,:,indexRan);
set = set(indexRan);
labels = labels(indexRan);
images = struct('data',{data},'data_mean',{data_mean},'set',{set},'labels',{labels});

%% Meta
sets = {'train'  'val'  'test'};
classes = {'male cat';'female cat'};
meta = struct('sets',{sets},'classes',{classes});
%% save imdb
save(fullfile('kitData','imdb.mat'),'images','meta');
