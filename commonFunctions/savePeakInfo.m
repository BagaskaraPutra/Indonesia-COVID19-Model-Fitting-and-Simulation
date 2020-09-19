function savePeakInfo(k,saveDir)
for i=1:numel(k)
    if(isfield(k{i},'peak'))
        fid=fopen([saveDir '/' num2str(i) '.' k{i}.name '.csv'],'w');
           fprintf(fid,'Jumlah:, %.0f\n',k{i}.peak.y);
           fprintf(fid,'Tanggal:,');
           fprintf(fid,datestr(k{i}.timeSim{k{i}.peak.x}));
        fclose(fid);
    end
end