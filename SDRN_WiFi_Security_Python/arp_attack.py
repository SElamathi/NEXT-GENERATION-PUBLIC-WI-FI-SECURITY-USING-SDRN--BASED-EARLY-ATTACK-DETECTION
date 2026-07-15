import numpy as np

def arp_attack(data):
    attack_start = 50

    data["arp_rate"][attack_start:] += 20
    data["beacon_power"][attack_start:] = -30 + np.random.randn(51)

    data["rogue_ap_mac"] = "AA:BB:CC:DD:EE:99"

    return data