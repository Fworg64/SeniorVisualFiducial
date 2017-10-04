%%myconv2
%outputs the centered convolution/correlation of a Kernal with the image A
%using even edge replication.
%If true correlation is desired, pass 'flip' to the flip argument.
%Otherwise, omit the third argument.

function B = myconv2(A, Kernal, flip)
    dims = size(Kernal);
    if (nargin>=3) %flip kernal
        Kernal = rot90(2,Kernal);
    end
    dim1 = floor(dims(1)/2);dim2 = floor(dims(2)/2);
    dims = size(A);
    Aex = zeros(dims(1) + 2*dim1, dims(2) + 2*dim2);
    Aex(dim1+1:dims(1)+dim1, dim2+1:dims(2)+dim2) = A(:,:);
    %column extension
    for u = 1:dim1
        Aex(dims(1) +dim1 + u, :) = Aex(dims(1) + dim1 - u+1,:);
        Aex(dim1 - u+1, :) = Aex(dim1+u,:);
    end
    %row extension
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