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
end

%% 
