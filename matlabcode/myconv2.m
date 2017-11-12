%%myconv2
%outputs the centered convolution/correlation of a Kernal with the image A
%using even edge replication.
%If correlation is desired, pass 'corr' to the flip argument.
%Otherwise, omit the third argument.

function B = myconv2(A, Kernal, flip)
    dims = size(Kernal);
    if (nargin<3) %flip kernal unless correlation
        Kernal = rot90(Kernal,2);
    end
    dim1 = floor(dims(1)/2);dim2 = floor(dims(2)/2);
    dims = size(A);
    %extend image
    Aex = zeros(dims(1) + 2*dim1, dims(2) + 2*dim2);
    Aex(dim1+1:dims(1)+dim1, dim2+1:dims(2)+dim2) = A(:,:);
    %Even column extension, mirror the edge
    for u = 1:dim1
        Aex(dims(1) +dim1 + u, :) = Aex(dims(1) + dim1 - u+1,:);
        Aex(dim1 - u+1, :) = Aex(dim1+u,:);
    end
    %Even row extension, mirror the edge
    for u = 1:dim2
        Aex(:, dims(2) +dim2 + u) = Aex(:, dims(2) +dim2 - u+1);
        Aex(:,dim2 - u +1) = Aex(:, dim2+u);
    end
    %run algorithm
    B = zeros(dims(1), dims(2));
    for r = 1:dims(1);
        for c = 1:dims(2)
            B(r,c) = sum(sum(Kernal.*Aex(r:r+2*dim1, c:c+2*dim2)));
        end
    end
end