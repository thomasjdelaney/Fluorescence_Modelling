T = 2000;

gr = [0.95,0.8];
g = poly(gr);

p = 0.02;

sp = rand(1,T)<p;
c = filter(1,g,sp);
b = 0.2;
sn = 0.2;
y = b + c + sn*randn(1,T);

%% run constrained_foopsi

[c1,b1,c_in1,g1,sn1,sp1] = constrained_foopsi(y);

%% run constrained foopsi on scaled data
fc = 10000;         % scaling factor
[c2,b2,c_in2,g2,sn2,sp2] = constrained_foopsi(fc*y);


%% test results

disp(norm(c2 - fc*c1)/norm(c2))
disp(norm(sp2 - fc*sp1)/norm(sp2))
disp(b2-fc*b1)
disp(sn2-fc*sn1)
disp(g1-g2)

plot(sp2);
hold on
plot(fc*sp1, 'r');

hold off
plot(c2);
hold on
plot(fc*c1, 'r');