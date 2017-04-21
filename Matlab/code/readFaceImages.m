function [im] = readFaceImages(imdir)
    function [imo] = crop(im)
        [x, y, ~, fig] = size(im);
        if x~= 385 
            im = imresize(im, ceil(385/x*100)/100);
        end
        [x, y, ~, fig] = size(im);
        if y < 385 
            im = imresize(im, ceil(385/y*100)/100);
        end
        imo = im(1:385,1:385,:);
        imo = single(imo);
    end
    files = dir(fullfile(imdir, '*.jpg'));
    im = single(zeros(385,385,3,numel(files)));
    for f = 1:numel(files)
        fn = files(f).name;
        im(:,:,:,f) = crop(im2single(imread(fullfile(imdir, fn))));
    end
end

% files = dir(fullfile(imdir, '*.gif'));
% for f = 1:numel(files)
%   fn = files(f).name;
%   id(f) = str2num(fn(8:9));
%   im{f} = imread(fullfile(imdir, fn));
% end
