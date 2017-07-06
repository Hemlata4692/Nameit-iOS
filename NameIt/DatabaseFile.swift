//
//  DatabaseFile.swift
//  CustomPhotoLibrary
//
//  Created by Ranosys on 29/06/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import Foundation


class DatabaseFile: NSObject {

    let databaseName:String="NameItDatabase.sqlite"
    var photoAlbumDb:OpaquePointer? = nil
  
// MARK: - Check Database existence
     private func getDBPath() -> NSString {
        
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuementDir:NSString = paths.object(at: 0) as! NSString
        return docuementDir.appendingPathComponent(databaseName) as NSString
    }

    func checkDataBaseExistence() {
        
        let success:Bool = FileManager.default.fileExists(atPath: getDBPath() as String)
        if !success {
            
            let defaultDBPath = Bundle.main.resourcePath! + "/" + databaseName
            do {
                try FileManager.default.copyItem(atPath: defaultDBPath, toPath: getDBPath() as String
                )
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
        }
    }
    
// MARK: - Create table in exist database
    func createTable(query:NSString) {

        // 1
        let cSql = query.cString(using: String.Encoding.utf8.rawValue)
        var createTableStatement: OpaquePointer? = nil
        // 2
        if sqlite3_open(getDBPath().utf8String, &photoAlbumDb) == SQLITE_OK {
            
            if sqlite3_prepare_v2(photoAlbumDb, cSql, -1, &createTableStatement, nil) == SQLITE_OK {
                // 3
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
//                    print("Contact table created.")
                } else {
//                    print("Contact table could not be created.")
                }
            } else {
//                print("CREATE TABLE statement could not be prepared.")
            }
            // 4
            sqlite3_finalize(createTableStatement)
            sqlite3_close(photoAlbumDb);
        }
    }
    
// MARK: - Insert data into database
    func insertIntoDatabase(query:NSString, tempArray:NSMutableArray) {
        
        var dataRows:OpaquePointer? = nil
        let cSql = query.cString(using: String.Encoding.utf8.rawValue)
        if sqlite3_open(getDBPath().utf8String, &photoAlbumDb) == SQLITE_OK {
            
            if sqlite3_prepare_v2(photoAlbumDb, cSql, -1, &dataRows, nil) != SQLITE_OK {
            
//                 print("error while preparing \(sqlite3_errmsg(photoAlbumDb))")
            }
        
            for x in 0 ..< tempArray.count {
                
                let anyArrayobj : AnyObject? = tempArray.object(at: x) as AnyObject
                if anyArrayobj == nil
                {
                    tempArray.replaceObject(at: x, with: "N.A")
                }
                
                if (anyArrayobj?.isKind(of: NSNumber.classForCoder()))! {
                    
                    if x==3 || x==4  {
                        sqlite3_bind_double(dataRows, Int32(x+1), (anyArrayobj?.doubleValue)!)
                    }
                    else {
                        sqlite3_bind_int(dataRows, Int32(x+1), (anyArrayobj?.int32Value)!)
                    }
                }
                else {
                    sqlite3_bind_text(dataRows, Int32(x+1), anyArrayobj?.utf8String, -1, nil)
                }
                
            }
            if SQLITE_DONE != sqlite3_step(dataRows) {
                
//                if let errorMessage: String? = String(cString: sqlite3_errmsg(photoAlbumDb)!) {
//                    
//                }
                
//                let errmsg:String? = String(cString: sqlite3_errmsg(photoAlbumDb))
//                if errmsg != nil {
//                    sqlite3_free(errmsg)
//                }
                 sqlite3_finalize(dataRows)
            }
            sqlite3_close(photoAlbumDb);
        }
        else {
        
            sqlite3_close(photoAlbumDb);
            photoAlbumDb=nil;
        }
    }
    
// MARK: - Update data into database
    func update(updateStatementString:NSString) {
        
        var updateStatement: OpaquePointer? = nil
        let cSql = updateStatementString.cString(using: String.Encoding.utf8.rawValue)
        if sqlite3_open(getDBPath().utf8String, &photoAlbumDb) == SQLITE_OK {
            if sqlite3_prepare_v2(photoAlbumDb, cSql, -1, &updateStatement, nil) == SQLITE_OK {
                if sqlite3_step(updateStatement) == SQLITE_DONE {
//                    print("Successfully updated row.")
                } else {
//                    print("Could not update row.")
                }
            } else {
//                print("UPDATE statement could not be prepared")
            }
            sqlite3_finalize(updateStatement)
            sqlite3_close(photoAlbumDb);
        }
    }

// MARK: - Check via query data is already exist
    func isExistDataQuery(query:NSString) -> Bool {
        
        let cSql = query.cString(using: String.Encoding.utf8.rawValue)
        var queryStatement: OpaquePointer? = nil
        
        var flag:Int32=0
        // 1
        if sqlite3_open(getDBPath().utf8String, &photoAlbumDb) == SQLITE_OK {
            if sqlite3_prepare_v2(photoAlbumDb, cSql, -1, &queryStatement, nil) == SQLITE_OK {
                
                // 2
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    flag=1
                }
                
            } else {
//                print("SELECT statement could not be prepared")
            }
            // 6
            sqlite3_finalize(queryStatement)
            sqlite3_close(photoAlbumDb);
            if flag==0 {
                return false
            }
            else {
                return true
            }
        }
        else {
        
            return false
        }
    }

// MARK: - Fetch data with where clause
    func selectQuery(query:NSString) -> NSMutableArray {
        
        var queryData: NSMutableArray = []
        let cSql = query.cString(using: String.Encoding.utf8.rawValue)
        var queryStatement: OpaquePointer? = nil

        // 1
        if sqlite3_open(getDBPath().utf8String, &photoAlbumDb) == SQLITE_OK {
            if sqlite3_prepare_v2(photoAlbumDb, cSql, -1, &queryStatement, nil) == SQLITE_OK {
                
                // 2
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    
//                    let id = sqlite3_column_int(queryStatement, 0)
//                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
//                    let name = String(cString: queryResultCol1!)
//                    print("Query Result:")
//                    print("\(id) | \(name)")
                    let myDictOfDict:NSDictionary = [
                        "PhotoActualName" : String(cString: sqlite3_column_text(queryStatement, 0)!)
                        , "PhotoRename" : String(cString: sqlite3_column_text(queryStatement, 1)!)]
                    queryData.add(myDictOfDict)
                }
                
            } else {
//                print("SELECT statement could not be prepared")
            }
            // 6
            sqlite3_finalize(queryStatement)
            sqlite3_close(photoAlbumDb);
            return queryData
        }
        else {
            return queryData
        }
    }
    
// MARK: - Delete data from selected table
    func delete(deleteStatementStirng:NSString) -> Bool {
        
        let cSql = deleteStatementStirng.cString(using: String.Encoding.utf8.rawValue)
        var flag:Int32=0
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_open(getDBPath().utf8String, &photoAlbumDb) == SQLITE_OK {
            if sqlite3_prepare_v2(photoAlbumDb, cSql, -1, &deleteStatement, nil) == SQLITE_OK {
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                    print("Successfully deleted row.")
                     flag=1
                } else {
//                    print("Could not delete row.")
                }
            } else {
//                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(deleteStatement)
            sqlite3_close(photoAlbumDb);
        }
        if flag==0 {
            return false
        }
        else {
            return true
        }
    }
}
