clc; clear; close all;

%% Read sinusoid input
fid = fopen('sinusoid_1024_input.txt','r');
C = textscan(fid,'%s %s');
fclose(fid);

hex_data = C{1};        % first column contains the signal
N = 1024;

%% Convert hex to signed 16-bit
x_uint = uint16(hex2dec(erase(hex_data,'0x')));
x = double(typecast(x_uint,'int16'));

x = x(1:N);             % use only 1024 samples

%% Compute FFT
X = fft(x,1024);
X = fftshift(X);

mag = abs(X);
mag = mag / max(mag);

%% Plot spectrum
figure;
plot(20*log10(mag+eps),'LineWidth',1.5);
grid on;
title('FFT of Input Sine Wave (1024-point)');
xlabel('FFT Bin');
ylabel('Magnitude (dB)');

%% Read FFT output
data = readmatrix('fft_comparison.txt');

X_out = data(:,1) + 1j*data(:,2);

mag_out = abs(X_out);
mag_out = mag_out / max(mag_out);

%% Plot provided FFT
figure;
plot(20*log10(mag_out+eps),'LineWidth',1.5);
grid on;
title('Provided 1024-Point FFT Output');
xlabel('FFT Bin');
ylabel('Magnitude (dB)');