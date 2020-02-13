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
        if gray_I(i,k)>200
            gray_I(i,k) = 2*gray_I(i,k);
        end
    end
end

figure(3)
histogram(gray_I);

BW_orig = gray_I>254;
BW = BW_orig;
BW(1:round(size(BW,1)/2),1:round(size(BW,2))) = 0;
figure(4);
imagesc(BW); colormap(gray(256));

%Finding bright regions
Regions = regionprops(BW);
big_Area = 0;
index = 1;
%Location the biggest one, i.e. enhancement artefact
%Can add check if area is a lot bigger if there are multiple enhancement
%artefacts
for i = 1:size(Regions,1)
    if big_Area<Regions(i).Area
        big_Area = Regions(i).Area;
        index = i;
    end     
end

for i = 1:size(Regions,1)
    not_enhancement(i,1) = Regions(i).Area<big_Area; 
end

Regions(not_enhancement) = [];

%Plot rectangle for one artefact
figure(5)
imagesc(I);
h= rectangle('Position',[round(Regions(1).BoundingBox(1)) round(Regions(1).BoundingBox(2)) ...
    round(Regions(1).BoundingBox(3)) round(Regions(1).BoundingBox(4))]);
set(h,'EdgeColor',[1 0 0]); % Hint: use you colourmap

%Modifying binary image to just artefact
BW_modified = BW;

%in row(i.e. x) direction 
BW_modified(:,1:round(Regions(1).BoundingBox(1)))=0;
BW_modified(:,round(Regions(1).BoundingBox(1)+Regions(1).BoundingBox(3)):size(BW_modified,2))=0;

%in column (i.e. y) direction
BW_modified(1:round(Regions(1).BoundingBox(2)),:)=0;
BW_modified((round(Regions(1).BoundingBox(2))+Regions(1).BoundingBox(3)):size(BW_modified,1),:)=0;

figure(6)
imagesc(BW_modified);colormap(gray(256));

% Displaying original image and image wiht rectangle
figure(7)
subplot(1,2,1);imagesc(I);colormap(gray(256));title('Original Image')
subplot(1,2,2);imagesc(I);
h= rectangle('Position',[round(Regions(1).BoundingBox(1)) round(Regions(1).BoundingBox(2)) ...
    round(Regions(1).BoundingBox(3)) round(Regions(1).BoundingBox(4))]);
set(h,'EdgeColor',[1 0 0]);title('Artefact detected')

% Display binary images through out the process
figure(8);
subplot(1,3,1); imagesc(BW_orig); colormap(gray(256)); title('Initial binary image');
subplot(1,3,2); imagesc(BW);colormap(gray(256)); title('Filtering out top part of image')
subplot(1,3,3); imagesc(BW_modified);colormap(gray(256));title('Locating the artefact');

%% Testing regionfill
low_x = round(Regions(1).BoundingBox(1));
high_x = round(Regions(1).BoundingBox(1) + Regions(1).BoundingBox(3));
low_y = round(Regions(1).BoundingBox(2));
high_y = round(Regions(1).BoundingBox(2) + Regions(1).BoundingBox(4));

x = [low_x high_x high_x low_x];
y = [low_y low_y high_y high_y];

% x = [0 250 250 0];
% y = [0 0 500 500];

J = regionfill(gray_I, x,y);

figure
subplot(1,2,1)
imshow(I)
title('Original image')
subplot(1,2,2)
imshow(J)
title('Image without artefact')