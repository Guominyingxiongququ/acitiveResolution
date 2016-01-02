addpath('vlfeat-0.9.19/toolbox/mex/mexa64');
%addpath('vlfeat-0.9.19/toolbox/mex/mexw64');

datasetFolder = '/scratch/kuenzlet/datasets';
resultFolder = '/scratch/kuenzlet/results';
dataset = 'raw4';
scaleFactor = 3;
regionSize = round(30/scaleFactor)*scaleFactor;

configurationBox = struct(...
    'num', 5,...
    'pen', 0,...
    'minScore', 0.1,...
    'verb', 1,...
    'overwrite', 1);

configurationStep1 = struct(...
    'scaleFactor', scaleFactor,...
    'threshold', 0,...
    'regionSize', regionSize);

configurationStep2 = struct('samplingFactor', 5);

configurationDownsampling = struct('num', 1, 'factor', 1);
configurationDict = struct(...
    'upscaling', scaleFactor,...
    'max_num', 5000000,...
    'overwrite', 1,...
    'scaling', configurationDownsampling);

configurationUpsampling = struct(...
    'upscaling', scaleFactor,...
    'overwrite', 1);

images = fullfile(datasetFolder, dataset, 'imgs');
properties = fullfile(datasetFolder, dataset, 'props');
load(images);load(properties);

for numbox = 1:10
    configurationBox.num = numbox;
    [imgs1, props1] = box_images(imgs, props, '/scratch/kuenzlet/datasets', configurationBox);
    [imgs1, feat1, props1] = collectRegions(imgs1, props1, configurationStep1);
    [imgs1, ~, props1] = computeKmeans(imgs1, feat1, props1, configurationStep2);
    imgs1 = matrixToCell(imgs1, regionSize);
    conf = build_dic_knn_pi(imgs1,props1,'/scratch/kuenzlet/dict',configurationDict);
    if numbox == 1
        configurationDict.max_num = conf.number_samples;
    end
    upsampling_NNE(conf, '/scratch/kuenzlet/results', 'Set5', '*.bmp', configurationUpsampling);
end

%output = '/scratch/kuenzlet/datsets'
%[imgs, props] = remove_redundancy(imgs, props, output, conf_patches);
