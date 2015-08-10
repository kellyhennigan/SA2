function [a, B] = getRLSubjParams(subjects,cond,context,fixedB)
% --------------------------------
% usage: return the best fitting parameter estimates
% (learning rate a and inverse temperature B) found using fminsearch
% on the function fitQLearningMod
%
% INPUT:
%   subjects - string identifying which subjects to return params for
%
%
%   cond - string or number specifying which condition (gain or loss) to
%          return data for; should be either 'gain' or 1 for gains and
%          'loss' or 2 for loss trials.
%
%   context - string or number specifying which context to return data for ('base' or 'stress' or
%          'both');
%
%   fixedB - either 'no' for letting B vary, 'subj' for fixing B within a
%   subject (across contexts) or 'group' for fixing B across subjects and
%   contexts.

%
% OUTPUT:
%   [a,B] - best fitting parameter estimates (learning rate a and inverse
%   temperature B) found using fminsearch on the function fitQLearningMod
%   and hard-coded in here.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('subjects')
    subjects = getSA2Subjects('fmri');
end


% return params for gains and/or losses?
if notDefined('cond')
    cond = 'gain'; % gains
end

% return params for gains and/or losses?
if notDefined('context')
    context = 'both';
end


% by default, return params from fixing B at the group level
if notDefined('fixedB')
    fixedB = 'group'; % gains
end


%% gains trials

% with B fixed across the group and context:

% both
p_gain_both_fixedBgroup = [  0.2683    3.3480
    0.2371    3.3480
    0.3390    3.3480
    0.0026    3.3480
    0.4214    3.3480
    0.3610    3.3480
    0.0000    3.3480
    0.5206    3.3480
    0.5171    3.3480
    0.2555    3.3480
    0.7339    3.3480
    0.0032    3.3480
    0.3714    3.3480
    0.3422    3.3480
    0.4273    3.3480
    0.5127    3.3480
    0.1372    3.3480
    0.0059    3.3480];

% base

p_gain_base_fixedBgroup = [ 0.1527    3.3480
    0.2996    3.3480
    0.2565    3.3480
    0.0112    3.3480
    0.3907    3.3480
    0.3308    3.3480
    0.0000    3.3480
    0.6046    3.3480
    0.3779    3.3480
    0.3215    3.3480
    0.7898    3.3480
    0.0000    3.3480
    0.2414    3.3480
    0.5656    3.3480
    0.2648    3.3480
    0.5340    3.3480
    0.1702    3.3480
    0.0245    3.3480];

% stress
p_gain_stress_fixedBgroup = [ 0.6509    3.3480
    0.1198    3.3480
    0.4962    3.3480
    0.0000    3.3480
    0.5225    3.3480
    0.3877    3.3480
    0.0000    3.3480
    0.4414    3.3480
    0.6401    3.3480
    0.2311    3.3480
    0.6878    3.3480
    0.0180    3.3480
    0.5466    3.3480
    0.2356    3.3480
    0.6207    3.3480
    0.4899    3.3480
    0.1107    3.3480
    0.0000    3.3480];


% with B fixed across context but differing across subjects
p_gain_both_fixedBsubj = [  0.1706    4.3434
    0.1422    4.4086
    0.3396    3.3413
    0.0866    0.2021
    0.4016    3.7331
    0.2883    7.3880
    0.0017    0.0000
    0.4996    3.7585
    0.1304    8.4538
    0.2117    5.8264
    0.8293    2.1929
    0.0012   10.0000
    0.3771    3.2694
    0.3120    5.0125
    0.2616    9.2402
    0.4562    5.2599
    0.0622   10.0000
    0.0019   10.0000];

p_gain_base_fixedBsubj = [   0.1053    4.3434
    0.2868    4.4086
    0.2569    3.3413
    0.2689    0.2021
    0.3765    3.7331
    0.1854    7.3880
    0.3232    0.0000
    0.5912    3.7585
    0.1932    8.4538
    0.2452    5.8264
    0.8653    2.1929
    0.0000   10.0000
    0.2455    3.2694
    0.4902    5.0125
    0.1453    9.2402
    0.4850    5.2599
    0.1347   10.0000
    0.0074   10.0000];


p_gain_stress_fixedBsubj = [  0.6151    4.3434
    0.0755    4.4086
    0.4975    3.3413
    0.0000    0.2021
    0.5017    3.7331
    0.3414    7.3880
    0.0009    0.0000
    0.4165    3.7585
    0.0764    8.4538
    0.1952    5.8264
    0.8010    2.1929
    0.0061   10.0000
    0.5579    3.2694
    0.2367    5.0125
    0.3364    9.2402
    0.4210    5.2599
    0.0417   10.0000
    0.0000   10.0000];


% with B differing across contexts and across subjects
p_gain_both = [ 0.1706    4.3434
    0.1422    4.4086
    0.3396    3.3413
    0.0866    0.2021
    0.4015    3.7331
    0.2883    7.3880
    0.0022    0.0000
    0.4997    3.7585
    0.1304    8.4538
    0.2117    5.8264
    0.8293    2.1929
    0.0012   10.0000
    0.3771    3.2694
    0.3120    5.0125
    0.2616    9.2402
    0.4561    5.2599
    0.0622   10.0000
    0.0019   10.0000];

p_gain_base = [
    0.0856    4.9660
    0.2866    5.4808
    0.2195    3.9087
    0.1895    0.7513
    0.3884    3.4031
    0.2396    6.1203
    0.3771    0.0000
    0.5832    4.1066
    0.1626   10.0000
    0.2361    6.8653
    0.8658    2.1880
    0.0000    0.0000
    0.2020    4.3909
    0.4734    5.5994
    0.1316   10.0000
    0.5037    4.1233
    0.1347   10.0000
    0.0074   10.0000];

p_gain_stress = [  0.6108    5.5253
    0.0346    7.6901
    0.6068    2.7631
    0.0000    0.0000
    0.4844    4.1136
    0.3598   10.0000
    0.0000    0.0000
    0.4265    3.5859
    0.6110    5.4508
    0.2014    5.1035
    0.7990    2.2089
    0.0061   10.0000
    0.7547    2.4814
    0.2345    4.3956
    0.3384    9.1399
    0.3809    8.7335
    0.0417   10.0000
    1.0000    0.1823];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% loss trials

% B fixed across group

% both
p_loss_both_fixedBgroup =[  0.6989    3.1583
    0.2609    3.1583
    0.5732    3.1583
    0.0039    3.1583
    0.4155    3.1583
    0.4151    3.1583
    0.0000    3.1583
    0.6853    3.1583
    0.2975    3.1583
    0.4047    3.1583
    0.4581    3.1583
    0.0000    3.1583
    0.1643    3.1583
    0.4833    3.1583
    0.2625    3.1583
    0.2387    3.1583
    0.8452    3.1583
    0.0081    3.1583];


% base
p_loss_base_fixedBgroup = [  0.6589    3.1583
    0.4280    3.1583
    0.6055    3.1583
    0.0000    3.1583
    0.4058    3.1583
    0.4558    3.1583
    0.0039    3.1583
    0.8154    3.1583
    0.3577    3.1583
    0.5355    3.1583
    0.3771    3.1583
    0.0196    3.1583
    0.1829    3.1583
    0.5154    3.1583
    0.2169    3.1583
    0.2510    3.1583
    0.1703    3.1583
    0.0000    3.1583];


% stress
p_loss_stress_fixedBgroup = [ 0.7436    3.1583
    0.1898    3.1583
    0.5109    3.1583
    0.0072    3.1583
    0.4209    3.1583
    0.3718    3.1583
    0.0000    3.1583
    0.5748    3.1583
    0.1670    3.1583
    0.3053    3.1583
    0.5597    3.1583
    0.0000    3.1583
    0.1606    3.1583
    0.4502    3.1583
    0.5169    3.1583
    0.2302    3.1583
    0.7590    3.1583
    0.0176    3.1583];


p_loss_both_fixedBsubj = [    0.7192   10.0000
    0.1057    7.6896
    0.5675    3.2243
    0.0111    1.1616
    0.3972    3.3957
    0.3914    7.4621
    0.0000    0.0000
    0.6534    3.6185
    0.2037    4.7353
    0.3463    4.6587
    0.4402    3.3358
    0.6922    0.3184
    0.1798    2.8774
    0.4383    5.1440
    0.1838    7.0273
    0.1595    4.7887
    0.0742   10.0000
    1.0000    0.2535];

p_loss_base_fixedBsubj = [
    0.6041   10.0000
    0.3584    7.6896
    0.6015    3.2243
    0.0000    1.1616
    0.3949    3.3957
    0.4016    7.4621
    0.1852    0.0000
    0.7773    3.6185
    0.3521    4.7353
    0.4954    4.6587
    0.3592    3.3358
    0.6614    0.3184
    0.2041    2.8774
    0.4565    5.1440
    0.1497    7.0273
    0.1364    4.7887
    0.0571   10.0000
    0.0000    0.2535];

p_loss_stress_fixedBsubj = [  0.8148   10.0000
    0.0648    7.6896
    0.5034    3.2243
    0.0187    1.1616
    0.3984    3.3957
    0.3599    7.4621
    0.0000    0.0000
    0.5506    3.6185
    0.1308    4.7353
    0.2321    4.6587
    0.5426    3.3358
    0.7404    0.3184
    0.1711    2.8774
    0.4286    5.1440
    0.3400    7.0273
    0.1939    4.7887
    0.7762   10.0000
    1.0000    0.2535];



p_loss_both = [   0.7192   10.0000
    0.1057    7.6896
    0.5675    3.2243
    0.0111    1.1616
    0.3972    3.3957
    0.3914    7.4621
    0.0000    0.0000
    0.6534    3.6185
    0.2037    4.7353
    0.3463    4.6587
    0.4402    3.3358
    0.6922    0.3184
    0.1798    2.8774
    0.4383    5.1440
    0.1838    7.0273
    0.1595    4.7887
    0.8865   10.0000
    1.0000    0.2535];

p_loss_base = [
    0.6042   10.0000
    0.3663   10.0000
    0.6348    2.7328
    0.9095    0.2246
    0.3977    3.3287
    0.4080   10.0000
    0.1012    0.2175
    0.6947    5.9540
    0.3512    4.2069
    0.5032    6.0430
    0.3970    2.9764
    0.5972    0.5605
    0.2659    1.8712
    0.4504    6.2534
    0.1736    5.5188
    0.1304    4.9055
    0.0571   10.0000
    0.0002    0.0000];

p_loss_stress = [   0.7471    7.6084
    0.0839    6.4371
    0.4417    4.0157
    0.0023   10.0000
    0.3906    3.4894
    0.3479    6.2516
    0.0002    0.0000
    0.6012    2.7737
    0.0683    9.8160
    0.2572    4.1057
    0.5074    3.8366
    0.8102    0.1821
    0.1209    4.2793
    0.4294    4.3664
    0.3683   10.0000
    0.1914    4.8706
    0.7762   10.0000
    1.0000    0.8397];


%% now get params based on inputs

if strcmp(cond,'gain')
    
    if strcmp(context,'both')
        
        if strcmp(fixedB,'no')
            p = p_gain_both;
            
        elseif strcmp(fixedB,'subj')
            p = p_gain_both_fixedBsubj;
            
        elseif strcmp(fixedB,'group')
            p = p_gain_both_fixedBgroup;
        end
        
    elseif strcmp(context,'base')
        
        if strcmp(fixedB,'no')
            p = p_gain_base;
            
        elseif strcmp(fixedB,'subj')
            p = p_gain_base_fixedBsubj;
            
        elseif strcmp(fixedB,'group')
            p = p_gain_base_fixedBgroup;
        end
        
    elseif strcmp(context,'stress')
        
        if strcmp(fixedB,'no')
            p = p_gain_stress;
            
        elseif strcmp(fixedB,'subj')
            p = p_gain_stress_fixedBsubj;
            
        elseif strcmp(fixedB,'group')
            p = p_gain_stress_fixedBgroup;
        end
        
    end
    
elseif strcmp(cond,'loss')
    
    if strcmp(context,'both')
        
        if strcmp(fixedB,'no')
            p = p_loss_both;
            
        elseif strcmp(fixedB,'subj')
            p = p_loss_both_fixedBsubj;
            
        elseif strcmp(fixedB,'group')
            p = p_loss_both_fixedBgroup;
        end
        
    elseif strcmp(context,'base')
        
        if strcmp(fixedB,'no')
            p = p_loss_base;
            
        elseif strcmp(fixedB,'subj')
            p = p_loss_base_fixedBsubj;
            
        elseif strcmp(fixedB,'group')
            p = p_loss_base_fixedBgroup;
        end
        
    elseif strcmp(context,'stress')
        
        if strcmp(fixedB,'no')
            p = p_loss_stress;
            
        elseif strcmp(fixedB,'subj')
            p = p_loss_stress_fixedBsubj;
            
        elseif strcmp(fixedB,'group')
            p = p_loss_stress_fixedBgroup;
        end
        
        
    end % context
    
end % cond

%% now get subset depending on desired subjects 


these_subs = getSA2Subjects('fmri'); % subjects coresponding to params listed here

if any(ismember(subjects,these_subs)==0)
    error('requesting params for at least 1 subj that isnt listed in this function')
end

idx=ismember(these_subs,subjects);

p=p(ismember(these_subs,subjects),:);

a = p(:,1); B = p(:,2);



