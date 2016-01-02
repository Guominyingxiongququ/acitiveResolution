function [ conf ] = collectPatches_nonsmooth_mat( conf, hires)
% Sample patches (from high-res. images) and remove smooth patches

% Load training high-res. image set and resample it
%hires = modcrop2(hires, conf.size); % crop to multiple of patch_size
scale = 1; % only get Gradient, without scaling
O = zeros(1, conf.conf_feat.scale-1);
G = [ 1 O -1 ]; % Gradient
L = [1 O -2 O 1]/2; % Laplacian
conf.conf_feat.filters = {G, G.', L, L.'}; % 2D versions
conf.conf_feat.overlap = [0 0]; %no overlapping patches
conf.conf_feat.window = [conf.size/conf.conf_feat.scale conf.size/conf.conf_feat.scale];
conf.conf_feat.level = 1;
conf.conf_feat.border = [1 1];
conf.conf_feat.interpolate_kernel = 'bicubic';

hires = modcrop2(hires, conf.conf_feat.scale, conf.window);

lores = resize(hires, 1/conf.conf_feat.scale, conf.conf_feat.interpolate_kernel);
midres = resize(lores, conf.conf_feat.scale, conf.conf_feat.interpolate_kernel);
features = cell(size(hires));
for i = 1:numel(hires) % Remove low frequencies
    features{i} = hires{i} - midres{i};
end

patches = collect(conf, hires, scale, {});
gradients = collect(conf, features, scale, conf.filters);
%features = collect(conf, midres, scale, conf.conf_feat.filters);
features = collect(conf, midres, scale, conf.conf_feat.filters);
clear hires;

xgrad = gradients(1:prod(conf.window),:);
ygrad = gradients(prod(conf.window)+1:end,:);
grad = sum(xgrad.^2 + ygrad.^2)/prod(conf.window);
indexes = grad>conf.threshold;
patches = patches(:,indexes);
features = features(:,indexes);

% patches = reshape(patches, [conf.window size(patches, 2)]);
conf.patches = double(patches);
conf.features = double(features);


end

