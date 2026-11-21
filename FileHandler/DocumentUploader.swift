//
//  DocumentUploader.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 04/08/26.
//

import Foundation
import UniformTypeIdentifiers
struct DocumentUploader {
    private let uploadURL = URL(string: "http://192.168.1.2:8080/upload")!

    
    func uploadFile (_ document : AppDocument) async throws {
        let boundary = UUID().uuidString
        var requestUrl = URLRequest(url: uploadURL)
        requestUrl.httpMethod = "POST"
        requestUrl.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        requestUrl.httpBody = try buildBody(document, boundary)
        
         let (data , response) = try await URLSession.shared.data(for: requestUrl)
        guard let response = response as? HTTPURLResponse , response.statusCode >= 200 && response.statusCode <= 299 else {throw DocumentError.invalidServerResponse}
        
        print("Upload success: \(String(data: data, encoding: .utf8) ?? "")")
        
    }

    
    func buildBody (_ document : AppDocument , _ boundary : String) throws -> Data {
        
        var body = Data()
        let fileName = document.docName
        let fileData = try Data(contentsOf: document.sandBoxUrl)
        let mimeType = document.utType.preferredMIMEType ?? "application/octet-stream"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition:form-data;name=\"file\";filename=\"\(fileName)\"\r\n")
        body.append("Content-Type:\(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n")
        return body
    }
}

private extension Data {
    mutating func append (_ string : String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


