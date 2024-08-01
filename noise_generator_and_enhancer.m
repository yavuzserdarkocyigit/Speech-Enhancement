rng(10)
fn = 'TIMIT_ver110train_0001.raw'
fid = fopen(fn,'rb');
s = fread(fid,'short');

n = randn(size(s));

Ps = sum( s.^2);
Pn = sum (n.^2);

snr = 10*log10(Ps/Pn);

snr = 0;
alpha = sqrt((Ps/Pn) * 10^(-snr/10))
y = s + alpha*n;

y = 0.9*y / (max(abs(y)));
audiowrite('noisy_newW.wav',y,16000)
%s = 0.9*s / (max(abs(s)));
%audiowrite('TIMIT_new.wav',y,16000)

% use the periodogram method to compute power spectrum of
% noise
wL = 320;
fR = 160;
win = hamming(320);
Sn = zeros(320, 1);
numFramesForNoiseEst = floor(300e-3 * 16000 / fR);
for i = 1:numFramesForNoiseEst
    seg = y(1 + (i-1)*fR:wL + (i-1)*fR) .* win;

    Sn = Sn + (abs(fft(seg)).^2) / numFramesForNoiseEst;
end
osf = 2; % oversubtraction factori

    % do spectral subtraction and enhance speech
    numFr = floor(length(y) / fR) - 1;
    s_hat = zeros(size(y));
    
    for i = 1:numFr
        seg = y(1 + (i-1)*fR:wL + (i-1)*fR) .* win;
    
        Ms = sqrt( max( abs(fft(seg)).^2 - osf*Sn, 1e-5) );
        Ps = angle(fft(seg));
    
        seg_s = real( ifft( Ms .* exp(1i * Ps) ) );
    
        % overlap-add (OLA) synthesis
        s_hat(1 + (i-1)*fR:wL + (i-1)*fR) = s_hat(1 + (i-1)*fR:wL + (i-1)*fR) + ...
            seg_s;
    end
       mse = mean((s-s_hat).^2);
  % y = 0.9*y/ (max(abs(y)));
 %audiowrite('noisy_last.wav',y,16000)
 s_hat = 0.9*s_hat/ (max(abs(s_hat)));
 audiowrite('my_enhanced.wav',s_hat,16000)