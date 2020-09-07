function zero = nan2zero(data)
for i=1:length(data)
    if(isnan(data(i)))
        zero(i) = 0;
    else
        zero(i) = data(i);
    end
end