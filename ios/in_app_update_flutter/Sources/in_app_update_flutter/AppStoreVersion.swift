import Foundation

/// Pure helpers for `checkForUpdateIos`, kept free of UIKit/StoreKit so they
/// can be unit tested on their own.
enum AppStoreVersion {
  /// Parses a version made of period-separated integers (for example `1.2.0`).
  /// Returns nil if any component is empty or not made only of digits 0-9.
  static func parse(_ version: String) -> [Int]? {
    let parts = version.split(separator: ".", omittingEmptySubsequences: false)
    var numbers: [Int] = []
    for part in parts {
      guard !part.isEmpty,
            part.allSatisfy({ ("0"..."9").contains($0) }),
            let number = Int(part) else {
        return nil
      }
      numbers.append(number)
    }
    return numbers
  }

  /// Returns whether `storeVersion` is newer than `installedVersion`, comparing
  /// component by component with missing components treated as 0 (so `1.2`
  /// equals `1.2.0`). Returns nil if either version cannot be parsed.
  static func isNewer(storeVersion: String, than installedVersion: String) -> Bool? {
    guard let store = parse(storeVersion), let installed = parse(installedVersion) else {
      return nil
    }
    for index in 0..<max(store.count, installed.count) {
      let storePart = index < store.count ? store[index] : 0
      let installedPart = index < installed.count ? installed[index] : 0
      if storePart != installedPart {
        return storePart > installedPart
      }
    }
    return false
  }

  /// Converts the ISO 3166-1 alpha-3 code StoreKit reports for a storefront
  /// (for example `IND`) into the alpha-2 code the iTunes Lookup API accepts
  /// (for example `IN`). The lookup rejects alpha-3 codes with HTTP 400.
  static func alpha2CountryCode(fromAlpha3 code: String) -> String? {
    return alpha3ToAlpha2[code.uppercased()]
  }

  /// ISO 3166-1 alpha-3 to alpha-2 codes, generated from the system ICU data
  /// (`uloc_getISOCountries` / `uloc_getISO3Country`).
  private static let alpha3ToAlpha2: [String: String] = [
    "ABW": "AW", "AFG": "AF", "AGO": "AO", "AIA": "AI", "ALA": "AX", "ALB": "AL",
    "AND": "AD", "ARE": "AE", "ARG": "AR", "ARM": "AM", "ASC": "AC", "ASM": "AS",
    "ATA": "AQ", "ATF": "TF", "ATG": "AG", "AUS": "AU", "AUT": "AT", "AZE": "AZ",
    "BDI": "BI", "BEL": "BE", "BEN": "BJ", "BES": "BQ", "BFA": "BF", "BGD": "BD",
    "BGR": "BG", "BHR": "BH", "BHS": "BS", "BIH": "BA", "BLM": "BL", "BLR": "BY",
    "BLZ": "BZ", "BMU": "BM", "BOL": "BO", "BRA": "BR", "BRB": "BB", "BRN": "BN",
    "BTN": "BT", "BVT": "BV", "BWA": "BW", "CAF": "CF", "CAN": "CA", "CCK": "CC",
    "CHE": "CH", "CHL": "CL", "CHN": "CN", "CIV": "CI", "CMR": "CM", "COD": "CD",
    "COG": "CG", "COK": "CK", "COL": "CO", "COM": "KM", "CPT": "CP", "CPV": "CV",
    "CRI": "CR", "CRQ": "CQ", "CUB": "CU", "CUW": "CW", "CXR": "CX", "CYM": "KY",
    "CYP": "CY", "CZE": "CZ", "DEU": "DE", "DGA": "DG", "DJI": "DJ", "DMA": "DM",
    "DNK": "DK", "DOM": "DO", "DZA": "DZ", "ECU": "EC", "EGY": "EG", "ERI": "ER",
    "ESH": "EH", "ESP": "ES", "EST": "EE", "ETH": "ET", "FIN": "FI", "FJI": "FJ",
    "FLK": "FK", "FRA": "FR", "FRO": "FO", "FSM": "FM", "GAB": "GA", "GBR": "GB",
    "GEO": "GE", "GGY": "GG", "GHA": "GH", "GIB": "GI", "GIN": "GN", "GLP": "GP",
    "GMB": "GM", "GNB": "GW", "GNQ": "GQ", "GRC": "GR", "GRD": "GD", "GRL": "GL",
    "GTM": "GT", "GUF": "GF", "GUM": "GU", "GUY": "GY", "HKG": "HK", "HMD": "HM",
    "HND": "HN", "HRV": "HR", "HTI": "HT", "HUN": "HU", "IDN": "ID", "IMN": "IM",
    "IND": "IN", "IOT": "IO", "IRL": "IE", "IRN": "IR", "IRQ": "IQ", "ISL": "IS",
    "ISR": "IL", "ITA": "IT", "JAM": "JM", "JEY": "JE", "JOR": "JO", "JPN": "JP",
    "KAZ": "KZ", "KEN": "KE", "KGZ": "KG", "KHM": "KH", "KIR": "KI", "KNA": "KN",
    "KOR": "KR", "KWT": "KW", "LAO": "LA", "LBN": "LB", "LBR": "LR", "LBY": "LY",
    "LCA": "LC", "LIE": "LI", "LKA": "LK", "LSO": "LS", "LTU": "LT", "LUX": "LU",
    "LVA": "LV", "MAC": "MO", "MAF": "MF", "MAR": "MA", "MCO": "MC", "MDA": "MD",
    "MDG": "MG", "MDV": "MV", "MEX": "MX", "MHL": "MH", "MKD": "MK", "MLI": "ML",
    "MLT": "MT", "MMR": "MM", "MNE": "ME", "MNG": "MN", "MNP": "MP", "MOZ": "MZ",
    "MRT": "MR", "MSR": "MS", "MTQ": "MQ", "MUS": "MU", "MWI": "MW", "MYS": "MY",
    "MYT": "YT", "NAM": "NA", "NCL": "NC", "NER": "NE", "NFK": "NF", "NGA": "NG",
    "NIC": "NI", "NIU": "NU", "NLD": "NL", "NOR": "NO", "NPL": "NP", "NRU": "NR",
    "NZL": "NZ", "OMN": "OM", "PAK": "PK", "PAN": "PA", "PCN": "PN", "PER": "PE",
    "PHL": "PH", "PLW": "PW", "PNG": "PG", "POL": "PL", "PRI": "PR", "PRK": "KP",
    "PRT": "PT", "PRY": "PY", "PSE": "PS", "PYF": "PF", "QAT": "QA", "REU": "RE",
    "ROU": "RO", "RUS": "RU", "RWA": "RW", "SAU": "SA", "SDN": "SD", "SEN": "SN",
    "SGP": "SG", "SGS": "GS", "SHN": "SH", "SJM": "SJ", "SLB": "SB", "SLE": "SL",
    "SLV": "SV", "SMR": "SM", "SOM": "SO", "SPM": "PM", "SRB": "RS", "SSD": "SS",
    "STP": "ST", "SUR": "SR", "SVK": "SK", "SVN": "SI", "SWE": "SE", "SWZ": "SZ",
    "SXM": "SX", "SYC": "SC", "SYR": "SY", "TAA": "TA", "TCA": "TC", "TCD": "TD",
    "TGO": "TG", "THA": "TH", "TJK": "TJ", "TKL": "TK", "TKM": "TM", "TLS": "TL",
    "TON": "TO", "TTO": "TT", "TUN": "TN", "TUR": "TR", "TUV": "TV", "TWN": "TW",
    "TZA": "TZ", "UGA": "UG", "UKR": "UA", "UMI": "UM", "URY": "UY", "USA": "US",
    "UZB": "UZ", "VAT": "VA", "VCT": "VC", "VEN": "VE", "VGB": "VG", "VIR": "VI",
    "VNM": "VN", "VUT": "VU", "WLF": "WF", "WSM": "WS", "XEA": "EA", "XIC": "IC",
    "XKK": "XK", "YEM": "YE", "ZAF": "ZA", "ZMB": "ZM", "ZWE": "ZW",
  ]
}
