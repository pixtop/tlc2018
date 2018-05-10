close all;
clear

%% Variables

Ts = 24; %Durée d'un symbole.
nb_bits = 10^4; %Longueur de la trame binaire.
%--------------------------------------------
V = 1;
bits = V*(randi(2,1,nb_bits)-1); 
%--------------------------------------------
bruit = true; % activation du bruit
%--------------------------------------------
filtre = 4; %(1, 2, 3, 4 ) Ordre question 
%--------------------------------------------
SNR_db = (1:0.01:6);
TEBs = zeros(1,length(SNR_db));
TES = 1-normcdf(sqrt(2)*10.^(SNR_db/20));
%--------------------------------------------

switch (filtre)
    case 1
        span = 0;
        h = ones(1,Ts);
        hr = h;
        t0 = Ts;
    case 2
        span = 0;
        h = ones(1,Ts);
        hr = kron([1 0], ones(1,Ts/2));
        t0 = Ts;
        TES = 1-normcdf(10.^(SNR_db/20));
    case 3
        span = 0;
        h = [-1*ones(1,Ts/4) ones(1,Ts/2) -1*ones(1,Ts/4)];
        hr = h;
        t0 = Ts;
    case 4
        span = 10;
        h = rcosdesign(0.5,span,Ts);
        hr = h;
        t0 = span*Ts+1; %Instant initial.
end

for i=1:length(TEBs)
    [ ~, z ] = chaine_transmission(bits, Ts, h, hr, 10^(SNR_db(i)/10), bruit, 0 );
    z_echan = z(t0:Ts:end);
    TEBs(i) = sum((z_echan > 0) ~= bits(1:end-span)) / nb_bits;
end

%% Affichages

figure (1)

% TEB = f(E0/N0)
semilogy(SNR_db, TES)
hold on
semilogy(SNR_db, TEBs)
grid on
legend('TEB théorique','TEB mesuré')
title("TEB = f(Eb/No)")