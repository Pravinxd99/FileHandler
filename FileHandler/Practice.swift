//
//  Practice.swift
//  FileHandler
//
//  Created by Sambath Kumar A, Praveen on 29/07/26.
//

import Foundation


struct Creation {
    
    private var fileManager = FileManager.default
    
    
    var createRoot : URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(path: "RecipeApp", directoryHint: .isDirectory)
    }
    
    func createDiffItemFolder () throws {
        try fileManager.createDirectory(at: createRoot, withIntermediateDirectories: true)
        for item in Items.allCases {
            let folderName = createRoot.appending(path: item.rawValue.capitalized , directoryHint: .isDirectory)
            try fileManager.createDirectory(at: folderName, withIntermediateDirectories: true)
            
            for subFolders in item.subItems {
                let folderName = folderName.appending(path: subFolders, directoryHint: .isDirectory)
                try fileManager.createDirectory(at: folderName, withIntermediateDirectories: true)
            }
            
        }
        
        
    }
    
    func createFile() throws {
        
    }
}

enum Items : String ,CaseIterable {
    case cuisines
    case favorites
    case shoppingList
    
    
    var subItems : [String] {
        switch self {
        case .cuisines:
            ["Italian","Indian","Mexican"]
        case .favorites:
            []
        case .shoppingList:
            []
        }
    }
}

/*
 RecipeApp/
   ├── Cuisines/
   │     ├── Italian/
   │     │     ├── pasta.txt
   │     │     └── pizza.txt
   │     ├── Indian/
   │     │     ├── biryani.txt
   │     │     └── curry.txt
   │     └── Mexican/
   │           └── tacos.txt
   ├── Favourites/
   │     └── favourites.txt
   └── ShoppingList/
         └── ingredients.txt
 */
