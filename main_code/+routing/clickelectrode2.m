function electrode = clickelectrode2(varargin)
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

selConfig.num_els_per_click = 1;
selConfig.edit_add_del = 1;


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
[ex ey]     = el2position([0:11015]);


quitLoop = '';
pH = [];
while ~strcmp(quitLoop ,'y')
    
    while and(k==0,length(electrode) < numElsToSelect)
        figure(figno)
        b     = axis;
        a     = get(src,'CurrentPoint');
        x     = a(1,1);
        y     = a(1,2);
        
        d     = (ex-x).^2+(ey-y).^2;
        %[dist idx] = min(d);
        [d_   idx] = sort(d);
        idx = idx(1:selConfig.num_els_per_click);
        
        
        %   tolx  = (b(2)-b(1)) * .01;
        %   toly  = (b(4)-b(3)) * .01;
        %   lox   = x-tolx;   hix = x+tolx;
        %   loy   = y-toly;   hiy = y+toly;
        %   idx   = find( ex>lox &  ex<hix &  ey>loy &  ey<hiy);
        
        
        if isempty(idx)
            fprintf(2,'Electrode not found near (%g,%g)\n',x,y);
        else
            % found electrode
            fprintf(2,'\nElectrode found:\t%i',idx-1);
            % check to see if in list already
            indExistingEl = find(ismember(electrode,idx-1));
            if or(isempty(indExistingEl),length(indExistingEl)<length(idx) ) & selConfig.edit_add_del == 1
                electrode = [electrode idx-1];
                [xt yt]   = el2position(idx-1);
                hold on
                % plot point
                for iXY = 1:length(xt)
                    pH(end+1) = plot(xt(iXY),yt(iXY),'ks'); %,'markerfacecolor',clr
                end
                hold off
                fprintf(2,'\n');
            elseif ~isempty(indExistingEl) & selConfig.edit_add_del == 0 % delete point
                electrode(indExistingEl) = [];
                delete(pH(indExistingEl));
                pH(indExistingEl) = [];
            else
                warning('Nothing done.')
            end
        end
        
        
        %         save(tmp_filename,'electrode')
        if ~(length(electrode) == numElsToSelect)
            fprintf('%d selected out of %d.\n', length(electrode), length(numElsToSelect));
            k = waitforbuttonpress;
            electrode = unique(electrode);
            suptitle(sprintf('Num els: %d', length(electrode)));
        end
         
        
    end
    
    if ~(length(electrode) == numElsToSelect)
        quitLoop = input('Zoom mode, press [y] to quit program>> ','s');

        if isempty(quitLoop)
            quitLoop = 'n';
            fprintf('Continue selecting points...\n')
        elseif ~strcmp(quitLoop,'y')
            try
            if strcmp(quitLoop,'m')
                selConfig = menu.change_struct_menu(selConfig);
            end
            catch
                error('menu.change_struct_menu error');
            end
                
            figure(figno)
            k = waitforbuttonpress;
        
        end
    else
        return
        
        
    end
    
    electrode = unique(electrode);
end

