function cols = getSA2Colors(cond,context)
% --------------------------------
% usage: function to return colors for SA2 plots
% 
% 
% OUTPUT:
%   cols - N x 3 array w/RGB values of colors in rows
% 
% 
% author: Kelly, kelhennigan@gmail.com, 12-Nov-2014
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cols = [
%     254 63 37
%     25 100 185
%     211 54 130
%     18,179,152]./255;


cols = [
    0,70,200        % gain
    23 102 109      % gain stress
    235 2 8         % loss base
    80 17 36        % loss stress
    ]./255;

% figure
% image(1:4)
% colormap(cols)

if notDefined('cond')
    cond = 'both';
end
if notDefined('context')
    context = 'both';
end

if strcmpi(cond, 'gain')
    cols = cols(1:2,:);
elseif strcmpi(cond, 'loss')
    cols = cols(3:4,:);
end

if strcmpi(context, 'base')
    cols = cols(1:2,:);
elseif strcmpi(context, 'stress')
    cols = cols(3:4,:);
end

