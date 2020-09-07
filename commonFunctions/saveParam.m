function saveParam(kebijakan,saveDir,model)
for i=1:numel(kebijakan)
    fid=fopen([saveDir '/' num2str(i) '. ' kebijakan{i}.name '.csv'],'w');
    for j=1:numel(kebijakan{i}.paramEst)
       fprintf(fid,model.paramName{j});
       fprintf(fid,':, %.16f\n',kebijakan{i}.paramEst(j));
    end
    if isfield(kebijakan{i},'R0')
        fprintf(fid,'R0:, %.6f\n',kebijakan{i}.R0);
    end
    fclose(fid);
end