close all
clear

%% Variables

Ts = 12; %Nb d'echantillon d'un symbole.
nb_bits = 100; %Longueur de la trame binaire.
fe = 10^4;  %Frequence d'echantillonage.
%--------------------------------------------------------------------------
V = 1;
bits = V*(randi(2,1,nb_bits)-1); 
%--------------------------------------------------------------------------
SNR = 10^(2/10);
bruit = 'none'; %('none','real','complex') type de bruit dans le canal
%--------------------------------------------------------------------------
filtre = 'RA'; %('RA','RNA','FA','CA') filtre Forme+Reception
%--------------------------------------------------------------------------
%Instant initial.
if strcmp(filtre,'CA')
    span = 10;
    t0 = span*Ts+1;
else
    t0 = Ts;
end
%--------------------------------------------------------------------------
% fp = 3000/fe;   
fp = 0;
%--------------------------------------------------------------------------
modu = 'BPSK'; %Type de modulation (BPSK,QPSK,8PSK,16QAM) 

%% Chaine de transmission

[ x, z ] = chaine_transmission(bits, Ts, filtre, SNR, bruit, fp, modu);

%% Echantillonnage

z_echan = z(t0:Ts:end);

%% Demapping

bits_estimes = zeros(1,nb_bits);
switch(modu)
    case 'BPSK'
        bits_estimes = (z_echan > 0);
    case 'QPSK'
        bits_estimes(1:2:end) = (real(z_echan) > 0 );
        bits_estimes(2:2:end) = (imag(z_echan) > 0 );
    case '8PSK'
        bits_recus2 = pskdemod(z_echan, 8, 0, 'gray');
        bits_recus1 = de2bi(bits_recus2)';
        bits_estimes = bits_recus1(:)';
    case '16QAM'
        bits_recus2 = qamdemod(z_echan, 16)';  
        bits_recus1 = de2bi(bits_recus2)';
        bits_estimes = bits_recus1(:)';
end

TEB = sum(bits_estimes ~= bits) / nb_bits;

%% Enveloppe complexe sur frequence

xp = x.*exp(1i*2*pi*fp*(1:length(x)));

%% Affichages
%--------------------------------------------------------------------------
% Phase

% figure(1)
% plot(real(x), 'black')
% grid on
% title("Trace du signal en phase")
% xlabel("Temps")
% ylabel("Amplitude")

%--------------------------------------------------------------------------
% Quadrature
%--------------------------------------------------------------------------

% figure(2)
% plot(imag(x), 'blue')
% grid on
% title("Trace du signal en quadrature")
% xlabel("Temps")
% ylabel("Amplitude")

%--------------------------------------------------------------------------
% Porteuse
%--------------------------------------------------------------------------

% figure (3)
% plot(real(xp), 'red')
% grid on;
% title("Trace du signal sur frequence porteuse")
% xlabel("Temps")
% ylabel("Amplitude")

%--------------------------------------------------------------------------
% Diagramme de l'oeil
%--------------------------------------------------------------------------

figure(4)
hold on
for i=1:nb_bits/2
    plot((0:2*Ts),z(i*Ts:(i+2)*Ts))
end
hold off
title("Diagramme de l'oeil")

%--------------------------------------------------------------------------
% Constellation en sortie d'echantillonneur
%--------------------------------------------------------------------------

% figure(5)
% if strcmp(modu,'BPSK')
%     plot(complex(z_echan,0),'*','LineStyle','none');
% else
%     plot(z_echan,'*','LineStyle','none');
% end
% grid on;
% title("Constellation");
% xlabel("Reel")
% ylabel("Imaginaire")

%--------------------------------------------------------------------------
% DSP
%--------------------------------------------------------------------------

% figure(6)
% frqs = (-fe:fe-1)/fe;
% plot(frqs,abs(fft(xp,length(frqs))).^2);
% title("DSP du signal sur frequence porteuse");
% xlabel("Frequences")
% ylabel("Amplitude")

%--------------------------------------------------------------------------
% Valeurs puissance + TEB
%--------------------------------------------------------------------------

% fprintf('Valeur de la puissance = %1.2f\n',mean(abs(real(xp)).^2));
% fprintf('Valeur de la puissance = %1.2f\n',mean(abs(xp).^2));

fprintf('Valeur du TEB = %1.2f\n',TEB)
