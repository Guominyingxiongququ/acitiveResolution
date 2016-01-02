function [conf_NNE_LH] = build_dic_knn_pi(imgs, props, outputdir, opts)

% extract HR and LR patches from a collection of images: collectSamples.m 
% extract HR and LR patches from a collection of images at multiple scales:
% collectSamplesScales     

% input_dir = 'CVPR08-SR/Data/Training'; %'/scratch/Dai/Data/saliency/ECSSD/image/'; %
%dataset = 'remred5__raw2_ov2_30_2';
%input_dir = strcat('Data/', dataset); %'/scratch/Dai/Data/saliency/ECSSD/image/'; %
%pattern = '*.bmp'; % Pattern to process
conf.conf_dataset = props;

outdir = outputdir;

% Simulation settings
upscaling = opts.upscaling; % the magnification factor x2, x3, x4...
win_size = 3; 
conf.scale = upscaling; % scale-up factor
conf.level = 1; % # of scale-ups to perform
conf.window = [win_size win_size]; % low-res. window size
conf.border = [1 1]; % border of the image (to ignore)
conf.dataset = props.cursetname;
conf.number_down = opts.scaling.num;
conf.factor_down = opts.scaling.factor;

% High-pass filters for feature extraction (defined for upsampled low-res.)
O = zeros(1, conf.scale-1);
G = [ 1 O -1 ]; % Gradient
L = [1 O -2 O 1]/2; % Laplacian
conf.filters = {G, G.', L, L.'}; % 2D versions
conf.interpolate_kernel = 'bicubic';

conf.overlap = [2 2]; % partial overlap (for faster training)
if upscaling <= 2
    conf.overlap = [2 2]; % partial overlap (for faster training)
end

conf.overlap = conf.window - [1 1]; % full overlap scheme (for better reconstruction)    
%conf.filenames = glob(input_dir, pattern); % Cell array  
%% added by dengxin  for conf.PPs2    
%[conf] = collectSamples(conf, load_images(glob(input_dir, pattern)));

if isfield(opts, 'dictname')
    dicname = opts.dictname;
else
    dicname = 'none';
end
conf.dictname = dicname;
outputdir = fullfile(outputdir, [dicname '_x' num2str(upscaling)]);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

vpca_mat = fullfile('dict', ['v_pca' num2str(upscaling) '.mat']);
%if ~exist(vpca_mat, 'file')
%    conf.pca_train = 0;
    [V_pca, confPCA] = trainPCA(conf, imgs);
    if conf.number_down == 1
        plores = confPCA.lowpatches;
        phires = confPCA.highpatches;
        numscales = 1;
        ks = size(plores, 2)/opts.max_num;
        if ks > 1
           plores = plores(:,1:ks:end);
           phires = phires(:,1:ks:end);
        end 
    end
    clear confPCA;
    conf.V_pca = V_pca;
    save(vpca_mat, 'V_pca');
%else
    load(vpca_mat);
    conf.V_pca = V_pca;
%end
conf.pca_train = 1;
%%  5 million

%extract5million = 1; 
%if opts.scaling.num ~= 0
% if 1
% [plores, phires] = collectSamplesScales(conf, imgs, conf.number_down, conf.factor_down);
% 
% tr_num = opts.max_num;
% fprintf('%d samples\n', size(plores,2));
% if size(plores,2) > tr_num     
%     s_factor = size(plores,2)/tr_num;
%     plores = plores(:,1:s_factor:end);
%     phires = phires(:,1:s_factor:end);
% end
if conf.number_down ~= 1
    [plores, phires, numscales] = collectSamplesScalesPerImage(conf, imgs, outdir, conf.number_down, conf.factor_down, opts.max_num);
end
number_samples = size(plores,2);
conf.number_down = numscales;


% l2 normalize LR patches, and scale the corresponding HR patches
l2 = sum(plores.^2).^0.5+eps;
l2n = repmat(l2,size(plores,1),1);   
%     l2(l2<0.1) = 1;
plores = plores./l2n;
phires = phires./repmat(l2,size(phires,1),1);
clear l2
clear l2n
conf.lowpatches = plores; 
conf.highpatches = phires;
conf.number_samples = number_samples;
clear plores
clear phires

% end

conf_NNE_LH = conf;
if isfield(opts, 'writeout') && opts.writeout == 1
    mat_file = fullfile(outputdir, 'dict');   
    save('-v7.3', mat_file, 'conf_NNE_LH');
end

end
