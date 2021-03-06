//
//  ThirdListViewController.swift
//  selfPedia
//
//  Created by 前田陸 on 2018/11/06.
//  Copyright © 2018年 川村周也. All rights reserved.
//

import UIKit
import RealmSwift

class ThirdListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var realm: Realm!
    
    var dataManager = DataManager()
    
    @IBOutlet weak var ThirdListTable: UITableView!
    
    private var animeList: Results<AnimeFolder>!
    private var token: NotificationToken!
    var parentID = "0"
    private var state: State = .nomal
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // RealmのAnimeリストを取得し，更新を監視
        dataManager.realm = try! Realm(configuration: dataManager.config)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        animeList = dataManager.realm.objects(AnimeFolder.self)
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
        ThirdListTable.delegate = self
        ThirdListTable.dataSource = self
        // Do any additional setup after loading the view.
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        print(dataManager.hierarchy)
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if (segue.identifier == "toMyItems") {
            // 次のリストのデータをテーブルビューに渡す
            let myVC = segue.destination as! MyListViewController
            dataManager.hierarchy.append(self.parentID)
            myVC.parentID = self.parentID
            myVC.dataManager = self.dataManager
            print("tapped")
        }else*/
        if segue.identifier == "toAddFromThird" {
            let addVC = segue.destination as! AddViewController
            addVC.dataManager = self.dataManager
            if parentID != "0"{
                addVC.currentID = parentID
            }
        }
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
    
    func reload() {
        ThirdListTable?.reloadData()
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
            
            let current = dataManager.loardFolders(rootKey: parentID)
            if indexPath.row < (current.count) {
                parentID = current[indexPath.row].id
            }
            //performSegue(withIdentifier: "toMyItems", sender: nil)
        } else if state == .edit{ //編集モードだったら
            if let title = tableView.cellForRow(at: indexPath)?.textLabel?.text {
                updateAlart(index: indexPath.row, item: title)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfFolders = 0
        var numberOfItems = 0
        let Folders = dataManager.loardFolders(rootKey: parentID)
        numberOfFolders = Folders.count
        
        if let Items = dataManager.loardItems(rootKey: parentID) {
            numberOfItems = Items.count
        }
        
        if dataManager.loardFolders(rootKey: parentID) == nil {
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
        
        let currentItems = dataManager.loardItems(rootKey: parentID)
        let currentFolder = dataManager.fetchFolder(folderID: parentID)
        var folders = List<AnimeFolder>()
        if parentID == "0" {
            folders = dataManager.loardFolders(rootKey: parentID)
        }else{
            folders = dataManager.getFolders(current: currentFolder!)
        }
        
        if indexPath.row < (folders.count) {
            cell.textLabel?.text = folders[indexPath.row].title
        }else if (currentItems != nil), indexPath.row < (folders.count) + (currentItems?.count)!{ //ここでエラーが出た。
            cell.textLabel?.text = currentItems![indexPath.row].title
        }
        
        
        if dataManager.loardFolders(rootKey: parentID) == nil {
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

}

extension ThirdListViewController: UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? MyListViewController{
            dataManager.hierarchy.removeLast()
            vc.parentID = dataManager.hierarchy.last!
            print(dataManager.hierarchy.last!)
            vc.dataManager = self.dataManager
        }
    }
    
}
