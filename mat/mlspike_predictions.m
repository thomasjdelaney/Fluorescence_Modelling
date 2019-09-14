% For using the MLspike package to infer spikes

addpath([getenv('HOME'), '/MLspike'])
home_dir = getenv('HOME');
data_dir = [home_dir '/Spike_finder/train/'];
dataset = '8';
calcium_trains = csvread([data_dir dataset '.train.calcium.csv'],1,0); % skip first row (column headers)
spike_trains = csvread([data_dir dataset '.train.spikes.csv'],1,0);    % skip first row (column headers)
[M,N] = size(calcium_trains);
sampling_rate = 100;
dt = 1/sampling_rate;
saturation = 0.1; % this is a guess, should check with the source of the calcium
drift_parameter = 0.1; % controls the amount of baseline drift

for n = 1:N
  calcium_train = calcium_trains(:,n);
  spike_train = spike_trains(:,n) > 0;
  pax = spk_autocalibration('par'); % parameter struct for estimating calcium inference parameters
  pax.dt = dt;
  pax.amin = 0.0;
  pax.amax = 10.0;
  pax.taumin = 0.0;
  pax.taumax = 5;
  pax.saturation = saturation;
  pax.mlspikepar.dographsummary = false; % don't display a graph summary?
  [tau a sigma] = spk_autocalibration(calcium_train, pax) % estimating parameters
  par = tps_mlspikes('par');
  par.dt = dt;
  par.a = a; % amplitude
  par.tau = tau; % time/decay constant
  par.finetune.sigma = sigma; % additional noise
  par.saturation = saturation;
  par.drift.parameter = drift_parameter;
  par.dographsummary = false; % don't display a graph summary?
  [spikest fit drift] = spk_est(calcium_train, par);
end
