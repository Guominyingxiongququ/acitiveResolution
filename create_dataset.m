function [imgs, props] = create_dataset(inputdir, outputdir, pattern, verb)

if nargin < 4
    verb = 0;
end

if nargin < 3
    pattern = '*.jpg';
end

inputdir = fullfile(inputdir);
paths = glob(strcat(inputdir, pattern));

parts = strsplit(inputdir, filesep);
props.setname = parts{end};
props.cursetname = props.setname;

imgs = cell(size(paths));
num_paths = numel(paths);
h = [];

if verb
    fprintf('%d images are beeing loaded...\n', num_paths);
end

for i = 1:num_paths
    h = progress(h, i / num_paths, verb);
    X = imread(paths{i});
    if size(X, 3) == 3 % we extract our features from Y channel
        X = rgb2ycbcr(X);                      
        X = X(:, :, 1);
    end
    imgs{i} = im2single(X);
end

mat_file = fullfile(outputdir, 'imgs');    
save('-v7.3', mat_file, 'imgs');
mat_file = fullfile(outputdir, 'props');    
save('-v7.3', mat_file, 'props');

if verb
    fprintf('\nSuccessfully created dataset "%s" containing %d images.', props.setname, num_paths);
end

end

