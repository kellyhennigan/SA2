
conds = {'gain','loss'};

c=1;

cond = conds{c};
%%

if strcmp(cond,'gain')
    
    
    
    fixedBval = 3.3480;
    
    a_all = [0.1609];
         
    a1_all=0.2014     
    a2_all= 0.1368;

    % learning param fit for gains w/inverse temp param b fixed at val above
a=[    0.2683
    0.2371
    0.3390
    0.0026
    0.4214
    0.3610
    0.0000
    0.5206
    0.5171
    0.2555
    0.7339
    0.0032
    0.3714
    0.3422
    0.4273
    0.5127
    0.1372
    0.0059];


% for gains in baseline context
a1=[ 0.1527
    0.2996
    0.2565
    0.0112
    0.3907
    0.3308
    0.0000
    0.6046
    0.3779
    0.3215
    0.7898
    0.0000
    0.2414
    0.5656
    0.2648
    0.5340
    0.1702
    0.0245];


% gains in stress context
a2=[  0.6509
    0.1198
    0.4962
    0.0000
    0.5225
    0.3877
    0.0000
    0.4414
    0.6401
    0.2311
    0.6878
    0.0180
    0.5466
    0.2356
    0.6207
    0.4899
    0.1107
    0.0000];


%% 

elseif strcmp(cond,'loss')
    
       fixedBval = 3.1583;
    
    a_all = [0.2017];
         
       
    a1=[
    0.6589
    0.4280
    0.6055
    0.0000
    0.4058
    0.4558
    0.0039
    0.8154
    0.3577
    0.5355
    0.3771
    0.0196
    0.1829
    0.5154
    0.2169
    0.2510
    0.1703
    0.0000];

a2=[   0.7436
    0.1898
    0.5109
    0.0072
    0.4209
    0.3718
    0.0000
    0.5748
    0.1670
    0.3053
    0.5597
    0.0000
    0.1606
    0.4502
    0.5169
    0.2302
    0.7590
    0.0176];

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

