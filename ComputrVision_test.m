%% Testing computer vision toolbox
clear all; close all;

USImage = rgb2gray(imread('Reverb.png'));
Arte = rgb2gray(imread('Reverb_arte.png'));

figure(1);
subplot(1,2,1);
imshow(USImage); title('Original US image');
subplot(1,2,2);
imshow(Arte); title('Original Artefact image')

USPoints = detectSURFFeatures(USImage);
ArtePoints = detectSURFFeatures(Arte);
figure(2);
subplot(1,2,1)
imshow(USImage);title('100 Strongest Feature Points in US image');
hold on;
plot(selectStrongest(USPoints,100));
subplot(1,2,2)
imshow(Arte);title('100 Strongest Feature Points in the artefact');
hold on;
plot(selectStrongest(ArtePoints,100));

[ArteFeatures, ArtePoints] = extractFeatures(Arte, ArtePoints);
[USFeatures, USPoints] = extractFeatures(USImage, USPoints);

ArtePairs = matchFeatures(ArteFeatures, USFeatures);

%Display putatively matched features
matchedArtePoints = ArtePoints(ArtePairs(:, 1), :);
matchedUSPoints = USPoints(ArtePairs(:, 2), :);
figure(3);
showMatchedFeatures(Arte, USImage, matchedArtePoints, ...
    matchedUSPoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%Locate object in the scene usin gPutative Matches
[tform, inlierArtePoints, inlierUSPoints] = ...
    estimateGeometricTransform(matchedArtePoints, matchedUSPoints, 'affine');

figure(4)
showMatchedFeatures(Arte, USImage, inlierArtePoints, ...
    inlierUSPoints, 'montage');
title('Matched Points (Inliers Only)');

ArtePolygon = [1, 1;...                           % top-left
        size(Arte, 2), 1;...                 % top-right
        size(Arte, 2), size(Arte, 1);... % bottom-right
        1, size(Arte, 1);...                 % bottom-left
        1, 1]; 
    
 newArtePolygon = transformPointsForward(tform, ArtePolygon);
 
 figure(5);
 imshow(USImage);
 hold on;
 line(newArtePolygon(:,1), newArtePolygon(:,2), 'Color', 'y');
 title('Detected Artefact')
 
 %Detect another one
 Arte2 = rgb2gray(imread('Reverb_arte2.png'));
 Arte2Points = detectSURFFeatures(Arte2);
 
[Arte2Features, Arte2Points] = extractFeatures(Arte2, Arte2Points);

Arte2Pairs = matchFeatures(Arte2Features, USFeatures);

matchedArte2Points = Arte2Points(Arte2Pairs(:, 1), :);
matchedUSPoints2 = USPoints(Arte2Pairs(:, 2), :);

[tform, inlierArte2Points, inlierUSPoints2] = ...
    estimateGeometricTransform(matchedArte2Points, matchedUSPoints2, 'affine');

Arte2Polygon = [1, 1;...                           % top-left
        size(Arte2, 2), 1;...                 % top-right
        size(Arte2, 2), size(Arte2, 1);... % bottom-right
        1, size(Arte2, 1);...                 % bottom-left
        1, 1]; 

newArte2Polygon = transformPointsForward(tform, Arte2Polygon);

figure(6)
imshow(USImage);
hold on;
line(newArtePolygon(:,1), newArtePolygon(:,2), 'Color', 'y');
line(newArte2Polygon(:,1), newArte2Polygon(:,2), 'Color', 'g');

title('Detected Artefact')