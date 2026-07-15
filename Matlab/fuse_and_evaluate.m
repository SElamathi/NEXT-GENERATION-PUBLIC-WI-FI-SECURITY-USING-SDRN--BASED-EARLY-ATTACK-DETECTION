function fusedResult = fuse_and_evaluate(beaconResult, arpResult, sim)
%% fuse_and_evaluate  –  Dual-Stage Decision Fusion & Performance Metrics
%
%  Fusion rule (conservative AND for high precision):
%    Final alert = Stage1 OR Stage2   (OR gives better recall)
%
%  Computes per-second confusion matrix entries and aggregate metrics:
%    TP, FP, TN, FN  ?  Accuracy, Precision, Recall, F1, FPR

gt      = sim.attackMask;          % ground truth (logical)
stage1  = beaconResult.detected;
stage2  = arpResult.combined;
fused   = stage1 | stage2;         % OR fusion for maximum coverage

N       = sim.N;

%% ?? Per-second Confusion Matrix ?????????????????????????????????????????
TP = sum( fused &  gt);
FP = sum( fused & ~gt);
TN = sum(~fused & ~gt);
FN = sum(~fused &  gt);

Accuracy  = (TP+TN) / N;
Precision = TP / max(TP+FP, 1);
Recall    = TP / max(TP+FN, 1);     % = True Positive Rate
F1        = 2*Precision*Recall / max(Precision+Recall, 1e-9);
FPR       = FP / max(FP+TN, 1);     % False Positive Rate

%% ?? Detection Latency ????????????????????????????????????????????????????
latency = NaN;
firstDet = find(fused, 1, 'first');
if ~isempty(firstDet)
    latency = sim.time(firstDet) - sim.time(find(gt,1,'first'));
    latency = max(0, latency);
end

%% ?? Print Summary ????????????????????????????????????????????????????????
fprintf('\n?? Performance Summary ???????????????????????????????????\n');
fprintf('  TP=%d  FP=%d  TN=%d  FN=%d\n', TP, FP, TN, FN);
fprintf('  Accuracy  : %.2f %%\n', Accuracy*100);
fprintf('  Precision : %.2f %%\n', Precision*100);
fprintf('  Recall    : %.2f %%\n', Recall*100);
fprintf('  F1-Score  : %.4f\n',    F1);
fprintf('  FP Rate   : %.2f %%\n', FPR*100);
if ~isnan(latency)
    fprintf('  Detection Latency : %.1f s after attack onset\n', latency);
end
fprintf('??????????????????????????????????????????????????????????\n');

%% ?? ROC Curve Data (vary threshold on beacon score) ?????????????????????
thresholds = linspace(0, 1, 200);
rocTPR = zeros(size(thresholds));
rocFPR = zeros(size(thresholds));
for i = 1:numel(thresholds)
    pred = (beaconResult.score > thresholds(i)) | arpResult.combined;
    rocTPR(i) = sum(pred &  gt) / max(sum(gt),1);
    rocFPR(i) = sum(pred & ~gt) / max(sum(~gt),1);
end

fusedResult.fused     = fused;
fusedResult.stage1    = stage1;
fusedResult.stage2    = stage2;
fusedResult.gt        = gt;
fusedResult.TP = TP; fusedResult.FP = FP;
fusedResult.TN = TN; fusedResult.FN = FN;
fusedResult.Accuracy  = Accuracy;
fusedResult.Precision = Precision;
fusedResult.Recall    = Recall;
fusedResult.F1        = F1;
fusedResult.FPR       = FPR;
fusedResult.latency   = latency;
fusedResult.rocTPR    = rocTPR;
fusedResult.rocFPR    = rocFPR;
end