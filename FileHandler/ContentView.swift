//
//  ContentView.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 28/07/26.
//

import SwiftUI


struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.documents) {  document in
                    HStack {
                        VStack {
                            Text(document.docName)
                            Text(document.displaySize)
                        }
                        Spacer()
                        ShareLink(item: document,preview: SharePreview(document.docName))
                    }
                    
                }
                .onDelete { indexSet in
                    Task {
                        for index in indexSet {
                            await viewModel.deleteFile(viewModel.documents[index])
                        }
                    }
                }
            }
            .toolbar(content: {
                trailingNavItem()
            })
            .navigationTitle("Upload Document")
            .fileImporter(isPresented: $viewModel.showFilePicker, allowedContentTypes: DocumentType.allUTTypes(),allowsMultipleSelection: false) { result in
                switch result {
                case .success(let url):
                    Task {
                        await viewModel.importFile(url[0])
                    }
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            
            }
            .overlay {
                if viewModel.isImporting {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: $viewModel.errorState) {
                
                Button("OK") { viewModel.errorMessage = nil
                    viewModel.errorState = false}
                   }
                message: {
                       Text(viewModel.errorMessage ?? "")
                
            }
        }
    }
    @ToolbarContentBuilder
    private func trailingNavItem () -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showFilePicker.toggle()
            }label: {
                Image(systemName: "plus")
            }
        }
    }
}



#Preview {
    ContentView()
}
