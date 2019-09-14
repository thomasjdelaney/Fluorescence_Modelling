%% calcium_buffering.m
% This is a script for simulating second order buffering of calcium within
% neurons.

% Should start of with lots of Ca2+, lots of Buffer molecules, 
% but not any buffered Calcium
clear all;

Ca2 = .5; % Concentration of Calcium
B = .25; % Concentration of Buffer
T_B = 1; % max concentration of buffer molecules
BCa = .75; % buffered molecules

f = .05; % forward binding rate
b = 0.1; % unbinding rate

t = 50; % number of time steps

Ca2_v = zeros(t, 1); % calcium trace
B_v = zeros(t, 1); % Buffer trace
BCa_v = zeros(t, 1); % Bound molecule trace

for tt = 1:t
    % adding values for plotting
    Ca2_v(tt) = Ca2;
    B_v(tt) = B;
    BCa_v(tt) = BCa;
    
    % doing the iterating
    bound = f * B * Ca2;
    unbound = b * BCa;
    dCa2 = unbound - bound;
    dB = unbound - bound;
    Ca2 = Ca2 + dCa2;
    B = B + dB;
    BCa = BCa + bound - unbound;
end

plot(Ca2_v, 'r');
hold on
plot(B_v, 'b');
plot(BCa_v, 'k');
hold off