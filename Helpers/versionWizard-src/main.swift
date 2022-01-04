import Foundation
import ArgumentParser


struct VersionWizard: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "versionWizard",
        abstract: "Returns a public version from Apple servers, and build number auto-incremented",
        discussion: "",
        version: "2.0",
        shouldDisplay: true,
        subcommands: [],
        defaultSubcommand: nil,
        helpNames: nil
    )
    
    enum Platform: String, ExpressibleByArgument {
        case ios
        case macos
    }
    
    @Option(name: [.long, .customShort("c")], help: "Git commit hash")
    var commit: String
    
    @Option(name: [.long, .customShort("a")], help: "Apple ID of the app")
    var appID: String
    
    @Option(name: [.long, .customShort("p")], help: "Platform: ios, macos")
    var platform: Platform = .ios
    
    @Option(name: [.long, .customShort("t")], help: "Train (major version number, or major.minor). Will use the last published one if unspecified. Only [0-9.] are kept, so you can use a git branch name like \"release/sprint61\".")
    var train: String?
    
    @Option(name: [.long, .customShort("k")], help: "App Store Connect key ID")
    var keyID: String
    
    @Option(name: [.long, .customShort("i")], help: "Key issuer")
    var issuer: String
    
    @Option(name: [.long, .customShort("K")], help: "P8 file for the key")
    var p8: String
    
    mutating func run() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Requests all versions ever on App Store Connect.
        var request = URLRequest(url: URL(string: "https://api.appstoreconnect.apple.com/v1/apps/\(appID)/appStoreVersions")!)
        try request.sign(keyID: keyID, issuer: issuer, p8File: p8)
        
        let response = try request.fetchAndDecode(ASCResponse.self, using: decoder)
        if let error = response.errors?.first {
            throw NSError(domain: "appstoreconnect", code: Int(error.status) ?? -1, userInfo: [
                "id": error.id,
                "status": error.status,
                "code": error.code,
                "title": error.title,
                "detail": error.detail,
                NSLocalizedDescriptionKey: "\(error.code) (\(error.title) -- \(error.detail))"
            ])
        }
        
        guard let apps = response.data else { throw NSError(domain: "appstoreconnect", code: -1, userInfo: ["code": "NO_DATA", NSLocalizedDescriptionKey: "No `data` returned."]) }
        
        // Find the highest train
        let highest = apps
            .map(\.attributes.versionString)
            .sorted(by: String.versionSort)
            .last?
            .fixNtoNPointZero
            .removingLastVersionComponent
        
        let train = train?.nilIfEmpty?.sanitized ?? highest ?? "1"
        
        let lastPublished = apps.filter({
            $0.attributes.versionString.fixNtoNPointZero.hasPrefix("\(train).") &&
            $0.attributes.appStoreState.hasBeenPublished
        }).map(\.attributes.versionString.fixNtoNPointZero).sorted().last
        
        let nextPublicVersion: String
        if let last = lastPublished {
            var pieces = last.components(separatedBy: ".")
            let lastPlusOne = Int(pieces.popLast()!)! + 1
            pieces.append(String(lastPlusOne))
            nextPublicVersion = pieces.joined(separator: ".")
        }
        else {
            nextPublicVersion = "\(train).0"
        }
        
        let request2 = URLRequest(url: URL(string: "https://uad.io/versions.php?app-id=\(appID)&commit=\(commit)")!)
        let build = try request2.fetchAndDecode(CommitResponse.self, using: decoder).build
        
        let output = try JSONSerialization.data(withJSONObject: [
            "public": nextPublicVersion,
            "build": build
        ], options: [])
        print(String(data: output, encoding: .utf8)!)
    }
}
VersionWizard.main()

extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        flatMap(\.nilIfEmpty)
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    var sanitized: String {
        // Keep only [0-9.]
        filter({ $0.isNumber || $0 == "." })
    }
    
    var fixNtoNPointZero: String {
        contains(".") ? self : self.appending(".0")
    }
    
    var removingLastVersionComponent: String {
        let pieces = components(separatedBy: ".")
        if pieces.count <= 1 { return self }
        return pieces.dropLast().joined(separator: ".")
    }
    
    static func versionSort(_ lhs: String, _ rhs: String) -> Bool {
        let L = lhs.components(separatedBy: ".").map({ Int($0) ?? 0 })
        let R = rhs.components(separatedBy: ".").map({ Int($0) ?? 0 })
        for (l, r) in zip(L, R) {
            if l < r { return true }
            if l > r { return false }
        }
        return false
    }
}

struct CommitResponse: Decodable {
    let build: Int
}


struct ASCResponse: Decodable {
    let errors: [ASCError]?
    let data: [ASCApplication]?
}

struct ASCError: Decodable {
    let id: String
    let status: String
    let code: String
    let title: String
    let detail: String
//    let links: ASCErrorLink
}

struct ASCApplication: Decodable {
    let type: String
    let id: UUID
    let attributes: ASCAttributes
    //    let relationships: ASCRelationships
    //    let links: ASCLinks
}

struct ASCAttributes: Decodable {
    let platform: ASCPlatform // IOS, MAC_OS
    let versionString: String // public version number
    let appStoreState: ASCAppStoreState
//    let copyright: String?
//    let releaseType: ASCReleaseType
//    let earliestReleaseDate: Date?
//    let usesIdfa: Bool?
//    let downloadable: Bool
//    let createdDate: Date
}

enum ASCPlatform: String, Decodable {
    case iOS = "IOS"
    case macOS = "MAC_OS"
    case tvOS = "TV_OS"
}

enum ASCAppStoreState: String, Decodable {
    case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
    case developerRejected = "DEVELOPER_REJECTED"
    case inReview = "IN_REVIEW"
    case invalidBinary = "INVALID_BINARY"
    case metadataRejected = "METADATA_REJECTED"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case pendingContract = "PENDING_CONTRACT"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case preorderReadyForSale = "PREORDER_READY_FOR_SALE"
    case processingForAppStore = "PROCESSING_FOR_APP_STORE"
    case readyForSale = "READY_FOR_SALE"
    case rejected = "REJECTED"
    case removedFromSale = "REMOVED_FROM_SALE"
    case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"

    var hasBeenPublished: Bool {
        switch self {
            case .developerRemovedFromSale, .pendingAppleRelease, .pendingDeveloperRelease, .preorderReadyForSale, .processingForAppStore, .readyForSale, .removedFromSale, .replacedWithNewVersion: return true
            default: return false
        }
    }
}
