function decisionNo = prompt_for_string_selection(promptText, optionsCell, varargin)
% function decisionNo = PROMPT_FOR_STRING_SELECTION(promptText, optionsCell)
% 
% input
%   promptText: enter in prompt text
%   optionsCell: choice selections
% 
% output
%   decisionNo: number selected from choices
% 
% varargin
%   'yes_no': for a binary 1/0 choice
%
% author: ijones@bsse

if isstr(optionsCell)
    if ~isempty(varargin)
        varargin{2:end+1} = varargin;
    end
    varargin{1} = optionsCell;
end

yesNoChoice = 0;

% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'yes_no')
            yesNoChoice = 1;
        end
    end
end

if yesNoChoice
    optionsCell = {'y','n'};
end

optionsStr = '';
for i=1:length(optionsCell)
    optionsStr(end+1) = '[';
    optionsStr(end+1:end+length(optionsCell{i})) = optionsCell{i};
    optionsStr(end+1) = ']';
   if i~=length(optionsCell)
       optionsStr(end+1) = '/';
   end
end

selectedChoice = input([promptText,': ', optionsStr,'>> '],'s');

for i=1:length(optionsCell)
    if strcmp(selectedChoice,optionsCell{i})
       decisionNo = i;
    end
end

% if it is a yes/no choice, then set "no" to zero
if yesNoChoice
    if decisionNo == 2
        decisionNo  = 0;
    end
end


end


