function [ x,  z ] = chaine_transmission( bits, Ts, SNR, bruit )
% Cette fonction modelise la chaine de transmission de l'emission jusqu'a
% la reception.
%   Parametres :
%    - bits   | la chaine de bits a transmettre
%    - Ts     | le nombre d'echantillon par symbole
%    - SNR    | la valeur du signal sur bruit a appliquer
%    - bruit  | ('none','real','complex') type de bruit dans le canal
%
%   Retours :
%    - x  | valeurs du signal mis en forme (complexe si QPSK,8PSK,16QAM)
%    - z  | valeurs du signal recu
%--------------------------------------------------------------------------
%% Filtre SRRCF

span = 10;
h = rcosdesign(0.35,span,Ts);
hr = h;

%% Symboles

symboles = 2*bits-1;

%% Modulation QPSK

M = 4;
sigma_a2 = 2;

symboles = -symboles;   %mise en norme.
symboles = symboles(1:2:end)+1i*symboles(2:2:end);

%% Diracs

diracs = kron(symboles, [1 zeros(1,Ts-1)]);
diracs = [diracs zeros(1,span*Ts)]; %Compensation du retard du filtre

%% Filtrage de mise en forme

x = filter(h,1,diracs);

%% Bruit AWGN

if  ~strcmp(bruit,'none')
    sigma_n2 = sigma_a2*(h*h')/(2*log2(M)*SNR);
    n = randn(1,length(diracs))*sqrt(sigma_n2);
    if strcmp(bruit,'complex')
        n = n + 1i*randn(1,length(diracs))*sqrt(sigma_n2);  %Bruit complexe
    end
else
    n = 0;
end

%% Canal de transmission

r = x + n;

%% Filtrage de reception

z = filter(hr,1,r);

end

