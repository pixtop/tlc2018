close all
clear

%% Variables

Ts = 20; %Durée d'un symbole.
nb_bits = 100; %Longueur de la trame binaire.
%--------------------------------------------
V = 1;
bits = V*(randi(2,1,nb_bits)-1); 
%--------------------------------------------
SNR = 1000;
bruit = false; % activation du bruit
%--------------------------------------------
filtre = 4; %(1, 2, 3, 4 ) Ordre question 
%--------------------------------------------
fp = 0;
%--------------------------------------------
switch (filtre)
    case 1
        span = 0;
        h = ones(1,Ts);
        hr = h;
        t0 = Ts;
    case 2
        span = 0;
        h = ones(1,Ts);
        hr = kron([1 0], ones(1,Ts/2));
        t0 = Ts;
    case 3
        span = 0;
        h = [-1*ones(1,Ts/4) ones(1,Ts/2) -1*ones(1,Ts/4)];
        hr = h;
        t0 = Ts;
    case 4
        span = 10;
        h = rcosdesign(0.5,span,Ts);
        hr = h;
        t0 = span*Ts+1; %Instant initial.
end

%% Chaine de transmission

[ x, z, ~, ~ ] = chaine_transmission(bits, Ts, h, hr, SNR, bruit, fp );

%% Echantillonage

z_echan = z(t0:Ts:end);


%% Calcul du TEB

TEB = sum((z_echan > 0) ~= bits(1:end-span)) / nb_bits;

%% Affichages

figure(1)

% Symboles transmis

plot(x, 'black')
grid on
title("Trace du signal d'emision")
%-------------------------------------------------
figure (2)

plot(z, 'red')
grid on;
title("Trace du signal de reception")

%-------------------------------------------------
figure(3)

% Diagramme de l'oeil
hold on
%axis([2 2*Ts -2 2]);
for i=1:nb_bits/2
    plot(z(i*Ts:(i+2)*Ts))
end
hold off
title("Diagramme de l'oeil")

%-------------------------------------------------

figure (4)

hhr = conv(h,hr);
% forme de h(t) * hr(t)
grid on
plot(hhr, 'red')
title("Réponse impulsionnelle de h(t) * hr(t)")

%-------------------------------------------------

fprintf('Valeur du TEB = %1.2f\n',TEB)

%-------------------------------------------------



