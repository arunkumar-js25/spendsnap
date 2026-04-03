Map<String, String> parseUpi(String uri) {
  final Uri parsed = Uri.parse(uri);

  return {
    "amount": parsed.queryParameters["am"] ??
        parsed.queryParameters["mam"] ??
        "0",
    "note": parsed.queryParameters["tn"] ?? "",
    "name": parsed.queryParameters["pn"] ?? "",
  };
}

String detectCategory(String note) {
  final text = note.toLowerCase();
  if (text.contains("milk") || text.contains("food") || text.contains("hotel")) {
    return "Food";
  } else if (text.contains("petrol") || text.contains("uber") || text.contains("bus")) {
    return "Travel";
  } else if (text.contains("amazon") || text.contains("shopping")) {
    return "Shopping";
  }else if (text.contains("contribution") || text.contains("tier type")) {
    return "Investment";
  }

  return "Others";
}