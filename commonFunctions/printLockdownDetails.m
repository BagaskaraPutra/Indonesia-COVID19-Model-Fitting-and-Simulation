function printLockdownDetails(lockdown,lang)
if(nargin < 2)
      annotation('textbox',[0.75 0.3 0.17 0.075], 'FontSize',10, 'String', ...
        {['Lockdown Start: ',num2str(lockdown.startDate)],...
        ['Lockdown Duration (days): ',num2str(lockdown.numDays)]});  
else
    annotation('textbox',[0.75 0.3 0.15 0.075], 'FontSize',10, 'String', ...
        {['Mulai Lockdown: ',num2str(lockdown.startDate)],...
        ['Durasi Lockdown (hari): ',num2str(lockdown.numDays)]});
end

end