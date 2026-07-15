function net = setup_network()
%% setup_network  –  Define the simulated public Wi-Fi topology
%
%  Returns a struct 'net' containing:
%    - Legitimate Access Point (AP) profiles (SSID, BSSID, channel, Tx power)
%    - Client MAC/IP assignments
%    - Attacker node profiles (rogue AP + ARP-spoofer)
%
%  In a real SDRN deployment the SDR hardware would capture these
%  parameters from live beacon frames; here we model them analytically.

%% ?? Legitimate APs ???????????????????????????????????????????????????????
net.numLegitAPs = 3;
net.APs(1) = struct('SSID','CafeNet','BSSID','AA:BB:CC:11:22:33',...
    'Channel',6,'TxPower_dBm',20,'Freq_MHz',2437,'BeaconInterval_ms',100);
net.APs(2) = struct('SSID','AirportFree','BSSID','AA:BB:CC:44:55:66',...
    'Channel',11,'TxPower_dBm',23,'Freq_MHz',2462,'BeaconInterval_ms',100);
net.APs(3) = struct('SSID','HotelWifi','BSSID','AA:BB:CC:77:88:99',...
    'Channel',1,'TxPower_dBm',18,'Freq_MHz',2412,'BeaconInterval_ms',100);

%% ?? Client Devices ???????????????????????????????????????????????????????
net.numClients = 8;
% Assign IP/MAC pairs – legitimate (no conflicts initially)
for k = 1:net.numClients
    net.Clients(k).IP  = sprintf('192.168.1.%d', 100 + k);
    net.Clients(k).MAC = sprintf('DE:AD:BE:EF:%02X:%02X', k, k*3);
    net.Clients(k).AssocAP = mod(k-1, net.numLegitAPs) + 1;
end

%% ?? Attacker Nodes ???????????????????????????????????????????????????????
net.numAttackers = 2;

% Attacker 1 – Rogue AP (mimics CafeNet with slight BSSID/power change)
net.Attackers(1).Type        = 'RogueAP';
net.Attackers(1).SSID        = 'CafeNet';          % same SSID (Evil-Twin)
net.Attackers(1).BSSID       = 'FF:EE:DD:11:22:33'; % spoofed BSSID
net.Attackers(1).Channel     = 6;
net.Attackers(1).TxPower_dBm = 28;                  % higher power – common trick
net.Attackers(1).Freq_MHz    = 2437;
net.Attackers(1).BeaconInterval_ms = 50;            % faster beacons

% Attacker 2 – ARP Spoofer / MITM
net.Attackers(2).Type        = 'ARPSpoofer';
net.Attackers(2).IP          = '192.168.1.1';       % Gateway IP
net.Attackers(2).MAC         = 'BA:DC:0D:ED:BE:EF'; % Attacker's real MAC
net.Attackers(2).TargetIP    = '192.168.1.101';     % Victim client IP

%% ?? Simulation Time ??????????????????????????????????????????????????????
net.SimDuration_s   = 120;   % total simulation seconds
net.AttackStart_s   = 40;    % attacks begin at t = 40 s
net.AttackEnd_s     = 100;   % attacks cease at t = 100 s
net.TimeStep_s      = 1;     % 1-second resolution
end