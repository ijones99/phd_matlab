function [ fData ] = asphalt(data, LENGTH, START, STOP, PLOT)
% all matlab instantiation of Wagenaar's SALPA (subtraction of artifacts by
% local polynomial approximation) algorithm
% D.A. Wagenaar and S.M. Potter, J. Neurosci. Meth., 120 (2002) 113-120.
%
% input to function:
% data  : the data vector to be processed
% LENGTH: the length of the fitting curve in samples; 100 is a good number
% START : sample at which it's safe to start the fitting
% STOP  : sample at which to stop fitting
% PLOT  : 1 -> make plot; 0 -> don't
%
% output of function:
% fData:  data vector with 3rd order polynomial fit substracted off
%

if nargin < 5
    PLOT = 0;
elseif nargin < 4
    STOP = length(data);
elseif nargin < 3
    START = 1;
    STOP = length(data);
elseif nargin < 2
    error('not enough input arguments.');
end

warning('off','MATLAB:polyfit:RepeatedPointsOrRescale'); % suppress warning since polyfit complains, but doing what it asks makes fit worse

x1 = START;
spl=zeros(1,length(data));
fData=zeros(1,length(data));

x{1}=zeros(1,LENGTH);
y{1}=zeros(1,LENGTH);

if PLOT
    figure; plot(data,'color',[0 0 0]);
    xlabel('samples'); ylabel('amplitude');
    if STOP-START-LENGTH > 1
        cmap=mkpj(STOP-START-LENGTH+1,'j_db');
    else
        cmap=[0 0 1; 0 0 0.9];
    end
end

m=1;
while x1 <= STOP-LENGTH
    x{m} = [x1:x1+LENGTH-1];
    p = polyfit(x{m},data(x{m}),3);
    for i=1:length(x{m})
        y{m}(i) = p(4) + p(3)*x{m}(i) + p(2)*x{m}(i)*x{m}(i) + p(1)*x{m}(i)*x{m}(i)*x{m}(i);
    end
    if PLOT
        hold on;
        plot(x{m},y{m},'color',cmap(m,:));
    end
    m=m+1;
    x1 = x1 + 1;
end

for i=1:START
    spl(i) = data(i);
end

m=1;
for i=1:STOP-START
    if i<LENGTH/2
        spl(i+START) = y{1}(i);
    elseif i<STOP-START-LENGTH/2
        m=m+1;
        spl(i+START) = y{m}(LENGTH/2);
    else
        spl(i+START) = y{m}(i-m-1);
    end
end
        
for i=1:STOP
    fData(i) = data(i) - spl(i);
end

warning('on','MATLAB:polyfit:RepeatedPointsOrRescale');    % back to status quo