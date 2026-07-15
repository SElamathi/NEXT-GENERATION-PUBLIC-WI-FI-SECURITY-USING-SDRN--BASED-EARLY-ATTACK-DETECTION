function generate_plots(sim, beaconResult, arpResult, fusedResult, net)
%% generate_plots  –  IEEE-Quality Figures for Paper and PPT
%
%  Figure 1 : ARP Traffic Rate vs Time  (with adaptive threshold)
%  Figure 2 : IP–MAC Conflict Detection Timeline
%  Figure 3 : Beacon Frame Fingerprinting (Stage-1 Score)
%  Figure 4 : Dual-Stage Attack Detection Timeline
%  Figure 5 : Detection Performance Bar Chart
%  Figure 6 : ROC Curve
%  Figure 7 : Confusion Matrix Heatmap
%
%  All figures use publication-quality formatting (300 dpi, Times font).

t  = sim.time;
FS = 11;  % base font size
LW = 1.6; % line width

colorNorm   = [0.18 0.55 0.34];   % green
colorAtk    = [0.85 0.20 0.20];   % red
colorDetect = [0.12 0.47 0.71];   % blue
colorWarn   = [0.93 0.60 0.10];   % amber

attackShade = [1 0.88 0.88];      % light red background

%% Helper: shade the attack window on current axes
    function shadeAttack()
        hold on;
        yl = ylim;
        fill([net.AttackStart_s net.AttackEnd_s net.AttackEnd_s net.AttackStart_s],...
            [yl(1) yl(1) yl(2) yl(2)], attackShade,...
            'EdgeColor','none','FaceAlpha',0.5);
        xl = xlim; ylim(yl); xlim(xl);
    end

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 1 – ARP Traffic Rate vs Time
%% ??????????????????????????????????????????????????????????????????????????
fig1 = figure('Name','Fig1_ARP_Traffic','NumberTitle','off',...
    'Position',[50 600 760 320]);
ax1 = axes(fig1);

plot(ax1, t, sim.arpRate, 'Color', colorNorm, 'LineWidth', LW); hold on;
plot(ax1, t, arpResult.arpThreshold, '--', 'Color', colorAtk, 'LineWidth', LW);
shadeAttack();
legend(ax1, 'ARP Rate (pkt/s)', 'Adaptive Threshold (\mu+3\sigma)',...
    'Attack Window', 'Location','northeast','FontSize',FS-1);
xlabel(ax1, 'Time (s)', 'FontSize', FS);
ylabel(ax1, 'ARP Packets per Second', 'FontSize', FS);
title(ax1, 'Figure 1: ARP Traffic Rate vs Time',...
    'FontSize', FS+1, 'FontWeight','bold');
xline(ax1, net.AttackStart_s, ':k', 'Attack Start', 'LabelVerticalAlignment','bottom',...
    'FontSize',FS-1,'LineWidth',1.2);
xline(ax1, net.AttackEnd_s,   ':k', 'Attack End',   'LabelVerticalAlignment','bottom',...
    'FontSize',FS-1,'LineWidth',1.2);
xlim(ax1,[0 net.SimDuration_s]); grid(ax1,'on');
set(ax1,'FontSize',FS,'FontName','Times New Roman','Box','on');

% Annotation box
annotation(fig1,'textbox',[0.55 0.62 0.32 0.1],'String',...
    'ARP flood: 80–150 pkt/s during attack','FontSize',9,...
    'BackgroundColor','w','EdgeColor',colorAtk,'Color',colorAtk);

saveas(fig1, '/home/claude/WiFi_SDRN_Simulation/Fig1_ARP_Traffic.png');

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 2 – IP–MAC Conflict Detection
%% ??????????????????????????????????????????????????????????????????????????
fig2 = figure('Name','Fig2_IPMAC_Conflict','NumberTitle','off',...
    'Position',[50 250 760 300]);
ax2 = axes(fig2);

% Ground truth conflict (injected)
area(ax2, t, double(sim.ipMacConflict)*2, 'FaceColor', [1 0.7 0.7],...
    'EdgeColor','none','FaceAlpha',0.7); hold on;
% Detected conflict flags
stem(ax2, t(arpResult.conflictFlag), ones(sum(arpResult.conflictFlag),1)*1.5,...
    'Marker','d','Color',colorAtk,'LineWidth',1.2,'MarkerFaceColor',colorAtk,...
    'MarkerSize',5);
% ARP detector flags
stem(ax2, t(arpResult.arpDetected), ones(sum(arpResult.arpDetected),1),...
    'Marker','^','Color',colorDetect,'LineWidth',1,'MarkerFaceColor',colorDetect,...
    'MarkerSize',5);

legend(ax2,'Ground-Truth Conflict Window','IP–MAC Binding Violation Detected',...
    'ARP Rate Anomaly Detected','Location','northeast','FontSize',FS-1);
xlabel(ax2,'Time (s)','FontSize',FS);
ylabel(ax2,'Detection Flag','FontSize',FS);
title(ax2,'Figure 2: IP–MAC Conflict & ARP Anomaly Detection',...
    'FontSize',FS+1,'FontWeight','bold');
yticks(ax2,[0 1 1.5 2]);
yticklabels(ax2,{'0','ARP Anomaly','IP–MAC Conflict','GT Conflict'});
xlim(ax2,[0 net.SimDuration_s]); ylim(ax2,[-0.1 2.5]);
grid(ax2,'on');
set(ax2,'FontSize',FS,'FontName','Times New Roman','Box','on');

saveas(fig2, '/home/claude/WiFi_SDRN_Simulation/Fig2_IPMAC_Conflict.png');

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 3 – Beacon Frame Fingerprinting (Stage-1)
%% ??????????????????????????????????????????????????????????????????????????
fig3 = figure('Name','Fig3_Beacon_Fingerprint','NumberTitle','off',...
    'Position',[830 600 760 380]);
ax3a = subplot(2,1,1);

bar(ax3a, t, sim.legitBeacons, 1, 'FaceColor', colorNorm, 'EdgeColor','none'); hold on;
bar(ax3a, t, -sim.rogueBeacons, 1, 'FaceColor', colorAtk, 'EdgeColor','none');
legend(ax3a,'Legitimate Beacons','Rogue AP Beacons (inverted)',...
    'Location','northeast','FontSize',FS-1);
ylabel(ax3a,'Beacon Frames/s','FontSize',FS);
title(ax3a,'Beacon Frame Counts (Legitimate vs Rogue AP)','FontSize',FS);
xlim(ax3a,[0 net.SimDuration_s]); grid(ax3a,'on');
set(ax3a,'FontName','Times New Roman','FontSize',FS);

ax3b = subplot(2,1,2);
area(ax3b, t, beaconResult.score, 'FaceColor',[0.12 0.47 0.71],...
    'FaceAlpha',0.6,'EdgeColor','none'); hold on;
yline(ax3b, beaconResult.threshold, '--r','Threshold','LineWidth',LW,...
    'LabelHorizontalAlignment','right','FontSize',FS-1);
shadeAttack();
xlabel(ax3b,'Time (s)','FontSize',FS);
ylabel(ax3b,'Anomaly Score','FontSize',FS);
title(ax3b,'Stage-1 Beacon Fingerprint Anomaly Score','FontSize',FS);
xlim(ax3b,[0 net.SimDuration_s]); ylim(ax3b,[0 1.1]); grid(ax3b,'on');
set(ax3b,'FontName','Times New Roman','FontSize',FS);

sgtitle(fig3,'Figure 3: Physical-Layer Beacon Fingerprinting',...
    'FontSize',FS+1,'FontWeight','bold','FontName','Times New Roman');
saveas(fig3, '/home/claude/WiFi_SDRN_Simulation/Fig3_Beacon_Fingerprint.png');

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 4 – Dual-Stage Attack Detection Timeline
%% ??????????????????????????????????????????????????????????????????????????
fig4 = figure('Name','Fig4_Detection_Timeline','NumberTitle','off',...
    'Position',[830 250 760 380]);
ax4 = axes(fig4);

% Stacked event rows
rowGT  = 3; rowS1 = 2; rowS2 = 1.5; rowFus = 1;
hold(ax4,'on');

% Ground truth bar
for k = find(fusedResult.gt)'
    fill(ax4,[t(k) t(k)+1 t(k)+1 t(k)],...
        [rowGT-0.3 rowGT-0.3 rowGT+0.3 rowGT+0.3],...
        [0.8 0.2 0.2],'EdgeColor','none');
end
% Stage-1 detections
for k = find(fusedResult.stage1)'
    fill(ax4,[t(k) t(k)+1 t(k)+1 t(k)],...
        [rowS1-0.3 rowS1-0.3 rowS1+0.3 rowS1+0.3],...
        [0.2 0.4 0.8],'EdgeColor','none');
end
% Stage-2 detections
for k = find(fusedResult.stage2)'
    fill(ax4,[t(k) t(k)+1 t(k)+1 t(k)],...
        [rowS2-0.3 rowS2-0.3 rowS2+0.3 rowS2+0.3],...
        [0.95 0.6 0.1],'EdgeColor','none');
end
% Fused output
for k = find(fusedResult.fused)'
    fill(ax4,[t(k) t(k)+1 t(k)+1 t(k)],...
        [rowFus-0.3 rowFus-0.3 rowFus+0.3 rowFus+0.3],...
        [0.1 0.6 0.2],'EdgeColor','none');
end

yticks(ax4,[rowFus rowS2 rowS1 rowGT]);
yticklabels(ax4,{'Fused Output','Stage-2 (ARP)','Stage-1 (Beacon)','Ground Truth'});
xlabel(ax4,'Time (s)','FontSize',FS);
title(ax4,'Figure 4: Dual-Stage Attack Detection Timeline',...
    'FontSize',FS+1,'FontWeight','bold');
xlim(ax4,[0 net.SimDuration_s]); ylim(ax4,[0.5 3.6]);
grid(ax4,'on'); box(ax4,'on');
set(ax4,'FontSize',FS,'FontName','Times New Roman');

% Latency annotation
if ~isnan(fusedResult.latency)
    text(ax4, net.AttackStart_s+fusedResult.latency+1, 0.85,...
        sprintf('Latency = %.0f s',fusedResult.latency),...
        'FontSize',FS-1,'Color',colorDetect,'FontName','Times New Roman');
    xline(ax4, net.AttackStart_s+fusedResult.latency, '-.b','LineWidth',1.2);
end

saveas(fig4, '/home/claude/WiFi_SDRN_Simulation/Fig4_Detection_Timeline.png');

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 5 – Performance Metrics Bar Chart
%% ??????????????????????????????????????????????????????????????????????????
fig5 = figure('Name','Fig5_Performance','NumberTitle','off',...
    'Position',[50 0 560 350]);
ax5 = axes(fig5);

% Metrics for Stage-1, Stage-2, Fused
labels   = {'Accuracy','Precision','Recall (TPR)','F1-Score','1 – FPR'};
nMetrics = numel(labels);

% Recompute per stage
gt = fusedResult.gt;
computeMetrics = @(pred) struct(...
    'Acc',  (sum(pred& gt)+sum(~pred&~gt))/numel(gt),...
    'Prec', sum(pred& gt)/max(sum(pred),1),...
    'Rec',  sum(pred& gt)/max(sum(gt),1),...
    'F1',   2*sum(pred&gt)/(max(sum(pred)+sum(gt),1)),...
    'Spec', sum(~pred&~gt)/max(sum(~gt),1));

mS1  = computeMetrics(fusedResult.stage1);
mS2  = computeMetrics(fusedResult.stage2);
mFus = computeMetrics(fusedResult.fused);

data = [[mS1.Acc  mS1.Prec  mS1.Rec  mS1.F1  mS1.Spec]*100;
        [mS2.Acc  mS2.Prec  mS2.Rec  mS2.F1  mS2.Spec]*100;
        [mFus.Acc mFus.Prec mFus.Rec mFus.F1 mFus.Spec]*100];

b = bar(ax5, data');
b(1).FaceColor = [0.12 0.47 0.71];
b(2).FaceColor = [0.93 0.60 0.10];
b(3).FaceColor = [0.18 0.55 0.34];

legend(ax5,'Stage-1 (Beacon FP)','Stage-2 (ARP Analysis)','Fused Output',...
    'Location','southeast','FontSize',FS-1);
xticklabels(ax5, labels);
ylabel(ax5,'Performance (%)', 'FontSize',FS);
title(ax5,'Figure 5: Detection Performance Metrics by Stage',...
    'FontSize',FS+1,'FontWeight','bold');
ylim(ax5,[0 110]); grid(ax5,'on'); box(ax5,'on');
set(ax5,'FontSize',FS,'FontName','Times New Roman');

% Label bars
for gi = 1:3
    for bi = 1:nMetrics
        text(ax5, bi + (gi-2)*0.27, data(gi,bi)+1.5,...
            sprintf('%.1f',data(gi,bi)),'FontSize',7,...
            'HorizontalAlignment','center','FontName','Times New Roman');
    end
end

saveas(fig5, '/home/claude/WiFi_SDRN_Simulation/Fig5_Performance.png');

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 6 – ROC Curve
%% ??????????????????????????????????????????????????????????????????????????
fig6 = figure('Name','Fig6_ROC','NumberTitle','off',...
    'Position',[630 0 430 380]);
ax6 = axes(fig6);

plot(ax6, fusedResult.rocFPR, fusedResult.rocTPR, '-b', 'LineWidth', LW+0.4);
hold on;
plot(ax6, [0 1],[0 1], '--k','LineWidth',1,'DisplayName','Random (AUC=0.5)');

% AUC via trapezoidal integration
[fprS,idx] = sort(fusedResult.rocFPR);
tprS       = fusedResult.rocTPR(idx);
AUC        = trapz(fprS, tprS);
text(ax6, 0.55, 0.25, sprintf('AUC = %.4f', AUC),...
    'FontSize',FS,'FontName','Times New Roman','Color',colorDetect);

% Operating point
opFPR = sum(fusedResult.fused & ~gt)/max(sum(~gt),1);
opTPR = sum(fusedResult.fused &  gt)/max(sum(gt),1);
plot(ax6, opFPR, opTPR, 'ro', 'MarkerSize',9, 'MarkerFaceColor','r',...
    'DisplayName','Operating Point');

legend(ax6, 'SDRN Dual-Stage ROC','Random Classifier','Operating Point',...
    'Location','southeast','FontSize',FS-1);
xlabel(ax6,'False Positive Rate','FontSize',FS);
ylabel(ax6,'True Positive Rate (Recall)','FontSize',FS);
title(ax6,'Figure 6: ROC Curve – SDRN Detection System',...
    'FontSize',FS+1,'FontWeight','bold');
xlim(ax6,[0 1]); ylim(ax6,[0 1]); grid(ax6,'on'); box(ax6,'on');
set(ax6,'FontSize',FS,'FontName','Times New Roman');
axis(ax6,'square');

saveas(fig6, '/home/claude/WiFi_SDRN_Simulation/Fig6_ROC.png');

%% ??????????????????????????????????????????????????????????????????????????
%  FIGURE 7 – Confusion Matrix Heatmap
%% ??????????????????????????????????????????????????????????????????????????
fig7 = figure('Name','Fig7_Confusion','NumberTitle','off',...
    'Position',[1080 0 380 340]);
ax7 = axes(fig7);

CM = [fusedResult.TP fusedResult.FN;
      fusedResult.FP fusedResult.TN];

imagesc(ax7, CM);
colormap(ax7, [linspace(0.95,0.12,256)', linspace(0.95,0.47,256)', ...
               linspace(0.95,0.71,256)']);
colorbar(ax7);

for r = 1:2
    for c = 1:2
        clr = 'w';
        if CM(r,c) < max(CM(:))*0.6, clr='k'; end
        text(ax7, c, r, num2str(CM(r,c)),...
            'HorizontalAlignment','center','FontSize',15,...
            'FontWeight','bold','Color',clr,...
            'FontName','Times New Roman');
    end
end

xticklabels(ax7,{'Predicted Attack','Predicted Normal'});
yticklabels(ax7,{'Actual Attack','Actual Normal'});
title(ax7,'Figure 7: Confusion Matrix (Fused Detector)',...
    'FontSize',FS+1,'FontWeight','bold');
set(ax7,'FontSize',FS,'FontName','Times New Roman','TickLength',[0 0]);

saveas(fig7, '/home/claude/WiFi_SDRN_Simulation/Fig7_Confusion.png');

fprintf('\n  All 7 figures saved to /home/claude/WiFi_SDRN_Simulation/\n');
end