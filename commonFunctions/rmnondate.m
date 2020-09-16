function out = rmnondate(x)
if(iscell(x) || ismatrix(x))
    out = [];
    if(size(x,1) > size(x,2))
        for i=1:numel(x)
            dateExtract = textscan(x{i},'%d/%d/%d');
                notdate = false;
                for j=1:numel(dateExtract)
                    notdate = isinteger(dateExtract{j});
                end
                if(notdate(1) && notdate(2) && notdate(3)) 
                    out = [out x(i)];
%                 else
%                     disp('not a date');
                end
        end
    else
        for i=1:numel(x)
            dateExtract = textscan(x{i},'%d/%d/%d');
                notdate = false;
                for j=1:numel(dateExtract)
                    notdate = isempty(dateExtract{j});
                end
                if(~notdate) 
                    out = [out; x(i)];
%                     fprintf('%d %d %d',dateExtract{1},dateExtract{2},dateExtract{3});
%                     disp('is integer');
%                 else
%                     disp('not a date');
                end
        end   
    end
else
    error('Input must be cell, array, or matrix');
end