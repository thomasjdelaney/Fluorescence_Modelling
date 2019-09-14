% infer from a calcium file, either train or modelled

home_dir = getenv('HOME');
data_dir = [home_dir '/Spike_finder/train/'];
data_set = '8';
calc_file = [data_dir data_set '.model.calcium.csv'];
spike_file = [data_dir data_set '.train.spikes.csv'];
calc_trains = csvread(calc_file, 1, 0);
spike_trains = csvread(spike_file, 1, 0);
[M,N] = size(calc_trains);
inferred_spike_trains = zeros(M,N);
for n = 1:N
    calc_train = calc_trains(:,n);
    spike_train = spike_trains(:,n);
    num_spikes = sum(spike_train);
    [c,b,c1,g,sn,spike_probs] = constrained_foopsi(calc_train);
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
save_name = [data_dir data_set '.paninski.model.spikes.csv'];
csvwrite(save_name, [0:N-1; inferred_spike_trains]);
disp(['Saved: ' save_name]);