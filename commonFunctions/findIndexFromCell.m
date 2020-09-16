function indexCell = findIndexFromCell(sourceCell,desiredValue)
  for i=1:numel(sourceCell)
    if(sourceCell{i} == desiredValue)
      indexCell = i;
    end
  end