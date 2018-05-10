function [ x, xp, z ] = chaine_transmission( bits, Ts, filtre, SNR, bruit, fp )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Type de filtre

switch (filtre)
    case 1
        h = ones(1,Ts);
        hr = h;
    case 2
        h = ones(1,Ts);
        hr = kron([1 0], ones(1,Ts/2));
    case 3
        h = [-1*ones(1,Ts/4) ones(1,Ts/2) -1*ones(1,Ts/4)];
        hr = h;
    case 4
        span = 10;
        h = rcosdesign(0.5,span,Ts);
        hr = h;
end

%% Diracs

symboles = 2*bits-1;

if fp
    symboles = symboles(1:2:end)+1i*symboles(2:2:end);
end

diracs = kron(symboles, [1 zeros(1,Ts-1)]);

%% Emission

if filtre == 4
    diracs = [diracs zeros(1,span*Ts)];
end

x = filter(h,1,diracs);

%% Emission frequence porteuse

if fp
   xp = x.*exp(1i*2*pi*fp*(1:length(x)));
   xp = real(xp);
end

%% Bruit AWGN

if bruit
    sigma_a2 = 1;
    M = 2;
    sigma_n2 = sigma_a2*(h*h')/(2*log2(M)*SNR);
    n = randn(1,length(diracs))*sqrt(sigma_n2);
else
    n = 0;
end

%% Canal de transmission

r = x + n;

%% Reception

if fp
   rc = r.*exp(1i*2*pi*fp*(1:length(x)));
end

z = filter(hr,1,rc);

end

