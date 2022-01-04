//
//  jwt.swift
//  jwt
//
//  Created by Cyrille Legrand on 10/09/2021.
//

import Foundation
import SwiftJWT

extension URLRequest {
    @discardableResult
    mutating func sign(keyID: String, issuer: String, p8File: String) throws -> Self {
        guard let keyData = FileManager.default.contents(atPath: p8File) else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        
        let header = Header(kid: keyID)
        let claims = ASCClaims(
            iss: issuer,
            iat: Int(Date().timeIntervalSince1970),
            exp: Int(Calendar.current.date(byAdding: .minute, value: 5, to: Date())!.timeIntervalSince1970),
            aud: "appstoreconnect-v1"
        )
        
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.es256(privateKey: keyData)
        let token = try jwt.sign(using: signer)
        
        addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return self
    }
    
    fileprivate struct ASCClaims: Claims {
        let iss: String
        let iat: Int // timestamp
        let exp: Int // timestamp
        let aud: String
    }
    
    func fetchAndDecode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder) throws -> T {
        let sema = DispatchSemaphore(value: 0)
        var retData: Data? = nil
        var retError: Error? = nil
        
        URLSession.shared.dataTask(with: self) { data, response, error in
            retData = data
            retError = error
            sema.signal()
        }.resume()
        _ = sema.wait(timeout: .distantFuture)
        
        guard let data = retData else {
            throw retError ?? CocoaError(.fileReadUnknown)
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

