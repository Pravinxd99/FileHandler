//
//  DocumentStore.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 29/07/26.
//

import Foundation

actor DocumentStore  {
    
   private(set) var documents : [AppDocument] = []
    private let fileManager = FileManager.default
    private let validator = DocumentValidator()
    
    var persistenceUrl : URL {
        return sandBoxRoot.appending(path: "Documents.json")
    }
    init(){
        print("Directory URL : \(sandBoxRoot.path)")
    }
    
    private var sandBoxRoot : URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(component: "ImportedDocs", directoryHint: .isDirectory)
    }
    
    func importFile (from url : URL) async throws -> AppDocument?{
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }
        guard accessed else {
            throw DocumentError.accessDenied
        }
        guard fileManager.fileExists(atPath: url.path) else {
            throw DocumentError.fileNotFound
        }
        
        let (utType , docType , size ) = try await validator.validate(url)
        try checkDiskSpace(fileSize: size)
        let sandBoxURL = try copyToSandBox(from: url, type: docType)
        
        let document = await AppDocument(uuid: UUID(), docName: url.lastPathComponent, docSize: size, docType: docType, sandBoxUrl: sandBoxURL, importedAt: Date(), utType: utType)
        
        documents.append(document)
        await saveDocuments()
        return document
        
      
    }
    
    func deleteDocument(_ document : AppDocument) async throws {
        try fileManager.removeItem(at: document.sandBoxUrl)
        documents.removeAll(){$0.id == document.id}
        await saveDocuments()
        
    }
        
         func checkDiskSpace (fileSize : Int64) throws {
             let directoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
             guard let freeSpace = try? fileManager.attributesOfFileSystem(forPath: directoryPath)[.systemFreeSize] as? Int64 else {
                 return
             }
             if fileSize > freeSpace {
                 throw DocumentError.insufficientDiskSpace
             }
        }
    
    func saveDocuments () async {
        do {
            try fileManager.createDirectory(atPath: sandBoxRoot.path, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(documents)
            try data.write(to: persistenceUrl)
        }
        catch {
            print("Failed to save documents")
        }
    }
    func changeDocUploadStatus (_ doc : AppDocument) {
        guard let index = documents.firstIndex(where: { document in
            document.id == doc.id
        }) else {return}
        
        documents[index].isUploaded = true
        Task {
            await saveDocuments()
        }
        
    }
    
    func loadDocuments () async  {
        guard fileManager.fileExists(atPath: persistenceUrl.path) else {return}
        do {
            let data = try Data(contentsOf: persistenceUrl)
             documents = try JSONDecoder().decode([AppDocument].self, from: data)
        }
        catch {
            print("Load Failed")
        }
       
    }
    
    func copyToSandBox (from url : URL , type docType : DocumentType) throws -> URL {
       
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
    

