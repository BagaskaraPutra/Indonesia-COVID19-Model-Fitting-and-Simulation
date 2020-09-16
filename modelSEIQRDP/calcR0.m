function kebijakan = calcR0(kebijakan,model)
cd(model.dir);
for i=1:numel(kebijakan)
    beta = kebijakan{i}.paramEst(find(strcmp(model.paramName,'beta')));
    delta = kebijakan{i}.paramEst(find(strcmp(model.paramName,'delta')));
    alpha = kebijakan{i}.paramEst(find(strcmp(model.paramName,'alpha')));

%     kebijakan{i}.R0 = max(abs(eig(K)));
%     kebijakan{i}.R0 = beta/delta*(1-alpha).^(numel(kebijakan{i}.timeFit));
%     fprintf('R0 kebijakan %d. %s: %f\n',i,kebijakan{i}.name,kebijakan{i}.R0);
end
end