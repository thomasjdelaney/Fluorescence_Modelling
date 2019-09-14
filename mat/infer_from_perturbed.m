% example matlab script for loading spikefinder data
%
% for more info see https://github.com/codeneuro/spikefinder

% load dataset
home_dir = getenv('HOME');
data_dir = [home_dir '/Spike_finder/train/'];
data_set = '8';
perturbed_data_dir = [home_dir '/Spike_finder/perturbed_fluoro/'];
perturbed_spike_dir = [home_dir '/Spike_finder/perturbed_spikes/'];
all_perturbed_files = dir(perturbed_data_dir);
perturbed_files = [];
for f_num = 1:length(all_perturbed_files)
    f = all_perturbed_files(f_num);
    if length(regexp(f.name, 'b_i_f_i+.+[0-9].model.calcium.csv')) > 0
        perturbed_files = [perturbed_files f];
    end
end

for file_num = 1:numel(perturbed_files)
    p_file = perturbed_files(file_num);
    calcium_trains = csvread([perturbed_data_dir p_file.name],1,0);
    dot_indices = find(p_file.name == '.');
    spike_trains = csvread([data_dir data_set '.train.spikes.csv']);
    [M,N] = size(calcium_trains);
    inferred_spike_trains = zeros(M,N);
    for n = 1:N
        calcium_train = calcium_trains(:,n);
        spike_train = spike_trains(:,n) > 0;
        t = (0:length(calcium_train)-1)/100; % 100 Hz sampling rate
        num_spikes = sum(spike_train);
        [c,b,c1,g,sn,spike_probs] = constrained_foopsi(calcium_train);
        max_activity = max(spike_probs);
        if max_activity == 0
            disp('WARNING: No spikes predicted.')
            inferred_spike_trains(:,n) = 0;
            continue
        end
        num_thresholds = 21;
        thresholds = 0:max_activity/num_thresholds:max_activity;
        spikes_at_thresholds = zeros(21,1);
        for i = 1:(length(thresholds)-1)
           t = thresholds(i);
           t_spikes = spike_probs > t;
           spikes_at_thresholds(i) = sum(t_spikes);
        end
        [mindiff, mindiff_index] = min(abs(spikes_at_thresholds - num_spikes));
        thresh_to_use = thresholds(mindiff_index);
        spike_preds = spike_probs > thresh_to_use;
        inferred_spike_trains(:,n) = spike_preds;
    end
    save_name = [perturbed_spike_dir data_set p_file.name(dot_indices(1):dot_indices(4)) 'paninski.model.csv'];
    csvwrite(save_name, [0:N-1; inferred_spike_trains]);
    disp(['Saved: ' save_name]);
end