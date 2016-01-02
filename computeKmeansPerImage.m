function [retImageArray, retFeatures, retProperties] = computeKmeansPerImage(...
    imageCellArray, imageProperties, configuration)
% COMPUTEKMEANSPERIMAGE - Samples regions of a given size for each image
% and returns the k most diverse regions.
% 
% Syntax: [imgs, props] = computeKmeansPerImage(imgs, props, conf)
%

requiredFields = {'samplingFactor', 'threshold',...
    'regionSize', 'scaleFactor'};
optionalFields = {'verbose', 'overwrite'};

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

regionConfiguration = struct(...
    'threshold', configuration.threshold,...
    'regionSize', configuration.regionSize,...
    'scaleFactor', configuration.scaleFactor,...
    'verbose', configuration.verbose);

kmeansConfiguration = struct(...
    'samplingFactor', configuration.samplingFactor,...
    'verbose', configuration.verbose);

retImageArray = [];
retFeatures = [];
for k = 1:numel(imageCellArray)
    thisImageCell = imageCellArray(k);
    [thisImageRegions, thisImageFeatures] = collectRegions(...
        thisImageCell, imageProperties, regionConfiguration);
    [thisImageRegions, thisImageFeatures] = computeKmeans(...
        thisImageRegions, thisImageFeatures, imageProperties,...
        kmeansConfiguration);
    retImageArray = [retImageArray, thisImageRegions]; %#ok<AGROW>
    retFeatures = [retFeatures, thisImageFeatures]; %#ok<AGROW>
end

retProperties = imageProperties;

end

