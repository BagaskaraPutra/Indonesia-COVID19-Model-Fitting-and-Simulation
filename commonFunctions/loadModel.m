function model = loadModel(model)
file = importdata([model.dir '/config.txt']); %[EDITABLE] if you change the config file name
headerStartChar = '['; headerEndChar = ']:'; %[EDITABLE] if you change the config header format

headerIndex = {};
tempIndex = strfind(file,headerEndChar);
for hIdxFound=1:numel(tempIndex)
    if(~isempty(tempIndex{hIdxFound}))
        headerIndex = [headerIndex hIdxFound];
	end
end

for hIdx=1:numel(headerIndex)
    if(hIdx == numel(headerIndex)) % last headerName
        for fIdx=1:size(file,1)-headerIndex{hIdx}
            headerName = extractCharBetween(file{headerIndex{hIdx}},headerStartChar,headerEndChar);
            model.(headerName){fIdx} = file{fIdx+headerIndex{hIdx}};
        end
    else % middle headerNames
        for fIdx=1:(headerIndex{hIdx+1}-headerIndex{hIdx})-1
            headerName = extractCharBetween(file{headerIndex{hIdx}},headerStartChar,headerEndChar);
            model.(headerName){fIdx} = file{fIdx+headerIndex{hIdx}}; 
        end
    end
end

function outputChar = extractCharBetween(inputChar,startChar,endChar)
    startIdx = strfind(inputChar,startChar);
    endIdx = strfind(inputChar,endChar);
    outputChar = inputChar(startIdx+1:endIdx-1);
end

end