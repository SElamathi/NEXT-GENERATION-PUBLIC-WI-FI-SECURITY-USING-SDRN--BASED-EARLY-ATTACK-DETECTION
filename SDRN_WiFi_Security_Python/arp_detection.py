def arp_detection(data):
    threshold = 15
    suspicious = data["arp_rate"] > threshold

    result = {
        "suspicious_arp": suspicious,
        "score": suspicious.sum()
    }

    return result