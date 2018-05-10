close all
clear

%% Variables

Ts = 10; %Durée d'un symbole.
nb_bits = 100; %Longueur de la trame binaire.
%--------------------------------------------
V = 1;
bits = V*(randi(2,1,nb_bits)-1); 
%--------------------------------------------
SNR = 1000;
bruit = false; % activation du bruit
%--------------------------------------------
filtre = 4;
span = 10;
t0 = span*Ts+1; %Instant initial.
%--------------------------------------------
fe = 10^4;
fp = 3000/fe;   

%% Chaine de transmission

[ x, xp, z ] = chaine_transmission(bits, Ts, filtre, SNR, bruit, fp );

%% Echantillonnage

z_echan = z(t0:Ts:end);
%% Demapping

bits_estimes = zeros(1,nb_bits);
bits_estimes(1:2:end) = (real(z_echan) > 0 );
bits_estimes(2:2:end) = (imag(z_echan) > 0 );

TEB = sum(bits_estimes ~= bits) / nb_bits;

%% Affichages

figure(1)

plot(real(x), 'black')
grid on
title("Trace du signal en phase")
%-------------------------------------------------
figure(2)

plot(imag(x), 'blue')
grid on
title("Trace du signal en quadrature")
%-------------------------------------------------

figure (3)

plot(real(z_echan), 'red')
grid on;
title("Trace du signal sur frequence porteuse")

%-------------------------------------------------
% DSP
%-------------------------------------------------
figure(4)

frqs = (-fe:fe-1)/fe;
plot(frqs,abs(fft(xp,length(frqs))).^2);
title("DSP du signal sur frequence porteuse");

%-------------------------------------------------
fprintf('Valeur de la puissance = %1.2f\n',mean(xp.^2))
fprintf('Valeur du TEB = %1.2f\n',TEB)
