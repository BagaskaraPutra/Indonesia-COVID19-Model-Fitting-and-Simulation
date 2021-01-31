function [k] = getDataModelSEIQRDP(download)
% collects the updated data from the COVID-19 epidemy from the
% John Hopkins university [1]
% 
% References:
% [1] https://github.com/CSSEGISandData/COVID-19
% 
% Author: E. Cheynet - Last modified - 20-03-2020
% Edited: Bagaskara P.P. - Last modified - 15-09-2020 

%% Import the data
Location = 'Indonesia';
status = {'confirmed','deaths','recovered'};
address = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/';
% address = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/';
ext = '.csv';
global softwareName;

filename = ['time_series_covid19_',status{1},'_global'];
fullName = [address,filename,ext];
if(download)
%     urlwrite(fullName,[filename,ext]);
    websave([filename,ext], fullName);
end
if(softwareName == 'matlab')
   opts = detectImportOptions([filename,ext]);
end

opts.VariableNames{1,1} = 'ProvinceState';
opts.VariableNames{1,2} = 'CountryRegion';
opts.VariableNames{1,3} = 'Lat';
opts.VariableNames{1,4} = 'Long';
    
opts.VariableTypes{1,1} = 'string';
opts.VariableTypes{1,2} = 'string';
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

for ii=1:numel(status)
    filename = ['time_series_covid19_',status{ii},'_global'];
    fullName = [address,filename,ext];
    if(download)
%         urlwrite(fullName,[filename,ext]);
        websave([filename,ext], fullName);
    end
    if strcmpi(status{ii},'Confirmed')
        if(softwareName == 'matlab')
            tableConfirmed =readtable([filename,ext], opts);
        else
            fid = fopen([filename,ext]);
            [headerWithDate,k.C] = extractDataFromLocation(fid,Location);
            fclose(fid);
        end
    elseif strcmpi(status{ii},'Deaths')
        if(softwareName == 'matlab')
            tableDeaths =readtable([filename,ext], opts);
        else
            fid = fopen([filename,ext]);
            [headerWithDate,k.D] = extractDataFromLocation(fid,Location);
            fclose(fid);
        end
    elseif strcmpi(status{ii},'Recovered')
        if(softwareName == 'matlab')
            tableRecovered =readtable([filename,ext], opts);
        else
            fid = fopen([filename,ext]);
            [headerWithDate,k.R] = extractDataFromLocation(fid,Location);
            fclose(fid);
        end
    else
        error('Unknown status')
    end
end
if(softwareName == 'matlab')
    fid = fopen([filename,ext]);
    tanggal = textscan(fid,repmat('%s',1,size(tableRecovered,2)), 1, 'Delimiter',',');
    tanggal(1:4)=[];  
%     k.timeFit = datetime([k.timeFit{1:end}])+years(2000);
    fclose(fid);
else
    tanggal = headerWithDate{1}(5:end);
end
for i=1:numel(tanggal)
    if(softwareName == 'matlab')
        pisahTanggal = textscan(tanggal{i}{1},'%d/%d/%d');
    else
        pisahTanggal = textscan(tanggal{i},'%d/%d/%d');
    end
    if(pisahTanggal{1} <=12 && pisahTanggal{2} > 12)
        inputFormat = 'MM/dd/yyyy';
%         disp('US Date Format');
    elseif(pisahTanggal{1} > 12 && pisahTanggal{2} <= 12)
        inputFormat = 'dd/MM/yyyy';
%        disp('Format tanggal Indo');
    end
end
for i=1:numel(tanggal)
    if(exist('inputFormat'))
        if(datenum(datetime(tanggal{i},'InputFormat',inputFormat)) < datenum(2000,0,0))
            k.timeFit{i} = datetime(datestr(datenum(datetime(tanggal{i},'InputFormat',inputFormat))+datenum(2000,0,0)));
        else
            k.timeFit{i} = datetime(tanggal{i},'InputFormat',inputFormat);
        end
    else
        k.timeFit{i} = datetime(tanggal{i});
    end
end
if(softwareName == 'matlab')
    try
      indR = find(contains(tableRecovered.CountryRegion,Location)==1)
      indC = find(contains(tableConfirmed.CountryRegion,Location)==1)
      indD = find(contains(tableDeaths.CountryRegion,Location)==1)
    catch exception
      searchLoc = strfind(tableRecovered.CountryRegion,Location)
      indR = find([searchLoc{:}]==1)
      searchLoc = strfind(tableConfirmed.CountryRegion,Location)
      indC = find([searchLoc{:}]==1)
      searchLoc = strfind(tableDeaths.CountryRegion,Location)
      indD = find([searchLoc{:}]==1)
    end
    disp(tableRecovered(indR,1:2));
    indR = indR(1);
    k.R = table2array(tableRecovered(indR,5:end));
    k.D = table2array(tableDeaths(indD,5:end));
    k.Q = table2array(tableConfirmed(indC,5:end))-k.R-k.D;  
else
    k.Q = k.C - k.R - k.D;
end

    function [hdt,kdata] = extractDataFromLocation(fid,Location)
        rows = textscan(fid,"%s","Delimiter","\n");
        for id=1:numel(rows{1})
            cols = textscan(rows{1}{id},"%s","Delimiter",",");
            if id==1
                hdt = cols;
            end
            if(strfind(rows{1}{id},Location))
                kdata = zeros(1,numel(cols{1})-4);
                for jd=5:numel(cols{1})
                    kdata(jd-4) = str2num(cols{1}{jd});
                end
            end
        end
    end

end
