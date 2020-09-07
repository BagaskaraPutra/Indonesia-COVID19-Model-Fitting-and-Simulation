function loadDefaultColors()
global blueDef orangeDef yellowDef purpleDef greenDef lightblueDef brownDef
defaultColor = get(0, 'DefaultAxesColorOrder');
blueDef = defaultColor(1,:); % blue default
orangeDef = defaultColor(2,:); % orange default
yellowDef = defaultColor(3,:); % yellow default
purpleDef = defaultColor(4,:); % purple default
greenDef = defaultColor(5,:); % green default
lightblueDef = defaultColor(6,:); % light blue default
brownDef = defaultColor(7,:); % brown default