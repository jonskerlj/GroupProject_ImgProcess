clear all; close all;
% import and display image
I = imread('test_img.jpg');
figure(1)
imshow(I)

gray_I = rgb2gray(I);

meanIntensityValue = mean2(gray_I);

% edge detection
BW1 = edge(gray_I, 'Sobel');
BW2 = edge(gray_I, 'Prewitt');
BW3 = edge(gray_I, 'Roberts');
BW4 = edge(gray_I, 'log');
BW5 = edge(gray_I, 'zerocross');
BW6 = edge(gray_I, 'Canny');
BW7 = edge(gray_I, 'approxcanny');


figure(2)
subplot(2,4,1);imshow(BW1);title('Sobel');
subplot(2,4,2);imshow(BW2);title('Prewitt');
subplot(2,4,3);imshow(BW3);title('Roberts');
subplot(2,4,4);imshow(BW4);title('log');
subplot(2,4,5);imshow(BW5);title('zerocross');
subplot(2,4,6);imshow(BW6);title('Canny');
subplot(2,4,7);imshow(BW7);title('approxcanny');


% test with intensities
[row col] = size(gray_I);
for i=1:row
    for k=1:col
        if gray_I(i,k)>180
            gray_I(i,k) = 2*gray_I(i,k);
        end
    end
end

figure(3)
imshow(gray_I)


%% Testing 2d fast fourier transform
Y = fft2(gray_I);

figure(3)
imagesc(abs(fftshift(Y)))