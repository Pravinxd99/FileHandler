//
//  DocumentValidator.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 29/07/26.
//

import Foundation
import UniformTypeIdentifiers

struct DocumentValidator  {
    
   
    
    func validate (_ url : URL) throws -> (type : UTType , doc : DocumentType , size : Int64) {
        guard let (docType , utType) = DocumentType.resolve(url: url) else {
            throw DocumentError.unsupportedType(url.pathExtension)
        }

        let size = try readFileSize(from: url)
        guard size > 0 else {
            throw DocumentError.fileEmpty
        }
       
        guard size <= docType.sizeLimit else {
            throw DocumentError.fileSizeExceeded(actualSize: size, acceptedFileSize: docType.sizeLimit)
        }

        return (utType, docType, size)
    }
    
    func readFileSize (from url : URL) throws -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            
            guard let size = attributes[.size] as? Int64 else {
                throw DocumentError.fileSizeUnreadable
            }
            return size
        }catch {
            throw DocumentError.fileSizeUnreadable
        }
        
    }
}
