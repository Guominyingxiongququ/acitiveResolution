function [retRegions, retFeatures, retProperties] = computeKmeans(regions,...
    features, imageProperties, configuration)

requiredFields = {'samplingFactor'};
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

if numel(regions) <1
    error('The image Array has to contain at least one image.');
end

C = double(features * features');
[V, ~] = eig(C);
V_pca = V(:,end-99:end);
pcaFeatures = V_pca' * features;
numClusters = ceil(size(features,2)/configuration.samplingFactor);
if configuration.verbose
    fprintf('Running kmeans...\n');
end
kmeans = tic;
centers = vl_kmeans(pcaFeatures, numClusters, 'Algorithm', 'ANN', 'MaxNumComparisons', 1000);
kmeansTime = toc(kmeans);
if configuration.verbose
    fprintf('It took %0.2f seconds to run kmeans.\n', kmeansTime);
end
kdTree = vl_kdtreebuild(pcaFeatures);
nnInd = vl_kdtreequery(kdTree, single(pcaFeatures), single(centers),'MaxComparisons', 1000);
    
retRegions = regions(:,nnInd);
retFeatures = features(:,nnInd);

imageProperties.conf_remred.remredfac = configuration.samplingFactor;
imageProperties.remred = 1;

setname = sprintf('%s_remred%i', configuration.samplingFactor);
imageProperties.cursetname = setname;

retProperties = imageProperties;

end


