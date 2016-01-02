function [setname, output_dir, conf_dataset] = crop_images(indir, outdir, pen, minScore, maxRes)
%addpath(genpath(pwd));
addpath('edgeobject/piotrstoolbox/matlab', 'edgeobject/piotrstoolbox/channels', 'edgeobject/piotrstoolbox/detector');

opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.pen = pen;
opts.minScore = minScore;  % min score of boxes to detect
opts.maxBoxes = 1000;  % max number of boxes to detect
opts.maxRes = maxRes;

setname = [indir '_pen' num2str(opts.pen) '_minSc' num2str(opts.minScore) '_numBox' num2str(opts.maxRes)];

input_dir = fullfile('Data', indir); %'/scratch/Dai/Data/saliency/ECSSD/image/'; %
pattern = '*.bmp'; % Pattern to process
paths = glob(input_dir, pattern);
output_dir = fullfile(outdir, setname);

basepath = fullfile(output_dir);
if ~exist(basepath,'dir')
   mkdir(basepath)
end

imgs = cell(size(paths));
for i = 1:numel(paths)
    imgs{i} = imread(paths{i});
end

patches = imgcrop(imgs, opts);

for i=1:numel(patches)
    img = patches{i};
    img = rgb2ycbcr(img{1});
    img = img(:,:,1);
    patches{i} = img;
end

mat_file = fullfile(basepath, 'patches');    
save('-v7.3', mat_file, 'patches');
clear patches;

conf_dataset.patch_size = 0;
conf_dataset.threshold = 0;
conf_dataset.dataset = input_dir(6:end);
conf_dataset.remred = 0;
conf_dataset.overlap = 0;
conf_dataset.border = 0;

mat_file = [basepath '/parameters'];
save('-v7.3', mat_file, 'conf_dataset');
%output_dir = output_dir(6:end);

% for i = 1:numel(imgs)
%     img = imgs{i};
%     for j = 1:size(img, 2)
%         patch = img(j);
%         imwrite(patch{1}, fullfile(basepath, sprintf('%02d_%02d.bmp',i,j)));
%     end
% end
end