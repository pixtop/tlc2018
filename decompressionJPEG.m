function [ im_recu ] = decompressionJPEG(bits, dict, taille)

Q = [16 11 10 16 24 40 51 61 ;...
    12 12 14 19 26 58 60 55;...
    14 13 16 24 40 57 69 56;...
    14 17 22 29 51 87 80 62;...
    18 22 37 56 68 109 103 77;...
    24 35 55 64 81 104 113 92;...
    49 64 78 87 103 121 120 101;...
    72 92 95 98 112 100 103 99];

    bits_reception = bits;
    deco_huff = huffmandeco(bits_reception, dict);
    
    z =deco_huff(2:2:end);
    y =deco_huff(1:2:end);
    
    receive = repelem(deco_huff(2:2:end), deco_huff(1:2:end));
    
    im_recu = zeros(taille);
    
    for i = 0:length(receive)/64-1
        bloc = receive(i*64+1:(i+1)*64);   
        de_zig = invzigzag(bloc,8,8);
        de_quant = de_zig .*Q;
        de_dct = floor(idct(de_quant));
        
        abs_bloc = mod(i, taille(2)/8)*8 + 1;
        ord_bloc = floor(i / (taille(2)/8))*8 + 1;
        
        im_recu(ord_bloc:ord_bloc+7, abs_bloc:abs_bloc+7) = de_dct;
    end
    im_recu = im_recu - (im_recu > 255).*im_recu + (im_recu > 255)*255;
    im_recu = uint8(im_recu);
    
end

