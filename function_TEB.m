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
Nb_bits = 10^5; %Redefinie si codage Rs
%--------------------------------------------------------------------------
bruit = 'complex'; %('none','real','complex') type de bruit dans le canal
TEBs = zeros(1,length(SNR_db));
%--------------------------------------------------------------------------
% Instant d'echantillonnage
span = 10;
t0 = span*Ts+1;
%--------------------------------------------------------------------------

if rs && conv
    Nb_bits_symb = 8;
    % capacite de correction du code
    t = 8;
    % nombre de symboles du mot de code RS (apres codage)
    N_RS = 2^Nb_bits_symb-1;
    % nombre de symboles du mot d'info RS
    K_RS = N_RS-2*t;
    %Génération de bits
    %On génère Nb_paquets_RS de taille K_RS*Nb_bits_symb bits
    Nb_paquets_RS=64;
    Nb_bits=Nb_paquets_RS*K_RS*Nb_bits_symb;
    H = comm.RSEncoder(N_RS,K_RS,'BitInput',true);
    
    bits=randi([0,1],1,Nb_bits);  
    bits_codes_RS=step(H,bits.').';

    k = 7;% longueur contrainte
    g1 = 171;g2 = 133; % polynomes générateurs en octal
    trellis = poly2trellis(k, [g1 g2]);
    p = [1 1 1 1]; % matrice de poinçonnage
    bits_codes = convenc(bits_codes_RS, trellis, p);
    
elseif rs && ~conv
    Nb_bits_symb = 8;
    % capacite de correction du code
    t = 8;
    % nombre de symboles du mot de code RS (apres codage)
    N_RS = 2^Nb_bits_symb-1;
    % nombre de symboles du mot d'info RS
    K_RS = N_RS-2*t;
    %Génération de bits
    %On génère Nb_paquets_RS de taille K_RS*Nb_bits_symb bits
    Nb_paquets_RS=64;
    Nb_bits=Nb_paquets_RS*K_RS*Nb_bits_symb;
    H = comm.RSEncoder(N_RS,K_RS,'BitInput',true);
    
    bits=randi([0,1],1,Nb_bits);  
    bits_codes=step(H,bits.').';
    
elseif ~rs && conv
    k = 7;% longueur contrainte
    g1 = 171;g2 = 133; % polynomes générateurs en octal
    trellis = poly2trellis(k, [g1 g2]);
    p = [1 1 1 1]; % matrice de poinçonnage
    bits = randi([0,1],1,Nb_bits);
    bits_codes = convenc(bits, trellis, p);
    
else
    bits = randi([0,1],1,Nb_bits);
    bits_codes = bits;
end

%% Entrelacement

if entrelac
    %Paramètres de l’entrelaceur
    nrows = 12; %Nombre de registres (FIFO)
    slope = 17; %Taille des registres (FIFO)
    %Délai introduit
    Delai = nrows*(nrows-1)*slope;
    %Génération des bits
    bits_paddes = [bits_codes zeros(1,Delai)];
    %Entrelacement
    bits_entrelaces = convintrlv(bits_paddes,nrows,slope);
else
    bits_entrelaces = bits_codes;
end

%% Calcul

for i=1:length(TEBs)
    [ ~, z ] = chaine_transmission(bits_entrelaces, Ts, 10^(SNR_db(i)/10), bruit);
    z_echan = z(t0:Ts:end);
    bits_estimes = zeros(1,length(bits_entrelaces));
    bits_estimes(1:2:end) = (real(z_echan) < 0 );
    bits_estimes(2:2:end) = (imag(z_echan) < 0 );
    
    if entrelac
        bits_desentrelaces = convdeintrlv(bits_estimes, nrows, slope);
        %Suppression du retard
        bits_estimes = bits_desentrelaces(Delai+1:end);
    end
    
    if conv && rs
        bits_decodes_conv = vitdec(bits_estimes, trellis, 5*k, 'trunc', 'hard', p);
        H = comm.RSDecoder(N_RS,K_RS,'BitInput',true);
        bits_decodes = step(H,bits_decodes_conv.').';
        
    elseif ~conv && rs
        H = comm.RSDecoder(N_RS,K_RS,'BitInput',true);
        bits_decodes = step(H,bits_estimes.').';
        
    elseif conv && ~rs
        bits_decodes = vitdec(bits_estimes, trellis, 5*k, 'trunc', 'hard', p);
        
    else
        bits_decodes = bits_estimes;
    end

    TEBs(i) = sum(bits_decodes ~= bits) / Nb_bits;
end

end