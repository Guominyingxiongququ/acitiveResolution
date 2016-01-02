function [imgs, props] = box_imagesrand(imgs, props, outputdir, conf)
verb = conf.verb;
addpath('edgeobject', 'edgeobject/piotrstoolbox/matlab', 'edgeobject/piotrstoolbox/channels', 'edgeobject/piotrstoolbox/detector');
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.pen = conf.pen;
opts.minScore = conf.minScore;  % min score of boxes to detect
opts.maxBoxes = 1000;  % max number of boxes to detect
opts.maxRes = conf.num;
opts.verb = verb;

setname = [props.cursetname '_pen' num2str(opts.pen) '_minSc' num2str(opts.minScore) '_numBox' num2str(opts.maxRes)];
outputdir = fullfile(outputdir, setname);

if ~exist(outputdir,'dir')
   mkdir(outputdir)
elseif ~conf.overwrite
   load(fullfile(outputdir, 'imgs'));
   load(fullfile(outputdir, 'props'));
   return;
end

for i=1:numel(imgs)
    X = imgs{i};
    X = cat(3, X, X, X);
    imgs{i} = im2uint8(X);
end

[patches, num] = imgcroprand(imgs, opts);

imgs = cell(1, num);
k = 1;
for i=1:numel(patches)
    img = patches{i};
    for j=1:numel(img)
        X = img{j};
        X = X(:,:,1);
        imgs{k} = im2single(X);
        k = k+1;
    end
end

mat_file = fullfile(outputdir, 'imgs');    
save('-v7.3', mat_file, 'imgs');
props.boxes = 1;
props.conf_boxes = conf;
props.cursetname = setname;
mat_file = fullfile(outputdir, 'props');
save('-v7.3', mat_file, 'props');
if verb
    fprintf('Successfully created dataset "%s" containing %d images.\n', setname, numel(imgs));
end
end