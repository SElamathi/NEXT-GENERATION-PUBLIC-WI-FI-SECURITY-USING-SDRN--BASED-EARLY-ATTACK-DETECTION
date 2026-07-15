function sim = simulate_traffic(net)
%% simulate_traffic  –  Generate per-second ARP + beacon traffic vectors
%
%  Models three phases:
%    Phase 1 (0 – AttackStart)  : Normal operation
%    Phase 2 (AttackStart – AttackEnd) : Active attacks
%    Phase 3 (AttackEnd – End)  : Post-attack (residual noise)
%
%  Output struct 'sim' contains:
%    .time          – time axis (seconds)
%    .arpRate       – ARP requests/responses per second (aggregate)
%    .arpFlood      – boolean flag: is ARP flooding occurring?
%    .ipMacConflict – boolean flag: detected IP–MAC mismatch
%    .rogueBeacons  – count of rogue AP beacon frames per second
%    .legitBeacons  – count of legitimate AP beacon frames per second
%    .phaseLabel    – 'Normal' | 'Attack' | 'PostAttack'

T  = net.SimDuration_s;
dt = net.TimeStep_s;
t  = (0:dt:T-1)';          % time vector [Tx1]
N  = length(t);

attackMask = (t >= net.AttackStart_s) & (t < net.AttackEnd_s);

%% ?? Normal ARP Rate (Poisson-like, ~5–15 pkt/s) ?????????????????????????
baseARP = 5 + 10*rand(N,1);                        % background ARP traffic
noise   = randn(N,1) * 1.5;

%% ?? ARP Flood (during attack: 80–150 pkt/s) ?????????????????????????????
floodARP = zeros(N,1);
floodARP(attackMask) = 80 + 70*rand(sum(attackMask),1);

sim.arpRate   = max(0, baseARP + noise + floodARP);
sim.arpFlood  = attackMask;                        % ground truth

%% ?? IP–MAC Conflict Table ????????????????????????????????????????????????
% Each second, record whether a conflict was injected by attacker
sim.ipMacConflict = false(N,1);
% Attacker starts spoofing gateway IP at AttackStart with 2 s ramp
conflictOnset = net.AttackStart_s + 2;
sim.ipMacConflict(t >= conflictOnset & t < net.AttackEnd_s) = true;

%% ?? Beacon Frame Counts ??????????????????????????????????????????????????
% Legitimate: 3 APs × 10 beacons/s each = ~30/s ±noise
sim.legitBeacons = 30 + randn(N,1)*2;
sim.legitBeacons = max(0, sim.legitBeacons);

% Rogue AP: begins at AttackStart with 20 beacons/s (faster interval)
sim.rogueBeacons = zeros(N,1);
sim.rogueBeacons(attackMask) = 20 + randn(sum(attackMask),1)*1.5;
sim.rogueBeacons = max(0, sim.rogueBeacons);

%% ?? Phase Labels ?????????????????????????????????????????????????????????
sim.phaseLabel = repmat({'Normal'}, N, 1);
sim.phaseLabel(attackMask) = {'Attack'};
sim.phaseLabel(t >= net.AttackEnd_s) = {'PostAttack'};

sim.time = t;
sim.N    = N;
sim.attackMask = attackMask;  % ground-truth label for evaluation
end