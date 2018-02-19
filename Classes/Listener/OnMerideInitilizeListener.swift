//
//  OnMerideInitilizeListener.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import Foundation
import UIKit
public protocol OnMerideInitilizeListener {
    func onMerideInitilizedSucess(successMessage:String)
    func onMerideInitilizedError(errorMessage:String)
    func noInternetConnection(message:String)
}

