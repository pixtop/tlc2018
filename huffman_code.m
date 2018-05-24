function [ bits_code, dct ] = huffman_code( val )
    unq = unique(val)';
    prob = [];
    for i=1:length(unq)
        prob = [prob sum(val==unq(i))];
    end
    prob = prob ./ length(val);
    dct = huffmandict(unq, prob);
    bits_code = huffmanenco(val, dct);
end

