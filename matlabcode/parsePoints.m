%parseCoords
%takes input coordinates to an edge, throws out outliers and finds a line
%that fits the data best for our application

%points is a Nx2 array of the form (y,x)

function [pointx, pointy, pointTheta] = parsePoints(points)
   meanY = mean(points(:,1));
   meanX = mean(points(:,2));
   stdX = std(points(:,2));
   stdY = std(points(:,1));
   %throw out all points outside 1std dev
   newXindex =1;
   newYindex =1;
   tol = 1.2;
   for k = 1:length(points)
       if (points(k,1) > meanY - tol*stdY && points(k,1) <meanY + tol*stdY)
           newY(newYindex) = points(k,1);
           newYindex = newYindex+1;
       end
       if (points(k,2) > meanX - tol*stdX && points(k,2) <meanX + tol*stdX)
           newX(newXindex) = points(k,2);
           newXindex = newXindex +1;
       end
   end
   %take mean of top half of data and mean of bottom half of data
   meanYtopHalf = mean(newY(1:floor(length(newY)/2)-1));
   meanYbotHalf = mean(newY(floor(length(newY)/2):length(newY)));
   meanXtopHalf = mean(newX(1:floor(length(newX)/2)-1));
   meanXbotHalf = mean(newX(floor(length(newX)/2):length(newX)));
   %get angle from these
   pointTheta = atan2(meanYtopHalf - meanYbotHalf,meanXtopHalf-meanXbotHalf);
   pointx = (meanXtopHalf + meanXbotHalf)/2;
   pointy = (meanYtopHalf + meanYbotHalf)/2;




end
