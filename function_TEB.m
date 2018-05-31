function [ TEBs ] = function_TEB( SNR_db, rs, entrelac, conv )
% Cette fonction modelise la chaine de transmission de l'emission jusqu'a
% la reception.
%   Parametres :
%    - SNR_db   | intervalle de calcul (en dB)
%    - rs       | active/desactive le codage RS
%    - entrelac | active/desactive l'entrelacement
%    - conv     | active/desactive le codage convolutif
%
%   Retours :
%    - TEBs  | valeurs du TEB
%--------------------------------------------------------------------------
%% Variables

Ts = 10; %Duree d'un symbole.
Nb_bits = 10^4; %Nb bits
bits = randi(2,1,Nb_bits)-1;
%--------------------------------------------------------------------------
bruit = 'complex'; %('none','real','complex') type de bruit dans le canal
TEBs = zeros(1,length(SNR_db));
%--------------------------------------------------------------------------
% Instant d'echantillonnage
span = 10;
t0 = span*Ts+1;

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

bits_codes = bits;
if rs
   bits_codes = codage_RS(t, N_RS, bits_codes, 'codage'); 
end
if entrelac
   bits_codes = entrelaceur(nrows, slope, bits_codes, 'entrelac');
end
if conv
   bits_codes = codage_conv(k, g1, g2, bits_codes, 'codage');
end

%% Calcul

for i=1:length(TEBs)
    [ ~, z ] = chaine_transmission(bits_codes, Ts, 10^(SNR_db(i)/10), bruit);
    z_echan = z(t0:Ts:end);
    bits_estimes = zeros(1,length(bits_codes));
    bits_estimes(1:2:end) = (real(z_echan) < 0 );
    bits_estimes(2:2:end) = (imag(z_echan) < 0 );
    
    bits_decodes = bits_estimes;
    if conv
       bits_decodes = codage_conv(k, g1, g2, bits_decodes, 'decodage');
    end
    if entrelac
       bits_decodes = entrelaceur(nrows, slope, bits_decodes, 'desentrelac');
    end
    if rs
       bits_decodes = codage_RS(t, N_RS, bits_decodes, 'decodage'); 
       bits_decodes = bits_decodes(1:Nb_bits);
    end

    TEBs(i) = sum(bits_decodes ~= bits) / Nb_bits;
end

end