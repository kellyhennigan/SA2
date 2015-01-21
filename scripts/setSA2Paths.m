function setSA2Paths(subject)

% gets relevant subject directories as specified in getSAPaths and creates
% them if they don't already exist.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expPaths = getSA2Paths(subject);

dirNames = fieldnames(expPaths);

for d = 4:numel(dirNames)   % 1st directories are main SA2 directories 
    if ~exist(expPaths.(dirNames{d}),'dir')
        mkdir(expPaths.(dirNames{d}));
    end
end

fprintf(['\n\nset up exp directories for subject ',subject,'\n\n']);

end
