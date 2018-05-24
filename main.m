close all
clear

%% Variables

Ts = 10; %Nb d'echantillon d'un symbole.
%--------------------------------------------------------------------------
SNR = 10^(2/10);
bruit = 'none'; %('none','real','complex') type de bruit dans le canal
%--------------------------------------------------------------------------
%Instant initial.
span = 10;
t0 = span*Ts+1;
%--------------------------------------------------------------------------
%PARAMETRES DU CODE
% nombre de bits par symbole
Nb_bits_symb = 8;
% capacite de correction du code
t = 8;
% nombre de symboles du mot de code RS (apres codage)
N_RS = 2^Nb_bits_symb-1;
% nombre de symboles du mot d'info RS
K_RS = N_RS-2*t;
%Génération de bits
%!! Le nombre de bits générés doit être un multiple de K_RS pour
%que les programmes de codage/décodage RS fonctionnent
%On génère Nb_paquets_RS de taille K_RS*Nb_bits_symb bits
Nb_paquets_RS=64;
Nb_bits=Nb_paquets_RS*K_RS*Nb_bits_symb;
bits=randi(2,1,Nb_bits)-1;

%% Codage RS

H = comm.RSEncoder(N_RS,K_RS,'BitInput',true);
bits_code_RS=step(H,bits.').';

%% Codage convolutif
k = 7;% longueur contrainte
g1 = 171;g2 = 133; % polynomes générateurs en octal
trellis = poly2trellis(k, [g1 g2]);
p = [1 1 1 1]; % matrice de poinçonnage
bits_RS_conv = convenc(bits_code_RS, trellis, p);

%% Chaine de transmission

[ x, z ] = chaine_transmission(bits_RS_conv, Ts, SNR, bruit);

%% Echantillonnage

z_echan = z(t0:Ts:end);

%% Demapping

bits_estimes = zeros(1,length(bits_RS_conv));
bits_estimes(1:2:end) = (real(z_echan) < 0 );
bits_estimes(2:2:end) = (imag(z_echan) < 0 );

bits_rcp = vitdec(bits_estimes, trellis, 5*k, 'trunc', 'hard', p);

H = comm.RSDecoder(N_RS,K_RS,'BitInput',true);
bits_decodes_RS = step(H,bits_rcp.').';

TEB = sum(bits_decodes_RS ~= bits) / Nb_bits;

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
