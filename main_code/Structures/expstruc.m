% function fns = expstruc(X,sname,ll,lname,mems)
%
% Recursively explode a structure to find all members.
%
% INPUTS
% ------
% X;        structure to be exploded
% sname;    structure name (generated during recursive call, not needed to start)
% ll;       structure level (1= top)
% lname;    name of the field (string, completely expanded)
% mems;     structure containing field names and data types
%
% written by Andy Clifton, October 2010.

function mems = expstruc(X,sname,ll,lname,mems)

if nargin == 1
    % generate us an empty name vector
    sname = inputname(1);
    lname = [];
    ll = 1;
    mems = struct('name',{''},'type',{''},'numel',[]);
end

switch class(X)
    case {'struct'} % still something to expand
        fns = fieldnames(X);
        for f = 1:numel(fns)
            % keep expanding the structure
            switch ll
                case 1
                    mems = expstruc(X.(fns{f}),sname,ll+1,...
                        [sname '.' char(fns{f})],mems);
                otherwise
                    mems = expstruc(X.(fns{f}),sname,ll+1,...
                        [lname '.' char(fns{f})],mems);
            end
        end
    otherwise % then no more fields to expand
        %fprintf('...Level (%i): %s\n', ll, lname)
        mems.name{end+1} = lname;
        mems.type{end+1} = class(X);
        mems.numel(end+1) = numel(X);
        return
end