function saveRMSE(fit,pred,saveDir,model)
fid=fopen([saveDir '/'  model.name '.csv'],'w'); 
delim = ',';
fprintf(fid,[model.name ' RMSE' '\n']);
fprintf(fid,['State' delim 'Fitting' delim 'Prediction' '\n']);
for fIdx=1:numel(model.fitStateName)
    fprintf(fid,model.fitStateName{fIdx});
    fprintf(fid,[delim '%.1f' delim '%.1f' '\n'],fit.RMSE.(model.fitStateName{fIdx}),pred.RMSE.(model.fitStateName{fIdx}));
end
fprintf(fid,['Average' delim '%.1f' delim '%.1f'],fit.RMSEavg,pred.RMSEavg);
fclose(fid);