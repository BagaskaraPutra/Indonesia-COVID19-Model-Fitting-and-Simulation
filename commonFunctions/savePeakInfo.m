function savePeakInfo(k,saveDir)
% for i=1:numel(k)
%     if(isfield(k{i},'peak'))
%         fid=fopen([saveDir '/' num2str(i) '.' k{i}.name '.csv'],'w');
%            fprintf(fid,'Jumlah:, %.0f\n',k{i}.peak.y);
%            fprintf(fid,'Tanggal:,');
%            fprintf(fid,datestr(k{i}.timeSim{k{i}.peak.x}));
%         fclose(fid);
%     end
% end
fid=fopen([saveDir '/' 'peakInfo.csv'],'w');
for i=1:numel(k)
    if(isfield(k{i},'peak'))
        fprintf(fid, [num2str(i) '.' k{i}.name '\n']);
        for j=1:numel(k{i}.peak)
           fprintf(fid,[k{i}.peak{j}.name '\n']);
           fprintf(fid,'Jumlah:, %.0f\n',k{i}.peak{j}.y);
           fprintf(fid,'Tanggal:,');
           fprintf(fid,datestr(k{i}.timeSim{k{i}.peak{j}.x}));
           fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
    end
end
fclose(fid);