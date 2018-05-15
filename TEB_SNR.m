close all;
clear

%% Variables

Ts = 10; %Duree d'un symbole.
nb_bits = 10^4; %Longueur de la trame binaire.
fe = 10^4; %Frequence d'echantillonage.
%--------------------------------------------------------------------------
V = 1;
bits = V*(randi(2,1,nb_bits)-1); 
%--------------------------------------------------------------------------
SNR_db = (0:0.01:6);
bruit = 'real'; %('none','real','complex') type de bruit dans le canal
TEBs = zeros(1,length(SNR_db));
%--------------------------------------------------------------------------
filtre = 'RA'; %('RA','RNA','FA','CA') filtre Forme+Reception
if strcmp(filtre,'CA')
    span = 10;
end
%--------------------------------------------------------------------------
%Instant initial.
if strcmp(filtre,'CA')
    t0 = span*Ts+1;
else
    t0 = Ts;
end
%--------------------------------------------------------------------------
% fp = 3000/fe;
fp = 0;
%--------------------------------------------------------------------------
modu = 'BPSK'; %Type de modulation (BPSK,QPSK,8PSK,16QAM)
%--------------------------------------------------------------------------
if strcmp(filtre,'RNA')
    TEB = 1-normcdf(10.^(SNR_db/20)); %Filtrage non adapte
elseif strcmp(modu,'8PSK')
    TES = 2*(1-normcdf(sqrt(2*log2(8))*sin(pi/8)*10.^(SNR_db/20)));
    TEB = TES./log2(8);
elseif strcmp(modu,'16QAM')
    TES = 4*(1-1/4)*(1-normcdf(sqrt(3*log2(16)/15)*10.^(SNR_db/20)));
    TEB = TES./log2(16);
else
    TEB = 1-normcdf(sqrt(2)*10.^(SNR_db/20));
end

%% Calcul

for i=1:length(TEBs)
    [ ~, z ] = chaine_transmission(bits, Ts, filtre, 10^(SNR_db(i)/10), bruit, fp, modu);
    z_echan = z(t0:Ts:end);
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
            bits_estimes = bits_recus1(:)' ;
    end
    TEBs(i) = sum(bits_estimes ~= bits) / nb_bits;
end

%% Affichages

figure (1)

% TEB = f(E0/N0)
semilogy(SNR_db, TEB)
hold on
semilogy(SNR_db, TEBs)
grid on
legend('TEB theorique','TEB mesure')
title("TEB = f(Eb/No)")
axis([0 6 10^-4 10^0]); 
xlabel("(Eb/No)dB")
ylabel("TEB")