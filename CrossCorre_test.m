%% Scanning the whole image to find the best cross correlation match
clear all; close all;
I = imread('Reverb_model.png');

gray = rgb2gray(I);

%gray(314:360,230:240) = 0;

[row_tot, col_tot] = size(gray);

small_row = floor(row_tot/15);
small_col = floor(col_tot/3);

%slice = zeros(small_row, small_col, 20*3);
count = 1;
for i=1:15
    for j = 1:3
        if (i == 1) & (j == 1)
            slice(:,:,count) = gray(1:small_row, 1:small_col);
            count = count + 1;
        elseif (i == 1)   
            slice(:,:,count) = gray(1:small_row, (j-1)*small_col+1:j*small_col);
            count = count + 1;
        elseif (j == 1)   
            slice(:,:,count) = gray((i-1)*small_row+1:i*small_row, 1:small_col);
            count = count + 1;
        else
            slice(:,:,count) = gray((i-1)*small_row+1:i*small_row, (j-1)*small_col+1:j*small_col);
            count = count + 1;
        end
        
    end
end

figure;
montage(slice)

%% Correlation between slices and original image
%correlation_out = zeros(row_tot,col_tot, 20*3);

good_correlations = []

for i = 1:size(slice,3)
    sample = slice(:,:,i);
    correlation_out(:,:,i)= normxcorr2(sample,gray);
      
end
figure;
for i = 1:size(correlation_out, 3)
   subplot(1,2,1); imshow(slice(:,:,i))
    
   test(:,:,i) = correlation_out(:,:,i)>0.4;
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
   % the one element with itself for each iteration of bigger loop
   counter = counter - size(regions,1);
   
   % 16 = number of repetitions^2 (4 aretfacts)
   if counter>16
       good_correlations = [good_correlations i];
   end
end

%% 
clear artefacts;
artefacts = [];
% for i = good_correlations
%     artefacts = regionprops(test(:,:,i));
%     
%     areas = zeros(size(regions,1),1);
%     for n = 1:size(regions,1)
%         areas(n,1) = regions(n).Area;
%    end
%    small_area = areas<50;
%    artefacts(small_area) = [];
% end

% select the second element of good correlation and find the artefacts
arte = regionprops(test(:,:,good_correlations(2)));

figure(5);
imagesc(I);
hold on;
% shifted for some reason - have to fix
for i=1:size(arte,1)
    h(i, 1)= rectangle('Position',[round(arte(i).BoundingBox(1)) round(arte(i).BoundingBox(2)) ...
        round(arte(i).BoundingBox(3)) round(arte(i).BoundingBox(4))]);
    set(h(i),'EdgeColor',[1 0 0]); % Hint: use you colourmap

end
   
