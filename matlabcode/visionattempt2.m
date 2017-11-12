%%visionattemp2
%this script loads in an RGB input image with a test banner, converts it to HSV,
%then slices the image into what it believes to be the red, green and blue of 
%the banner. Then it attempts to find the corners and from that, an affine 
%transform (it currently does not take into consideration the camera matrix, 
%which is necessary to get any useful information from the tag image).

Argb = imread('/home/fworg64/seniorvision/banner1.png');

dims = size(Argb);

Ahsv = uint8(255*rgb2hsv(Argb));

Hmap = zeros(256,3); %%approximate Hue to RGB map for colorbar
for u = 0:255;
  if (u >=0 && u <=255/3) %reds are close to 0 deg on the polar Hue circle
    Hmap(u+1,1) = (255/3 - u)*(3/255);
  end
  if (u >= 255*2/3)
    Hmap(u+1, 1) = (u - 255*2/3)*(3/255);
  end
  
  if(u <= 255*2/3) %greeen is close to 120 deg and ranges from 0 to 240
    Hmap(u+1, 2) = (255/3 - abs(u - 255/3))*(3/255);
  end
  
  if(u >= 255/3) %blue is close to 240 deg and starts at 120 and ends at 360/0
    Hmap(u+1,3) = (255/3 - abs(u - 255*2/3))*(3/255);
  end
end

filtersize = 7;
lowpassfilter = 1/(filtersize^2) * ones(filtersize,filtersize);

AHuesFilt = uint8(conv2(Ahsv(:,:,1), lowpassfilter, 'same'));
ASatFilt = uint8(conv2(Ahsv(:,:,2), lowpassfilter, 'same'));
AValFilt = uint8(conv2(Ahsv(:,:,3), lowpassfilter, 'same'));

%should want range of hues, what color is it?
%%red should be close to 0 and 255
%%green should be close to 255/3
%%blue should be close to 255*2/3
maxRed = 20; %less than this, red is special
minRed = 235; %grater than this
maxGreen = 130;
minGreen = 55;
maxBlue = 210;
minBlue = 130;

% minnimum value of saturation, how 'deep' the color is
%%looks like these sheets of construction paper are very saturated, lets go for 245 and up
minSat = 200;

%and min value, how 'not dark?' it is
%%need to have a minimum value, or else the hue and saturation value are garbage
minVal = 30;

%strategy:
%turn saturation into binary mask
%turn value into binary mask
%sort masked hues image into red green and blue
%apply masks to each channeled image

satMask = zeros(dims(1), dims(2));

for r = 1:dims(1) %rows
  for c = 1:dims(2) %cols
    if (ASatFilt(r,c) > minSat)
      satMask(r,c) = 1;
    end
  end
end

valMask = zeros(dims(1), dims(2));

for r = 1:dims(1) %rows
  for c = 1:dims(2) %cols
    if (AValFilt(r,c) > minVal)
      valMask(r,c) = 1;
    end
  end
end


%AHuesFilt = AHuesFilt .* satMask;

redChan = zeros(dims(1), dims(2));
greenChan = zeros(dims(1), dims(2));
blueChan = zeros(dims(1), dims(2));


for r = 1:dims(1)
  for c = 1:dims(2)
   if (AHuesFilt(r,c) <= maxRed || AHuesFilt(r,c) >= minRed) %red is special
     redChan(r,c) = 127;
   end
   if (AHuesFilt(r,c) >= minGreen && AHuesFilt(r,c) <= maxGreen)
     greenChan(r,c) = 127;
   end
   if (AHuesFilt(r,c) >=minBlue && AHuesFilt(r,c) <= maxBlue)
     blueChan(r,c) = 127;
   end
  end
end

redChan = redChan .* satMask .*valMask;
greenChan = greenChan .* satMask .*valMask;
blueChan = blueChan .* satMask .*valMask;


newImage = zeros(dims(1), dims(2), 3);
newImage(:,:,1) = redChan;
newImage(:,:,2) = greenChan;
newImage(:,:,3) = blueChan;
figure();
image(newImage);

figure();
%ax1 = subplot(1,3,1);
image(AHuesFilt);
%colormap(ax1, Hmap);
colormap(Hmap);
colorbar;
caxis([0,255]);
title ('Hues')

%ax2 = subplot(1,3,2);
figure()
image(ASatFilt);
%colormap(ax2, gray)
colormap(gray)
colorbar;
caxis([0,255]);
title('Sat');

%ax3 = subplot(1,3,3);
figure()
image(AValFilt);
%colormap(ax3, gray)
colormap(gray);
colorbar;
caxis([0,255]);
title('Val');
