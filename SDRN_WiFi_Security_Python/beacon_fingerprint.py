def beacon_fingerprint(data):
    threshold = -35
    suspicious = data["beacon_power"] > threshold

    result = {
        "suspicious_beacon": suspicious,
        "score": suspicious.sum()
    }

    return result