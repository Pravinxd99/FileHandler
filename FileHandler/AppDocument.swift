//
//  AppDocument.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 29/07/26.
//

import Foundation
import UniformTypeIdentifiers

struct AppDocument : Identifiable , Hashable , Sendable{
    var id : UUID {
        return uuid
    }
    let uuid : UUID
    let docName : String
    let docSize  : Int64
    let docType : DocumentType
    let utType : UTType
    let sandBoxUrl : URL
    let importedAt : Date
    
    var displaySize : String {
        ByteCountFormatter.string(fromByteCount: docSize, countStyle: .file)
    }
}
