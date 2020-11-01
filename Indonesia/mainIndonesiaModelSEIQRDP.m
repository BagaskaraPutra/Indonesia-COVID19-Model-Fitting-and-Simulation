%% SEIQRDP Indonesia:
% Semua yang ada komentar [EDITABLE] dapat diprioritaskan untuk diedit jika
% ada perubahan model, parameter model, parameter plotting, kebijakan, dll.
% Compartments: 
%   S: susceptible cases
%   E: exposed cases
%   I: infectious cases
%   Q: quarantined cases
%   R: recovered cases
%   D: dead cases
%   P: insusceptible cases
%By: Bagaskara P.P., Last Modified: 2020-09-16

clear all; close all; clc; 
mainDir = pwd; % get current main directory 
addpath('../commonFunctions'); % add path to common functions
prompt = 'Are you using Matlab or Octave? If Matlab, enter [m]. If Octave, enter [o]: ';
softwareAcronym = input(prompt, 's');
global softwareName;
if(softwareAcronym == 'm' || softwareAcronym == 'M')
    softwareName = 'matlab';
else
    softwareName = 'octave';
    pkg load io;
    pkg load optim;
end
prompt = 'Download new data? If first time downloading, enter [Y]. If not, enter [N]: ';
str = input(prompt,'s');
if(str=='N' || str=='n')
    download = false;
else
    download = true;
end

% [EDITABLE] Jika ingin mengubah model, state fiting, dan parameter; edit variable2 di bawah ini:
namaDaerah = 'Indonesia';
model.name = 'SEIQRDP';
model.dir = ['../models/SEIQRDP'];
model = loadModel(model);
global Npop; Npop = 273.52e6; % Indonesia total population
% kapasitasRS = ; % kapasitas Rumah Sakit

% [EDITABLE] Kebijakan: disimpan dalam cell struct k{i}, di mana i adalah urutan kebijakan
% ubah startDate & endDate sesuai kebijakan. Jika tidak tahu endDate, tidak usah diisi, data terakhir yang diambil.
% numDays = berapa hari akan disimulasikan setelah hari terakhir kebijakan?
k{1}.name = 'Sebelum Lonjakan'; 
k{1}.startDate = '2020-04-30'; %k{1}.endDate = '2020-08-27'; k{1}.numDays = 14;
% k{2}.name = 'Lonjakan Long Weekend'; 
% k{2}.startDate = '2020-08-28';
rfi = numel(k); % real fitting index: indeks kebijakan terakhir yang merupakan data fitting nyata

lockdown.index = rfi+1;
% lockdown.startDate = '2020-07-27';
lockdown.startDate = '2020-09-14'; 
% lockdown.startDate = '2020-11-24'; 
% lockdown.startDate = '2020-12-25'; 
% lockdown.startDate = '2021-02-08'; 
% lockdown.startDate = '2021-03-14'; 
lockdown.numDays = 14; % durasi simulasi lockdown total
postlockdown.numDays = 730; % durasi simulasi pasca lockdown
k{lockdown.index}.name = 'Simulasi Lockdown Total';
k{lockdown.index}.startDate = lockdown.startDate; 
% k{lockdown.index}.endDate = lockdown.startDate; 
k{lockdown.index}.numDays = lockdown.numDays;

k{lockdown.index+1}.name = 'Simulasi Pelonggaran Lockdown Total';
k{lockdown.index+1}.startDate = datestr(datenum(datetime(k{lockdown.index}.startDate)) + datenum(0,0,k{lockdown.index}.numDays)); %[Edited for Octave]
k{lockdown.index+1}.numDays = postlockdown.numDays;

% Inisialisasi semua state berdasarkan model.allStateName baik ada data fitting maupun tidak
for i=1:numel(k)
    k{i}.y0 = zeros(1,numel(model.allStateName));
    for j=1:numel(model.allStateName)  
        k{i}.(model.allStateName{j}) = zeros(1,1);
    end
end

% Ambil data dari xls atau csv
if(softwareName == 'matlab')
    gabung = getDataModelSEIQRDP(download); %[EDITABLE Matlab]
else
    gabung = getDataModelSEIQRDP(download); %[EDITABLE Octave]
end

% Potong data sesuai tanggal kebijakan, lalu simpan dalam struct k{i}
for i=1:numel(k)
    k{i} = getDataKebijakanFromDate(k{i},gabung,model);
end

k{rfi}.numDays = datenum(k{lockdown.index}.timeFit{1}-k{rfi}.timeFit{end})+lockdown.numDays+postlockdown.numDays; 
% supaya tanggal akhir simulasi tanpa lockdown = dengan lockdown

% [EDITABLE] keterangan simulasi berdasarkan konfigurasi fitting & simulasi lockdown
keteranganSimulasi = ['MulaiFiting' datestr(k{1}.timeFit{1},'yyyy-mm-dd') ...
            'AkhirFitting' datestr(k{rfi}.timeFit{end},'yyyy-mm-dd') ...
          'Lockdown' lockdown.startDate 'Durasi' num2str(lockdown.numDays)];
if(softwareName == 'matlab')
    keteranganSimulasi = ['Matlab_', keteranganSimulasi];
else
    keteranganSimulasi = ['Octave_', keteranganSimulasi];
end

%% [EDITABLE] Lower bound of parameter for estimation constraint
for i=1:numel(k) 
    k{i}.lbParam = zeros(1,size(model.paramName,2));
end
% If you want to manually set parameter: 
% k{1}.lbParam(find(strcmp(model.paramName, 'beta'))) = 0; OR k{1}.lbParam(1) = 0;

%% [EDITABLE] Upper bound of parameter for estimation constraint
for i=1:numel(k) 
    k{i}.ubParam = 2*ones(1,size(model.paramName,2));
end
% If you want to manually set parameter: 
% k{1}.ubParam(find(strcmp(model.paramName, 'beta'))) = 1; OR k{1}.ubParam(1) = 1;

%% [EDITABLE] Initial parameter guess
alpha_guess = 0.06; % protection rate
beta_guess = 1.0; % Infection rate
LT_guess = 5; % latent time in days
QT_guess = 21; % quarantine time in days
lambda_guess = 0.1; %[0.1,0.05]; % recovery rate
kappa_guess = 0.1; %[0.1,0.05]; % death rate
guess = [alpha_guess,...
    beta_guess,...
    1/LT_guess,...
    1/QT_guess,...
    lambda_guess,...
    kappa_guess];
% for i=1:numel(k)
%     k{i}.guessParam = guess;
%     %0.5.*(k{i}.lbParam+k{i}.ubParam); % if first time running, use this.
% end

% Load initial guess from previously fitted param %[EDITABLE]
paramDir = 'results/SEIQRDP/Matlab_MulaiFiting2020-04-30AkhirFitting2020-09-15Lockdown2020-09-14Durasi14/param';
k = loadParam(k,paramDir,model);

% If you want to manually set parameter:
% k{1}.guessParam(find(strcmp(model.paramName, 'beta'))) = 0.5; OR k{1}.guessParam(1) = 0.5;

%% Fit and Simulate Iteratively for Real Fitting Index (rfi) Segments

% Find index for non-fitting data (not available from real world data)
nonFitIndex = [];
for i=1:numel(model.allStateName)
    fitBool = false;
    for j=1:numel(model.fitStateName)
        if(strcmp(model.allStateName{i},model.fitStateName{j}))
            fitBool = true;
        end
    end
    if(~fitBool)
         nonFitIndex = [nonFitIndex i];
    end
end

% First segment only
for j=1:numel(model.fitStateName)
    k{1}.y0(find(strcmp(model.allStateName, model.fitStateName(j)))) = k{1}.(model.fitStateName{j})(1);
end
%Jika data fitting tidak tersedia, set manual:
% jumlah selain yang suceptible (hanya berlaku untuk model ini), jika model lain ubah manual
k{1}.y0(find(strcmp(model.allStateName, 'E'))) = k{1}.y0(find(strcmp(model.allStateName, 'Q'))) + ...
                                                 k{1}.y0(find(strcmp(model.allStateName, 'R'))) + ...
                                                 k{1}.y0(find(strcmp(model.allStateName, 'D')));
k{1}.y0(find(strcmp(model.allStateName, 'I'))) = k{1}.y0(find(strcmp(model.allStateName, 'E')));
notS = sum(k{1}.y0); 
k{1}.y0(find(strcmp(model.allStateName, 'S'))) =  Npop - notS;

% Fitting of the model to real data
k{1}.tolX = 1e-6; k{1}.tolFun = 1e-6; % Optimization options
k{1} = fitModel(k{1},model);
    
% Simulate based on fitted parameters or manually set parameters
k{1} = simulateModel(k{1},k{1}.paramEst,model);
    
% Second segment until last fitting index
for i=2:rfi
    % Initial state conditions for fitting
    k{i}.y0 = zeros(1,numel(model.allStateName));
    % initial value y0 for fitting states
    for j=1:numel(model.fitStateName)
        k{i}.y0(find(strcmp(model.allStateName, model.fitStateName(j)))) = k{i}.(model.fitStateName{j})(1);
    end
    % use initial fitting data from previous segment simulation
    for j=1:numel(nonFitIndex)
        k{i}.y0(nonFitIndex(j)) = k{i-1}.Yest(findIndexFromCell(k{i-1}.timeSim,datetime(k{i}.startDate)),nonFitIndex(j));
    end
    
    % Fitting of the model to real data
    k{i}.tolX = 1e-6; k{i}.tolFun = 1e-6; % Optimization options
    k{i} = fitModel(k{i},model);
    
    % Simulate based on fitted parameters or manually set parameters
    k{i} = simulateModel(k{i},k{i}.paramEst,model);
end

%% Simulate based on fitted parameters or manually set parameters

% [EDITABLE] Simulasi Kebijakan Lockdown Total
k{lockdown.index}.y0 = zeros(1,numel(model.allStateName));
if(datenum(k{lockdown.index}.startDate) > datenum(k{rfi}.timeFit{end})) % jika tanggal lockdown melebihi tanggal akhir fitting
% nilai awal kebijakan lockdown = nilai dari data simulasi kebijakan sebelumnya pada tanggal tsb.
    for i=1:numel(model.fitStateName)
        k{lockdown.index}.y0(find(strcmp(model.allStateName, model.fitStateName{i}))) = k{rfi}.Yest((findIndexFromCell(k{rfi}.timeSim,datetime(k{lockdown.index}.startDate))),find(strcmp(model.allStateName, model.fitStateName{i})));
    end
else
% nilai awal kebijakan lockdown = nilai dari data riil kebijakan sebelumnya pada tanggal tsb.
    for i=1:numel(model.fitStateName)
        k{lockdown.index}.y0(find(strcmp(model.allStateName, model.fitStateName{i}))) = k{rfi}.(model.fitStateName{i})(findIndexFromCell(k{rfi}.timeFit,datetime(k{lockdown.index}.startDate)));
    end
end
% use initial fitting data from previous segment simulation
for j=1:numel(nonFitIndex)
    k{lockdown.index}.y0(nonFitIndex(j)) = k{lockdown.index-1}.Yest(findIndexFromCell(k{lockdown.index-1}.timeSim,datetime(k{lockdown.index}.startDate)),nonFitIndex(j));
end
k{lockdown.index}.paramEst = k{rfi}.paramEst; % set parameter sama seperti kebijakan sebelumnya,
k{lockdown.index}.paramEst(find(strcmp(model.paramName, 'beta'))) = 0; % namun nilai beta di-set nol
k{lockdown.index} = simulateModel(k{lockdown.index},k{lockdown.index}.paramEst,model);

% [EDITABLE] Simulasi Kebijakan Pelonggaran Lockdown Total
k{lockdown.index+1}.y0 = zeros(1,numel(model.allStateName));
k{lockdown.index+1}.y0 = k{lockdown.index}.Yest(findIndexFromCell(k{lockdown.index}.timeSim,datetime(k{lockdown.index+1}.startDate)),:); %ambil data dari k{n-1}.Yest pada tanggal k{n}.startDate
k{lockdown.index+1}.paramEst = k{rfi}.paramEst; % set parameter sama seperti kebijakan sebelum lockdown,
k{lockdown.index+1} = simulateModel(k{lockdown.index+1},k{lockdown.index+1}.paramEst,model);

% Calculate reproduction number R0
k = calcR0(k,model);

%% Comparison of the fitted and real data
%MATLAB default colors:
loadDefaultColors();
global blueDef orangeDef yellowDef purpleDef greenDef lightblueDef brownDef

% [EDITABLE] Property garis untuk plot state sistem, ubah sesuai jumlah state
stateLineProp = cell(numel(model.allStateName),3);
stateLineProp(find(strcmp(model.allStateName,'S')),:) = {blueDef,'-',1.5};
stateLineProp(find(strcmp(model.allStateName,'E')),:) = {purpleDef,'-',1.5};
stateLineProp(find(strcmp(model.allStateName,'I')),:) = {[0.5 0.5 0.5],'-',1.5};
stateLineProp(find(strcmp(model.allStateName,'Q')),:) = {'m','-',1.5};
stateLineProp(find(strcmp(model.allStateName,'R')),:) = {greenDef,'-',1.5};
stateLineProp(find(strcmp(model.allStateName,'D')),:) = {'r','-',1.5};
stateLineProp(find(strcmp(model.allStateName,'P')),:) = {brownDef,'-',1.5};

% Atur property plot kebijakan simulasi berbeda agar lebih mudah dilihat
for i=1:numel(k)
    k{i}.stateLineProp = stateLineProp;
    if(i==lockdown.index || i==lockdown.index+1)
        k{i}.stateLineProp = cell(numel(model.allStateName),3);
        k{i}.stateLineProp(find(strcmp(model.allStateName,'S')),:) = {blueDef,'--',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'E')),:) = {purpleDef,'--',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'I')),:) = {[0.5 0.5 0.5],'--',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'Q')),:) = {'m','--',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'R')),:) = {greenDef,'--',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'D')),:) = {'r','--',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'P')),:) = {brownDef,'--',1.5};
    end
end

% [EDITABLE] Warna garis vertikal kebijakan, ubah sesuai jumlah kebijakan
k{1}.vlColor = 'g';
k{2}.vlColor = lightblueDef;
k{3}.vlColor = yellowDef;
% k{4}.vlColor = 'b';
% k{5}.vlColor = orangeDef;
% k{6}.vlColor = 'k';
% k{7}.vlColor = brownDef;
% k{8}.vlColor = 'm';

% [EDITABLE] Index untuk meletakkan cursor secara otomatis pada nilai maksimum figure
cursorIndexMax{1}.kebijakan = rfi; % indeks kebijakan tanpa lockdown yang akan diberi cursor
cursorIndexMax{1}.stateName = {'I','Q'}; % nama state yang akan diberi cursor
cursorIndexMax{2}.kebijakan = lockdown.index+1; % indeks kebijakan pasca-lockdown yang akan diberi cursor
cursorIndexMax{2}.stateName = {'I','Q'}; % nama state yang akan diberi cursor
% garis batas kapasitas RS 
if(exist('kapasitasRS'))
    if(softwareName == 'matlab')
        kapRS.x = [k{1}.timeSim{1} k{end}.timeSim{end}];
    else
        kapRS.x = [datenum(k{1}.timeSim{1}) datenum(k{end}.timeSim{end})];
    end
    kapRS.y = [kapasitasRS kapasitasRS];
    kapRS.title = ['Kapasitas RS: ' num2str(kapasitasRS)];
    kapRS.nameArray = {'Color','LineStyle','LineWidth'};
    kapRS.lineProp = {'k','-.',1.5};
end

% all states
hFigAllStates = figure('units','normalized','outerposition',[0 0 1 1]); % otomatis full screen
k = plotAllStates(k,model, hFigAllStates,cursorIndexMax);
k = plotVerticalLines(k);
if(exist('kapasitasRS'))
    kapRS.plot = line(kapRS.x,kapRS.y);
    set(kapRS.plot,kapRS.nameArray,kapRS.lineProp);
    plotLegend(k,kapRS.plot,kapRS.title);
else
    plotLegend(k);
end
printLockdownDetails(lockdown);
title(['Fitting & Simulasi Semua State dengan Model ' model.name ' untuk ' namaDaerah ' per Kebijakan']);

% fitting states only
hFigFittingStates = figure('units','normalized','outerposition',[0 0 1 1]);
k = plotFittingStates(k,model, hFigFittingStates,cursorIndexMax);
k = plotVerticalLines(k);
if(exist('kapasitasRS'))
    kapRS.plot = line(kapRS.x,kapRS.y);
    set(kapRS.plot,kapRS.nameArray,kapRS.lineProp);
    plotLegend(k,kapRS.plot,kapRS.title);
else
    plotLegend(k);
end
printLockdownDetails(lockdown);
title(['Fitting & Simulasi State Fitting Saja dengan Model ' model.name ' untuk ' namaDaerah ' per Kebijakan']);

% custom states
customStates = {'E','I','Q','D'}; % [EDITABLE] Ubah nama state sesuai yang ingin di-plot. Pisahkan dengan koma ','.
hFigCustomStates = figure('units','normalized','outerposition',[0 0 1 1]);
k = plotCustomStates(k,customStates,model, hFigCustomStates,cursorIndexMax); 
k = plotVerticalLines(k);
if(exist('kapasitasRS'))
    kapRS.plot = line(kapRS.x,kapRS.y);
    set(kapRS.plot,kapRS.nameArray,kapRS.lineProp);
    plotLegend(k,kapRS.plot,kapRS.title);
else
    plotLegend(k);
end
printLockdownDetails(lockdown);
stringCustom = [];
for i=1:numel(customStates)
    stringCustom = [stringCustom ' ' customStates{i}];
end
title(['Fitting & Simulasi State ' stringCustom ' dengan model ' model.name ' untuk ' namaDaerah ' per Kebijakan']);

% save peak info
saveDir = [mainDir '/results/' model.name '/' keteranganSimulasi '/peakInfo/'];
mkdir(saveDir);
savePeakInfo(k,saveDir);

% save time series into csv
saveDir = [mainDir '/results/' model.name '/' keteranganSimulasi '/timeSeries/'];
mkdir(saveDir);
saveTimeSeries(k,saveDir,model);

% print and save fitted parameters
printParam(k,model);
saveDir = [mainDir '/results/' model.name '/' keteranganSimulasi '/param/'];
mkdir(saveDir);
saveParam(k,saveDir,model);

figure('units','normalized','outerposition',[0.25 0.25 0.4 0.2]);
annotation('textbox',[0 0 1 1], 'FontSize',12, 'String', ...
    {['Pastikan semua grafik sudah benar, terutama penempatan cursor.'],...
    ['Jika sudah, buka Command Window untuk menyimpan grafik.']});

saveDir = [mainDir '/results/' model.name '/' keteranganSimulasi '/figure/'];
mkdir(saveDir); cd(saveDir);
if(softwareName == 'matlab')
    prompt = 'Apakah Anda ingin menyimpan semua grafik secara otomatis?\n Jika ya, masukkan [Y]\n Jika tidak, masukkan sembarang\n';
else
    prompt = "Apakah Anda ingin menyimpan semua grafik secara otomatis?\n Jika ya, masukkan [Y]\n Jika tidak, masukkan sembarang\n";
end
saveGraph = input(prompt, 's');
if(saveGraph == 'Y' || saveGraph == 'y')
saveas(hFigAllStates,[saveDir '/AllStates.fig']);
saveas(hFigAllStates,[saveDir '/AllStates.png']);
saveas(hFigFittingStates,[saveDir '/FittingStates.fig']);
saveas(hFigFittingStates,[saveDir '/FittingStates.png']);
saveas(hFigCustomStates,[saveDir '/CustomStates.fig']);
saveas(hFigCustomStates,[saveDir '/CustomStates.png']);
fprintf(['Grafik berhasil disimpan di:']); saveDir
else
    fprintf(['Grafik TIDAK disimpan.\n Jika masih ingin menyimpan, simpan secara manual atau jalankan ulang script [F5].\n']);
end