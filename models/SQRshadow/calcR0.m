function kebijakan = calcR0(kebijakan,model)
cd(model.dir);
for i=1:numel(kebijakan)
    beta = kebijakan{i}.paramEst(find(strcmp(model.paramName,'beta')));
    gamma = kebijakan{i}.paramEst(find(strcmp(model.paramName,'gamma')));
    muI = kebijakan{i}.paramEst(find(strcmp(model.paramName,'muI')));
    beta_s = kebijakan{i}.paramEst(find(strcmp(model.paramName,'beta_s')));

    F = [beta 0; 
        0 beta_s];
    V = [(gamma + muI) 0;
         0  (gamma + muI)];
    K = F*inv(V);

    kebijakan{i}.R0 = max(abs(eig(K)));
    fprintf('R0 kebijakan %d. %s: %f\n',i,kebijakan{i}.name,kebijakan{i}.R0);
end
end