function model = loadModel(model)
file = importdata([model.dir '/config.txt']);
model.headerName = {'allStateName','fitStateName','paramName'}; 
for i=1:numel(model.headerName)
%     headerIndex{i} = find(contains(file,model.headerName{i})); %gak bisa di octave
    tempIndex = strfind(file,model.headerName{i});
    for j=1:numel(tempIndex)
        if(~isempty(tempIndex{j}))
            headerIndex{i} = j;
        end
    end
end
for i=1:numel(model.headerName)
    if(i == numel(model.headerName))
        for j=1:size(file,1)-headerIndex{i}
            model.(model.headerName{i}){j} = file{j+headerIndex{i}};
        end
    else
        for j=1:(headerIndex{i+1}-headerIndex{i})-1
            model.(model.headerName{i}){j} = file{j+headerIndex{i}}; 
        end
    end
end