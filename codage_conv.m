function [ output_bits ] = codage_conv( k, g1, g2, input_bits, mode )
%Codage convolutif / Decodage Viterbi

working_bits = input_bits; 
trellis = poly2trellis(k, [g1 g2]);
p = [1 1 1 1]; % matrice de poinçonnage

if strcmp(mode,'codage')
    output_bits = convenc(working_bits, trellis, p);
else
    output_bits = vitdec(working_bits, trellis, 5*k, 'trunc', 'hard', p);
end

