close all;
clear

% Calcul le TEB en fonction des codages.

%% Variables
SNR_db = (-4:0.5:2);
TEBs = zeros(1,length(SNR_db));
%--------------------------------------------------------------------------

%% Calculs
theorique = 1-normcdf(sqrt(2)*10.^(SNR_db/20));
non_code = function_TEB(SNR_db, false, false, false );
code_conv = function_TEB(SNR_db, false, false, true );
code_rs_conv = function_TEB(SNR_db, true, false, true );
code_rs_entrelac_conv = function_TEB(SNR_db, true, true, true );

%% Affichages

figure (1)

% TEB = f(E0/N0)
semilogy(SNR_db, theorique, 'red')
hold on
semilogy(SNR_db, non_code, '-ok')
semilogy(SNR_db, code_conv, '-+b')
semilogy(SNR_db, code_rs_conv, '-*g')
semilogy(SNR_db, code_rs_entrelac_conv, '-^c')
grid on
legend('TEB theorique non code','TEB simule, non code','TEB simule, codage convolutif','TEB simule, codes concatenes sans entrelaceur','TEB simule, codes concatenes avec entrelaceur')
title("TEB = f(Eb/No)")
axis([-4 2 10^-6 10^0]); 
xlabel("(Eb/No)dB")
ylabel("TEB")