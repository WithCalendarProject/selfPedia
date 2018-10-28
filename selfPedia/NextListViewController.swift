//
//  NextListViewController.swift
//  selfPedia
//
//  Created by 川村周也 on 2018/10/25.
//  Copyright © 2018年 川村周也. All rights reserved.
//

import UIKit
import RealmSwift

class NextListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var realm: Realm!
    
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
    
    @IBOutlet weak var NextListTable: UITableView!
    
    private var animeList: Results<AnimeFolder>!
    private var token: NotificationToken!
    var parentID = "0"
    private var parentPrimaryKey = "0"
    private var state: State = .nomal
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // RealmのAnimeリストを取得し，更新を監視
        realm = try! Realm(configuration: config)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        animeList = realm.objects(AnimeFolder.self)
        //Resultsが更新されたらテーブルをリロードする
        token = animeList.observe { [weak self] _ in
            self?.reload()
        }
    }
    
    deinit {
        token.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NextListTable.delegate = self
        NextListTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toNextItems") {
            // 次のリストのデータをテーブルビューに渡す
            let nextVC = segue.destination as! MyListViewController
            nextVC.parentID = self.parentID
            print("tapped")
        }
    }
    
    func addAlart(){ // 新規Anime追加用のダイアログを表示
        let folder = AnimeFolder()
        let dlg = UIAlertController(title: "新規Anime", message: "", preferredStyle: .alert)
        dlg.addTextField(configurationHandler: nil)
        dlg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = dlg.textFields![0].text,
                !t.isEmpty {
                folder.title = t
                //self.addAnimeFolder(folder: folder)
            }
        }))
        present(dlg, animated: true)
    }
    
    func updateAlart(index: Int, item: String){ // Anime更新用のダイアログを表示
        let dlg = UIAlertController(title: "Anime編集", message: "", preferredStyle: .alert)
        dlg.addTextField(configurationHandler: nil)
        dlg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = dlg.textFields![0].text,
                !t.isEmpty {
                //self.updateAnimeItem(at: index, newValue: t, itemTitle: item)
            }
        }))
        present(dlg, animated: true)
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
     
     //フォルダーの追加
     func addAnimeFolder(folder: AnimeFolder) {
     
     folder.id = NSUUID().uuidString
     folder.parentID = parentID
     
     try! realm.write {
     if parentID == "0" {
     realm.add(folder)
     }else{
     //今現在のルートフォルダを取得し、そのフォルダのfoldersにappendする
     realm.object(ofType: AnimeFolder.self, forPrimaryKey: parentID)?.folders.append(folder.id)
     }
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
    
    func reload() {
        NextListTable?.reloadData()
        print("root: \(parentID)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //フォルダのグループ化などで可変にしたいかも
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if state == .nomal {  //編集モードじゃなかったら
            /*Todo: もし追加用のセルがタップされたら
             if indexPath.row == セルの最後{
             addAlart()
             } */
            // 次のデータリストへ遷移するために Segue を呼び出す
            
            let current = loardFolders(rootKey: parentID)
            print(current[indexPath.row])
            if indexPath.row < (current.count) {
                parentID = current[indexPath.row].id
            }
            //performSegue(withIdentifier: "toNextItems", sender: nil)
        } else if state == .edit{ //編集モードだったら
            if let title = tableView.cellForRow(at: indexPath)?.textLabel?.text {
                updateAlart(index: indexPath.row, item: title)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfFolders = 0
        var numberOfItems = 0
        let Folders = loardFolders(rootKey: parentID)
        numberOfFolders = Folders.count
        
        if let Items = loardItems(rootKey: parentID) {
            numberOfItems = Items.count
        }
        
        if loardFolders(rootKey: parentID) == nil {
            return 0
        }
        
        //ある親階層下の、foldersの要素数 + contentsの要素数
        return numberOfFolders + numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         // 条件によってセルが変わる想定
         if  /* 条件式 */  {
         return getXxxCell() // 上記の　XxxTableViewCell　セル
         
         } else {
         return getYyyCell() // 上記とはまた別のセル
         
         }
         */
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "animeItem", for: indexPath)
        
        let currentItems = loardItems(rootKey: parentID)
        let currentFolder = fetchFolder(folderID: parentID)
        var folders = List<AnimeFolder>()
        if parentID == "0" {
            folders = loardFolders(rootKey: parentID)
        }else{
            folders = getFolders(current: currentFolder!)
        }
        
        print(folders)
        if indexPath.row < (folders.count) {
            cell.textLabel?.text = folders[indexPath.row].title
        }else if (currentItems != nil), indexPath.row < (folders.count) + (currentItems?.count)!{ //ここでエラーが出た。
            cell.textLabel?.text = currentItems![indexPath.row].title
        }
        
        
        if loardFolders(rootKey: parentID) == nil {
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //deleteAnimeItem(at: indexPath.row)
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
