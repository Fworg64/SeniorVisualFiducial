%can convolve 5x5 kernal with 240 x 320 image in 1ms
%need to find square in 7ms
%strategy:
%let the square be a green bordered red square which ranges in
%size from most of the image to 10% of the image width

%convolve green channel with high pass kernal to find green edges
%convolve red channel with high pass kernal to find red edges
%flip sign of one channel so edges match and add them together
%threshold new image, should now have rectangle
%need to find corners coordinates

%this method struggles with white because no clipping in HSV is done first

figure();
%A = imread('/home/fworg64/seniorvision/Untitled3.png');
A = imread('/home/fworg64/seniorvision/banner1.png');
subplot(2,2,1);
Ared = A(:,:,1);
Agreen = A(:,:,2);
Ablue = A(:,:,3);
imshow(A);
title('image')
subplot(2,2,2);
imshow(Ared);
title('Red');
subplot(2,2,3);
imshow(Ablue);
title('blue');
subplot(2,2,4);
imshow(Agreen);
title('green');

greenedgefilter = [3,10,3;
                   0,0,0;
                   -3,-10,-3];

greenedges = conv2(Agreen,greenedgefilter, 'same');
greenedges = greenedges / 4096;%normalize
greenedgespos = zeros(240, 320);
greenedgesneg = zeros(240, 320);
for u= 1:320
    for v= 1:240
        if (greenedges(v, u) >0) 
            greenedgespos(v,u) = greenedges(v,u);
        else 
            greenedgesneg(v,u) = -greenedges(v,u);
        end
    end
end


figure()
subplot(2,2,1);
imshow(greenedgespos);
title('greenedges vert pos');
subplot(2,2,2);
imshow(greenedgesneg);
title('greenedges vert neg');

rededges = conv2(Ared, greenedgefilter, 'same');
rededges = rededges / 4096; %normalize
rededgespos = zeros(240, 320);
rededgesneg = zeros(240, 320);
for u= 1:320
    for v= 1:240
        if (rededges(v, u) >0) 
            rededgespos(v,u) = rededges(v,u);
        else 
            rededgesneg(v,u) = -rededges(v,u);
        end
    end
end
subplot(2,2,3);
imshow(rededgespos);
title('rededges vert pos2');
subplot(2,2,4);
imshow(rededgesneg);
title('rededges vert neg');

figure()
edgescombined1 = rededgesneg.*greenedgespos;
edgescombined2 = rededgespos.*greenedgesneg;
subplot(2,2,1);
imshow(edgescombined1);
title('redneg, greenpos');
subplot(2,2,2);
imshow(edgescombined2);
title('redpos, greenneg');

%find points

linepoints = [0,0];
pointscounter =1;

for u = 1:240
  for v = 1:320
    if edgescombined1(u,v) > .5
      linepoints(pointscounter,:) = [v,u]; %row column vs X, Y
      pointscounter = pointscounter +1;
    end
  end
end

coeffs = polyfit(linepoints(:,1), linepoints(:,2),1);

minx = min(linepoints(:,1));
maxx = max(linepoints(:,1));
miny = coeffs(1)*minx + coeffs(2);
maxy = coeffs(1)*maxx  +coeffs(2);

subplot(2,2,3)
plot([minx, maxx], [-miny, -maxy]);
axis([0,320,-240,0]);
