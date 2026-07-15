import numpy as np

def wifi_environment():
    time = np.arange(1, 101)

    beacon_power = -40 + np.random.randn(100)
    arp_rate = 5 + np.random.rand(100)

    data = {
        "time": time,
        "beacon_power": beacon_power,
        "arp_rate": arp_rate,
        "legit_ap_mac": "AA:BB:CC:DD:EE:01"
    }

    return data