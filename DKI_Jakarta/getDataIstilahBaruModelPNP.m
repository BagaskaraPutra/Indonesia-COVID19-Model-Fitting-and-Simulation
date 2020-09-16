function k = getDataIstilahBaruModelPNP(fileName)
    global softwareName;
    headerName = {'Suspek','Probable','Pelaku Perjalanan','Kontak Erat','Discarded','Positif'}; % samakan dengan yang ada di file Excel
    if(softwareName == 'matlab')
        table = importdata(fileName);
        headerRow = find(ismember(table.textdata,'Tanggal')); % ini bisa diganti string apa pun yang sebaris 
        for i=1:numel(headerName)
            headerCol{i} = find(ismember(table.textdata(headerRow,:),headerName{i}));
        end
    else
        delimiterType = ';'; % tergantung file menggunakan format pemisah cell apa
        table = importdata(fileName,delimiterType);
        textSplit = [];
        for i=1:numel(table.textdata)
          tempSplit = strsplit(table.textdata{i},delimiterType,"collapsedelimiters",false);
          if(numel(tempSplit) > 1)
            textSplit = [textSplit; tempSplit];  
          end
        end
        headerRow = find(ismember(textSplit,'Tanggal'));
        for i=1:numel(headerName)
          headerCol{i} = find(ismember(textSplit(headerRow,:),headerName{i}));
        end
    end
    
    % Hati-hati! String harus ditulis benar dan sesuai dengan file Excel
    SuspekIsolasiRS = getSubHeaderData('Suspek','Perawatan RS'); 
    SuspekIsolasiRumah = getSubHeaderData('Suspek','Isolasi di Rumah');
    SuspekMeninggal = getSubHeaderData('Suspek','Meninggal');
    SuspekSelesaiIsolasi = getSubHeaderData('Suspek','Selesai Isolasi');
    
    ProbableIsolasiRS = getSubHeaderData('Probable','Perawatan RS');
    ProbableMeninggal = getSubHeaderData('Probable','Meninggal');
    ProbableSelesaiIsolasi = getSubHeaderData('Probable','Selesai Isolasi');
    
    PelakuPerjalananIsolasiRumah = getSubHeaderData('Pelaku Perjalanan','Isolasi di Rumah');
    PelakuPerjalananSelesaiIsolasi = getSubHeaderData('Pelaku Perjalanan','Selesai Isolasi');
    
    KontakEratIsolasiRumah = getSubHeaderData('Kontak Erat','Isolasi di Rumah');
    KontakEratSelesaiIsolasi = getSubHeaderData('Kontak Erat','Selesai Isolasi');
    
    DiscardedMeninggal = getSubHeaderData('Discarded','Meninggal');
    DiscardedSelesaiIsolasi = getSubHeaderData('Discarded','Selesai Isolasi');
    
    PositifIsolasiRS =  getSubHeaderData('Positif','Dirawat');
    PositifSembuh = getSubHeaderData('Positif','Sembuh');
    PositifMeninggal = getSubHeaderData('Positif','Meninggal');
    PositifIsolasiRumah = getSubHeaderData('Positif','Self Isolation');
    
    k.NI = SuspekIsolasiRS + SuspekIsolasiRumah + ProbableIsolasiRS + PelakuPerjalananIsolasiRumah + KontakEratIsolasiRumah;
    k.NR = SuspekSelesaiIsolasi + ProbableSelesaiIsolasi + PelakuPerjalananSelesaiIsolasi + KontakEratSelesaiIsolasi + DiscardedSelesaiIsolasi;
    k.P = PositifIsolasiRS + PositifIsolasiRumah;
    k.R = PositifSembuh;
    k.ND = SuspekMeninggal + ProbableMeninggal + DiscardedMeninggal;
    k.D = PositifMeninggal;

    tanggal = rmnondate(rmmissing(table.textdata(headerRow+2:end,1)));
    for i=1:numel(tanggal)
      pisahTanggal = textscan(tanggal{i},'%d/%d/%d');
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
        k.timeFit{i} = datetime(tanggal{i},'InputFormat',inputFormat);
      else
        k.timeFit{i} = datetime(tanggal{i});
      end
    end
    
    function subHeaderData = getSubHeaderData(header,subHeader)
        if(softwareName == 'matlab')
            nameIndex = find(strcmp(headerName,header));
            lower = headerCol{nameIndex};

            if(nameIndex == numel(headerCol) )
                upper = size(table.textdata,2);
            else
                upper = headerCol{find(strcmp(headerName,header))+1}-1;
            end
            subHeaderData = nan2zero(table.data(:,lower-2+find(ismember(table.textdata(headerRow+1,lower:upper),subHeader))));
        else
            nameIndex = find(strcmp(headerName,header));
            lower = headerCol{nameIndex};

            if(nameIndex == numel(headerCol) )
                upper = size(textSplit,2);
            else
                upper = headerCol{find(strcmp(headerName,header))+1}-1;
            end
            subHeaderData = nan2zero(table.data(:,lower-2+find(ismember(textSplit(headerRow+1,lower:upper),subHeader)))); 
        end
    end
end
