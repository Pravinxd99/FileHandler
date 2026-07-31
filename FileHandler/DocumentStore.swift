//
//  DocumentStore.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 29/07/26.
//

import Foundation

actor DocumentStore {
   private(set) var documents : [AppDocument] = []
    private let fileManager = FileManager.default
    private let validator = DocumentValidator()
    
    private var sandBoxRoot : URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(component: "ImportedDocs", directoryHint: .isDirectory)
    }
    
    func importFile (from url : URL) async throws -> AppDocument?{
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        guard accessed else {
            throw DocumentError.accessDenied
        }
        guard fileManager.fileExists(atPath: url.path()) else {
            throw DocumentError.fileNotFound
        }
        
        let (utType , docType , size ) = try validator.validate(url)
        let sandBoxURL = try copyToSandBox(from: url, from: docType)
        
        let document = AppDocument(uuid: UUID(), docName: url.lastPathComponent, docSize: size, docType: docType, utType: utType, sandBoxUrl: sandBoxURL, importedAt: Date())
        
        documents.append(document)
        return document
        
      
    }
        
         func checkDiskSpace (fileSize : Int64) throws {
             guard let freeSpace = try fileManager.attributesOfFileSystem(forPath: sandBoxRoot.path())[.systemFreeSize] as? Int64 else {
                 return
             }
             if fileSize > freeSpace {
                 throw DocumentError.insufficientDiskSpace
             }
        }
    
    func copyToSandBox (from url : URL , from docType : DocumentType) throws -> URL {
       
            var typeFolderName : String {
                switch docType {
                case .image:
                    return "Images"
                case .video:
                    return "Videos"
                case .pdf:
                    return "PDF"
                case .audio:
                    return "Audios"
                case .plainText:
                    return "Text"
                }
            }
            
            let typeFolder = sandBoxRoot.appending(path: typeFolderName, directoryHint: .isDirectory)
        do {
            try fileManager.createDirectory(at: typeFolder, withIntermediateDirectories: true)
            
            let uniqueFileName = UUID().uuidString+"-"+url.lastPathComponent
            let destination = typeFolder.appending(path:uniqueFileName)
            try fileManager.copyItem(at: url, to: destination)
            return destination
        }
        catch  let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileWriteOutOfSpaceError {
                throw DocumentError.insufficientDiskSpace
            }
            throw DocumentError.sandBoxCopyFailed
        }
    }
    }
    

