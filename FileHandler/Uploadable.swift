//
//  Uploadable.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 05/08/26.
//

import Foundation


protocol Uploadable : AnyObject {
    func upload(_ document : AppDocument) async
    func startAutoUpload(_ document : AppDocument) async 
    
    
}
