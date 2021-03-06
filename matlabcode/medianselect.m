%%medianselect
%this function takes an input array and a kernal size and selects the
%median value in each window and assignes it to the center of the window.
%dim1 is how many rows of the image and dim2 is how many columns of the
%image the window takes up

function B = medianselect(A, dim1, dim2)
    dims = size(A);
    Aex = zeros(dims(1) + 2*dim1, dims(2) + 2*dim2);
    Aex(dim1+1:dims(1)+dim1, dim2+1:dims(2)+dim2) = A(:,:);
    %column extension
    for u = 1:dim1
        Aex(dims(1) +dim1 + u, :) = Aex(dims(1) + dim1 - u+1,:);
        Aex(dim1 - u+1, :) = Aex(dim1+u,:);
    end
    for u = 1:dim2
        Aex(:, dims(2) +dim2 + u) = Aex(:, dims(2) +dim2 - u+1);
        Aex(:,dim2 - u +1) = Aex(:, dim2+u);
    end
    B = zeros(dims(1), dims(2));
    for r = 1:dims(1)
        for c = 1:dims(2)
            B(r,c) = median(median( Aex( r+floor(dim1-1):r+dim1+floor(dim1-1), c+floor(dim2-1):c+dim2+floor(dim2-1) )));%sum(sum(Kernal.*Aex(r+floor(dim1-1):r+dim1+floor(dim1-1), c+floor(dim2-1):c+dim2+floor(dim2-1) )
        end
    end
end