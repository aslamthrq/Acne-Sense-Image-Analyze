%Resize Citra
citra = imread('3.png');
    % Ukuran Citra Semula
[bar, kol, dlm] = size(citra);

figure; imshow(citra);title('Citra Asli');

if (bar > kol)
    maxLength = bar;
    if (maxLength >= 480);
        citra = imresize(citra, [480 NaN]);
    end;
else
    maxLength = kol;
    if (maxLength >= 480);
        citra = imresize(citra, [NaN 480]);
    end;
end;

%Segmentasi Kulit

citraG = rgb2gray(citra);
level = graythresh(citraG);

citraB = im2bw(citraG, level);
citraB = imfill(citraB, 'holes');


citraCC = bwconncomp(citraB);
citraL = labelmatrix(citraCC);

figure; imshow(citraL);title('Citra Asli');

    % Ukuran Citra Setelah Resize
[bar, kol, dlm] = size(citra);
    % Cari Connected Component Terbanyak
terluas = 0;
for i = 1 : length(citraCC.PixelIdxList)
    if (length(citraCC.PixelIdxList{i})) > terluas
        terluas = length(citraCC.PixelIdxList{i});
        index = i;
    end;
end;

    % Ambil Label
wajah = uint8(zeros(bar, kol, dlm));
for i = 1 : bar
    for j = 1 : kol
        if citraL(i, j) == index;
            wajah(i, j, :) = citra(i, j, :);
        end;
    end;
end;

%Perbaikan Citra
    % Sharpening
wajahG = rgb2gray(wajah);
h = fspecial('log', [9 9], 2);
m = imfilter(wajahG, h, 'circular', 'same', 'conv');
    
    % Labeling
candidate = logical(m);
[labeledCandidate, numberOfCandidates] = bwlabel(candidate, 8);

%Ekstrasi Ciri Luas dan Bentuk

    % Eliminasi Berdasarkan Luas Dan Bentuk
blobMeasurements = regionprops(labeledCandidate, 'Area', 'Eccentricity');

allArea = [blobMeasurements.Area];
allEccentricity = [blobMeasurements.Eccentricity];

meanArea = mean(allArea);
stdArea = std(allArea);

indexBlob = find(allArea >= 24 & allArea <= (meanArea + stdArea) & allEccentricity < 0.81);

ambilBlob = ismember(labeledCandidate, indexBlob);
blobBW = ambilBlob > 0;
[labeledBlob, numberOfBlobs] = bwlabel(blobBW);

%Ekstrasi Ciri Warna
    % Eliminasi Berdasarkan Warna
red = citra(:, :, 1);
green = citra(:, :, 2);
blue = citra(:, :, 3);

r = regionprops(labeledBlob, red, 'MeanIntensity');
g = regionprops(labeledBlob, green, 'MeanIntensity');
b = regionprops(labeledBlob, blue, 'MeanIntensity');

fiturR = [r.MeanIntensity]';
fiturG = [g.MeanIntensity]';
fiturB = [b.MeanIntensity]';
fitur = [fiturR fiturG fiturB];

meanR = mean(fiturR);
meanG = mean(fiturG);
meanB = mean(fiturB);
stdR = std(fiturR);
stdG = std(fiturG);
stdB = std(fiturB);

indexJerawat = [];
for i = 1 : numberOfBlobs
    if(fiturR(i) >= (meanR-stdR*1.75) && fiturR(i) <= (meanR+stdR*1.75) && fiturG(i) >= (meanG-stdG*1.75) && fiturG(i) <= (meanG+stdG*1.75) && fiturB(i) >= (meanB-stdB*1.75) && fiturB(i) <= (meanB+stdB*1.75))indexJerawat = [indexJerawat i];
    end;
end;

jumlahJerawat = length(index);
jerawatBW = ismember(labeledBlob, indexJerawat);

%Marking

jerawatEdge = edge(jerawatBW, 'canny');
hasil = citra;

for i = 1 : bar
    for j = 1 : kol
        if jerawatEdge(i, j) == 1;
             hasil(i, j, 1) = 0;
             hasil(i, j, 2) = 255;
             hasil(i, j, 3) = 0;
        end;
    end;
end;

hasil = uint8(hasil);
imshow(hasil);