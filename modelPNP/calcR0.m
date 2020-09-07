function kebijakan = calcR0(kebijakan,model)
cd(model.dir);
for i=1:numel(kebijakan)
    r_S_P = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_S_P')));
    r_P_R = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_P_R')));
    r_P_D = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_P_D')));
%     r_NI_P = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_NI_P')));
%     r_NI_NR = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_NI_NR')));
%     r_NI_ND = kebijakan{i}.paramEst(find(strcmp(model.paramName,'r_NI_ND')));

% % dengan pertimbangan kompartemen 'NI'
%     F = [0, 0; 
%          0, r_S_P];
%     V = [(r_NI_NR + r_NI_P + r_NI_ND), 0;
%          -r_NI_P, (r_P_R + r_P_D)];

% tanpa pertimbangan kompartemen 'NI'
    F = r_S_P;
    V = r_P_R + r_P_D;
    K = F*inv(V);
    kebijakan{i}.R0 = max(abs(eig(K)));
    
    fprintf('R0 kebijakan %d. %s: %f\n',i,kebijakan{i}.name,kebijakan{i}.R0);
end
end