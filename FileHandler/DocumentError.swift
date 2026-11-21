//
//  DocumentError.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 28/07/26.
//

import Foundation

enum DocumentError : Error , LocalizedError {
    // Access related
    case accessDenied
    case fileNotFound
    case invalidURL
    
    // Type related
    case unsupportedType(String)
    case uttypeUnresolvable
    case mimeTypeMismatch
    
    // Size related
    
    case fileSizeUnreadable
    case fileEmpty
    case fileSizeExceeded(actualSize : Int64 , acceptedFileSize : Int64)
    
    // Input/Output
    
    case insufficientDiskSpace
    case sandBoxCopyFailed
    case partiallyWritten
    case directoryCreationFailed
    
    // Content
    
    case corruptFile
    case passwordProtected
    case encodingUnrecognized
    case iCloudNotDownloaded
    
    // Photos / Transferable
    
    case transferableFailed
    case iCloudDownloadFailed
    
    // MetaData
    
    case metaDataExtractionFailed
    
    // Upload Error
    
    case uploadFailed
    case invalidServerResponse
    
    // Unknown

    case unknownError
     
}
