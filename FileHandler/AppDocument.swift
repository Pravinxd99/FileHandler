//
//  AppDocument.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 29/07/26.
//

import Foundation
import UniformTypeIdentifiers

struct AppDocument : Identifiable , Hashable , Sendable , Codable{
    var id : UUID {
        return uuid
    }
    let uuid : UUID
    let docName : String
    let docSize  : Int64
    let docType : DocumentType
    let sandBoxUrl : URL
    let importedAt : Date
    var isUploaded : Bool
    private var utTypeIdentifier : String
    var utType : UTType {UTType(utTypeIdentifier) ?? .data}
    var displaySize : String {
        ByteCountFormatter.string(fromByteCount: docSize, countStyle: .file)
    }
    
    init(uuid: UUID, docName: String, docSize: Int64, docType: DocumentType, sandBoxUrl: URL, importedAt: Date, utType : UTType , isUploaded : Bool = false) {
        self.uuid = uuid
        self.docName = docName
        self.docSize = docSize
        self.docType = docType
        self.sandBoxUrl = sandBoxUrl
        self.importedAt = importedAt
        self.utTypeIdentifier = utType.identifier
        self.isUploaded = isUploaded
    }
}
