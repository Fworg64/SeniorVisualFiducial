%%findsingleROI
%this function finds the biggest brightest blob in a relativly sparse image
%and returns the bounding rectangle

function [rowBegin, colBegin, rowEnd, colEnd] = findsingleROI(A)
    dims = size(A);
    columns = sum(A);
    row = sum(A');
    runningcount =0;
    toprunningcount =0;
    for u = 2:dims(2)
        if (columns(u) >0) 
            %need to set start on every first >0
            if (columns(u-1) ==0)
                tempstartu = u;
            end
            runningcount = runningcount+columns(u);
            if (runningcount > toprunningcount)
                colEnd = u;
                colBegin = tempstartu;
                toprunningcount = runningcount;
            end
        else
            runningcount =0;
        end
    end
    runningcount =0;
    toprunningcount =0;
    for v = 2:dims(1)
        if (row(v) >0) 
            %need to set start on every first >0
            if (row(v-1) ==0)
                tempstartv = v;
            end
            runningcount = runningcount+row(v);
            if (runningcount > toprunningcount)
                rowEnd = v;
                rowBegin = tempstartv;
                toprunningcount = runningcount;
            end
        else
            runningcount =0;
        end
    end
end