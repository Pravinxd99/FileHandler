//
//  AppDocument+Ext.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 31/07/26.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

extension AppDocument : Transferable {
    static var transferRepresentation : some TransferRepresentation {
        FileRepresentation(exportedContentType: .data) { document in
            SentTransferredFile(document.sandBoxUrl)
        }
    }
    
    
}
