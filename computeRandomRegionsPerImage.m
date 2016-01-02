function [retImageArray, retFeatures, retProperties] = computeRandomRegionsPerImage(...
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
    'scaleFactor', configuration.scaleFactor,...
    'regionSize', configuration.regionSize,...
    'threshold', configuration.threshold,...
    'verbose', configuration.verbose...
    );

retImageArray = [];
retFeatures = [];
for k = 1:numel(imageCellArray)
    thisImageCell = imageCellArray(k);
    %thisImageRegions = remove_redundancy(thisImageCell, ...
    %    imageProperties, configuration.outputDir, redundancyConfiguration);
    [thisImageRegions, thisImageRegionFeatures] = collectRegions(...
        thisImageCell, imageProperties, regionConfiguration);
    nImages = size(thisImageRegions, 2);
    nRegions = ceil(nImages/configuration.samplingFactor);
    samples = randsample(nImages, nRegions);
    thisImageRegions = thisImageRegions(:,samples);
    thisImageRegionFeatures = thisImageRegionFeatures(:,samples);
    retImageArray = [retImageArray, thisImageRegions]; %#ok<AGROW>
    retFeatures = [retFeatures, thisImageRegionFeatures]; %#ok<AGROW>
end

retProperties = imageProperties;

end

