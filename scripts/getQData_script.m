
% subs = getSA2Subjects('q');

subs=getSA2Subjects('dti');

saveOut = 0; % 1 to save out, 0 otherwise
saveDir = fullfile(paths.data, 'q_data');
outStr = '_dti'; % this string will be appended to out names


%%%%%%%%%%% discounting parameters
k = []; % hyperbolic discounting rate based on intertemp choice task
m = []; % variance of k
logL=[]; % log-likelihood of k
k_m_logL=[]; % k,m,log-l estimated using max likelihood

%%%%%%%%%%% questionnaire scores
BIS11 = []; % barratt impulsivity scale
BISBAS = []; % behavioral inhibition/approach system
PSS = []; % perceived stress scale
STAI = []; % state-trait inventory


% i = 1;
for i=1:numel(subs)
    sub = subs{i};
    paths = getSA2Paths(sub);
    cd(paths.behavior);
    
    
    %%%%%%%% intertemporal choice task
    dataFile = [sub '_StaircaseData.mat'];
    if exist(dataFile,'file')
        load(dataFile);
        N = length(choiceArray);
        SS = ones(N,1).*10; % SS option was always $10 now
        d0 = zeros(N,1);
        LL = rewardArray;
        d=  timeArray;
        choice = abs(choiceArray-1); % recode responses so 1=SS and 0=LL
        kdata=[SS LL d choice kvalArray]; kdata=sortrows(kdata,5);
        [k(i,1),m(i,1),logL(i,1)]=FitK([SS d0 LL d choice]);
        [k_m_logL(i,:)] = MLE_estimation([SS LL d choice]);
    else
        k(i,1)=nan; m(i,1)=nan; logL(i,1)=nan;
        k_m_logL(i,:)=nan(1,3);
        
    end
    clear dataFile
    
    
    % BIS11 - Barratt Impulsivity Scale
    dataFile = [sub '_BIS11.mat'];
    if exist(dataFile,'file');
        load(dataFile);
        BIS11(i,1) = attn;
        BIS11(i,2) = motor;
        BIS11(i,3) = nonplan;
        clear attn motor nonplan rating
    else
        BIS11(i,1) = nan;
        BIS11(i,2) = nan;
        BIS11(i,3) = nan;
    end
    clear dataFile
    
    % BISBAS - Behavioral Inhibition System /  Behavioral Approach System
    dataFile = [sub '_BISBAS.mat'];
    if exist(dataFile,'file')
        load(dataFile);
        BISBAS(i,1) = BASDrive;
        BISBAS(i,2) = BASFS;
        BISBAS(i,3) = BASRewRes;
        BISBAS(i,4) = BIS;
        clear BASDrive BASFS BASRewRes BIS rating
    else
        BISBAS(i,1) = nan;
        BISBAS(i,2) = nan;
        BISBAS(i,3) = nan;
        BISBAS(i,4) = nan;
    end
    clear dataFile
    
    
    % PSS - Cohen perceived stress scale
    dataFile = [sub '_PSS.mat'];
    if exist(dataFile,'file')
        load(dataFile);
        PSS(i,1) = score;
        clear score rating
    else
        PSS(i,1)=nan;
    end
    clear dataFile
    
    % STAI - State Trait Anxiety Inventory
    dataFile = [sub '_stateAI.mat'];
    dataFile2 = [sub '_traitAI.mat'];
    if exist(dataFile,'file') && exist(dataFile2,'file')
        load(dataFile);
        STAI(i,1) = score;
        load(dataFile2);
        STAI(i,2) = score;
        clear score rating
    else
        STAI(i,:) = nan(1,2);
    end
    clear dataFile
    
end % subs

% cue preference

%% save out 

if saveOut
    cd(saveDir);
    dlmwrite(['BIS11' outStr],BIS11);
    dlmwrite(['BISBAS' outStr],BISBAS);
    dlmwrite(['PSS' outStr]',PSS);
    dlmwrite(['STAI' outStr],STAI);
    dlmwrite(['k_m_logl' outStr],[k m logL]);
    dlmwrite(['k_m_logl_MLE' outStr],[k_m_logL]);
end


