addpath('vlfeat-0.9.20/toolbox/mex/mexa64');
%addpath('vlfeat-0.9.19/toolbox/mex/mexw64');

% dict?
% input testSets?
% NNE?
dictFolder = '/scratch/kuenzlet/dict';
resultFolder = '/scratch/kuenzlet/results';
scaleFactor = 3;
dict = 'generic_0.95_x3';
testSets = {'Set5', 'Set14', 'BD100', 'SuperTex136'};
endings = {'*.bmp', '*.bmp', '*.jpg', '*.jpg'};

configurationUpsampling = struct(...
    'upscaling', scaleFactor,...
    'overwrite', 1);

configurationUpsampling.description = 'generic_0.95';
configurationUpsampling.writeout = 1;

dictpath = fullfile(dictFolder, dict, 'dict.mat');
load(dictpath);

for i = 1:numel(testSets)
    go_upsampling_NNE(conf_NNE_LH, resultFolder, testSets{i}, endings{i},...
    configurationUpsampling);
end