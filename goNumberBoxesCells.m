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

configurationBox = struct(...
    'num', 1,...
    'pen', 0,...
    'minScore', 0.1,...
    'verb', 1,...
    'overwrite', 1);

images = fullfile(datasetFolder, dataset, 'imgs');
properties = fullfile(datasetFolder, dataset, 'props');
load(images);load(properties);
imgso = collectRegions(imgs, props, configurationStep1);
nCells = size(imgso,2)

% numbers = zeros(1,10);
% for numberBox = 1:10
%     configurationBox.num = numberBox;
%     [imgsb, propb] = box_images(imgs, props, '/scratch/kuenzlet/datasets', configurationBox);
%     imgsb = collectRegions(imgsb, propb, configurationStep1);
%     numbers(numberBox) = size(imgsb,2);
% end