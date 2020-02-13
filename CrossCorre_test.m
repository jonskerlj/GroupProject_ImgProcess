%% Scanning the whole image to find the best cross correlation match
clear all; close all;
I = imread('Reverberation_test2.jpg');

gray_I = rgb2gray(I);

%gray(314:360,230:240) = 0;

[row_tot, col_tot] = size(gray_I);

small_row = floor(row_tot/15);
small_col = floor(col_tot/3);

%slice = zeros(small_row, small_col, 20*3);
count = 1;
for i=1:15
    for j = 1:3
        if (i == 1) & (j == 1)
            slice(:,:,count) = gray_I(1:small_row, 1:small_col);
            count = count + 1;
        elseif (i == 1)   
            slice(:,:,count) = gray_I(1:small_row, (j-1)*small_col+1:j*small_col);
            count = count + 1;
        elseif (j == 1)   
            slice(:,:,count) = gray_I((i-1)*small_row+1:i*small_row, 1:small_col);
            count = count + 1;
        else
            slice(:,:,count) = gray_I((i-1)*small_row+1:i*small_row, (j-1)*small_col+1:j*small_col);
            count = count + 1;
        end
        
    end
end

figure;
montage(slice)

%% Correlation between slices and original image
%correlation_out = zeros(row_tot,col_tot, 20*3);

good_correlations = [];

for i = 1:size(slice,3)
    sample = slice(:,:,i);
    correlation_out(:,:,i)= normxcorr2e(sample,gray_I,'same');
      
end
figure;
for i = 1:size(correlation_out, 3)
   subplot(1,2,1); imshow(slice(:,:,i))
    
   test(:,:,i) = correlation_out(:,:,i)>0.45;
   subplot(1,2,2); imshow(test(:,:,i));
   
   regions = regionprops(test(:,:,i));
   
   counter = 0;
   areas = zeros(size(regions,1),1);
   % can filter out small areas as well before testing centroids
   for n = 1:size(regions,1)
        areas(n,1) = regions(n).Area;
   end
   small_area = areas<50;
   regions(small_area) = [];
   
   % Logic test if centroids are within +- 10 pixels in x-directions
   % Using assumption that artefact appears at the same x location
   if size(regions,2)>0
       for j = 1:size(regions,1)
            for k = 1:size(regions,1)
                if abs(regions(j).Centroid(1)-regions(k).Centroid(1))<10
                    counter = counter + 1;
                end
            end
       end
   end
   % Have to subtract with the number of areas because the loop compares 
   % the one element with itself for each iteration of the bigger loop
   counter = counter - size(regions,1);
   
   % 16 = number of repetitions^2 (4 aretfacts)
   if counter>16
       good_correlations = [good_correlations i];
   end
end

%% Eliminate bad correlations
good_samples = test(:,:,good_correlations);


for i = 1:size(good_samples,3)
    figure;
    imagesc(gray_I); colormap(gray(128)); hold on;
    
    % filter out small areas
    regions = regionprops(good_samples(:,:,i));
    areas = zeros(size(regions,1),1);
    for n = 1:size(regions,1)
        areas(n,1) = regions(n).Area;
    end
    small_area = areas<50;
    regions(small_area) = [];
    
    %display rectangles around artefacts for each "good" correlation
    for j=1:size(regions,1)
        x = regions(j).BoundingBox(1);
        y = regions(j).BoundingBox(2);
        width = regions(j).BoundingBox(3);
        height = regions(j).BoundingBox(4);
        h(j, 1)= rectangle('Position',[x y width height]);
        set(h(j),'EdgeColor',[1 0 0]);
    end
   
end



%% Temporary location finder - needs to be improved
close all;
width = small_col;
height = small_row;

figure;
imagesc(I);
hold on;
no = 1
for i = good_correlations(1:3)
    modulus = mod(i,3);
    if modulus == 0
        y = 20*i/3-20+i/3-1;
        x = round(2*col_tot/3)+1;
    elseif modulus == 1
        y = 20*floor(i/3)+floor(i/3);
        x = 1;
    else
        y = 20*floor(i/3)+floor(i/3);
        x = round(col_tot/3)+1;
    end
    h(no, 1)= rectangle('Position',[x y width height]);
    set(h(no),'EdgeColor',[1 0 0]); % Hint: use you colourmap
    no = no + 1;
end
