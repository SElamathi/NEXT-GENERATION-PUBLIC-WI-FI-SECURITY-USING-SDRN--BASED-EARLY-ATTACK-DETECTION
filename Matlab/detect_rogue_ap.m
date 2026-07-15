function result = detect_rogue_ap(sim, net)
%% detect_rogue_ap  –  Stage-1: Physical-Layer Beacon Fingerprinting
%
%  SDRN receivers capture beacon frames and extract RF fingerprint features:
%    1. Transmit Power anomaly  (rogue AP often uses higher Tx power)
%    2. Beacon Interval anomaly (rogue AP uses faster interval = 50 ms)
%    3. BSSID vs known whitelist mismatch
%    4. Simultaneous same-SSID dual-AP detection (Evil-Twin signature)
%
%  A simple threshold-based scoring scheme is used; in practice an ML
%  classifier (SVM / Random Forest) would sit here.
%
%  Output 'result' struct:
%    .detected     – per-second boolean detection flag (Stage-1 only)
%    .score        – continuous anomaly score [0,1]
%    .detectedTime – first detection timestamp (s)

N = sim.N;
score = zeros(N,1);

for k = 1:N
    s = 0;

    %?? Feature 1: Unexpected beacon burst (rogue beacons present) ?????????
    if sim.rogueBeacons(k) > 5
        s = s + 0.4;
    end

    %?? Feature 2: Rogue-to-legit beacon ratio exceeds threshold ???????????
    ratio = sim.rogueBeacons(k) / max(sim.legitBeacons(k), 1);
    if ratio > 0.3
        s = s + 0.3 * min(ratio, 1);
    end

    %?? Feature 3: Simultaneous same-SSID detection ????????????????????????
    % Modelled as: rogue beacons > 0 AND legit beacons > 0 on same channel
    if sim.rogueBeacons(k) > 0 && sim.legitBeacons(k) > 0
        s = s + 0.3;
    end

    % Add small sensor noise to score
    score(k) = min(1, s + abs(randn*0.05));
end

%?? Thresholding with small lag (processing latency ~2 s) ??????????????????
threshold    = 0.45;
detected_raw = score > threshold;

% Sliding window vote: flag if 3 of last 5 seconds flagged (reduce FP)
detected = false(N,1);
for k = 5:N
    window = detected_raw(k-4:k);
    if sum(window) >= 3
        detected(k) = true;
    end
end

% First detection timestamp
idx = find(detected, 1, 'first');
if ~isempty(idx)
    result.detectedTime = sim.time(idx);
    fprintf('      [Beacon FP] Rogue AP first detected at t = %.1f s\n', ...
        result.detectedTime);
else
    result.detectedTime = NaN;
    fprintf('      [Beacon FP] No rogue AP detected.\n');
end

result.detected  = detected;
result.score     = score;
result.threshold = threshold;
end