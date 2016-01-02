function [retRegions, retFeatures, retProperties] = collectRegions(...
    imageCellArray, imageProperties, configuration)

requiredFields = {'regionSize', 'scaleFactor', 'threshold'};
optionalFields = {'verbose'};

for k = 1:numel(requiredFields) % Test wether all required fields exist.
    thisField = requiredFields{k};
    if ~isfield(configuration, thisField)
        error('The field %s does not exist in the parameters struct.', ...
            thisField);
    end
end

for k = 1:numel(optionalFields)
    thisField = optionalFields{k};
    if ~isfield(configuration, thisField)
        configuration.(thisField) = 0;
    end
end

G = [1 0 -1];

configurationFeatures = struct(...
    'interpolate_kernel', 'bicubic',...
    'scale', configuration.scaleFactor);

configurationSampling = struct(...
    'level', 1,...
    'size', configuration.regionSize,...
    'window', [configuration.regionSize configuration.regionSize],...
    'border', [1 1],...
    'threshold', configuration.threshold,...
    'interpolate_kernel', 'bicubic',...,
    'overlap', [2 2],...
    'conf_feat', configurationFeatures);
configurationSampling.filters = {G, G.'};

setname = sprintf('%s_size%i_thres%0.3f_sc%i',...
    imageProperties.cursetname, configuration.regionSize,...
    configuration.threshold, configurationFeatures.scale);
conf = collectPatches_nonsmooth_mat(configurationSampling, imageCellArray);

retRegions = conf.patches;
retFeatures = conf.features;

conf_remred.patch_size = configurationSampling.size;
conf_remred.threshold = configurationSampling.threshold;
conf_remred.overlap = configurationSampling.overlap;
conf_remred.remredfac = 0;

imageProperties.conf_remred = conf_remred;
imageProperties.cursetname = setname;
imageProperties.patches = 1;

retProperties = imageProperties;

end

