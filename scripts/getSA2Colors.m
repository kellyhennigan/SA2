function cols = getSA2Colors(cond,context)
% --------------------------------
% usage: function to return colors for SA2 plots
% 
% INPUT: 
%   cond - string or integer indicating gain or loss condition. 'gain' or 1
%          for gains, 'loss' or 2 for losses
%   context - string or integer indicating base or stress context. 'base'
%          or 1 for baseline, 'stress' or 2 for stress context. 
% 
% OUTPUT:
%   cols - N x 3 array w/RGB values of colors in rows
% 
% 
% author: Kelly, kelhennigan@gmail.com, 12-Nov-2014
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cols = [
    7,207,239      % gain-base
    46 67 211      % gain-stress
    255 41 30       % loss-base
    150 15 30      % loss-stress
    ]./255;


% figure
% image(1:4)
% colormap(cols)

% if notDefined('cond')
%     cond = 'both';
% end
% if notDefined('context')
%     context = 'both';
% end

% return only gain or loss colors if requested 
if ~notDefined('cond')
    if strcmpi(cond, 'gain') || cond(1)==1
        cols = cols(1:2,:);
    elseif strcmpi(cond, 'loss') || cond(1)==2
        cols = cols(3:4,:);
    end
end

% return only base or stress colors if requested 
if ~notDefined('context')
    if strcmpi(context, 'base') || context(1)==1
        cols = cols(1:2:end,:);
    elseif strcmpi(context, 'stress') || context(1)==2
        cols = cols(2:2:end,:);
    end
end
