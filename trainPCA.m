function [V_pca, conf]= trainPCA(conf, imgs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
conf = collectSamples(conf, imgs);

V_pca = conf.V_pca;
end

