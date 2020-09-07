function plotLegend(k,additionalHandlers,additionalNames)
if(nargin == 1)
    legend([k{1}.plotHandler k{1}.vlHandler], [k{1}.varName k{1}.vlName'],'Location','Best');
else
    legend([k{1}.plotHandler k{1}.vlHandler additionalHandlers], [k{1}.varName k{1}.vlName' additionalNames'],'Location','Best');
end