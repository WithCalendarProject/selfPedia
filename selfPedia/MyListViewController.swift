//
//  MyListViewController.swift
//  selfPedia
//
//  Created by 川村周也 on 2018/09/18.
//  Copyright © 2018年 川村周也. All rights reserved.
//

import UIKit
import RealmSwift

class MyListViewController: UIViewController {
    
    private var realm: Realm!
    private var animeList: Results<AnimeItem>!
    private var token: NotificationToken!
    @IBOutlet weak var myListTable: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // RealmのTodoリストを取得し，更新を監視
        realm = try! Realm()
        animeList = realm.objects(AnimeItem.self)
        token = animeList.observe { [weak self] _ in
            self?.reload()
        }
    }
    
    deinit {
        token.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTapped(_ sender: Any) {
        // 新規Todo追加用のダイアログを表示
        let dlg = UIAlertController(title: "新規Anime", message: "", preferredStyle: .alert)
        dlg.addTextField(configurationHandler: nil)
        dlg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = dlg.textFields![0].text,
                !t.isEmpty {
                self.addAnimeItem(title: t)
            }
        }))
        present(dlg, animated: true)
    }
    
    
    //アイテムの追加
    func addAnimeItem(title: String) {
        try! realm.write {
            realm.add(AnimeItem(value: ["title": title]))
        }
    }
    
    //アイテムの更新
    func updateAnimeItem(at index: Int, newValue: String){
        let resutls = realm.objects(AnimeItem.self)
        let updateItem = resutls[index]
        try! realm.write {
            updateItem.title = newValue
        }
    }
    
    //アイテムの削除
    func deleteAnimeItem(at index: Int) {
        try! realm.write {
            realm.delete(animeList[index])
        }
    }
    
    func reload() {
        myListTable?.reloadData()
    }
    
}

extension MyListViewController: UITableViewDelegate {
}

extension MyListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "animeItem", for: indexPath)
        cell.textLabel?.text = animeList[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dlg = UIAlertController(title: "Anime編集", message: "", preferredStyle: .alert)
        dlg.addTextField(configurationHandler: nil)
        dlg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = dlg.textFields![0].text,
                !t.isEmpty {
                self.updateAnimeItem(at: indexPath.row, newValue: t)
            }
        }))
        present(dlg, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        deleteAnimeItem(at: indexPath.row)
    }
}


