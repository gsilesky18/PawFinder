//
//  PetFinderApi.swift
//  PawFinder
//
//  Created by Greg Silesky on 10/11/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Siesta

class PetFinderApi: Service {
    //Singleton instance of API
    static let sharedInstance = PetFinderApi()
    //PetFinders key and secret for OAuth
    fileprivate let type: String = "client_credentials"
    fileprivate let key: String = "RkvOae6eesNE6XUB1QxQvDNPeNRDvveWUEix0P5zSKXQWmhtPK"
    fileprivate let secret: String = "CTPs7G6cMiygXVNFDM9QVGvvuD3KFk47HNkdgFDZ"
    
    fileprivate var authToken: String?
    
    fileprivate let jsonDecoder = JSONDecoder()
    
    fileprivate init(){
        #if DEBUG
        SiestaLog.Category.enabled = .common
        #endif
        //Siesta init
        super.init(baseURL: "https://api.petfinder.com/v2", standardTransformers: [.text, .image])
        
        //Config all request headers to include Bearer token
        configure("**") {
          if let authToken = self.authToken {
            $0.headers["Authorization"] =  "Bearer " + authToken         // Set the token header from a var that we can update
          }
          //Add decorator incase access token has expired
          $0.decorateRequests {
            self.refreshTokenOnAuthFailure(request: $1)
          }
        }
        
        //Mapping from specific paths to models
        configureTransformer("/animals") {
            try self.jsonDecoder.decode(GetAnimalsResponse.self, from: $0.content)
        }
    }
    
    /// Checks to see if request failed authentication. If so, then chain oauth request and repeat.
    ///
    /// - Parameter request: Current request
    /// - Returns: Returns current request or chain request.
    fileprivate func refreshTokenOnAuthFailure(request: Request) -> Request {
        return request.chained {
        guard case .failure(let error) = $0.response,  // Did request fail…
          error.httpStatusCode == 401 else {           // …because of expired token?
            return .useThisResponse                    // If not, use the response we got.
        }

        return .passTo(
          self.createAuthToken().chained {             // If so, first request a new token, then:
            if case .failure = $0.response {           // If token request failed…
              return .useThisResponse                  // …report that error.
            } else {
              return .passTo(request.repeated())       // We have a new token! Repeat the original request.
            }
          }
        )
      }
    }

    /// Makes request to get new access token.
    ///
    /// - Returns: Oauth request
    fileprivate func createAuthToken() -> Request {
      return resource("/oauth2/token")
        .request(.post, json: getAccessTokenRequest())
        .onSuccess {
            if let data = $0.content as? Data, let response = try? self.jsonDecoder.decode(AccessTokenResponse.self, from: data){
                self.authToken = response.accessToken   // Store the new token, then…
                self.invalidateConfiguration()          // …make future requests use it
            }
        }
    }
    
    fileprivate func getAccessTokenRequest() -> JSONConvertible {
        return ["grant_type": type, "client_id": key, "client_secret": secret]
    }
    
    /// Get resource for adoptable animals
    ///
    /// - Returns: Resource to load data
    func getAnimals() -> Resource {
        return resource("/animals").withParam("type", "dog")
    }
    
}

