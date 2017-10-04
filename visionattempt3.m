%%visionattempt3
%this scripts seeks to demonstrate the capture of a visual fiducial
%marker in an image. First it perfomes a selection through HSV data.
%Second, it extracts the corners of the tag from the selected image.
%Finally, it delivers the transform through a camera matrix to the camera.

%load image
A = imread('banner1.png');
dims = size(A);
Hmap = huesmap();
Ahsv = uint8(255*rgb2hsv(A));
%perfrom HSV selection
%show hue channel masked with selection, lightness and darkness mask

Hues = Ahsv(:,:,1);
%figure();
%subplot(2,2,1)
%dispImage(Hues,'Hues', Hmap);
%%range Hues into desired color bins
%%multiply bins with stauration and value masks

%Sats = Ahsv(:,:,2);
%figure();
%subplot(2,2,2)
%dispImage(Sats,'Sats', gray);

%Vals  =Ahsv(:,:,3);
%figure();
%dispImage(Vals,'Vals', gray);

maxRed = 20; %less than this, red is special
minRed = 235; %grater than this
maxGreen = 130;
minGreen = 40;
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
    if (Sats(r,c) > minSat)
      satMask(r,c) = 1;
    end
  end
end

valMask = zeros(dims(1), dims(2));

for r = 1:dims(1) %rows
  for c = 1:dims(2) %cols
    if (Vals(r,c) > minVal)
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
   if (Hues(r,c) <= maxRed || Hues(r,c) >= minRed) %red is special
     redChan(r,c) = 127;
   end
   if (Hues(r,c) >= minGreen && Hues(r,c) <= maxGreen)
     greenChan(r,c) = 127;
   end
   if (Hues(r,c) >=minBlue && Hues(r,c) <= maxBlue)
     blueChan(r,c) = 127;
   end
  end
end

redChan = redChan .* satMask .*valMask;
greenChan = greenChan .* satMask .*valMask;
blueChan = blueChan .* satMask .*valMask;

figure()
dispImage(redChan, 'Red Thresh', summer);
figure()
dispImage(greenChan, 'Green Thresh', winter);
figure()
dispImage(blueChan, 'Blue Thresh', autumn);
%fill in resulting image as needed
%%regenerative filter?
%%lowpass and threshhold? %isotropic ? %%needs to fill in rectangles
%lets try lowpass
% filtersize = 21;
% lowpassfilter = 1/(filtersize^2) * ones(filtersize,filtersize);
% edgefilter = [1,1,1;
%                 1,-8,1;
%                 1,1,1];
% redChanFilt = (conv2(redChan, lowpassfilter, 'same'));
% greenChanFilt = (conv2(greenChan, lowpassfilter, 'same'));
% blueChanFilt =  conv2(blueChan, lowpassfilter, 'same');
% 
% %rerange
% %(max(max(redChanFilt)))
% redChanFilt = redChanFilt * 255.0/(max(max(redChanFilt)));
% greenChanFilt = greenChanFilt * 255.0/(max(max(greenChanFilt)));
% blueChanFilt = blueChanFilt * 255.0/(max(max(blueChanFilt)));
% %(max(max(redChanFilt)))
% 
% figure()
% dispImage(redChanFilt, 'Red Low', summer);
% figure()
% dispImage(greenChanFilt, 'Green Low', winter);
% figure()
% dispImage(blueChanFilt, 'Blue Low', autumn);

%median select in order to posturize image a bit, this works much better
%than the low pass
medianwindow= [9,9];
redChanMed = medianselect(redChan, medianwindow(1), medianwindow(2));
greenChanMed = medianselect(greenChan, medianwindow(1), medianwindow(2));
blueChanMed = medianselect(blueChan, medianwindow(1), medianwindow(2));
figure()
dispImage(redChanMed, 'Red Med', summer);
figure()
dispImage(greenChanMed, 'Green Med', winter);
figure()
dispImage(blueChanMed, 'Blue Med', autumn);

%find ROI from lowpass on column and row sum
[RedrB,RedcB,RedrE,RedcE] = findsingleROI(redChanMed);
RedRoi = redChanMed(RedrB:RedrE, RedcB:RedcE);
[BluerB,BluecB,BluerE,BluecE] = findsingleROI(blueChanMed);
BlueRoi = blueChanMed(BluerB:BluerE, BluecB:BluecE);
[GreenrB,GreencB,GreenrE,GreencE] = findsingleROI(greenChanMed);
GreenRoi = greenChanMed(GreenrB:GreenrE, GreencB:GreencE);
            
figure()
dispImage(RedRoi, 'Red ROI', summer);
figure()
dispImage(GreenRoi, 'Green ROI', winter);
figure()
dispImage(BlueRoi, 'Blue ROI', autumn);
    
yedgefilter = [3,10,3;
                0,0,0;
                -3,-10,-3];
            
redChanFilt2 = conv2(RedRoi, yedgefilter, 'same');
greenChanFilt2 = conv2(GreenRoi,yedgefilter, 'same');
blueChanFilt2 =  conv2(BlueRoi, yedgefilter, 'same');

xedgefilter = yedgefilter';
redChanFilt3 = conv2(RedRoi, xedgefilter, 'same');
greenChanFilt3 = conv2(GreenRoi,xedgefilter, 'same');
blueChanFilt3 =  conv2(BlueRoi, xedgefilter, 'same');


%rerange
%(max(max(redChanFilt2)))
redChanFilt2 = redChanFilt2 * 255.0/(max(max(redChanFilt2)));
greenChanFilt2 = greenChanFilt2 * 255.0/(max(max(greenChanFilt2)));
blueChanFilt2 = blueChanFilt2 * 255.0/(max(max(blueChanFilt2)));
%(max(max(redChanFilt2)))
redChanFilt3 = redChanFilt3 * 255.0/(max(max(redChanFilt3)));
greenChanFilt3 = greenChanFilt3 * 255.0/(max(max(greenChanFilt3)));
blueChanFilt3 = blueChanFilt3 * 255.0/(max(max(blueChanFilt3)));
%split each square on its own, get transform for it and also a confidance
%level. Make transform a weighted sum of the three based on confidance for
%each one.

reddims = size(redChanFilt2);
greendims = size(greenChanFilt2);
bluedims = size(blueChanFilt2);

%for each square, get best fit line for top bottom left and right
%find 4 intersection points (T+L, B+L, T+R, B+R)
%use square parameters to generate transform to unit
%square/rectangle/whatever

mythresh = 150;
[redposycoords,rednegycoords] = duallythresh(redChanFilt2, mythresh);
[redposxcoords,rednegxcoords] = duallythresh(redChanFilt3, mythresh);

[blueposycoords,bluenegycoords] = duallythresh(blueChanFilt2, mythresh);
[blueposxcoords,bluenegxcoords] = duallythresh(blueChanFilt3, mythresh);

[greenposycoords,greennegycoords] = duallythresh(greenChanFilt2, mythresh);
[greenposxcoords,greennegxcoords] = duallythresh(greenChanFilt3, mythresh);

rcoeffs = polyfit(redposycoords(:,2) + RedcB, redposycoords(:,1) + RedrB,1);
rcoeffs2 = polyfit(rednegycoords(:,2)+ RedcB, rednegycoords(:,1)+ RedrB,1);
rcoeffs3 = polyfit(redposxcoords(:,2)+ RedcB, redposxcoords(:,1)+ RedrB,1);
rcoeffs4 = polyfit(rednegxcoords(:,2)+ RedcB, rednegxcoords(:,1)+ RedrB,1);

%1 and 3 are uppper left
redUpLeft(1) = (rcoeffs3(2) - rcoeffs(1))/(rcoeffs(1) - rcoeffs3(1));
redUpLeft(2) = rcoeffs(1) * redUpLeft(1) + rcoeffs(2);
%1 and 4 are upper right
redUpRight(1) = (rcoeffs4(2) - rcoeffs(1))/(rcoeffs(1) - rcoeffs4(1));
redUpRight(2) = rcoeffs(1) * redUpRight(1) + rcoeffs(2);
%2 and 3 are lower left
redDownLeft(1) = (rcoeffs3(2) - rcoeffs2(1))/(rcoeffs2(1) - rcoeffs3(1));
redDownLeft(2) = rcoeffs2(1) * redDownLeft(1) + rcoeffs2(2);
%2 and 4 are lower right
redDownRight(1) = (rcoeffs4(2) - rcoeffs2(1))/(rcoeffs2(1) - rcoeffs4(1));
redDownRight(2) = rcoeffs2(1) * redDownRight(1) + rcoeffs2(2);

figure();
imshow(A)
hold on
plot(redUpLeft(1), redUpLeft(2),'r<')
plot(redUpRight(1), redUpRight(2),'r^')
plot(redDownLeft(1), redDownLeft(2),'rv')
plot(redDownRight(1), redDownRight(2),'r>')
hold off



%minx = min(redposycoords(:,1)) +RedcB;maxx = max(redposycoords(:,1)) +RedcB;
%miny = coeffs(1)*minx + coeffs(2)+ RedrB;maxy = coeffs(1)*maxx  +coeffs(2) +RedrB;

%figure()
%plot([minx, maxx], [-miny, -maxy]);
%axis([0,dims(1),-dims(2),0]);



%threshhold them
%thresher = 1;
% for u = 1:dims(1)
%     for v =1:dims(2)
%         if (redChanFilt2(u,v) < thresher)
%             redChanFilt2(u,v) =0;
%         end
%         if (greenChanFilt2(u,v) < thresher)
%             greenChanFilt2(u,v) =0;
%         end
%         if (blueChanFilt2(u,v) < thresher)
%             blueChanFilt2(u,v) =0;
%         end
%     end
% end
figure()
dispImage(redChanFilt2, 'Red Filt Y', summer);
figure()
dispImage(greenChanFilt2, 'Green Filt Y', winter);
figure()
dispImage(blueChanFilt2, 'Blue Filt Y', autumn);
figure()
dispImage(redChanFilt3, 'Red Filt X', summer);
figure()
dispImage(greenChanFilt3, 'Green Filt X', winter);
figure()
dispImage(blueChanFilt3, 'Blue Filt X', autumn);

%find corners of tag

%form tag transform matrix

%form camera transform matrix

%display final transform matrix from camera to tag (or inverse)