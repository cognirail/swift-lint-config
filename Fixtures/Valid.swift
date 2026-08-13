struct AccountIdentifier {
    let rawValue: String
}

func normalizedName(for accountIdentifier: AccountIdentifier) -> String {
    accountIdentifier.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
}
