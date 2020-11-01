function kebijakan = calcR0(kebijakan,model)
cd(model.dir);
for i=1:numel(kebijakan)
    beta = kebijakan{i}.paramEst(find(strcmp(model.paramName,'beta')));
%     gamma = kebijakan{i}.paramEst(find(strcmp(model.paramName,'gamma')));
%     muI = kebijakan{i}.paramEst(find(strcmp(model.paramName,'muI')));
    r_I_Q = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_I_Q')));

%     F = beta;
%     V = gamma + muI;
    K = beta/r_I_Q;

    kebijakan{i}.R0 = max(abs(eig(K)));
    fprintf('R0 kebijakan %d. %s: %f\n',i,kebijakan{i}.name,kebijakan{i}.R0);
end
end