function k = plotVerticalLines(k)
global softwareName;
for i=1:numel(k)
    vl(i).name = k{i}.name;
    if(softwareName == 'matlab')
        vl(i).line = line([datetime(k{i}.timeFit{1}) datetime(k{i}.timeFit{1})], ylim,'Linestyle','--','Linewidth',1,'Color',k{i}.vlColor);
    else
        vl(i).line = line([datenum(k{i}.timeFit{1}) datenum(k{i}.timeFit{1})], ylim,'Linestyle','--','Linewidth',1,'Color',k{i}.vlColor);
    end
end
vlHandler = []; vlName = [];
for i=1:numel(vl)
    vlHandler = [vlHandler vl(i).line];
    vlName = [vlName; cellstr([num2str(i) '. ' vl(i).name])];
end
k{1}.vlHandler = vlHandler; k{1}.vlName = vlName;
% legend([k{1}.plotHandler k{1}.vlHandler], [k{1}.varName k{1}.vlName'],'Location','Best');