clear; clc;

% ---------- helpers ----------
sat16 = @(x) int16(max(min(int32(x), 32767), -32768));

add_sat_s1 = @(a,b) sat16( bitshift(int32(a) + int32(b), -1) );
sub_sat_s1 = @(a,b) sat16( bitshift(int32(a) - int32(b), -1) );

RND = int32(bitshift(1,14));   % 2^14 for rounding before >>15

% Correct way to build signed Q15 from hex text
q15s = @(h) typecast(uint16(hex2dec(h)), 'int16');

% Q15 complex multiply with rounding + saturation
cmul_q15 = @(ar,ai, br,bi) deal( ...
    sat16( bitshift(int32(ar).*int32(br) - int32(ai).*int32(bi) + RND, -15) ), ...
    sat16( bitshift(int32(ar).*int32(bi) + int32(ai).*int32(br) + RND, -15) ) );

% ---------- twiddles (Q15, exactly as your C++) ----------
W4 = int16([ ...
    q15s('7FFF') q15s('0000'); ...
    q15s('0000') q15s('8000'); ...  % -j (imag = -32768)
    q15s('8000') q15s('0000'); ...
    q15s('0000') q15s('7FFF') ...
]);

W8 = int16([ ...
    q15s('7FFF') q15s('0000'); ...
    q15s('5A82') q15s('A57E'); ...
    q15s('0000') q15s('8000'); ...
    q15s('A57E') q15s('A57E'); ...
    q15s('8000') q15s('0000'); ...
    q15s('A57E') q15s('5A82'); ...
    q15s('0000') q15s('7FFF'); ...
    q15s('5A82') q15s('5A82') ...
]);

% ---------- input from hex, force signed int16 ----------
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
xi = int16(zeros(8,1));

% ---------- bit reverse (same algorithm as your C++) ----------
N = 8;
j = uint32(0);
for i = uint32(0):uint32(N-1)
    if i < j
        ii = double(i)+1; jj = double(j)+1;
        [xr(ii), xr(jj)] = deal(xr(jj), xr(ii));
        [xi(ii), xi(jj)] = deal(xi(jj), xi(ii));
    end
    bit = bitshift(uint32(N), -1);
    while bitand(j, bit)
        j = bitxor(j, bit);
        bit = bitshift(bit, -1);
    end
    j = bitxor(j, bit);
end

% ---------- Stage 1: 2-pt butterflies (scaled) ----------
for i = 1:2:8
    aR = xr(i);   aI = xi(i);
    bR = xr(i+1); bI = xi(i+1);

    xr(i)   = add_sat_s1(aR, bR);
    xi(i)   = add_sat_s1(aI, bI);
    xr(i+1) = sub_sat_s1(aR, bR);
    xi(i+1) = sub_sat_s1(aI, bI);
end

% ---------- Stage 2: 4-pt FFT blocks ----------
for base = 1:4:8
    E0R=xr(base);   E0I=xi(base);
    E1R=xr(base+1); E1I=xi(base+1);
    O0R=xr(base+2); O0I=xi(base+2);
    O1R=xr(base+3); O1I=xi(base+3);

    [t0R,t0I] = cmul_q15(O0R,O0I, W4(1,1),W4(1,2));   % W4^0
    [t1R,t1I] = cmul_q15(O1R,O1I, W4(2,1),W4(2,2));   % W4^1

    xr(base)   = add_sat_s1(E0R, t0R);  xi(base)   = add_sat_s1(E0I, t0I);
    xr(base+2) = sub_sat_s1(E0R, t0R);  xi(base+2) = sub_sat_s1(E0I, t0I);

    xr(base+1) = add_sat_s1(E1R, t1R);  xi(base+1) = add_sat_s1(E1I, t1I);
    xr(base+3) = sub_sat_s1(E1R, t1R);  xi(base+3) = sub_sat_s1(E1I, t1I);
end

% ---------- Stage 3: 8-pt combine ----------
E_R = xr(1:4); E_I = xi(1:4);
O_R = xr(5:8); O_I = xi(5:8);

for k = 0:3
    [tR,tI] = cmul_q15(O_R(k+1), O_I(k+1), W8(k+1,1), W8(k+1,2));

    xr(k+1) = add_sat_s1(E_R(k+1), tR);
    xi(k+1) = add_sat_s1(E_I(k+1), tI);

    xr(k+5) = sub_sat_s1(E_R(k+1), tR);
    xi(k+5) = sub_sat_s1(E_I(k+1), tI);
end

% ---------- print hex + float ----------
q15 = 32768;
fprintf("Bit-true MATLAB model (should match your C++):\n");
for k = 1:8
    fprintf("X[%d] = 0x%04X + j0x%04X   (%.6f + j%.6f)\n", ...
        k-1, typecast(xr(k),'uint16'), typecast(xi(k),'uint16'), ...
        double(xr(k))/q15, double(xi(k))/q15);
end
