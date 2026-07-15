from wifi_environment import wifi_environment
from arp_attack import arp_attack
from beacon_fingerprint import beacon_fingerprint
from arp_detection import arp_detection
from detection_engine import detection_engine
from plot_results import plot_results

print("SDRN-Based Early Attack Detection Simulation Started")

data = wifi_environment()
data = arp_attack(data)

beacon_result = beacon_fingerprint(data)
arp_result = arp_detection(data)

final_result = detection_engine(beacon_result, arp_result)

plot_results(data, final_result)

print("Simulation Completed")