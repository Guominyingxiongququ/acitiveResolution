function imgs = modcrop2(imgs, modulo, window)

indexes = [];
for i = 1:numel(imgs)
    if any(size(imgs{i})<window)
        indexes = [indexes i];
    else
        sz = size(imgs{i});
        sz = sz - mod(sz, modulo);
        imgs{i} = imgs{i}(1:sz(1), 1:sz(2));
    end
end
imgs(indexes) = [];
