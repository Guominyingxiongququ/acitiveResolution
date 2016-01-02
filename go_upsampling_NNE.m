function go_upsampling_NNE(conf_NNE_LH, input_dir, pattern)
% super-resolution by NNE
% Reference:
% [1] Super-Resolution Through Neighbor Embedding, ICCV 2004
% [2] Anchored Neighborhood Regression for Fast Example-Based Super-Resolution, ICCV 2013. 
% [3] Jointly Optimized Regressors for Image Super-resolution, Eurographics 2015 

addpath('methods');
addpath('vlfeat-0.9.20\toolbox\mex\mexw64');
upscaling = 3; % the magnification factor x2, x3, x4...
%input_dir = 'Set5'; % test dataset 
%input_dir = 'Set14'; % Directory with input images from Set14 image dataset
%pattern = '*.bmp'; % Pattern to process

w_size = 3; 
NNE_k = 24;              % the size of neighborhood 
istree =1;               % using k-d tree to speedup 

fprintf('loading conf_NNE_LH .....')
if ~exist('conf_NNE_LH', 'var' )
    load(['./models/conf_NNE_LH_5mil_' num2str(upscaling)]);
end  
    conf_NNE_LH.dict_lores = conf_NNE_LH.lowpatches;  conf_NNE_LH.lowpatches = []; 
    conf_NNE_LH.dict_hires = conf_NNE_LH.highpatches; conf_NNE_LH.highpatches = [];

    fprintf('building the kd-tree .....')
    conf_NNE_LH.kdtree = vl_kdtreebuild(conf_NNE_LH.dict_lores) ;
  
    conf.dataset = conf_NNE_LH.dataset;
    conf.number_samples = conf_NNE_LH.number_samples;
    %% 
   
   % Simulation settings
    conf.scale = upscaling; % scale-up factor
    conf.level = 1; % # of scale-ups to perform
    conf.window = [w_size w_size]; % low-res. window size
    conf.border = [1 1]; % border of the image (to ignore)

    % High-pass filters for feature extraction (defined for upsampled low-res.)
    conf.upsample_factor = upscaling; % upsample low-res. into mid-res.
    O = zeros(1, conf.upsample_factor-1);
    G = [1 O -1]; % Gradient
    L = [1 O -2 O 1]/2; % Laplacian
    conf.filters = {G, G.', L, L.'}; % 2D versions
    conf.interpolate_kernel = 'bicubic';

    conf.overlap = [1 1]; % partial overlap (for faster training)
    if upscaling <= 2
        conf.overlap = [2 2]; % partial overlap (for faster training)
    end

    startt = tic;
    conf.overlap = conf.window - [1 1]; % full overlap scheme (for better reconstruction)    
    conf.trainingtime = toc(startt);
    toc(startt)
    
    conf.filenames = glob(input_dir, pattern); % Cell array  
    %conf.filenames = {conf.filenames{4}};
    
    conf.desc = {'original'};
    conf.desc{2} = 'NNE_ALearning';
  
    conf.results = {}; 
    
    resdir = strcat('results/', conf.dataset, '-');
    
    tag = [input_dir '_x' num2str(upscaling)];
    conf.result_dirImages = qmkdir([input_dir '/results_' tag]);
    conf.result_dirImagesRGB = qmkdir([input_dir '/results_' tag 'RGB']);
    conf.result_dir = qmkdir([resdir datestr(now, 'YYYY-mm-dd_HH-MM-SS')]);
   
    conf.V_pca = conf_NNE_LH.V_pca;
    %%
    t = cputime;    
        
    conf.countedtime = zeros(numel(conf.desc),numel(conf.filenames));
    
    res =[];
    for i = 1:numel(conf.filenames)
        f = conf.filenames{i};
        [p, n, x] = fileparts(f);
        [img, imgCB, imgCR] = load_images({f}); 
%         if imgscale<1
%             img = resize(img, imgscale, conf.interpolate_kernel);
%             imgCB = resize(imgCB, imgscale, conf.interpolate_kernel);
%             imgCR = resize(imgCR, imgscale, conf.interpolate_kernel);
%         end
        sz = size(img{1});
        
        fprintf('%d/%d\t"%s" [%d x %d]\n', i, numel(conf.filenames), f, sz(1), sz(2));
    
        img = modcrop(img, conf.scale^conf.level);
        imgCB = modcrop(imgCB, conf.scale^conf.level);
        imgCR = modcrop(imgCR, conf.scale^conf.level);

            low = resize(img, 1/conf.scale^conf.level, conf.interpolate_kernel);
            if ~isempty(imgCB{1})
                lowCB = resize(imgCB, 1/conf.scale^conf.level, conf.interpolate_kernel);
                lowCR = resize(imgCR, 1/conf.scale^conf.level, conf.interpolate_kernel);
            end
            
        interpolated = resize(low, conf.scale^conf.level, conf.interpolate_kernel);
        if ~isempty(imgCB{1})
            interpolatedCB = resize(lowCB, conf.scale^conf.level, conf.interpolate_kernel);    
            interpolatedCR = resize(lowCR, conf.scale^conf.level, conf.interpolate_kernel);    
        end
        
        % super_resolution   
        result = img{1}; 
        for kid=1:1     
%             res{kid} = scaleup_AdaptiveSelection(conf, low, dict_sizes, d, conf_NNE_LH_set{kid}, img, 40); 
            startt = tic;
            if istree
                res{kid} = scaleup_NE_NNLS_kdtree(conf_NNE_LH, low,  NNE_k);
%                   res{kid} = scaleup_NE_RReg_kdtree(conf, imgs, K); 

            else 
                res{kid} = scaleup_NE_NNLS(conf_NNE_LH, low, NNE_k);
            end
            result = cat(3, result, res{kid}{1});
            toc(startt)
            conf.countedtime(2,kid+1) = toc(startt);
            ['computing:' num2str(kid) '...']
        end
    
        result = shave(uint8(result * 255), conf.border * conf.scale);
        
        if ~isempty(imgCB{1})
            resultCB = interpolatedCB{1};
            resultCR = interpolatedCR{1};           
            resultCB = shave(uint8(resultCB * 255), conf.border * conf.scale);
            resultCR = shave(uint8(resultCR * 255), conf.border * conf.scale);
        end

        conf.results{i} = {};
        for j = 1:numel(conf.desc)            
            conf.results{i}{j} = fullfile(conf.result_dirImages, [n sprintf('[%d-%s]', j, conf.desc{j}) x]);            
            imwrite(result(:, :, j), conf.results{i}{j});

            conf.resultsRGB{i}{j} = fullfile(conf.result_dirImagesRGB, [n sprintf('[%d-%s]', j, conf.desc{j}) x]);
            if ~isempty(imgCB{1})
                rgbImg = cat(3,result(:,:,j),resultCB,resultCR);
                rgbImg = ycbcr2rgb(rgbImg);
            else
                rgbImg = cat(3,result(:,:,j),result(:,:,j),result(:,:,j));
            end
            
            imwrite(rgbImg, conf.resultsRGB{i}{j});
        end        
        conf.filenames{i} = f;
    end   
    conf.duration = cputime - t;

    % Test performance
    scores = run_comparison(conf);
%     process_scores_Tex(conf, scores,length(conf.filenames));
    scores = mean(scores);
%     run_comparisonRGB(conf); % provides color images and HTML summary
    %%    
%     save([tag '_' mat_file '_results_imgscale_' num2str(imgscale)],'conf');

result.patch_size = conf_NNE_LH.conf_dataset.patch_size;
result.threshold = conf_NNE_LH.conf_dataset.threshold;
result.number_samples = conf.number_samples;
result.dataset = conf_NNE_LH.conf_dataset.dataset;
if conf_NNE_LH.conf_dataset.remred == 0
    result.red_factor = 0;
else
    result.red_factor = conf_NNE_LH.conf_dataset.remredfac;
end
result.overlap = conf_NNE_LH.conf_dataset.overlap(1);
result.border = conf_NNE_LH.conf_dataset.border(1);
result.score = scores(2);

push_result(result, 'results/');

display('finished');
end
%