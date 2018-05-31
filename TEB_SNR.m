close all;
clear

% Calcul le TEB en fonction des codages.

%% Variables
rs = true;
conv = true;
entrelac = true;
%--------------------------------------------------------------------------
SNR_db = (-4:0.5:2);

%% Calculs

TEB = 1-normcdf(sqrt(2)*10.^(SNR_db/20));
TEBs = function_TEB( SNR_db, rs, entrelac, conv );

%% Affichages

figure (1)

% TEB = f(E0/N0)
semilogy(SNR_db, TEB, 'red')
hold on
semilogy(SNR_db, TEBs, '-*g')
grid on
legend('TEB theorique','TEB mesure')
title("TEB = f(Eb/No)")
axis([-4 2 10^-6 10^0]); 
xlabel("(Eb/No)dB")
ylabel("TEB")