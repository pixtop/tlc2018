function [ output_bits ] = entrelaceur( nrows, slope, input_bits, mode )
%Entrelaceur/Desentrelaceur

working_bits = input_bits; 
%Délai introduit
Delai = nrows*(nrows-1)*slope;
%Génération des bits
bits_paddes = [working_bits zeros(1,Delai)];

if strcmp(mode, 'entrelac')
    output_bits = convintrlv(bits_paddes,nrows,slope);
else
    bits_desentrelaces = convdeintrlv(working_bits, nrows, slope);
    %Suppression du retard
    output_bits = bits_desentrelaces(Delai+1:end);
end

