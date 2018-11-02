//
//  DataManager.swift
//  selfPedia
//
//  Created by 川村周也 on 2018/11/01.
//  Copyright © 2018 川村周也. All rights reserved.
//

import UIKit
import RealmSwift

class DataManager: NSObject {
    
    var realm: Realm!
    var hierarchy = ["0"]
    
    //Realmのマイグレーション処理
    let config = Realm.Configuration(
        schemaVersion : 2 , //データの構造が変わったらここを変える
        migrationBlock : { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                var nextID = 0
                migration.enumerateObjects(ofType: AnimeItem.className()) { oldObject, newObject in
                    newObject!["id"] = String(nextID)
                    nextID += 1
                }
                migration.enumerateObjects(ofType: AnimeFolder.className()) { oldObject, newObject in
                    newObject!["id"] = String(nextID)
                    nextID += 1
                }
            }
    }
    )
    
    override init() {
        realm = try! Realm(configuration: config)
    }
    
    func addAnimeFolder(parent:String, folder: AnimeFolder) {
        
        let parentID = parent
        
        folder.id = NSUUID().uuidString
        folder.parentID = parentID
        
        try! realm.write {
            realm.add(folder)
            if parentID == "0" {
                
            }else{
                //今現在のルートフォルダを取得し、そのフォルダのfoldersにappendする
                realm.object(ofType: AnimeFolder.self, forPrimaryKey: parentID)?.folders.append(folder.id)
            }
        }
    }
    
    /*
     //アイテムの追加
     func addAnimeItem(item: AnimeItem) {
     
     item.id = NSUUID().uuidString
     
     try! realm.write {
     realm.add(item)
     //今現在のルートフォルダを取得し、そのフォルダのcontentsにappendする
     realm.object(ofType: AnimeFolder.self, forPrimaryKey: parentID)?.contents.append(item)
     }
     }
     
     //アイテムの更新
     func updateAnimeItem(at index: Int, newValue: String, itemTitle: String){
     let resutls = realm.objects(AnimeFolder.self).filter("title == itemTitle")
     let updateItem = resutls[index]
     try! realm.write {
     updateItem.title = newValue
     }
     }
     
     //アイテムの削除
     func deleteAnimeItem(at index: Int) {
     try! realm.write {
     realm.delete(animeList[index])
     realm.object(ofType: AnimeFolder.self, forPrimaryKey: parentID)?.folders.remove(at: index)
     }
     }
     */
    
    func fetchFolder(folderID: String) -> AnimeFolder?{
        // プライマリキーを指定してオブジェクトを取得
        if let data = realm.object(ofType: AnimeFolder.self, forPrimaryKey: folderID){
            print("id:\(folderID)\n data: \(data)")
            return data
        }
        return nil
    }
    
    // 現在のフォルダの階層下フォルダをリストとして返す
    func getFolders(current: AnimeFolder) -> List<AnimeFolder>{
        let resultFolders = List<AnimeFolder>()
        for i in current.folders{
            resultFolders.append(fetchFolder(folderID: i)!)
        }
        return resultFolders
    }
    
    func fetchItems(itemID: String) -> AnimeItem?{
        // プライマリキーを指定してオブジェクトを取得
        if let data = realm.object(ofType: AnimeItem.self, forPrimaryKey: itemID){
            print("id:\(itemID)\n data: \(data)")
            return data
        }
        return nil
    }
    
    func loardFolders(rootKey: String) -> List<AnimeFolder> {
        let resultFolders = List<AnimeFolder>()
        let resuliList = realm.objects(AnimeFolder.self).filter("parentID == %@", rootKey)
        for i in resuliList{
            resultFolders.append(i)
        }
        //print(resuliList.count)
        return resultFolders
    }
    
    func loardItems(rootKey: String) -> List<AnimeItem>? {
        let items = realm.object(ofType: AnimeFolder.self, forPrimaryKey: rootKey)
        return items?.contents
    }
    
}
