function status = dispImage(A, tit, map)
    newDims = size(A);

    myfig = image(A);
    myfig.CDataMapping = 'scaled';
    if (nargin >2)
        colormap(map)
        caxis([0,255]);
        colorbar;
    end
    pbaspect([newDims(2),newDims(1),1]); % force square aspect
    ax = gca;
    ax.XTick = [0:int32(newDims(2)/5):newDims(2)];
    ax.YTick = [0:int32(newDims(1)/5):newDims(1)];
    if (nargin >1)
        title(tit, 'fontsize',32);
    end
    status =0;
end