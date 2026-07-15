def detection_engine(beacon_result, arp_result):
    alert = False

    if beacon_result["score"] > 10 and arp_result["score"] > 10:
        alert = True
        message = "⚠️ Rogue AP / MITM Attack Detected"
    else:
        message = "✅ Network Safe"

    return {
        "alert": alert,
        "message": message
    }