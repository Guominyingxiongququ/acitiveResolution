function [conf] = collectSamples(conf, hires)
% Sample patches (from high-res. images) and extract features (from low-res.)
% for the Super Resolution algorithm training phase, using specified scale 
% factor between high-res. and low-res.

% Load training high-res. image set and resample it
hires = modcrop(hires, conf.scale); % crop a bit (to simplify scaling issues)
% Scale down images
lores = resize(hires, 1/conf.scale, conf.interpolate_kernel);

midres = resize(lores, conf.scale, conf.interpolate_kernel);
features = collect(conf, midres, conf.scale, conf.filters);
clear midres

interpolated = resize(lores, conf.scale, conf.interpolate_kernel);
clear lores
patches = cell(size(hires));
for i = 1:numel(patches) % Remove low frequencies
    patches{i} = hires{i} - interpolated{i};
end
clear hires %interpolated

patches = collect(conf, patches, conf.scale, {});

% Set KSVD configuration
%ksvd_conf.iternum = 20; % TBD
ksvd_conf.iternum = 20; % TBD
ksvd_conf.memusage = 'normal'; % higher usage doesn't fit...
%ksvd_conf.dictsize = 5000; % TBD
ksvd_conf.Tdata = 3; % maximal sparsity: TBD
ksvd_conf.samples = size(patches,2);

% PCA dimensionality reduction
C = double(features * features');
[V, D] = eig(C);
D = diag(D); % perform PCA on features matrix 
D = cumsum(D) / sum(D);
k = find(D >= 1e-3, 1); % ignore 0.1% energy
conf.V_pca = V(:, k:end); % choose the largest eigenvectors' projection
conf.ksvd_conf = ksvd_conf;
features_pca = conf.V_pca' * features;


conf.lowpatches = double(features_pca); 
conf.highpatches = double(patches);



