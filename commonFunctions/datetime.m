function d = datetime(t,argString,infmt);
  if(nargin > 1)
    if(argString == 'InputFormat')
      dateEl = textscan(t,'%d/%d/%d');
      if(infmt == 'dd/MM/yyyy')
      %    d = [dateEl{3} dateEl{2} dateEl{1} 0 0 0];
        d = datevec([num2str(dateEl{3}) '-' num2str(dateEl{2}) '-' num2str(dateEl{1})]);    
      elseif(infmt == 'MM/dd/yyyy')
        d = datevec([num2str(dateEl{3}) '-' num2str(dateEl{1}) '-' num2str(dateEl{2})]);
      end
    end
  else
%    disp('Using Default Format');
    d = datevec(t);
  end

  d(:,6) = round(d(:,6));  % Round seconds
  dd = d(:,3);  % Original DayNumber
  quot = [ 60 60 24 ]; %  [ ss-->mm  mm-->hh  hh-->dd ]
  ind  = [ 6  5  4  ];
  for ii = 1 : 3
      p = fix( d(:,ind(ii)) / quot(ii) );
   d(:,ind(ii)-0) = d(:,ind(ii)-0) - p * quot(ii);
   d(:,ind(ii)-1) = d(:,ind(ii)-1) + p;
  end

  % Check if DayNumber has changed
  ii = find( d(:,3) > dd );
  if isempty(ii)
     d(:,1:3) = d(:,1:3) + all( d(:,1:3) == 0  , 2 ) * [ -1 12 31 ];
     return
  end

  % New Date
  [d(ii,1),d(ii,2),d(ii,3)] = datevec( datenum(d(ii,1),d(ii,2),d(ii,3)) );
  d(:,1:3) = d(:,1:3) + all( d(:,1:3) == 0  , 2 ) * [ -1 12 31 ];