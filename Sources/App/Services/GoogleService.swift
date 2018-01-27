//
//  GoogleService.swift
//  InvestingInMeAPIPackageDescription
//
//  Created by Liam Goodwin on 2018-01-26.
//

import Foundation
import Vapor
import HTTP
import JWT

final class GoogleService {
  
  static func getJWTKeys(token: JWT) throws -> JWTKeys.Key? {
    let request = Request (method: .get, uri: "https://www.googleapis.com/oauth2/v3/certs", headers: [.contentType : "application/json"])
    let response = try EngineClient.factory.respond(to: request)
    return try response.decodeJSONBody(JWTKeys.self)
      .keys
      .first{$0.kid == token.headers["kid"]?.string}
  }
  
  struct JWTKeys: Decodable {
    let keys: [Key]
    struct Key: Decodable {
      let kty: String
      let alg: String
      let use: String
      let kid: String
      let n: String
      let e: String
    }
  }
  
  
  
}
