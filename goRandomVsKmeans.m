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
%imgs = imgs(1:50:end);
regions = collectRegions(imgs, props, configurationStep1);
nRegionsOrig = size(regions, 2); clear regions;
nImgs = numel(imgs);
for kmean = 2:5
    configurationStep2.samplingFactor = kmean;
for fact = 2
    %imgs3 = imgs(round(1:fact:nImgs));
    %[imgs3, feat3, props3] = collectRegions(imgs3, props, configurationStep1);
    %nRegionsDown = size(imgs3, 2);

    %configurationStep1.samplingFactor = round(nRegionsOrig/nRegionsDown);
    configurationStep1.samplingFactor = fact;
    

    [imgs1, feat1, props1] = computeKmeansPerImage(imgs, props, configurationStep1);
 %   [imgs2, feat2, props2] = computeRandomRegionsPerImage(imgs, props,...
     %   configurationStep1);
    %nImgs1 = size(imgs1, 2); nImgs3 = size(imgs3, 2);

    %if nImgs1 < nImgs3
    %    imgs3 = imgs3(:,round(linspace(1, nImgs3, nImgs1)));
    %    feat3 = feat3(:,round(linspace(1, nImgs3, nImgs1)));
    %else
    %    imgs1 = imgs1(:,round(linspace(1, nImgs1, nImgs3)));
    %    feat1 = feat1(:,round(linspace(1, nImgs1, nImgs3)));
    %    imgs2 = imgs2(:,round(linspace(1, nImgs1, nImgs3)));
    %    feat2 = feat2(:,round(linspace(1, nImgs1, nImgs3)));
    %end
    [imgs1, ~, props1] = computeKmeans(imgs1, feat1, props1,...
        configurationStep2);
%    [imgs2, ~, props2] = computeKmeans(imgs2, feat2, props2,...
    %    configurationStep2);
    %[imgs3, ~, props3] = computeKmeans(imgs3, feat3, props3,...
    %    configurationStep2);
    imgs1 = matrixToCell(imgs1, regionSize);
  %  imgs2 = matrixToCell(imgs2, regionSize);
    %imgs3 = matrixToCell(imgs3, regionSize);
    conf1 = build_dic_knn_pi(imgs1, props1, '/scratch', configurationDict);
   % conf2 = build_dic_knn_pi(imgs2, props2, '/scratch', configurationDict);
    %conf3 = build_dic_knn_pi(imgs3, props3, '/scratch', configurationDict);
    upsampling_NNE(conf1, resultFolder, 'Set5', '*.bmp', configurationUpsampling);
   % upsampling_NNE(conf2, resultFolder, 'Set5', '*.bmp', configurationUpsampling);
    %upsampling_NNE(conf3, resultFolder, 'Set5', '*.bmp', configurationUpsampling);
end
end
