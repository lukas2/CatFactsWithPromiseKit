//
//  ViewController.swift
//  CatFactsWithPromiseKit
//
//  Created by lukas2 on 26.02.19.
//  Copyright © 2019 lukas2. All rights reserved.
//

import UIKit
import PromiseKit

struct CatFact: Decodable {
    var text: String
}

struct CatError: Error {
    let message: String
}

class ViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    private let backgroundQueue = DispatchQueue.global(qos: .background)
    
    @IBAction func onTap() {
        firstly { self.printInfo() }
            .then { self.fetch() }
            .then { self.parse($0) }
            .then { self.display($0.text) }
            .catch { self.display("*** ERROR: \(($0 as! CatError).message)") }
    }
    
    private func printInfo() -> Promise<Void> {
        return Promise<Void> { seal in
            Swift.print("Fetching a cat fact from the Internet..")
            seal.fulfill_()
        }
    }
    
    private func fetch() -> Promise<Data> {
        return Promise<Data> { seal in
            backgroundQueue.async {
                //sleep(arc4random() % 5)
                
                let url = URL(string: "https://cat-fact.herokuapp.com/facts/random")!
                
                if let data = try? Data(contentsOf: url) {
                    seal.fulfill(data)
                } else {
                    seal.reject(CatError(message: "Fetch failed."))
                }
            }
        }
    }
    
    private func parse(_ data: Data) -> Promise<CatFact> {
        return Promise<CatFact> { seal in
            let decoder = JSONDecoder()
            
            if let catFact = try? decoder.decode(CatFact.self, from: data) {
                seal.fulfill(catFact)
            } else {
                seal.reject(CatError(message: "Parse failed."))
            }
        }
    }
    
    @discardableResult private func display(_ string: String) -> Promise<Void> {
        return Promise<Void> { seal in
            textView.text = string
            seal.fulfill_()
        }
    }
}
