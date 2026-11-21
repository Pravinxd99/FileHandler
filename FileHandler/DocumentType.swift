//
//  DcoumentType.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 28/07/26.
//

import Foundation
import UniformTypeIdentifiers
enum DocumentType : String , Codable , CaseIterable {
    
    case image
    case video
    case pdf
    case audio
    case plainText
    
    
    var documentUTType : [UTType] {
        switch self {
        case .image:
            [.image , .jpeg , .png , .gif,.tiff,.bmp , .heic ]
        case .video:
            [.video , .movie , .mpeg4Movie , .avi , .quickTimeMovie]
        case .pdf:
            [.pdf ]
        case .audio:
            [.audio , .mp3 ,.mpeg4Audio, .aiff, .wav]
        case .plainText:
            [.text , .plainText , .json , .xml , .html  ]
        }
    }
    
    var sizeLimit : Int64  { // FileManager.attributesOfItem[.size] returns the value as Int64 internally and apple uses it internally since it has a large number of bits
        switch self {
        case .image:
            return 7 * 1_000_000
        case .video:
            return  15 * 1_000_000
        case .pdf:
            return 5 * 1_000_000
        case .audio:
            return 10 * 1_000_000
        case .plainText:
            return 2 * 1_000_000
        }
    }
    
    
    static func allUTTypes () -> [UTType] {
        allCases.flatMap{$0.documentUTType}
    }
    
    static func resolve (url : URL) -> (_type : DocumentType , utType : UTType)? {
        guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey
                                                                    ]) , let detected = resourceValues.contentType
        else {
            return nil
        }
        guard let matched = allCases.first(where : { docType in
            docType.documentUTType.contains{detected.conforms(to: $0)}})
        
        else {
            return nil
        }
        
        return (matched , detected)
    }
}
