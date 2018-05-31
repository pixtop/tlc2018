function [ bits, dict ] = compressionJPEG( Image )

Q = [16 11 10 16 24 40 51 61 ;...
    12 12 14 19 26 58 60 55;...
    14 13 16 24 40 57 69 56;...
    14 17 22 29 51 87 80 62;...
    18 22 37 56 68 109 103 77;...
    24 35 55 64 81 104 113 92;...
    49 64 78 87 103 121 120 101;...
    72 92 95 98 112 100 103 99];

if size(Image,3) > 1
    Image = rgb2gray(Image);
end    

imagelin = Image(:);
liste = [];

for i = 0:size(Image,1)/8-1
    
    for j = 0: size(Image,2)/8-1
       
       % Lecture bloc à bloc 
       IBloc = Image( i*8+1 : (i+1)*8, j*8+1 : (j+1)*8 ) ;
       
       % DCT
       IDCT = dct(double(IBloc));
       
       % Quantification
       IQ = round(IDCT./Q);
       
       % Lecture en zig zag
       IQzig = parcours(IQ)'; 
       liste = [liste IQzig];
    end
end
       % RLE
       IQRLE = rle(liste)';
 
       % Codage
       
       send = zeros(1,2*length(IQRLE{1,1}));
       send(2:2:end) = IQRLE{1,1};
       send(1:2:end) = IQRLE{2,1};
       
       [bits, dict] = huffman_code(send);

end

