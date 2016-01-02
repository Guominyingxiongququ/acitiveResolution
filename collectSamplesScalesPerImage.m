function [rlores, rhires, numberdown] = collectSamplesScalesPerImage(conf, ohires, output_dir, numscales, scalefactor, max_num)

train = (isfield(conf, 'pca_train') && conf.pca_train);
k = 0;
m = 0;
h = [];
numberdown = numscales;
total = numscales * numel(ohires);
fprintf('Collecting Samples...\n');
for scale = 1:numscales
    if k > max_num
        numberdown = scale - 1;
        break;
    end
    sfactor = scalefactor^(scale-1);
    for i = 1:numel(ohires)
        h = progress(h, m / total, 1);
        img = ohires(i);
        chires = resize(img, sfactor, 'bicubic');
        chires = modcrop(chires, conf.scale);
        clores = resize(chires, 1/conf.scale, conf.interpolate_kernel);
        midres = resize(clores, conf.scale, conf.interpolate_kernel);
        features = collect(conf, midres, conf.scale, conf.filters);
        clear midres
        interpolated = resize(clores, conf.scale, conf.interpolate_kernel);
        clear clores
        patches = cell(size(chires));
        for j = 1:numel(patches) % Remove low frequencies
            patches{j} = chires{j} - interpolated{j};
        end
        clear chires interpolated
        hires = collect(conf, patches, conf.scale, {});
        if train
            features = conf.V_pca' * features;
        end
        lores = features;
        matfile = fullfile(output_dir, ['t' num2str(m)]);
        if ~exist(output_dir, 'dir')
            mkdir(output_dir);
        end
        save(matfile, 'k', 'lores', 'hires');
        m = m + 1;
        k = k + size(lores, 2);
    end
end
fprintf('\nnumber of samples: %i\n', k);
if k > max_num
        s_factor = k/max_num;
        s = 1;
        t = 0;
        nlo = size(lores,1);
        nhi = size(hires,1);
        rlores = zeros(nlo, max_num, 'single');
        rhires = zeros(nhi, max_num, 'single');
        h = [];
        fprintf('\nResampling...\n');
        for i = 0:(m-1)
            h = progress(h, (i+1) / m, 1);
            matfile = fullfile(output_dir, ['t' num2str(i) '.mat']);
            load(matfile);
            n = size(lores, 2);
            ind = s:s_factor:(n+0.5);
            if ~(numel(ind) == 0 || (numel(ind) == 1 && round(ind(end))>n))
                inde = ind(end);
                ind = round(ind);
                if ind(end)>n
                    ind = ind(1:end-1);
                    inde = inde-s_factor;
                    fprintf('\nblabla\n');
                end
                shires = hires(:,ind);
                slores = lores(:,ind);
                s = inde + s_factor - n;
                cslo = size(slores, 2);
                rlores(:,(1:cslo)+t)=slores;
                rhires(:,(1:cslo)+t)=shires;
                t = t + cslo;
            else
                s = s-n;
            end
            delete(matfile);
        end
else
    nlo = size(lores,1);
    nhi = size(hires,1);
    rlores = zeros(nlo, k, 'single');
    rhires = zeros(nhi, k, 'single');
    t = 0;
    h = [];
    fprintf('\nResampling...\n');
    for i = 0:(m-1)
        h = progress(h, (i+1) / m, 1);
        matfile = fullfile(output_dir, ['t' num2str(i) '.mat']);
        load(matfile);
        cslo = size(lores, 2);
        rlores(:,(1:cslo)+t)=lores;
        rhires(:,(1:cslo)+t)=hires;
        t = t + cslo;
        delete(matfile);
    end
end
end
