# 🖼️ JPEG-like Image Compression using DCT in MATLAB

This project implements a simplified JPEG-like image compression pipeline in MATLAB. It includes RGB to YCbCr conversion, 4:2:0 chroma subsampling, block-wise DCT transform, custom quantization, run-length encoding (RLE), bitstream generation, and decompression with full reconstruction and PSNR analysis.

---

## 🔧 Features

- ✅ RGB to YCbCr conversion using transformation matrix
- ✅ 4:2:0 chroma subsampling (horizontal and vertical)
- ✅ DCT (Discrete Cosine Transform) based compression (optional Haar/Walsh)
- ✅ Separate quantization matrices for luminance (Y) and chrominance (Cb, Cr)
- ✅ Custom Run-Length Encoding (RLE) and decoding
- ✅ Bitstream generation from quantized data
- ✅ Inverse quantization and 2D inverse DCT
- ✅ YCbCr to RGB conversion with full image reconstruction
- ✅ PSNR and Compression Ratio calculation

---

## 📂 Project Structure

| Section | Functionality |
|--------|----------------|
| `RGB to YCbCr` | Uses custom transformation matrix |
| `4:2:0 Subsampling` | Downsamples chroma planes Cb and Cr |
| `DCT Compression` | Applies blockwise 8x8 DCT to Y, Cb, Cr |
| `Quantization` | Uses separate quantization matrices Qy and Qc |
| `Bitstream` | Converts int8 matrix → uint8 → binary bitstream |
| `RLE` | Applies run-length encoding for each channel |
| `Decompression` | Performs reverse RLE, inverse quantization and DCT |
| `Evaluation` | Computes PSNR and compression ratio |

---

## 📸 Output

- `Original Image`: Displayed alongside
- `Reconstructed Image`: After decompression and conversion
- `PSNR`: Peak Signal-to-Noise Ratio printed to console
- `Compression Ratio`: Ratio of original image size to encoded bitstream size

---

## 📊 Results (Example Output)

| Metric                | Value (example) |
|-----------------------|-----------------|
| Compression Ratio     | ~11.56:1        |
| Compressed Size       | ~24 KB          |
| PSNR                  | ~31.84 dB       |

---

## 🧪 Requirements

- MATLAB (R2020a or newer recommended)
- `lena.png` image file in the same directory
- Functions:
  - `rlc_encode()`, `rlc_decode()` – for custom run-length encoding
  - `bitstream_to_vars()` – converts binary bitstream to int8 matrix
  - `four_two_zero_recovery()` – (you should define this) to upsample Cb/Cr

---

## 📝 Notes

- You can optionally switch from DCT to Haar/Walsh by modifying the transform:
  ```matlab
  Cf = dctmtx(8);          % Default: DCT
  %Cf = haarmtx(8);        % Optional: Haar
  %Cf = (1/sqrt(8)) * walsh(8); % Optional: Walsh
  
---
  
## 📉 Compression Insights

- **4:2:0 Subsampling**: Reduces chrominance resolution by sampling Cb and Cr once for every 2×2 block of pixels, reducing data by 50% for each channel.
- **DCT (Discrete Cosine Transform)**: Converts 8×8 image blocks into frequency components; most energy concentrates in the top-left corner.
- **Quantization**: Uses separate quantization matrices for luminance (Y) and chrominance (Cb, Cr) to discard less significant high-frequency details.
- **Run-Length Encoding (RLE)**: Efficiently encodes long sequences of identical bits (usually zeros), common in high-frequency DCT coefficients.
- **Bitstream Construction**: Transformed and quantized values are cast to bytes, converted to binary strings, and compressed into bitstreams via RLE.
- **Compression Ratio**: Defined as the ratio between the original bit rate (24 bits/pixel for RGB) and the total size of the encoded bitstreams.
- **Visual Fidelity**: Despite being lossy, this pipeline retains good perceptual quality at reasonable compression rates (e.g., ~10:1).

---

## 📐 PSNR (Peak Signal-to-Noise Ratio)

Used to measure the quality of the reconstructed image relative to the original.

### Formula:

![ChatGPT Image Jul 1, 2025, 05_35_52 PM](https://github.com/user-attachments/assets/ba54c8c6-3fa7-401a-ac9c-5182f7a25c25)

---

### Terms:
- `255`: Maximum pixel value in 8-bit images
- `3`: Number of color channels (R, G, B)
- `width × height`: Resolution of the image
- `sum(...)`: Total squared error between the original and decompressed image pixels

### Interpretation:
- **Higher PSNR = better quality**
- PSNR > 30 dB is considered visually acceptable
- PSNR > 40 dB indicates high-fidelity reconstruction

---

