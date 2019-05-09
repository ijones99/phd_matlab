function electrode = clickelectrode2(elInfo, varargin)
% Douglas Bakkum 2012
% Returns electrodes closest to clicked points.
%
% Usage:
%       electrode = clickelectrode;
%       electrode = clickelectrode(color);
%       electrode = clickelectrode(color,number);   % number of closest electrodes to capture
%       electrode = clickelectrode(color,number,fignumber);
%

electrode   = [];
numElsToSelect = 1e10;
figno=gcf;
clr = 'w';
number = 1;
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'num_els')
            numElsToSelect = varargin{i+1};
            
        elseif strcmp( varargin{i}, 'color')
            clr = varargin{i+1};
            
        end
    end
end

fprintf(2,' Click a location to find its electrode. \n Press a key to stop.\n');


figure(figno);

k           = waitforbuttonpress;
src         = gca;


quitLoop = '';
pH = [];
while ~strcmp(quitLoop ,'y')
    
    while and(k==0,length(electrode) < numElsToSelect)
        figure(figno)
        b     = axis;
        a     = get(src,'CurrentPoint');
        x     = a(1,1);
        y     = a(1,2);
        
        d     = (elInfo.x-x).^2+(elInfo.y-y).^2;
        %[dist idx] = min(d);
        [d_   idx] = sort(d);
        idx = idx(1:number);

        
        if isempty(idx)
            fprintf(2,'Electrode not found near (%g,%g)\n',x,y);
        else
            % found electrode
            fprintf(2,'\nElectrode found:\t%i',idx-1);
            % check to see if in list already
            indExistingEl = find(electrode == idx-1);
            if isempty(indExistingEl)
                electrode = [electrode idx-1];
                [xt yt]   = el2position(idx-1);
                hold on
                % plot point
                pH(end+1) = plot(xt,yt,'ks','markerfacecolor',clr);
                hold off
                fprintf(2,'\n');
            else % delete point
                electrode(indExistingEl) = [];
                delete(pH(indExistingEl));
                pH(indExistingEl) = [];
            end
        end
        
        
        %         save(tmp_filename,'electrode')
        if ~(length(electrode) == numElsToSelect)
            fprintf('%d selected out of %d.\n', length(electrode), length(numElsToSelect));
            k = waitforbuttonpress;
         end
    end
    
    if ~(length(electrode) == numElsToSelect)
        quitLoop = input('Zoom mode, press [y] to quit program>> ','s');
        if isempty(quitLoop)
            quitLoop = 'n';
            fprintf('Continue selecting points...\n')
        end
        if ~strcmp(quitLoop,'y')
            figure(figno)
            k = waitforbuttonpress;
            
        end
    else
        return
        
        
    end
    
end

