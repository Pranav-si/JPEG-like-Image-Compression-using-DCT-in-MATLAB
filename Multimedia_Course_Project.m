% Image Compression (RGB)
clc; clear;
tic;

%% Load Image
imNTU = imread('lena.png');      

BlockSize = 8;                
[rows1, columns1, numberOfColorChannels] = size(imNTU);
e1 = floor(rows1 / BlockSize);
e2 = floor(columns1 / BlockSize);

% Set desired size 
% h1 = max(e1,e2)*8;
% imNTU = imresize(imNTU, [h1 h1]);

info = imfinfo('lena.png');
ImageSize = info.FileSize

a = size(imNTU);           
width = a(1); 
height = a(2);

imNTU = double(imNTU);      
R = imNTU(:, :, 1);
G = imNTU(:, :, 2);
B = imNTU(:, :, 3);

%% RGB to YCbCr Conversion and 4:2:0 Downsampling
trans = [0.299 0.587 0.114 ; -0.169 -0.334 0.500 ; 0.500 -0.419 -0.081];  % RGB -> YCbCr conversion
inv_trans = inv(trans); % YCbCr -> RGB conversion

Y  = trans(1,1)*R + trans(1,2)*G + trans(1,3)*B;
Cb = trans(2,1)*R + trans(2,2)*G + trans(2,3)*B + 128;
Cr = trans(3,1)*R + trans(3,2)*G + trans(3,3)*B + 128;

% Perform 4:2:0 downsampling on Cb and Cr channels
Cb1 = Cb(1:2:end, 1:2:end);  
Cr1 = Cr(1:2:end, 1:2:end);  

%% Apply 2D Transform (DCT, Haar, Walsh)
 Cf = dctmtx(8);                  %  DCT transform
%Cf = haarmtx(8);                  %  Haar wavelet
% Cf = (1/sqrt(8)) * walsh(8);    %  Walsh transform


YF  = blkproc(Y  ,[8 8],'P1*x*P2',Cf,Cf');
CbF = blkproc(Cb1,[8 8],'P1*x*P2',Cf,Cf');
CrF = blkproc(Cr1,[8 8],'P1*x*P2',Cf,Cf');

%% Quantization
var = 1;    % Quantization quality factor

Qy = floor(var * [16 11 10 16 24 40 51 61;
                  12 12 14 19 26 58 60 55;
                  14 13 16 24 40 57 69 56;
                  14 17 22 29 51 87 80 62;
                  18 22 37 56 68 109 103 77;
                  24 35 55 64 81 104 113 92;
                  49 64 78 87 103 121 120 101;
                  72 92 95 98 112 100 103 99]);  % Luminance quantization

Qc = floor(var * [17 18 24 47 99 99 99 99;
                  18 21 26 66 99 99 99 99;
                  24 26 56 99 99 99 99 99;
                  47 66 99 99 99 99 99 99;
                  99 99 99 99 99 99 99 99;
                  99 99 99 99 99 99 99 99;
                  99 99 99 99 99 99 99 99;
                  99 99 99 99 99 99 99 99]);  % Chrominance quantization

% Quantize the transformed coefficients
YQ  = blkproc(YF, [8 8], 'round(x./P1)', Qy);
CbQ = blkproc(CbF,[8 8], 'round(x./P1)', Qc);
CrQ = blkproc(CrF,[8 8], 'round(x./P1)', Qc);

%%
    Yq = YQ(:);
    Yq=int8(Yq);
    Yq = typecast(Yq, 'uint8');    
    bin_strs = dec2bin(Yq, 8);   
    yq_bitstream = reshape(bin_strs'=='1', [], 1);

    Cbq = CbQ(:); 
    Cbq = int8(Cbq);  
    Cbq = typecast(Cbq, 'uint8');
    bin_strs = dec2bin(Cbq, 8);
    Cbq_bitstream = reshape(bin_strs'=='1', [], 1);
    
    Crq = CrQ(:);  
    Crq = int8(Crq);
    Crq = typecast(Crq, 'uint8');
    bin_strs = dec2bin(Crq, 8);
    Crq_bitstream = reshape(bin_strs'=='1', [], 1);
    
%%   
    yqrl=rlc_encode(yq_bitstream);
    cbqrl=rlc_encode(Cbq_bitstream);
    crqrl=rlc_encode(Crq_bitstream);
    
    Yqbit= rlc_decode(yqrl);
    Cbbit = rlc_decode(cbqrl);
    Crbit =rlc_decode(crqrl);
    
    Yy1= bitstream_to_vars(Yqbit);
    Yq1= reshape(Yy1,size(Y));
    Cbcb1= bitstream_to_vars(Cbbit);
    Cbcb1= reshape(Cbcb1,size(Cb1));
    Crcr1= bitstream_to_vars(Crbit);
    Crcr2= reshape(Crcr1,size(Cr1));

%%
function values = bitstream_to_vars(bitstream)

    bin_matrix = reshape(char(bitstream + '0'), 8, [])';    
    uint_vals = uint8(bin2dec(bin_matrix));
    values = typecast(uint_vals, 'int8');
end
%%
function run_lengths = rlc_encode(bitstream)
  
    if isempty(bitstream)
        run_lengths = [];
        return;
    end
    start = bitstream(1);    
    run_lengths = [];
    count = 1;

    for i = 2:length(bitstream)
        if bitstream(i) == bitstream(i-1)
            count = count + 1;
        else
            run_lengths(end+1) = count;
            count = 1;
        end
    end
    run_lengths(end+1) = count;    
    if start == 0
        run_lengths = [0 run_lengths];  
    end    
end
%%
function bitstream = rlc_decode(run_lengths)
    current_bit = 1;
    bitstream = [];

    for i = 1:length(run_lengths)
        bitstream = [bitstream; repmat(current_bit, run_lengths(i), 1)]; 
        current_bit = ~current_bit;
    end
end
 %% Compression Ratio Calculation

 max_len=ceil(log2(max(cbqrl)));
 data_len=max_len*length(cbqrl);
 max_len=ceil(log2(max(crqrl)));
 data_len=data_len+max_len*length(crqrl);
 max_len=ceil(log2(max(yqrl)));
 data_len=data_len+max_len*length(yqrl);

 
 bit_rate = data_len / (width * height);
 Compression_Ratio = 24 / bit_rate
 
 fprintf('Compressed image size is: ')
 compressedsize = ImageSize / Compression_Ratio

%% Inverse Quantization and Transform

YF_rec  = blkproc(Yq1,  [8 8], 'x .* P1', Qy);
CbF_rec = blkproc(Cbcb1, [8 8], 'x .* P1', Qc);
CrF_rec = blkproc(Crcr2, [8 8], 'x .* P1', Qc);

Yy  = blkproc(YF_rec,  [8 8], 'P1 * x * P2', Cf', Cf);
Cbcb = blkproc(CbF_rec, [8 8], 'P1 * x * P2', Cf', Cf);
Crcr = blkproc(CrF_rec, [8 8], 'P1 * x * P2', Cf', Cf);

Cbb = four_two_zero_recovery(width, height, Cbcb);
Cr2 = four_two_zero_recovery(width, height, Crcr);

R3 = inv_trans(1,1)*Yy + inv_trans(1,2)*(Cbb - 128) + inv_trans(1,3)*(Cr2 - 128);
G3 = inv_trans(2,1)*Yy + inv_trans(2,2)*(Cbb - 128) + inv_trans(2,3)*(Cr2 - 128);
B3 = inv_trans(3,1)*Yy + inv_trans(3,2)*(Cbb - 128) + inv_trans(3,3)*(Cr2 - 128);

%% PSNR Calculation

imfinal = cat(3, R3, G3, B3);
se = abs(imNTU - imfinal).^2;
PSNR = 10 * log10(255^2 * 3 * width * height / sum(se(:)))

%% Display Final Image
imNTU = imread('lena.png');      
figure(1);
subplot(121)
imshow(imNTU);
title('Original Image')
fprintf('Original image size is: ')

subplot(122)
imfinal = uint8(cat(3, R3, G3, B3));
imshow(imfinal)
title('Reconstructed Image with RLE')

toc