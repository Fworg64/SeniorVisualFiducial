%visionattemp4

%strategy
%find ROI using LUT on RBG image to select 
%Red green and blue
%chanells mask
%load image
A = imread('testimages\rawdiffR165.jpg');
%results
dims = size(A);
Hmap = huesmap();
Ahsv = uint8(255*rgb2hsv(A));
figure();
dispImage(Ahsv(:,:,1),'Hues',Hmap );
%So for any RGB value with the right HSV, it would go into
%a bin.
%make HSV lookup table, these values pass
maxRed = 20;minRed = 235; %red wraps around
maxGreen = 150;minGreen =50;
maxBlue = 220; minBlue = 150;
minSat=150;minVal = 50;

%eventually this table would be combined with the rgb2hsv conversion
%it will also be computed statically before runtime
LUTabom = uint8(zeros(2^24,1)); %hue, sat, val, output
for k = 0:255
    for l = minSat:255
        for m=minVal:255
            output=0;
            if (l >minSat && m>minVal)
                if (k <maxRed || k >minRed) output =1; end
                if (k >minGreen && k<maxGreen) output =2; end
                if (k >minBlue && k<maxBlue) output =3; end
            end
            LUTabom((k)*2^16 + l*2^8 + m +1)= uint8(output);
        end
    end
end

%seperate into channels using LUT
bigRed = uint8(zeros(dims(1:2)));
bigGreen = uint8(zeros(dims(1:2)));
bigBlue = uint8(zeros(dims(1:2)));
for u = 1:dims(1)
    for v = 1:dims(2)
        result = LUTabom(int32(Ahsv(u,v,1))*2^16+ int32(Ahsv(u,v,2))*2^8 + int32(Ahsv(u,v,3)+1));
        if (result ==1) bigRed(u,v) = 1; end
        if (result ==2) bigGreen(u,v) = 1; end
        if (result ==3) bigBlue(u,v) = 1; end
    end
end

%Then, either against the mask or the image, find the ROI
%for each color
%should be able to do it against the 1bit mask
%find ROI from lowpass on column and row sum
[RedrB,RedcB,RedrE,RedcE] = findsingleROI(bigRed);
RedRoi = bigRed(RedrB:RedrE, RedcB:RedcE);
[BluerB,BluecB,BluerE,BluecE] = findsingleROI(bigBlue);
BlueRoi = bigBlue(BluerB:BluerE, BluecB:BluecE);
[GreenrB,GreencB,GreenrE,GreencE] = findsingleROI(bigGreen);
GreenRoi = bigGreen(GreenrB:GreenrE, GreencB:GreencE);

%Sobel the ROI next to get pos/neg x/y edges
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

% %median filter this ROI <-- dont need it!
% 
% %this removes extra garbage and reduces number of colors
% medianSize =3;
% redChanFilt2 = medianselect(redChanFilt2,medianSize,medianSize);
% greenChanFilt2 = medianselect(greenChanFilt2,medianSize,medianSize);
% blueChanFilt2 = medianselect(blueChanFilt2,medianSize,medianSize);
% 
% redChanFilt3 = medianselect(redChanFilt3,medianSize,medianSize);
% greenChanFilt3 = medianselect(greenChanFilt3,medianSize,medianSize);
% blueChanFilt3 = medianselect(blueChanFilt3,medianSize,medianSize);

%thresh the images next to sort pos and neg x and y edges
%into their own bins

mythresh = 14;
[redposycoords,rednegycoords] = duallythresh(redChanFilt2, mythresh);
[redposxcoords,rednegxcoords] = duallythresh(redChanFilt3, mythresh);

[blueposycoords,bluenegycoords] = duallythresh(blueChanFilt2, mythresh);
[blueposxcoords,bluenegxcoords] = duallythresh(blueChanFilt3, mythresh);

[greenposycoords,greennegycoords] = duallythresh(greenChanFilt2, mythresh);
[greenposxcoords,greennegxcoords] = duallythresh(greenChanFilt3, mythresh);

[redposyX, redposyY, redposyT] = parsePoints(redposycoords);
[redposxX, redposxY, redposxT] = parsePoints(redposxcoords);
[rednegyX, rednegyY, rednegyT] = parsePoints(rednegycoords);
[rednegxX, rednegxY, rednegxT] = parsePoints(rednegxcoords);

[blueposyX, blueposyY, blueposyT] = parsePoints(blueposycoords);
[blueposxX, blueposxY, blueposxT] = parsePoints(blueposxcoords);
[bluenegyX, bluenegyY, bluenegyT] = parsePoints(bluenegycoords);
[bluenegxX, bluenegxY, bluenegxT] = parsePoints(bluenegxcoords);

[greenposyX, greenposyY, greenposyT] = parsePoints(greenposycoords);
[greenposxX, greenposxY, greenposxT] = parsePoints(greenposxcoords);
[greennegyX, greennegyY, greennegyT] = parsePoints(greennegycoords);
[greennegxX, greennegxY, greennegxT] = parsePoints(greennegxcoords);

plotLL = 100;
figure()
imshow(bigRed*255)
hold on;
plot(redposycoords(:,2) +RedcB,redposycoords(:,1) +RedrB,'o')
plot([redposyX + RedcB + plotLL*cos(redposyT),redposyX + RedcB - plotLL*cos(redposyT)], [redposyY + RedrB+plotLL*sin(redposyT),redposyY + RedrB - plotLL*sin(redposyT)],'-')
plot(rednegycoords(:,2) +RedcB,rednegycoords(:,1) +RedrB,'o')
plot([rednegyX + RedcB + plotLL*cos(rednegyT),rednegyX + RedcB - plotLL*cos(rednegyT)], [rednegyY + RedrB+plotLL*sin(rednegyT),rednegyY + RedrB - plotLL*sin(rednegyT)],'-')
plot(redposxcoords(:,2) +RedcB,redposxcoords(:,1) +RedrB,'o')
plot([redposxX + RedcB + plotLL*cos(redposxT),redposxX + RedcB - plotLL*cos(redposxT)], [redposxY + RedrB+plotLL*sin(redposxT),redposxY + RedrB - plotLL*sin(redposxT)],'-')
plot(rednegxcoords(:,2) +RedcB,rednegxcoords(:,1) +RedrB,'o')
plot([rednegxX + RedcB + plotLL*cos(rednegxT),rednegxX + RedcB - plotLL*cos(rednegxT)], [rednegxY + RedrB+plotLL*sin(rednegxT),rednegxY + RedrB - plotLL*sin(rednegxT)],'-')
title('red')
hold off;
figure()
imshow(bigBlue*255)
hold on;
plot(blueposycoords(:,2) +BluecB,blueposycoords(:,1) +BluerB,'o')
plot([blueposyX + BluecB + plotLL*cos(blueposyT),blueposyX + BluecB - plotLL*cos(blueposyT)], [blueposyY + BluerB+plotLL*sin(blueposyT),blueposyY + BluerB - plotLL*sin(blueposyT)],'-')
plot(bluenegycoords(:,2) +BluecB,bluenegycoords(:,1) +BluerB,'o')
plot([bluenegyX + BluecB + plotLL*cos(bluenegyT),bluenegyX + BluecB - plotLL*cos(bluenegyT)], [bluenegyY + BluerB+plotLL*sin(bluenegyT),bluenegyY + BluerB - plotLL*sin(bluenegyT)],'-')
plot(blueposxcoords(:,2) +BluecB,blueposxcoords(:,1) +BluerB,'o')
plot([blueposxX + BluecB + plotLL*cos(blueposxT),blueposxX + BluecB - plotLL*cos(blueposxT)], [blueposxY + BluerB+plotLL*sin(blueposxT),blueposxY + BluerB - plotLL*sin(blueposxT)],'-')
plot(bluenegxcoords(:,2) +BluecB,bluenegxcoords(:,1) +BluerB,'o')
plot([bluenegxX + BluecB + plotLL*cos(bluenegxT),bluenegxX + BluecB - plotLL*cos(bluenegxT)], [bluenegxY + BluerB+plotLL*sin(bluenegxT),bluenegxY + BluerB - plotLL*sin(bluenegxT)],'-')
title('blue')
hold off;
figure()
imshow(bigGreen*255)
hold on;
plot(greenposycoords(:,2) +GreencB,greenposycoords(:,1) +GreenrB,'o')
plot([greenposyX + GreencB + plotLL*cos(greenposyT),greenposyX + GreencB - plotLL*cos(greenposyT)], [greenposyY + GreenrB+plotLL*sin(greenposyT),greenposyY + GreenrB - plotLL*sin(greenposyT)],'-')
plot(greennegycoords(:,2) +GreencB,greennegycoords(:,1) +GreenrB,'o')
plot([greennegyX + GreencB + plotLL*cos(greennegyT),greennegyX + GreencB - plotLL*cos(greennegyT)], [greennegyY + GreenrB+plotLL*sin(greennegyT),greennegyY + GreenrB - plotLL*sin(greennegyT)],'-')
plot(greenposxcoords(:,2) +GreencB,greenposxcoords(:,1) +GreenrB,'o')
plot([greenposxX + GreencB + plotLL*cos(greenposxT),greenposxX + GreencB - plotLL*cos(greenposxT)], [greenposxY + GreenrB+plotLL*sin(greenposxT),greenposxY + GreenrB - plotLL*sin(greenposxT)],'-')
plot(greennegxcoords(:,2) +GreencB,greennegxcoords(:,1) +GreenrB,'o')
plot([greennegxX + GreencB + plotLL*cos(greennegxT),greennegxX + GreencB - plotLL*cos(greennegxT)], [greennegxY + GreenrB+plotLL*sin(greennegxT),greennegxY + GreenrB - plotLL*sin(greennegxT)],'-')
title('green')
hold off;
%get angles
%redAngles = atan2(redChanFilt2, redChanFilt3);
%blueAngles = atan2(blueChanFilt2, blueChanFilt3);
%greenAngles = atan2(greenChanFilt2, greenChanFilt3);
%find most popular angles between all three channels, these should be the
%same, that is: there should be two primary angles

%find best fit line for each edge using pixels in image as
%points

%find intersection of best fit lines to find points on tag

[redUpLeft(1),redUpLeft(2)] = myCornerPoints(redposxX + RedcB, redposxY + RedrB, redposxT, redposyX+ RedcB,redposyY + RedrB,redposyT)
[redUpRight(1),redUpRight(2)] = myCornerPoints(rednegxX + RedcB, rednegxY + RedrB, rednegxT, redposyX+ RedcB,redposyY + RedrB,redposyT)
[redDownLeft(1),redDownLeft(2)] = myCornerPoints(redposxX + RedcB, redposxY + RedrB, redposxT, rednegyX+ RedcB,rednegyY + RedrB,rednegyT)
[redDownRight(1),redDownRight(2)] = myCornerPoints(rednegxX + RedcB, rednegxY + RedrB, rednegxT, rednegyX+ RedcB,rednegyY + RedrB,rednegyT)

[greenUpLeft(1),greenUpLeft(2)] = myCornerPoints(greenposxX + GreencB, greenposxY + GreenrB, greenposxT, greenposyX+ GreencB,greenposyY + GreenrB,greenposyT)
[greenUpRight(1),greenUpRight(2)] = myCornerPoints(greennegxX + GreencB, greennegxY + GreenrB, greennegxT, greenposyX+ GreencB,greenposyY + GreenrB,greenposyT)
[greenDownLeft(1),greenDownLeft(2)] = myCornerPoints(greenposxX + GreencB, greenposxY + GreenrB, greenposxT, greennegyX+ GreencB,greennegyY + GreenrB,greennegyT)
[greenDownRight(1),greenDownRight(2)] = myCornerPoints(greennegxX + GreencB, greennegxY + GreenrB, greennegxT, greennegyX+ GreencB,greennegyY + GreenrB,greennegyT)

[blueUpLeft(1),blueUpLeft(2)] = myCornerPoints(blueposxX + BluecB, blueposxY + BluerB, blueposxT, blueposyX+ BluecB,blueposyY + BluerB,blueposyT)
[blueUpRight(1),blueUpRight(2)] = myCornerPoints(bluenegxX + BluecB, bluenegxY + BluerB, bluenegxT, blueposyX+ BluecB,blueposyY + BluerB,blueposyT)
[blueDownLeft(1),blueDownLeft(2)] = myCornerPoints(blueposxX + BluecB, blueposxY + BluerB, blueposxT, bluenegyX+ BluecB,bluenegyY + BluerB,bluenegyT)
[blueDownRight(1),blueDownRight(2)] = myCornerPoints(bluenegxX + BluecB, bluenegxY + BluerB, bluenegxT, bluenegyX+ BluecB,bluenegyY + BluerB,bluenegyT)


%solve for each color
%red
    rcoeffs =  polyfit(redposycoords(:,2) + RedcB, redposycoords(:,1) + RedrB,1);
    rcoeffs2 = polyfit(rednegycoords(:,2) + RedcB, rednegycoords(:,1) + RedrB,1);
    rcoeffs3 = polyfit(redposxcoords(:,2) + RedcB, redposxcoords(:,1) + RedrB,1);
    rcoeffs4 = polyfit(rednegxcoords(:,2) + RedcB, rednegxcoords(:,1) + RedrB,1);

    %1 and 3 are uppper left
    %redUpLeft(1) = (rcoeffs3(2) - rcoeffs(1))/(rcoeffs(1) - rcoeffs3(1));
    %redUpLeft(2) = rcoeffs(1) * redUpLeft(1) + rcoeffs(2);
    %1 and 4 are upper right
    %redUpRight(1) = (rcoeffs4(2) - rcoeffs(1))/(rcoeffs(1) - rcoeffs4(1));
    %redUpRight(2) = rcoeffs(1) * redUpRight(1) + rcoeffs(2);
    %2 and 3 are lower left
    %redDownLeft(1) = (rcoeffs3(2) - rcoeffs2(1))/(rcoeffs2(1) - rcoeffs3(1));
    %redDownLeft(2) = rcoeffs2(1) * redDownLeft(1) + rcoeffs2(2);
    %2 and 4 are lower right
    %redDownRight(1) = (rcoeffs4(2) - rcoeffs2(1))/(rcoeffs2(1) - rcoeffs4(1));
    %redDownRight(2) = rcoeffs2(1) * redDownRight(1) + rcoeffs2(2);
%

%green
    gcoeffs = polyfit(greenposycoords(:,2) + GreencB, greenposycoords(:,1) + GreenrB,1);
    gcoeffs2 = polyfit(greennegycoords(:,2)+ GreencB, greennegycoords(:,1)+ GreenrB,1);
    gcoeffs3 = polyfit(greenposxcoords(:,2)+ GreencB, greenposxcoords(:,1)+ GreenrB,1);
    gcoeffs4 = polyfit(greennegxcoords(:,2)+ GreencB, greennegxcoords(:,1)+ GreenrB,1);

    %1 and 3 are uppper left
    %greenUpLeft(1) = (gcoeffs3(2) - gcoeffs(1))/(gcoeffs(1) - gcoeffs3(1));
    %greenUpLeft(2) = gcoeffs(1) * greenUpLeft(1) + gcoeffs(2);
    %1 and 4 are upper right
    %greenUpRight(1) = (gcoeffs4(2) - gcoeffs(1))/(gcoeffs(1) - gcoeffs4(1));
    %greenUpRight(2) = gcoeffs(1) * greenUpRight(1) + gcoeffs(2);
    %2 and 3 are lower left
    %greenDownLeft(1) = (gcoeffs3(2) - gcoeffs2(1))/(gcoeffs2(1) - gcoeffs3(1));
    %greenDownLeft(2) = gcoeffs2(1) * greenDownLeft(1) + gcoeffs2(2);
    %2 and 4 are lower right
    %greenDownRight(1) = (gcoeffs4(2) - gcoeffs2(1))/(gcoeffs2(1) - gcoeffs4(1));
    %greenDownRight(2) = gcoeffs2(1) * greenDownRight(1) + gcoeffs2(2);
%

%blue
    bcoeffs = polyfit(blueposycoords(:,2) + BluecB, blueposycoords(:,1) + BluerB,1);
    bcoeffs2 = polyfit(bluenegycoords(:,2)+ BluecB, bluenegycoords(:,1)+ BluerB,1);
    bcoeffs3 = polyfit(blueposxcoords(:,2)+ BluecB, blueposxcoords(:,1)+ BluerB,1);
    bcoeffs4 = polyfit(bluenegxcoords(:,2)+ BluecB, bluenegxcoords(:,1)+ BluerB,1);

    %1 and 3 are uppper left
    %blueUpLeft(1) = (bcoeffs3(2) - bcoeffs(1))/(bcoeffs(1) - bcoeffs3(1));
    %blueUpLeft(2) = bcoeffs(1) * blueUpLeft(1) + bcoeffs(2);
    %1 and 4 are upper right
    %blueUpRight(1) = (bcoeffs4(2) - bcoeffs(1))/(bcoeffs(1) - bcoeffs4(1));
    %blueUpRight(2) = bcoeffs(1) * blueUpRight(1) + bcoeffs(2);
    %2 and 3 are lower left
    %blueDownLeft(1) = (bcoeffs3(2) - bcoeffs2(1))/(bcoeffs2(1) - bcoeffs3(1));
    %blueDownLeft(2) = bcoeffs2(1) * blueDownLeft(1) + bcoeffs2(2);
    %2 and 4 are lower right
    %blueDownRight(1) = (bcoeffs4(2) - bcoeffs2(1))/(bcoeffs2(1) - bcoeffs4(1));
    %blueDownRight(2) = bcoeffs2(1) * blueDownRight(1) + bcoeffs2(2);
%

%solve points on tag in camera coords against tag points in 
%tag coords with camera matrix to find camera's location in 
%tag coords
%show solved corners
figure();
imshow(A)
hold on
plot(redUpLeft(1), redUpLeft(2),'r*')
plot(redUpRight(1), redUpRight(2),'ro')
plot(redDownLeft(1), redDownLeft(2),'r+')
plot(redDownRight(1), redDownRight(2),'r.')

plot(greenUpLeft(1), greenUpLeft(2),'g*')
plot(greenUpRight(1), greenUpRight(2),'go')
plot(greenDownLeft(1), greenDownLeft(2),'g+')
plot(greenDownRight(1), greenDownRight(2),'g.')

plot(blueUpLeft(1), blueUpLeft(2),'b*')
plot(blueUpRight(1), blueUpRight(2),'bo')
plot(blueDownLeft(1), blueDownLeft(2),'b+')
plot(blueDownRight(1), blueDownRight(2),'b.')
hold off

% figure()
% dispImage(8*redChanFilt2, 'Red Filt Y', summer);
% figure()
% dispImage(8*greenChanFilt2, 'Green Filt Y', winter);
% figure()
% dispImage(8*blueChanFilt2, 'Blue Filt Y', autumn);
% figure()
% dispImage(8*redChanFilt3, 'Red Filt X', summer);
% figure()
% dispImage(8*greenChanFilt3, 'Green Filt X', winter);
% figure()
% dispImage(8*blueChanFilt3, 'Blue Filt X', autumn);
%get confidance measure of best fit line being in the tag
%? see how self consistant the points are with the others? (are the green
%corners near the red and blue corners?)



%form camera in tag coordinates transform matrix
%do this from the located corners and information from the tag. Use
%parameters about the tag like width and length and find the transform that
%converts coordinates on the tag to coordinates in the (camera or world)

tagwidth = .277;
redheight = .15;
blueheight = .15;
greenheight = .15;


%corresponding points in tag coordinates in (x,y,z)
%tag center is 0,0;
%if you are the tag, facing outward, 
%positive x is out away from the tag, positive y is to the left
%positive z is up
tagRedUpLeft = [0,-tagwidth/2, greenheight/2 + redheight];
tagRedUpRight = [0, tagwidth/2, greenheight/2 + redheight];
tagRedDownRight = [0,tagwidth/2, greenheight/2];
tagRedDownLeft = [0,-tagwidth/2, greenheight/2];
tagBlueUpLeft = [0, -tagwidth/2, -greenheight/2];
tagBlueUpRight = [0, tagwidth/2, -greenheight/2];
tagBlueDownRight = [0, tagwidth/2, -greenheight/2 - blueheight];
tagBlueDownLeft = [0, -tagwidth/2, -greenheight/2 - blueheight];
tagGreenUpLeft = [0, -tagwidth/2, greenheight/2];
tagGreenUpRight = [0, tagwidth/2, greenheight/2];
tagGreenDownRight = [0, tagwidth/2, -greenheight/2];
tagGreenDownLeft = [0, -tagwidth/2, -greenheight/2];

%strategy, get transform for each color individually
%other strategy, combine all confidant points (how?)

%camParam = cameraParameters('IntrinsicMatrix', cameraMatrix);
camParam = cameraIntrinsics([595,595],[320,240],[480,640]);
%these are in r,c
inputImagePoints = [redUpLeft;
                    redUpRight;
                    redDownRight;
                    redDownLeft;
                    blueUpLeft;
                    blueUpRight;
                    blueDownRight;
                    blueDownLeft];
                    %greenUpLeft;
                    %greenUpRight;
                    %greenDownRight;
                    %greenDownLeft];

inputWorldPoints = [tagRedUpLeft;
                    tagRedUpRight;
                    tagRedDownRight;
                    tagRedDownLeft;
                    tagBlueUpLeft;
                    tagBlueUpRight;
                    tagBlueDownRight;
                    tagBlueDownLeft];
                    %tagGreenUpLeft;
                    %tagGreenUpRight;
                    %tagGreenDownRight;
                    %tagGreenDownLeft];


[worldOrientation,worldLocation] = estimateWorldCameraPose(inputImagePoints,inputWorldPoints,camParam)
