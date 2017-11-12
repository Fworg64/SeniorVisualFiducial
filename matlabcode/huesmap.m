%%huemap()
%generates a huemap for an 8bit H channel on an HSV image
function B = huesmap()
    Hmap = zeros(256,3); %%approximate Hue to RGB map for colorbar
    for u = 0:255;
        if (u <= 255/6)
            Hmap(u+1, 1) = 1;
            Hmap(u+1, 2) = u/(255/6); %green rises linearly until saturation
            Hmap(u+1, 3) = 0;
        end
        if (u > 255/6 && u<= 255/3)
            Hmap(u+1, 1) = 1 - (u-255/6)/(255/6); %red falls linearly
            Hmap(u+1, 2) = 1;
            Hmap(u+1, 3) = 0;
        end
        if (u > 255/3 && u<= 255/2)
            Hmap(u+1, 1) = 0;
            Hmap(u+1, 2) = 1;
            Hmap(u+1, 3) = (u - 255/3)/(255/6); %blue is on the rise
        end
        if (u > 255/2 && u<= 255*2/3)
            Hmap(u+1, 1) = 0;
            Hmap(u+1, 2) = 1 - (u-255/2)/(255/6); %green falls linearly
            Hmap(u+1, 3) = 1;
        end
        if (u > 255*2/3 && u<= 255*5/6)
            Hmap(u+1, 1) = (u - 255*2/3)/(255/6); %red is on the rise
            Hmap(u+1, 2) = 0;
            Hmap(u+1, 3) = 1;
        end
        if (u > 255*5/6)
            Hmap(u+1, 1) = 1;
            Hmap(u+1, 2) = 0;
            Hmap(u+1, 3) = 1 - (u-255*5/6)/(255/6); %red falls linearly
        end
    end
    B = Hmap;
end