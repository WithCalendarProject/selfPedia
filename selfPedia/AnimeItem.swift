//
//  AnimeItem.swift
//  selfPedia
//
//  Created by 川村周也 on 2018/09/24.
//  Copyright © 2018年 川村周也. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class AnimeItem: Object {
    //AnimeTitle
    @objc dynamic var title = ""
    //ジャンル
    @objc dynamic var genre = ""
    //primary key
    @objc dynamic var id = ""
    //Number of stories(話数)
    @objc dynamic var stories = 0
    //evaluation(評価) -> range: 0~100 %
    @objc dynamic var evaluation = 0
    //Broadcast start date(放送開始日)
    @objc dynamic var startDay = Date()
    //when user added(ユーザーが追加した日)
    @objc dynamic var addDay = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class AnimeFolder: Object {
    @objc dynamic var title = ""
    @objc dynamic var id = ""
    @objc dynamic var parentID = ""
    var contents = List<AnimeItem>()
    var folders = List<String>() //[key: id, value: title]
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
