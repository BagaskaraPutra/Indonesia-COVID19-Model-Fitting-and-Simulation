function kebijakan = getDataKebijakanFromDate(kebijakan,raw,model)
if(datenum(datetime(kebijakan.startDate)) > datenum(raw.timeFit{end}))
  % if startDate > last RawTime
  kebijakan.timeFit{1} = datetime(kebijakan.startDate);
  for i=1:numel(model.fitStateName)
    kebijakan.(model.fitStateName{i}) = zeros(1,numel(kebijakan.timeFit));
  end
else
  startArray = findIndexFromCell(raw.timeFit,datetime(kebijakan.startDate));
  if(isfield(kebijakan,'endDate'))
      endArray = findIndexFromCell(raw.timeFit,datetime(kebijakan.endDate));
  else
      endArray = numel(raw.timeFit);
  end
  kebijakan.timeFit = raw.timeFit(startArray:endArray);
  for i=1:numel(model.fitStateName)
    kebijakan.(model.fitStateName{i}) = raw.(model.fitStateName{i})(startArray:endArray);
  end
end
