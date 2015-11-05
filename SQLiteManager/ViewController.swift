//
//  ViewController.swift
//  SQLiteManager
//
//  Created by liuzhu on 15/11/5.
//  Copyright © 2015年 liuzhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //插入数据
        demoInsert();
        
        //查询所有数据
        demoSelect();
    }
    
    ///测试查询数据
    func demoSelect(){
    
        print(Person.persons())
    }

    ///测试插入数据
    func demoInsert(){
    
        let p = Person(dict: ["age":18,"name":"zhangsan","height":1.7])
        
        if p.insertPerson() {
            print("插入成功 \(p)")
        } else {
            print("插入失败")
        }
    }
    
    ///测试更新数据
    func demoUpdate(){
    
        let p = Person(dict:["age":19,"name":"lisi","height":1.7])
        
        if p.updatePerson() {
            print("更新成功 \(p)")
        } else {
            print("更新失败")
        }
    }

    ///测试删除数据
    func demoDelete(){
    
        let p = Person(dict:["age":19,"name":"lisi","height":1.7])
        
        if p.deletePerson() {
            print("删除成功 \(p)")
        } else {
            print("删除失败")
        }
    }
}

