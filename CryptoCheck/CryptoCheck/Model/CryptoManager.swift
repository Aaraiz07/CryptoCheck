//
//  CryptoManager.swift
//  CryptoCheck
//
//  Created by Aaraiz Wasim on 22/10/2023.
//

import Foundation

protocol CryptoManagerDelegate {
    
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CryptoManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1FD10FE9-E158-4C6C-9F2A-3E7F8B8FF04A"
    var delegate : CryptoManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
            
            let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"

            if let url = URL(string: urlString) {
                
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    
                    if let safeData = data {
                        
                        if let bitcoinPrice = self.parseJSON(safeData) {
                            
                            //Optional: round the price down to 2 decimal places.
                            let priceString = String(format: "%.2f", bitcoinPrice)
                            
                            //Call the delegate method in the delegate (ViewController) and
                            //pass along the necessary data.
                            self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                        }
                    }
                }
                task.resume()
            }
        }
    
    func parseJSON(_ data: Data) -> Double? {
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CoinData.self, from: data)
                let lastPrice = decodedData.rate
                print(lastPrice)
                return lastPrice
                
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    
}
