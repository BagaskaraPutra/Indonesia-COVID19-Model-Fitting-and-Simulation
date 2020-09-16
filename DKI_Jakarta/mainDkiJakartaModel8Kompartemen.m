%% 8 compartments model DKI Jakarta per Kebijakan:
% Semua yang ada komentar [EDITABLE] dapat diprioritaskan untuk diedit jika
% ada perubahan model, parameter model, parameter plotting, kebijakan, dll.

%By: Bobby R.D., Last Modified: 2020-04-01
%By: Bagaskara P.P., Last Modified: 2020-09-02

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
model.name = '8Kompartemen';
model.dir = ['../model8Kompartemen'];
model = loadModel(model);
global Npop; Npop = 10770487; % DKI Jakarta total population
% kapasitasRS = 12150; % dari kapasitas RS 70% pada 31 Agustus

% [EDITABLE] Kebijakan: disimpan dalam cell struct k{i}, di mana i adalah urutan kebijakan
% ubah startDate & endDate sesuai kebijakan. Jika tidak tahu endDate, tidak usah diisi, data terakhir yang diambil.
% numDays = berapa hari akan disimulasikan setelah hari terakhir kebijakan?
k{1}.name = 'Istilah Lama'; 
k{1}.startDate = '2020-03-01'; k{1}.endDate = '2020-06-18'; k{1}.numDays = 730;
rfi = numel(k); % real fitting index: indeks kebijakan terakhir yang merupakan data fitting nyata

% Inisialisasi semua state berdasarkan model.allStateName baik ada data fitting maupun tidak
for i=1:numel(k)
    for j=1:numel(model.allStateName)
        k{i}.(model.allStateName{j}) = zeros(1,1);
    end
end

% Ambil data dari xls atau csv
if(softwareName == 'matlab')
    lama = getDataIstilahLamaModel8Kompartemen('COVID19_DkiJakarta_IstilahLama.xls'); %[EDITABLE]
else
    lama = getDataIstilahLamaModel8Kompartemen('COVID19_DkiJakarta_IstilahLama.csv'); %[EDITABLE]
end

% Gabung data istilah lama (sampai dengan 16 Juli)
for i=1:numel(model.fitStateName)
    gabung.(model.fitStateName{i}) = [lama.(model.fitStateName{i})];
end
gabung.timeFit = [lama.timeFit];

% Potong data sesuai tanggal kebijakan, lalu simpan dalam struct k{i}
for i=1:numel(k)
    k{i} = getDataKebijakanFromDate(k{i},gabung,model);
end

% [EDITABLE] keterangan simulasi berdasarkan konfigurasi fitting & simulasi lockdown
keteranganSimulasi = ['AkhirFitting' datestr(k{rfi}.timeFit{end},'yyyy-mm-dd')];

%% [EDITABLE] Lower bound of parameter for estimation constraint
for i=1:numel(k) 
    k{i}.lbParam = zeros(1,size(model.paramName,2));
end
% If you want to manually set parameter: 
% k{1}.lbParam(find(strcmp(model.paramName, 'beta'))) = 0; OR k{1}.lbParam(1) = 0;
k{1}.lbParam(find(strcmp(model.paramName, 'f1'))) = 864;
k{1}.lbParam(find(strcmp(model.paramName, 'f2'))) = 432;
k{1}.lbParam(find(strcmp(model.paramName, 'f3'))) = 864;
k{1}.lbParam(find(strcmp(model.paramName, 'd'))) = 115.2;

%% [EDITABLE] Upper bound of parameter for estimation constraint
for i=1:numel(k) 
    k{i}.ubParam = 1e-7*ones(1,size(model.paramName,2));
end
% If you want to manually set parameter: 
% k{1}.ubParam(find(strcmp(model.paramName, 'beta'))) = 1; OR k{1}.ubParam(1) = 1;

k{1}.ubParam(find(strcmp(model.paramName, 'q1'))) = 0.2;
k{1}.ubParam(find(strcmp(model.paramName, 'q2'))) = 0.1;

k{1}.ubParam(find(strcmp(model.paramName, 'beta2'))) = 1.0;
k{1}.ubParam(find(strcmp(model.paramName, 'beta3'))) = 1e-2;

k{1}.ubParam(find(strcmp(model.paramName, 'eta1'))) = 1.0;
k{1}.ubParam(find(strcmp(model.paramName, 'eta2'))) = 1.0;
k{1}.ubParam(find(strcmp(model.paramName, 'eta3'))) = 1e-2;

k{1}.ubParam(find(strcmp(model.paramName, 'delta1'))) = 1e-3;
k{1}.ubParam(find(strcmp(model.paramName, 'delta2'))) = 1e-2;
k{1}.ubParam(find(strcmp(model.paramName, 'theta'))) = 1/2.9;

k{1}.ubParam(find(strcmp(model.paramName, 'f1'))) = 2160;
k{1}.ubParam(find(strcmp(model.paramName, 'f2'))) = 1440;
k{1}.ubParam(find(strcmp(model.paramName, 'f3'))) = 2592;
k{1}.ubParam(find(strcmp(model.paramName, 'd'))) = 172.8;
k{1}.ubParam(find(strcmp(model.paramName, 'betav1'))) = 3e-7;
k{1}.ubParam(find(strcmp(model.paramName, 'theta1'))) = 1/10;
k{1}.ubParam(find(strcmp(model.paramName, 'sigma'))) = 1/5.2;

%% [EDITABLE] Initial parameter guess
for i=1:numel(k)
%     k{i}.guessParam = 0.5.*(k{i}.lbParam+k{i}.ubParam); % if first time running, use this.
    k{i}.guessParam = [0.104019975566408 0.0254649082270350 4.34204393067696e-08 2.94611788769311e-12 2.36215340041881e-08 1.77648151134506e-08 1.77499414139147e-08 7.45421016285879e-09 0.00586935331811477 0.00872402720537740 0.00383283240925105 0.000957940140938790 0.00104392455336793 0.0505786405131493 1458.26256241399 720.016567197310 1654.22654225347 151.964301792858 9.93555594062767e-14 0.000114226319951830 0.00104818413747778]; %2020-04-20-22.06
end
% If you want to manually set parameter:
% k{1}.guessParam(find(strcmp(model.paramName, 'beta'))) = 0.5; OR k{1}.guessParam(1) = 0.5;
k{1}.guessParam = [0.104019975566408 0.0254649082270350 4.34204393067696e-08 2.94611788769311e-12 2.36215340041881e-08 1.77648151134506e-08 1.77499414139147e-08 7.45421016285879e-09 0.00586935331811477 0.00872402720537740 0.00383283240925105 0.000957940140938790 0.00104392455336793 0.0505786405131493 1458.26256241399 720.016567197310 1654.22654225347 151.964301792858 9.93555594062767e-14 0.000114226319951830 0.00104818413747778]; %2020-04-20-22.06

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
    k{1}.y0(find(strcmp(model.allStateName, model.fitStateName{j}))) = k{1}.(model.fitStateName{j})(1);
end
%Jika data fitting tidak tersedia, set manual:
k{1}.y0(find(strcmp(model.allStateName, 'Sq'))) = 0;
k{1}.y0(find(strcmp(model.allStateName, 'E1'))) = 0.87*k{1}.('E2')(1);
k{1}.y0(find(strcmp(model.allStateName, 'E2'))) = 0.13*k{1}.('E2')(1);
k{1}.y0(find(strcmp(model.allStateName, 'V'))) = 21080;
% jumlah selain yang suceptible (hanya berlaku untuk model ini), jika model lain ubah manual
notS = sum(k{1}.y0)-k{1}.y0(find(strcmp(model.allStateName, 'V'))); 
k{1}.y0(find(strcmp(model.allStateName, 'S'))) =  Npop - notS;

% Fitting of the model to real data
k{1}.tolX = 2.0e-7; k{1}.tolFun = 2.0e-7; % Optimization options
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
        k{i}.y0(j) = k{i-1}.Yest(findIndexFromCell(k{i-1}.timeSim,datetime(k{i}.startDate)),j);
    end
    
    % Fitting of the model to real data
    k{i}.tolX = 2.0e-7; k{i}.tolFun = 2.0e-7; % Optimization options
    k{i} = fitModel(k{i},model);
    
    % Simulate based on fitted parameters or manually set parameters
    k{i} = simulateModel(k{i},k{i}.paramEst,model);
end

%% Comparison of the fitted and real data
%MATLAB default colors:
loadDefaultColors();
global blueDef orangeDef yellowDef purpleDef greenDef lightblueDef brownDef

% [EDITABLE] Property garis untuk plot state sistem, ubah sesuai jumlah state
stateLineProp = cell(numel(model.allStateName),3);
stateLineProp(1,:) = {blueDef,'-',1.5};
stateLineProp(2,:) = {lightblueDef,'-',1.5};
stateLineProp(3,:) = {brownDef,'-',1.5};
stateLineProp(4,:) = {orangeDef,'-',1.5};
stateLineProp(5,:) = {'m','-',1.5};
stateLineProp(6,:) = {greenDef,'-',1.5};
stateLineProp(7,:) = {'r','-',1.5};
stateLineProp(8,:) = {purpleDef,'-',1.5};

% Atur property plot kebijakan simulasi berbeda agar lebih mudah dilihat
for i=1:numel(k)
    k{i}.stateLineProp = stateLineProp;
end

% [EDITABLE] Warna garis vertikal kebijakan, ubah sesuai jumlah kebijakan
k{1}.vlColor = 'g';

% [EDITABLE] Index untuk meletakkan cursor secara otomatis pada nilai maksimum figure
cursorIndexMax{1}.kebijakan = rfi; % indeks kebijakan tanpa lockdown yang akan diberi cursor
cursorIndexMax{1}.stateName = 'H'; % nama state yang akan diberi cursor

% garis batas kapasitas RS 
if(exist('kapasitasRS'))
    kapRS.x = [datetime(k{1}.timeSim(1)) datetime(k{end}.timeSim(end))];
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
title(['Fitting & Simulasi State Fitting Saja dengan Model ' model.name ' untuk ' namaDaerah ' per Kebijakan']);

% custom states
customStates = {'H','D'}; % [EDITABLE] Ubah nama state sesuai yang ingin di-plot. Pisahkan dengan koma ','.
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