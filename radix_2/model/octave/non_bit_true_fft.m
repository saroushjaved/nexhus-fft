clear; clc;
q15 = 32768;

u = uint16(hex2dec([ ...
    "0000"
    "5A82"
    "7FFF"
    "5A82"
    "0000"
    "A57E"
    "8000"
    "A57E"
]));
xr = typecast(u,'int16');
x  = double(xr)/q15;

X_scaled = fft(x,8)/8;                 % match your stage scaling

% quantize to Q15 int16 (round-to-nearest, saturate)
qr = int32(round(real(X_scaled)*q15));
qi = int32(round(imag(X_scaled)*q15));
qr = max(min(qr, 32767), -32768);
qi = max(min(qi, 32767), -32768);
Yr = int16(qr); Yi = int16(qi);

fprintf("Expected Q15 outputs (hex):\n");
for k = 1:8
    fprintf("X[%d] = 0x%04X + j0x%04X\n", k-1, typecast(Yr(k),'uint16'), typecast(Yi(k),'uint16'));
end
