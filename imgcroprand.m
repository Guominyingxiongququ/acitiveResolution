function [imgs, num] = imgcroprand(imgs, opts)

verb = opts.verb;

model=load('edgeobject/models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

pen = opts.pen;
maxRes = opts.maxRes;
opts = rmfield(opts, 'pen');
opts = rmfield(opts, 'maxRes');
opts = rmfield(opts, 'verb');

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
h = [];
num_imgs = numel(imgs);
num=0;
if verb
    fprintf('%d images are beeing processed...\n', num_imgs);
end
for i = 1:num_imgs
    if verb
        h = progress(h, i / num_imgs, verb);
    end
    I = imgs{i};
    bbs=edgeBoxes(I,model,opts);
    
    sarea = zeros(size(bbs,1));
    for j=1:size(bbs,1)
        sarea(j) = bbApply('area', bbs(j,:));
        bbs(j,5) = bbs(j,5) + pen / sarea(j);
    end
    
    bbs = flipud(sortrows(bbs, 5));
    if size(bbs,1) > maxRes
        bbs = bbs(1:maxRes,:);
    end
    
    union = [1 1 0 0 0];
    for j=1:size(bbs,1)
        union = bbApply('union', union, bbs(j,:));
    end

    uarea = bbApply('area', union);
    sarea = 0;
    for j=1:size(bbs,1)
        sarea = sarea + bbApply('area', bbs(j,:));
    end

    if uarea < sarea
        bbs = union;
    end
    
    for j = 1:size(bbs,1)
        bb = bbs(j,:);
        xd = size(I,2) - bb(3);
        yd = size(I,1) - bb(4);
        bb(1) = randi(xd);
        bb(2) = randi(yd);
        bbs(j,:) = bb;
    end
    
%     union = bbs(1,:);
%     for j=2:size(bbs,1)
%         union = bbApply('union', union, bbs(j,:));
%     end
% 
%     uarea = bbApply('area', union);
%     sarea = 0;
%     for j=1:size(bbs,1)
%         sarea = sarea + bbApply('area', bbs(j,:));
%     end
% 
%     if uarea < sarea
%         bbs = union;
%     end

    %figure(1);
    %imshow(I);
    %bbApply('draw', res);
    imgs{i} = bbApply('crop',I,bbs);
    num = num + numel(imgs{i});
end
    if verb
        fprintf('\n%d boxes have been proposed successfully out of %d images.\n', num, num_imgs);
    end
end