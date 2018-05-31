function [ output_bits ] = codage_RS( t, N_RS, input_bits, mode)
% Codage/Decodage RS

K_RS = N_RS-2*t; 

if strcmp(mode,'codage')
    reste = mod(length(input_bits),K_RS*8);
    if reste ~= 0
        working_bits = [input_bits zeros(1,K_RS*8-reste)];
    end
    H = comm.RSEncoder(N_RS,K_RS,'BitInput',true);
    output_bits = step(H,working_bits.').';
else
    working_bits = input_bits;
    H = comm.RSDecoder(N_RS,K_RS,'BitInput',true);
    output_bits = step(H,working_bits.').';
end

