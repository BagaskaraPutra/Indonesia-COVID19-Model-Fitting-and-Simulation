%% SQRshadow
% Semua yang ada komentar [EDITABLE] dapat diprioritaskan untuk diedit jika
% ada perubahan model, parameter model, parameter plotting, kebijakan, dll.

%By: Bagaskara P.P., Last Modified: 2020-10-15

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

% [EDITABLE] Jika ingin mengubah model, state fiting, dan parameter; edit variable2 di bawah ini:
namaDaerah = 'DKI Jakarta';
model.name = 'SQRshadow';
model.dir = ['../models/SQRshadow'];
model = loadModel(model); cd(mainDir);
global Npop; Npop = 10770487; % DKI Jakarta total population
% kapasitasRS = 12150; % dari kapasitas RS 70% pada 28 Agustus 2020

% [EDITABLE] Kebijakan: disimpan dalam cell struct k{i}, di mana i adalah urutan kebijakan
% ubah startDate & endDate sesuai kebijakan. Jika tidak tahu endDate, tidak usah diisi, data terakhir yang diambil.
% numDays = berapa hari akan disimulasikan setelah hari terakhir kebijakan?
% k{1}.name = 'PSBB Masa Transisi';
k{1}.name = 'Data Dummy'; 
k{1}.startDate = '2020-06-05'; k{1}.endDate = '2020-09-28'; k{1}.numDays = 100; %730;
%k{1}.endDate = '2020-09-13'; k{1}.numDays = 14;
% k{2}.name = 'PSBB Total 14 September 2020';
% k{2}.startDate = '2020-09-14'; k{2}.endDate = '2020-09-28'; k{2}.numDays = 730;
rfi = numel(k);

% Inisialisasi semua state berdasarkan model.allStateName baik ada data fitting maupun tidak
for i=1:numel(k)
    k{i}.y0 = zeros(1,numel(model.allStateName));
    for j=1:numel(model.allStateName)
        k{i}.(model.allStateName{j}) = zeros(1,1);
    end
end

% Ambil data dari xls atau csv
if(softwareName == 'matlab')
    lama = getDataIstilahLamaModelSQRshadow('COVID19_DkiJakarta_IstilahLama.xls'); %[EDITABLE Matlab]
    baru = getDataIstilahBaruModelSQRshadow('COVID19_DkiJakarta_IstilahBaru.xls'); %[EDITABLE Matlab]
else
    lama = getDataIstilahLamaModelSQRshadow('COVID19_DkiJakarta_IstilahLama.csv'); %[EDITABLE Octave]
    baru = getDataIstilahBaruModelSQRshadow('COVID19_DkiJakarta_IstilahBaru.csv'); %[EDITABLE Octave]
end

% Gabung data istilah lama (sampai dengan 16 Juli) & istilah baru (setelah 16 Juli)
for i=1:numel(model.fitStateName)
    gabung.(model.fitStateName{i}) = [lama.(model.fitStateName{i}) baru.(model.fitStateName{i})];
end
gabung.timeFit = [lama.timeFit baru.timeFit];

% Potong data sesuai tanggal kebijakan, lalu simpan dalam struct k{i}
for i=1:numel(k)
    k{i} = getDataKebijakanFromDate(k{i},gabung,model);
end

% [EDITABLE] keterangan simulasi berdasarkan konfigurasi fitting & simulasi lockdown
keteranganSimulasi = ['DummyData'];

%% [EDITABLE] Simulate manually set parameters

for i=1:numel(k) 
%     k{i}.paramDummy(find(strcmp(model.paramName, 'beta'))) = 0.08;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Rt'))) = 0.98; 
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Tinf'))) = 8.53;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Trecov'))) = 16.54;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Tdeath'))) = 200;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'lambda'))) = 1e-5;
    
%     k{i}.paramDummy(find(strcmp(model.paramName, 'beta'))) = 2e-1;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Rt'))) = 2.0; 
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Tinf'))) = 6; 
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Trecov'))) = 15;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'Tdeath'))) = 20;
%     k{i}.paramDummy(find(strcmp(model.paramName, 'lambda'))) = 5e-2;

    k{i}.paramDummy(find(strcmp(model.paramName, 'beta'))) = 2e-1;
    k{i}.paramDummy(find(strcmp(model.paramName, 'gamma'))) = 1/15;
    k{i}.paramDummy(find(strcmp(model.paramName, 'muI'))) = 1/20;
    k{i}.paramDummy(find(strcmp(model.paramName, 'beta_s'))) = 2.0/6;
    k{i}.paramDummy(find(strcmp(model.paramName, 'lambda'))) = 5e-2;
end

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
k{1}.y0(find(strcmp(model.allStateName, 'Q_s'))) = k{1}.y0(find(strcmp(model.allStateName, 'Q'))); %...
%                                                    + k{1}.y0(find(strcmp(model.allStateName, 'R'))) ...
%                                                    + k{1}.y0(find(strcmp(model.allStateName, 'D')));
k{1}.y0(find(strcmp(model.allStateName, 'R_s'))) = 10; %k{1}.y0(find(strcmp(model.allStateName, 'R')));
k{1}.y0(find(strcmp(model.allStateName, 'D_s'))) = k{1}.y0(find(strcmp(model.allStateName, 'D')));
notS = sum(k{1}.y0); 
k{1}.y0(find(strcmp(model.allStateName, 'S'))) =  Npop - notS;
k{1} = simulateModel(k{1},k{1}.paramDummy,model);

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
    
    % Simulate based on fitted parameters or manually set parameters
    k{i} = simulateModel(k{i},k{i}.paramDummy,model);
end

% Calculate reproduction number R0
% k = calcR0(k,model);

%% Make simulated data into fitting data
for fIdx=1:numel(model.fitStateName)
    k{1}.(model.fitStateName{fIdx}) = k{1}.Yest(1:numel(k{1}.timeFit),...
        find(strcmp(model.allStateName,model.fitStateName{fIdx})))';
end

%% Fit dummy data
% [EDITABLE] Lower bound of parameter for estimation constraint
for i=1:numel(k) 
%     k{i}.lbParam = zeros(1,size(model.paramName,2));

%     k{i}.lbParam(find(strcmp(model.paramName, 'beta'))) = 0;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Rt'))) = 0.1;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Tinf'))) = 1.5;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Trecov'))) = 7;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Tdeath'))) = 6;
%     k{i}.lbParam(find(strcmp(model.paramName, 'lambda'))) = 0;

%     k{i}.lbParam(find(strcmp(model.paramName, 'beta'))) = 0;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Rt'))) = 0.1;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Tinf'))) = 1.5;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Trecov'))) = 7;
%     k{i}.lbParam(find(strcmp(model.paramName, 'Tdeath'))) = 6;
%     k{i}.lbParam(find(strcmp(model.paramName, 'lambda'))) = 0;

    k{i}.lbParam(find(strcmp(model.paramName, 'beta'))) = 0;
    k{i}.lbParam(find(strcmp(model.paramName, 'gamma'))) = 0;
    k{i}.lbParam(find(strcmp(model.paramName, 'muI'))) = 0;
    k{i}.lbParam(find(strcmp(model.paramName, 'beta_s'))) = 0;
    k{i}.lbParam(find(strcmp(model.paramName, 'lambda'))) = 0;
end

% [EDITABLE] Upper bound of parameter for estimation constraint
for i=1:numel(k) 
%     k{i}.ubParam = 1*ones(1,size(model.paramName,2));

%     k{i}.ubParam(find(strcmp(model.paramName, 'beta'))) = 0.1;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Rt'))) = 1.0;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Tinf'))) = 10;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Trecov'))) = 20;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Tdeath'))) = 210;
%     k{i}.ubParam(find(strcmp(model.paramName, 'lambda'))) = 5e-5;

%     k{i}.ubParam(find(strcmp(model.paramName, 'beta'))) = 0.5;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Rt'))) = 4.0;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Tinf'))) = 10;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Trecov'))) = 50;
%     k{i}.ubParam(find(strcmp(model.paramName, 'Tdeath'))) = 41; 
%     k{i}.ubParam(find(strcmp(model.paramName, 'lambda'))) = 0.1;

%     k{i}.ubParam(find(strcmp(model.paramName, 'beta'))) =10*2e-1;
%     k{i}.ubParam(find(strcmp(model.paramName, 'gamma'))) = 10*1/15;
%     k{i}.ubParam(find(strcmp(model.paramName, 'muI'))) = 10*1/20;
%     k{i}.ubParam(find(strcmp(model.paramName, 'beta_s'))) = 10*2.0/6;
%     k{i}.ubParam(find(strcmp(model.paramName, 'lambda'))) = 10*5e-2;
    k{i}.ubParam = 10.*k{i}.paramDummy;
end

% [EDITABLE] Initial parameter guess
for i=1:numel(k)
    k{i}.guessParam = 0.5.*(k{i}.lbParam+k{i}.ubParam); % if first time running, use this.
%     k{i}.guessParam = [0.0500000000000000,2.05000000000000,30.5995792112422,59.9999841850553,5.75000000000000,0.0999999999999778];
end

% Fitting of the model to real data
% k{1}.tolX = 1.9e-11; k{1}.tolFun = 1.9e-11; % Optimization options
k{1}.tolX = 1e-12; k{1}.tolFun = 1e-12; % Optimization options
k{1} = fitModel(k{1},model);
    
% Simulate based on fitted parameters or manually set parameters
k{1} = simulateModel(k{1},k{1}.paramEst,model);

%% Comparison of the fitted and real data
%MATLAB default colors:
loadDefaultColors();
global blueDef orangeDef yellowDef purpleDef greenDef lightblueDef brownDef

% [EDITABLE] Property garis untuk plot state sistem, ubah sesuai jumlah state
stateLineProp = cell(numel(model.allStateName),3);
stateLineProp(find(strcmp(model.allStateName,'S')),:) = {blueDef,'-',2};
stateLineProp(find(strcmp(model.allStateName,'Q')),:) = {'r','-',2};
stateLineProp(find(strcmp(model.allStateName,'R')),:) = {greenDef,'-',2};
stateLineProp(find(strcmp(model.allStateName,'D')),:) = {purpleDef,'-',2};
stateLineProp(find(strcmp(model.allStateName,'Q_s')),:) = {'m','-.',1.5};
stateLineProp(find(strcmp(model.allStateName,'R_s')),:) = {'g','-.',1.5};
stateLineProp(find(strcmp(model.allStateName,'D_s')),:) = {brownDef,'-.',1.5};

% Atur property plot kebijakan simulasi berbeda agar lebih mudah dilihat
for i=1:numel(k)
    k{i}.stateLineProp = stateLineProp;
    if(i==1 || i==1+1)
        k{i}.stateLineProp(find(strcmp(model.allStateName,'S')),:) = {blueDef,'--',2};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'Q')),:) = {'r','--',2};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'R')),:) = {greenDef,'--',2};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'D')),:) = {purpleDef,'--',2};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'Q_s')),:) = {'m',':',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'R_s')),:) = {'g',':',1.5};
        k{i}.stateLineProp(find(strcmp(model.allStateName,'D_s')),:) = {brownDef,':',1.5};
    end
end

% [EDITABLE] Warna garis vertikal kebijakan, ubah sesuai jumlah kebijakan
k{1}.vlColor = 'g';
% k{2}.vlColor = lightblueDef;
% k{3}.vlColor = yellowDef;
% k{4}.vlColor = 'b';
% k{5}.vlColor = orangeDef;
% k{6}.vlColor = 'k';
% k{7}.vlColor = brownDef;
% k{8}.vlColor = 'm';

% [EDITABLE] Index untuk meletakkan cursor secara otomatis pada nilai maksimum figure
cursorIndexMax{1}.kebijakan = 1; % indeks kebijakan tanpa lockdown yang akan diberi cursor
cursorIndexMax{1}.stateName = {'Q','Q_s'}; % nama state yang akan diberi cursor

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
% printLockdownDetails(lockdown);
title(['Fitting & Simulasi Semua State dengan Model ' model.name ' Data Dummy']);

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
% printLockdownDetails(lockdown);
title(['Simulasi State Fitting Saja dengan Model ' model.name ' Data Dummy']);

% custom states
customStates = {'Q','D','Q_s','D_s'}; % [EDITABLE] Ubah nama state sesuai yang ingin di-plot. Pisahkan dengan koma ','.
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
% printLockdownDetails(lockdown);
stringCustom = [];
for i=1:numel(customStates)
    stringCustom = [stringCustom ' ' customStates{i}];
end
title(['Simulasi State ' stringCustom ' dengan model ' model.name ' Data Dummy']);

%% Save results
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