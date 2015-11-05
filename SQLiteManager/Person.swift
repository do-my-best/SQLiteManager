//
//  Person.swift
//  SQLiteManager
//
//  Created by liuzhu on 15/11/5.
//  Copyright © 2015年 liuzhu. All rights reserved.
//

import UIKit

class Person: NSObject {

    //MARK: - 模型属性
    ///代号
    var id = 0
    
    ///姓名
    var name : String?
    
    ///年龄
    var age = 0
    
    ///身高
    var height : Double = 0
    
    ///MARK: - 构造函数
    init(dict:[String:AnyObject]) {
        
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    ///MARK: -  person 对象的描述
    override var description : String{
    
        let keys = ["id", "name", "age", "height"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
    
    ///从数据库中查询数据,保存在 person 数组中
    ///
    ///- returns : 从 sql中读取的数据分条转换成 person 对象并保存
    class func persons() -> [Person]?{
    
        //1.准备 sql
         let sql = "select id,name,age,height from T_Person"
        
        //2.访问数据库,获取字典数组
         let dictArray = SQLiteManager.sharedManager.execRecord(sql)
        
        //3.字典转模型
        //定义person数组,保存字典
        var persons : [Person] = [Person]()
        
        for c in dictArray!{
        
            persons.append(Person(dict: c))
        }
        
        //4.返回结果
        return persons
        
    }
    
    ///用 person 对象更新数据库中的内容
    ///
    ///- returns : 是否成功
    func updatePerson() -> Bool{
    
        //1.准备 sql
        let sql = "update T_Person set name = '\(name)',age = '\(age)',height = '\(height)'"
        
        let row = SQLiteManager.sharedManager.execUpdate(sql)
        
        print("更新了\(row)条内容")
        
        return  row > 0
    }
    
    ///删除数据库中与 person 对象的属性'name'相同的数据
    ///
    ///- returns : 是否成功
    func  deletePerson() -> Bool{
        
        //1.准备 sql
        let sql = "delete from T_Person where name = '\(name)'"
        
        let row = SQLiteManager.sharedManager.execUpdate(sql)
        
        print("删除了\(row)条内容")
        
        return  row > 0
    }
    
    
    ///将当前对象的属性插入到数据库中
    /// 
    ///- returns : 是否成功
    func insertPerson() ->Bool{
    
        
        //1.准备 sql
        let sql = "insert into T_Person (name,age,height) values ('\(name!)',\(age),\(height));"
        
        //2.返回结果
        return SQLiteManager.sharedManager.execInsert(sql) > 0
    }
}
