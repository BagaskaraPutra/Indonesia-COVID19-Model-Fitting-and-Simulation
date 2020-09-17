function kebijakan = loadParam(kebijakan,paramDir,model)
for i=1:numel(kebijakan)
%     cd(paramDir];
    fileName = [paramDir '/' num2str(i) '. ' kebijakan{i}.name '.csv'];
%     fid=fopen([paramDir '/' num2str(i) '. ' kebijakan{i}.name '.csv'],'r');
    fid=fopen(fileName,'r');
    param = textscan(fid,'%s %f','Delimiter',',');
    for j=1:numel(model.paramName)
        if(strfind(param{1}{j},model.paramName{j}))
            kebijakan{i}.guessParam(j) = param{2}(j);
        end
%        fprintf(fid,model.paramName{j});
%        fprintf(fid,':, %.16f\n',kebijakan{i}.paramEst(j));
    end
    fclose(fid);
end