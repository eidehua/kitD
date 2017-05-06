function [im] = readFaceImages(imdir)
    imagesize = 32;
    function [imo] = crop(im,imagesize)
        [x, y, ~, fig] = size(im);
        if x~= imagesize 
            im = imresize(im, ceil(imagesize/x*100)/100);
        end
        [x, y, ~, fig] = size(im);
        if y < imagesize 
            im = imresize(im, ceil(imagesize/y*100)/100);
        end
        imo = im(1:imagesize,1:imagesize,:);
        imo = single(imo);
    end
    files = dir(fullfile(imdir, '*.jpg'));
    im = single(zeros(imagesize,imagesize,3,numel(files)));
    for f = 1:numel(files)
        fn = files(f).name;
        im(:,:,:,f) = crop(im2single(imread(fullfile(imdir, fn))),imagesize);
    end
end

% files = dir(fullfile(imdir, '*.gif'));
% for f = 1:numel(files)
%   fn = files(f).name;
%   id(f) = str2num(fn(8:9));
%   im{f} = imread(fullfile(imdir, fn));
% end
