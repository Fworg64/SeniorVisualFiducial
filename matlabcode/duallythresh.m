%%duallythresh
%threshes an image into two bins of coordinates, those high positve 
%(>thresh) and those  low negative (<-thresh) points

function [poss,negs] = duallythresh(A,thresh)
    counter1 =1;
    counter2 =1;
    poss = [0,0];
    negs = [0,0];
    dims = size(A);
    for r = 1:dims(1)
        for c = 1:dims(2)
            if (A(r,c) > thresh)  
            poss(counter1,:) = [r,c];
            counter1 = counter1 + 1;
            elseif (A(r,c) < -thresh)
            negs(counter2,:) = [r,c];
            counter2 = counter2 +1;
            end
        end
    end


end