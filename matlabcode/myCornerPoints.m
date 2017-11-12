%find corner from points and angle

function [x,y] = myCornerPoints(x1,y1,t1,x2,y2,t2)
    x = (y2 - y1 + x1*tan(t1) - x2*tan(t2))/(tan(t1) - tan(t2));
    y = tan(t1)*(x-x1) +y1;
end