addpath('vlfeat-0.9.19/toolbox/mex/mexa64');
%addpath('vlfeat-0.9.19/toolbox/mex/mexw64');

datasetFolder = '/scratch/kuenzlet/datasets';
resultFolder = '/scratch/kuenzlet/results';
dataset = 'raw4';
scaleFactor = 3;
regionSize = round(30/scaleFactor)*scaleFactor;

configurationStep1 = struct(...
    'scaleFactor', scaleFactor,...
    'threshold', 0,...
    'regionSize', regionSize);

configurationStep2 = struct('samplingFactor', 4);

configurationDownsampling = struct('num', 1, 'factor', 1);
configurationDict = struct(...
    'upscaling', scaleFactor,...
    'max_num', 400000,...
    'overwrite', 1,...
    'scaling', configurationDownsampling);

configurationUpsampling = struct(...
    'upscaling', scaleFactor,...
    'overwrite', 1);

images = fullfile(datasetFolder, dataset, 'imgs');
properties = fullfile(datasetFolder, dataset, 'props');
load(images);load(properties);
imgs = imgs(1:5:end);

[imgs, feat, props] = collectRegions(imgs, props, configurationStep1);
for kmean = 6%:-0.5:1
    configurationStep2.samplingFactor = kmean;
    imgs1 = imgs; props1 = props;
    %[imgs1, ~, props1] = computeKmeans(imgs, feat, props,...
    %    configurationStep2);
    imgs1 = matrixToCell(imgs1, regionSize);
    conf = build_dic_knn_pi(imgs1, props1, '/scratch', configurationDict);
    upsampling_NNE(conf, resultFolder, 'Set5', '*.bmp',...
        configurationUpsampling);
end
