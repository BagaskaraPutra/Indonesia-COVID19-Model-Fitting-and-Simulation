function printParam(kebijakan,model)
for i=1:numel(kebijakan)
    fprintf([num2str(i) '.' kebijakan{i}.name]);
    fprintf('\n');
    for j=1:numel(kebijakan{i}.paramEst)
        fprintf(model.paramName{j});
        fprintf(': %.16f\n',kebijakan{i}.paramEst(j));
    end
    fprintf('\n');
end