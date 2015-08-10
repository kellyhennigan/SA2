function d = getQData(subjects,scale)


if notDefined('subjects')
    subjects = getSA2Subjects('fmri');
end

if notDefined('scale')
    error('what scale?')
end

%%

q_subs = getSA2Subjects('all'); % q data is stored for these subjects

qDir = '/Users/Kelly/SA2/data/q_data';

    cd(qDir);
    
    switch lower(scale)
        
        case 'bis11'
            
            d = dlmread('BIS11');
            
        case 'bisbas'
            
            d = dlmread('BISBAS');
            
        case 'pss'
            
            d = dlmread('PSS');
            
        case 'stai'
            
            d = dlmread('STAI');
            
        case 'k'
            
            d = dlmread('k_m_logl');
    
        case 'k_mle'
            
            d = dlmread('k_m_logl_MLE');
           
    end
    
    %% return data for subset of subjects requested
    
    d = d(ismember(q_subs,subjects),:);
    
    