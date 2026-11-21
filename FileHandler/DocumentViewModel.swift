//
//  DocumentViewModel.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 31/07/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ViewModel: ObservableObject {

    @Published var documents: [AppDocument] = []
    @Published var errorMessage: String? = nil
    @Published var showFilePicker: Bool = false
    @Published var isImporting: Bool = false
    @Published var errorState : Bool = false
    private var documentUploader = DocumentUploader()
    private var documentStore = DocumentStore()
    
    init() {
        Task {
            await documentStore.loadDocuments()
            let docs = await documentStore.documents
            self.documents = docs
        }
    }
    
    func startAutoUpload (_ doc : AppDocument) {
        guard !doc.isUploaded else {return}
        Task.detached(priority: .background) { [weak self] in
            await self?.upload(doc)
        }
        
    }
    func changeDocUploadStatus(_ doc: AppDocument) {
        guard let index = documents.firstIndex(where: { $0.id == doc.id }) else { return }
        documents[index].isUploaded = true
        Task {
            await documentStore.changeDocUploadStatus(doc)
        }
    }
    
    
    
    func upload(_ document : AppDocument) async {
        do {
            try await documentUploader.uploadFile(document)
             self.changeDocUploadStatus(document)
        }
        catch {
            print("error uploading the document")
        }
    }
    
    func importFile (_ url : URL) async {
        isImporting = true
        errorState = false
        errorMessage = nil
        defer {
            isImporting = false
        }
        do {
            if let doc = try await documentStore.importFile(from: url) {
                documents.append(doc)
                startAutoUpload(doc)
                
            }
        }
        catch  let error as DocumentError {
            errorMessage = error.localizedDescription
            errorState = true
        }
        catch {
            errorMessage = error.localizedDescription
            errorState = true
        }
        
      
    }
    
    func deleteFile (_ document : AppDocument) async {
        errorState = false
        errorMessage = nil
        do {
            try await documentStore.deleteDocument(document)
            documents.removeAll(){$0.id == document.id}
        }
        catch let error as DocumentError {
            errorMessage = error.localizedDescription
            errorState = true
        }
        catch {
            errorMessage = error.localizedDescription
            errorState = true
        }
    }
}
