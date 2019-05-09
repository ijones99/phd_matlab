function metaData = load_metadata_to_struct(filename, varargin)
% metaData = LOAD_METADATA_TO_STRUCT(filename, varargin)

numEls = 1;
selRows = [];
interleavedRgc = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'num_els')
            numEls = varargin{i+1};
        elseif strcmp( varargin{i}, 'file_name')
            name2 = varargin{i+1};
        elseif strcmp( varargin{i}, 'select_rows')
            selRows = varargin{i+1};
        elseif strcmp( varargin{i}, 'interleaved')
            interleavedRgc = 1;
        end
    end
end


FID = fopen(filename, 'r');
if FID == -1, error('Cannot open file'), end
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
if ~isempty(selRows)
    CStr = Data{1}(selRows);
else
    CStr = Data{1};
end

% remove lines
SearchedString=  'phase';
IndexC = strfind(CStr, SearchedString);
Index = find(~cellfun('isempty', IndexC));

%del idx with junk
CStr(Index)=[];

% find connect lines
SearchedString=  'Connect El';
IndexC = strfind(CStr, SearchedString);
Index = find(~cellfun('isempty', IndexC));

%%
metaData = [];
if numEls == 1
    Index = [Index; length(CStr)+1];
    for i=1:length(Index)-1
        metaData(i).el = sscanf(CStr{Index(i)}, '%*s %*s %d,%d ', [1, inf]);
        iCnt = 1;
        for j=Index(i)+1:Index(i+1)-1
            s2 = regexp(CStr{j}, ':', 'split');
            s3 = str2num(s2{2});
            metaData(i).amp(iCnt) = s3(1);
            iCnt = 1+iCnt;
        end
    end
elseif numEls == 2
    Index = [Index(1:numEls:end); length(CStr)+1];
    for i=1:length(Index)-1
        for k=1:numEls
            metaData(i).el(k) = sscanf(CStr{Index(i)+k-1}, '%*s %*s %d,%d ', [1, inf]);
        end
        iCnt = 1;
        for j=Index(i)+2:Index(i+1)-1
            s2 = regexp(CStr{j}, ':', 'split');
            s3 = str2num(s2{2});
            metaData(i).amp(iCnt) = s3(1);
            iCnt = 1+iCnt;
        end
        if interleavedRgc > 0 
            metaData(i).amp = metaData(i).amp(interleavedRgc:2:end);
        end
    end    
end
