close all
clear

% Simulation envoie d'image avec respect de la norme DVB-S

%% Variables

Ts = 10; %Nb d'echantillon d'un symbole.
%--------------------------------------------------------------------------
SNR = 10^(2/10);
bruit = 'none'; %('none','real','complex') type de bruit dans le canal
%--------------------------------------------------------------------------
%Instant initial.
span = 10;
t0 = span*Ts+1;

%% Image

[bits, dict] = compressionJPEG(imread('index.png'));

%% Parametre codage

% Codage RS
t = 8;
N_RS = 204;
% Codage convolutif
k = 7;% longueur contrainte
g1 = 171;g2 = 133; % polynomes générateurs en octal
% Entrelaceur
nrows = 12;
slope = 17;

%% Codage

bits_codes = codage_RS(t, N_RS, bits, 'codage');
bits_codes = entrelaceur(nrows, slope, bits_codes, 'entrelac');
bits_codes = codage_conv(k, g1, g2, bits_codes, 'codage');

%% Chaine de transmission

[ x, z ] = chaine_transmission(bits_codes, Ts, SNR, bruit);

%% Echantillonnage

z_echan = z(t0:Ts:end);

%% Demapping

bits_estimes = zeros(1,length(bits_codes));
bits_estimes(1:2:end) = (real(z_echan) < 0 );
bits_estimes(2:2:end) = (imag(z_echan) < 0 );

bits_decodes = codage_conv(k, g1, g2, bits_estimes, 'decodage');
bits_decodes = entrelaceur(nrows, slope, bits_decodes, 'desentrelac');
bits_decodes = codage_RS(t, N_RS, bits_decodes, 'decodage');
bits_decodes = bits_decodes(1:length(bits));

image = decompressionJPEG(bits_decodes, dict, size(imread('index.png')));
figure(2)
imshow(image)

TEB = sum(bits_decodes ~= bits) / length(bits);

%% Affichages
%--------------------------------------------------------------------------
% Signal emis

% figure(1)
% plot(real(x), 'black')
% grid on
% title("Trace du signal emis")
% xlabel("Temps")
% ylabel("Amplitude")

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
