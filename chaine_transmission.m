function [ x,  z ] = chaine_transmission( bits, Ts, filtre, SNR, bruit, fp, modu )
% Cette fonction modelise la chaine de transmission de l'emission jusqu'a
% la reception.
%   Parametres :
%    - bits   | la chaine de bits a transmettre
%    - Ts     | le nombre d'echantillon par symbole
%    - filtre | ('RA','RNA','FA','CA') filtre Forme+Reception
%    - SNR    | la valeur du signal sur bruit a appliquer
%    - bruit  | ('none','real','complex') type de bruit dans le canal
%    - fp     | Valeur de la fréquence porteuse, 0+QPSK = passe-bas
%    - modu   | (BPSK,QPSK,8PSK,16QAM)  modulation sur frq porteuse
%
%   Retours :
%    - x  | valeurs du signal mis en forme (complexe si QPSK,8PSK,16QAM)
%    - z  | valeurs du signal recu
%--------------------------------------------------------------------------
%% Type de filtre

switch (filtre)
    case 'RA'
        h = ones(1,Ts);
        hr = h;
    case 'RNA'
        h = ones(1,Ts);
        hr = kron([1 0], ones(1,Ts/2));
    case 'FA'
        h = [-1*ones(1,Ts/4) ones(1,Ts/2) -1*ones(1,Ts/4)];
        hr = h;
    case 'CA'
        span = 10;
        h = rcosdesign(0.5,span,Ts);
        hr = h;
end

%% Symboles

symboles = 2*bits-1;

%% Type de modulation

switch (modu)
    case 'BPSK'
        M = 2;
        sigma_a2 = 1;
    case 'QPSK'
        M = 4;
        sigma_a2 = 2;
        symboles = symboles(1:2:end)+1i*symboles(2:2:end);
    case '8PSK'
        M = 8;
        sigma_a2 = 1;
        bits1 = reshape(bits,log2(M),[]);
        bits2 = bi2de(bits1');
        symboles = pskmod(bits2', M, 0,'gray');
    case '16QAM'
        M = 16;
        sigma_a2 = 10;
        bits1 = reshape(bits,log2(M) ,[]);
        bits2 = bi2de(bits1');
        symboles = qammod(bits2', M,'gray');
end

%% Diracs

diracs = kron(symboles, [1 zeros(1,Ts-1)]);

if strcmp(filtre,'CA')
    diracs = [diracs zeros(1,span*Ts)]; %Compensation du retard du filtre
end

%% Filtrage de mise en forme

x = filter(h,1,diracs);

%% Transposition sur frequence porteuse

if fp ~= 0 && strcmp(modu,'QPSK')
   xp = x.*exp(1i*2*pi*fp*(1:length(x)));
   xp = real(xp);
end

%% Bruit AWGN

if  ~strcmp(bruit,'none')
    if fp ~= 0 && strcmp(modu,'QPSK')
        sigma_n2 = sigma_a2*(h*h')/(4*log2(M)*SNR);
    else
        sigma_n2 = sigma_a2*(h*h')/(2*log2(M)*SNR);
    end
    n = randn(1,length(diracs))*sqrt(sigma_n2);
    if strcmp(bruit,'complex')
        n = n + 1i*randn(1,length(diracs))*sqrt(sigma_n2);  %Bruit complexe
    end
else
    n = 0;
end

%% Canal de transmission

if fp ~= 0 && strcmp(modu,'QPSK')
    r = xp + n;
else
	r = x + n;
end

%% Filtrage de reception

if fp ~= 0 && strcmp(modu,'QPSK')
   r = r.*exp(-1i*2*pi*fp*(1:length(x)));
end

z = filter(hr,1,r);

end

