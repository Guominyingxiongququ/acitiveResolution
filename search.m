function search(query,path)

addpath('jsonlab-1.1/jsonlab');
% Download full size images from Google image search. Saves image files
% locally. Do not print or republish images without permission.
%
% Based on Python code by Craig Quiter at https://gist.github.com/crizCraig/2816295
%
% Requires the JSONLab package, available from
% http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encodedecode-json-files-in-matlaboctave
%
% USAGE
%   >> search('dog')
%   >> search('landscape')
%

    error(nargchk(1,2,nargin));
    if nargin < 2, path = ''; end

%     baseurl = ['https://www.google.com/search?q=site:images.google.com+%s&tbm=isch' query '&start=%d'];
%     baseurl = strrep(baseurl, ' ', '%%20');
    baseurl = sprintf('https://www.google.com/search?q=site:images.google.com+%s&tbm=isch', query);
    basepath = fullfile(path,query);
    if ~exist(basepath,'dir')
        mkdir(basepath)
    end
    
    start = 0;
    
    while start < 60 % Google will only return a max of 60 results

        json = loadjson(urlread(sprintf(baseurl,start)));
        json
        for ii = 1:length(json.responseData.results)
            imageinfo = json.responseData.results(ii);
            url = imageinfo.unescapedUrl;
            
            try
                image = imread(url);
            catch %#ok
                fprintf('Could not download %s\n',url);
                continue
            end
            
            try
                imwrite(image, fullfile(basepath, sprintf('%s%02d.jpg',query,start+ii)));
            catch %#ok
                fprintf('Could not save %s\n', url);
                continue
            end
        end
        
        disp(start)
        start = start + 4; % 4 images per page
        
        % be nice to Google!
        pause(1.5)
        
    end

end