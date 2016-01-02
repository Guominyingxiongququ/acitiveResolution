addpath('vlfeat-0.9.19/toolbox/mex/mexa64');
%addpath('vlfeat-0.9.19/toolbox/mex/mexw64');

datasetFolder = '/scratch/kuenzlet/datasets';
resultFolder = '/scratch/kuenzlet/results';
dataset = 'raw5';
scaleFactor = 3;
regionSize = round(30/scaleFactor)*scaleFactor;

configurationBox = struct(...
    'num', 1,...
    'pen', 0,...
    'minScore', 0.1,...
    'verb', 1,...
    'overwrite', 1);

configurationStep1 = struct(...
    'scaleFactor', scaleFactor,...
    'threshold', 0,...
    'regionSize', regionSize);

configurationStep2 = struct('samplingFactor', 5);

configurationDownsampling = struct('num', 20, 'factor', 0.95);
configurationDict = struct(...
    'upscaling', scaleFactor,...
    'max_num', 1250000,...
    'overwrite', 1,...
    'scaling', configurationDownsampling);

configurationUpsampling = struct(...
    'upscaling', scaleFactor,...
    'overwrite', 1);

images = fullfile(datasetFolder, dataset, 'imgs');
properties = fullfile(datasetFolder, dataset, 'props');
load(images);load(properties); %imgs = imgs(1:100:end);

for fracDown = 1:0.5:3
    imgs1 = imgs(1:fracDown:end);
    [imgs1, props1] = box_images(imgs1, props, '/scratch/kuenzlet/datasets', configurationBox);
    [imgs1, feat1, props1] = collectRegions(imgs1, props1, configurationStep1);
    [imgs1, ~, props1] = computeKmeans(imgs1, feat1, props1, configurationStep2);
    imgs1 = matrixToCell(imgs1, regionSize);
    conf = build_dic_knn_pi(imgs1,props1,'/scratch/kuenzlet/dict',configurationDict);
    upsampling_NNE(conf, '/scratch/kuenzlet/results', 'Set5', '*.bmp', configurationUpsampling);
end

%output = '/scratch/kuenzlet/datsets'
%[imgs, props] = remove_redundancy(imgs, props, output, conf_patches);
