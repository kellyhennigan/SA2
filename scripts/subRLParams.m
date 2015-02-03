
conds = {'gain','loss'};

c=1;

cond = conds{c};
%%

if strcmp(cond,'gain')
    
    
    
    fixedBval = 3.3236;
    
    a_all = [0.1724];
         
    a1_all=0.2014     
    a2_all= 0.1368;

    % learning param fit for gains w/inverse temp param b fixed at val above
a=[0.2721
    0.2395
    0.3414
    0.0027
    0.4228
    0.3620
    0.0000
    0.5220
    0.5199
    0.2563
    0.7352
    0.0033
    0.3731
    0.3428
    0.4300
    0.5140
    0.1376
    0.2714
    0.0059];


% for gains in baseline context
a1 = [ 0.1053
    0.2872
    0.1901
    0.0082
    0.3604
    0.2949
    0.0000
    0.5792
    0.3090
    0.2720
    0.0545
    0.0000
    0.2034
    0.5143
    0.2385
    0.4982
    0.1649
    0.0674
    0.0182];

% gains in stress context
a2=[ 0.6151
    0.0773
    0.3345
    0.0000
    0.4749
    0.3598
    0.0000
    0.3873
    0.6131
    0.2110
    0.6328
    0.0140
    0.4669
    0.2344
    0.5429
    0.4464
    0.0939
    0.2998
    0.0000];


%% 

elseif strcmp(cond,'loss')
    
    fixedBval = 3.1259;
% learning rate for losses w/fixed B value
a = [ 0.7007
    0.2628
    0.5761
    0.0039
    0.4182
    0.4163
    0.0000
    0.6879
    0.3003
    0.4068
    0.4616
    0.0000
    0.1662
    0.4850
    0.2637
    0.2403
    0.8471
    0.3822
    0.0082];

a1=[ 0.6610
    0.4298
    0.6075
    0.0000
    0.4076
    0.4574
    0.0039
    0.8185
    0.3581
    0.5374
    0.3805
    0.0199
    0.1859
    0.5172
    0.2177
    0.2542
    0.1715
    0.3436
    0.0000]

a2=[ 0.7454
    0.1914
    0.5147
    0.0073
    0.4243
    0.3727
    0.0000
    0.5768
    0.1680
    0.3072
    0.5631
    0.0000
    0.1618
    0.4514
    0.5208
    0.2309
    0.7607
    0.4369
    0.0179]

end

%% plot it

cd ~/SA2/figures

cols = getSA2Colors();
cols = cols(c*2-1:c*2,:);
fh=setupfig;
subplot(1,2,1)
hist(a1)
h = findobj(gca,'Type','patch');
set(h,'FaceColor',cols(1,:),'EdgeColor','w')
title(['subject learning rates for ' cond ' trials w/fixed B=' num2str(fixedBval)])
xlabel('baseline')

subplot(1,2,2)
hist(a2)
h = findobj(gca,'Type','patch');
set(h,'FaceColor',cols(2,:),'EdgeColor','w')
xlabel('stress')

saveas(fh,['subj_a_fixedB_' cond '_base_vs_stress'],'epsc')
saveas(fh,['subj_a_fixedB_' cond '_base_vs_stress'],'pdf')

