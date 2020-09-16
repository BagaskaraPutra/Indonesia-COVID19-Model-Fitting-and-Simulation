function printLockdownDetails(lockdown)
annotation('textbox',[0.75 0.3 0.15 0.075], 'FontSize',10, 'String', ...
    {['Mulai Lockdown: ',num2str(lockdown.startDate)],...
    ['Durasi Lockdown (hari): ',num2str(lockdown.numDays)]});
end