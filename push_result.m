function push_result( result, result_dir )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
qmkdir(result_dir);
line = '\n';
conf_dataset = result.dataset;
line = [line sprintf('%s', conf_dataset.setname) ';'];
if isfield(conf_dataset, 'boxes')
    conf_boxes = conf_dataset.conf_boxes;
    line = [line sprintf('%i', conf_boxes.num) ';'];
    line = [line sprintf('%i', conf_boxes.pen) ';'];
    line = [line sprintf('%0.2f', conf_boxes.minScore) ';'];
else
    line = [line ';;;'];
end
if isfield(conf_dataset, 'patches')
    conf_patches = conf_dataset.conf_remred;
    line = [line sprintf('%i', conf_patches.patch_size) ';'];
    line = [line sprintf('%0.3f', conf_patches.threshold) ';'];
    line = [line sprintf('%i', conf_patches.remredfac) ';'];
    line = [line sprintf('%i', conf_patches.overlap(1)) ';'];
else
    line = [line ';;;;'];
end
line = [line sprintf('%i', result.scaledown) ';'];
line = [line sprintf('%0.2f', result.scaledownfac) ';'];
line = [line sprintf('%i', result.number_samples) ';'];
line = [line sprintf('%0.2f', result.score) ';'];
line = [line sprintf('%s', result.input) ';'];

fid = fopen(fullfile(result_dir, 'results.csv'), 'a');
fprintf(fid, line);
fclose(fid);
end

