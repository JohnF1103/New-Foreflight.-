//
//  API_Req.swift
//  New_Foreflight
//
//  Created by John Foster on 12/23/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ContentView{
    
    
    func Get_Metar(res: String, IACO: String){
       

        var semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: "https://api.checkwx.com/metar/\(IACO)/decoded")!,timeoutInterval: Double.infinity)

        //client side exposure. best practice to encrypt this
        request.addValue("8bf1b3467a3548a1bb8b643978", forHTTPHeaderField: "X-API-Key")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
            print(String(data: data, encoding: .utf8)!)
            

          semaphore.signal()
        }


        task.resume()
        semaphore.wait()

        
        
        
    }
    
}



