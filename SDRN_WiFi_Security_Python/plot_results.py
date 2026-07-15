import matplotlib.pyplot as plt

def plot_results(data, final_result):
    time = data["time"]
    beacon = data["beacon_power"]
    arp = data["arp_rate"]

    plt.figure(figsize=(8,6))

    plt.subplot(2,1,1)
    plt.plot(time, beacon)
    plt.xlabel("Time")
    plt.ylabel("Beacon Power (dBm)")
    plt.title("Beacon Signal Analysis")

    plt.subplot(2,1,2)
    plt.plot(time, arp)
    plt.xlabel("Time")
    plt.ylabel("ARP Packet Rate")
    plt.title("ARP Behavior Analysis")

    plt.suptitle(final_result["message"])
    plt.tight_layout()
    plt.show()