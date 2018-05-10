close all
clear

%% Variables

Ts = 6; %Durée d'un symbole.
t0 = Ts; %Instant initial.
nb_bits = 20; %Longueur de la trame binaire.
V = 1;  %Amplitude des symboles.

%% Emission

bits = V*(randi(2,1,nb_bits)-1); 
symboles = 2*bits-1;
diracs = kron(symboles, [1 zeros(1,Ts-1)]);
h = ones(1,Ts);
x = filter(h,1,diracs);

%% Bruit AWGN

sigma_a2 = 1;
SNR = 1;
M = 2;
sigma_n2 = sigma_a2*(h*h')/(2*log2(M)*SNR);
%n = randn(1,length(diracs))*sigma_n2;
n = 0;

%% Canal de transmission

r = x + n;

%% Reception

hr = ones(1,Ts);
z = filter(hr,1,r);

%% Echantillonage

z_echan = z(t0:Ts:end);

%% Detecteur de seuil + demapping

bits_estimes = zeros(size(z_echan));
for i=1:length(z_echan)
    if z_echan(i) >= 0
        bits_estimes(i) = 1;
    end
end

%% Calcul du TEB

erreurs = 0;
for i=1:length(z_echan)
    if bits(i) ~= bits_estimes(i)
        erreurs = erreurs + 1;
    end
end

TEB = erreurs / length(bits);

%% Affichages

figure(1)

% Symboles transmis
plot(1:nb_bits*Ts, x)
axis([1 nb_bits*Ts -Ts-1 Ts+1])
hold on
plot(1:nb_bits*Ts, z)
hold off
grid on
legend('x(t)','z(t)')
title("Trace du signal d'emision et de reception")

%-------------------------------------------------

figure(2)

% Diagramme de l'oeil
axis([0 2*Ts -Ts-1 Ts+1])
hold on
for i=1:2*Ts-1
    plot(0:2*Ts, z(i*Ts:(i+2)*Ts))
end
hold off
title("Diagramme de l'oeil")

%-------------------------------------------------

fprintf('Valeur du TEB = %1.2f\n',TEB)

