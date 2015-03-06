
subs = getSA2Subjects('q');

k = []; % hyperbolic discounting rate based on intertemp choice task

% i = 1;
for i=1:numel(subs)
    sub = subs{i};
    paths = getSA2Paths(sub);
    cd(paths.behavior);
    
    
    % intertemporal choice task
    load([sub '_StaircaseData.mat'])
    N = length(choiceArray);
    SS = ones(N,1).*10; % SS option was always $10 now
    d0 = zeros(N,1);
    LL = rewardArray;
    d=  timeArray;
    choice = abs(choiceArray-1); % recode responses so 1=SS and 0=LL
    kdata=[SS LL d choice kvalArray]; kdata=sortrows(kdata,5);
    [k(i,1),m(i,1),logL(i,1)]=FitK([SS d0 LL d choice]);
    [k_m_logL(i,:)] = MLE_estimation([SS LL d choice]);
    
    
end

%%
BIS11 = []; % barratt impulsivity scale
BISBAS = []; % behavioral inhibition/approach system
PSS = []; % perceived stress scale
STAI = []; % state-trait inventory

for i=1:numel(subs)
    sub = subs{i};
    paths = getSA2Paths(sub);
    cd(paths.behavior);
    
    
    % BIS11 - Barratt Impulsivity Scale
    load([sub '_BIS11.mat'])
    BIS11(i,1) = attn;
    BIS11(i,2) = motor;
    BIS11(i,3) = nonplan;
    clear attn motor nonplan rating
    
    
    % BISBAS - Behavioral Inhibition System /  Behavioral Approach System
    load([sub '_BISBAS.mat'])
    BISBAS(i,1) = BASDrive;
    BISBAS(i,2) = BASFS;
    BISBAS(i,3) = BASRewRes;
    BISBAS(i,4) = BIS;
    clear BASDrive BASFS BASRewRes BIS rating
    
    % PSS - Cohen perceived stress scale
    load([sub '_PSS.mat'])
    PSS(i,1) = score;
    clear score rating
    
    % STAI - State Trait Anxiety Inventory
    load([sub '_stateAI.mat'])
    STAI(i,1) = score;
    load([sub '_traitAI.mat'])
    STAI(i,2) = score;
    clear score rating
    
end
% cue preference
