function [out] = rmmissing (x)
if(iscell(x))
    out = [];
    if(size(x,1) > size(x,2))
        for i=1:numel(x)
            if(~isempty(x{i}))
                out = [out x(i)];
            end
        end
    else
        for i=1:numel(x)
            if(~isempty(x{i}))
                out = [out; x(i)];
            end
        end   
    end
elseif(ismatrix(x) && ~iscell(x))
    out = [];
    if(size(x,1) > size(x,2))
        for i=1:numel(x)
            if(~isempty(x{i}))
                out = [out x(i)];
            end
        end
    else
        for i=1:numel(x)
            if(~isempty(x{i}))
                out = [out; x(i)];
            end
        end
    end
else
    error('input must be cell, array, or matrix');
end