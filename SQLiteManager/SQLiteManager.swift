//
//  File.swift
//  SQLiteManager
//
//  Created by liuzhu on 15/11/5.
//  Copyright © 2015年 liuzhu. All rights reserved.
//

import Foundation

class SQLiteManager {
    
    ///单例的管理类
    static let sharedManager = SQLiteManager()
    
    ///全局的数据库访问句柄
    private var db : COpaquePointer = nil
    
    ///构造方法,初始化数据库信息,在创建单例对象的时候使用
    private init(){
    
        //打开数据库
        openDB("status.db")
    }
    
//    #define SQLITE_INTEGER  1
//    #define SQLITE_FLOAT    2
//    #define SQLITE_BLOB     4
//    #define SQLITE_NULL     5
//    #ifdef SQLITE_TEXT
//    # undef SQLITE_TEXT
//    #else
//    # define SQLITE_TEXT     3
//    #endif
//    #define SQLITE3_TEXT     3
    
    /// 执行 SQL 返回结果集合
    ///
    /// - parameter sql: sql
    func execRecord(sql:String) -> [[String:AnyObject]]? {
    
        //保存查询的结果集
        var stmt:COpaquePointer = nil
        
        //获取结果集
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
        
            print("sql 语句错误")
            return nil
        }

        //保存结果的数组
        var selectedResult : [[String:AnyObject]] = [[String:AnyObject]]()
        
        //遍历每一条查询结果
        while sqlite3_step(stmt) == SQLITE_ROW{
        
            //保存每条查询结果的字段名和字段内容到字典
             let dict = recordForEachField(stmt)
            
            //保存每条内容字典
            selectedResult.append(dict)
        }
        //释放语句句柄
        sqlite3_finalize(stmt)
    
        return selectedResult
        
    }
    
    //保存从数据库读取的一条结果的字段名和字段内容
    func recordForEachField(stmt:COpaquePointer) -> [String:AnyObject]{
    
        //定义一个字典,保存字段名和内容
        var dict : [String:AnyObject] = [String:AnyObject]();
        
        //要查询的字段数
        let colCount = sqlite3_column_count(stmt)
        
        //遍历每一个字段
        for col in 0..<colCount{
            
            //每个字段的名称,作为字典的 key
            let cName = sqlite3_column_name(stmt, col)
            let name = String(CString: cName, encoding: NSUTF8StringEncoding)
            
            //每个字段的数据类型,用于根据类型获取字段的内容
            let type = sqlite3_column_type(stmt, col)
            
            //定义一个 value 保存每个字段的值
            var value : AnyObject?
            
            //根据不同的 type 设置字段的内容
            switch type{
                
            case SQLITE_INTEGER:
                value = Int(sqlite3_column_int64(stmt,col))
                
            case SQLITE_FLOAT:
                value = sqlite3_column_double(stmt,col)
                
            case SQLITE_NULL:
                value = NSNull()
                
            case SQLITE3_TEXT:
                let cText = UnsafePointer<Int8>(sqlite3_column_text(stmt, col))
                value = String(CString: cText, encoding: NSUTF8StringEncoding)
                
            default:
                print("不支持的数据类型")
            }
            
            //保存 value 值
            dict[name!] = value ?? NSNull()
        }
        
        return dict
    }
    
    /// 执行 更新 / 删除 SQL
    ///
    /// - parameter sql: sql
    ///
    /// - returns: 返回 更新 / 删除 的数据行数
    func execUpdate(sql:String) -> Int {
        
        if !execSQL(sql){
            
            return -1
        }
        
        return Int(sqlite3_changes(db));
    }
    
    /// 执行插入 SQL
    ///
    /// - parameter sql: sql
    ///
    /// - returns: 返回自动增长 id
    func execInsert(sql:String)->Int{
    
        if !execSQL(sql) {
            
            return -1
        }
        
        //返回自动增长的 id
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    ///打开数据库的操作
    ///
    /// - parameter dbName: SQL
    ///
    /// - returns: 是否成功
    func openDB(dbName:String){
    
        //document 路径
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!;
        
        //拼接数据库文件路径
        let filePath = (path as NSString).stringByAppendingPathComponent(dbName)
        
        //打开或创建数据库
        if  sqlite3_open(filePath, &db) != SQLITE_OK{
        
            print("打开数据库失败")
            return
        }
        
        print("打开数据库成功")
        
        //打开数据表
        if !createTable() {
            print("创建数据表失败")
            return
        }
        
        print("打开数据表成功")

    }
    
    /// 执行 SQL
    ///
    /// - parameter sql: SQL
    ///
    /// - returns: 是否成功 
    func execSQL(sql:String) -> Bool{
    
        return sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK
    }
    
    /// 创建数据表,默认创建T_Person表
    ///
    /// - returns: 是否成功
    func createTable () -> Bool{
    
        //获取路径
        let filePath = NSBundle.mainBundle().pathForResource("db.sql", ofType: nil)
        
        //获取 sql 语句
        guard let sql = try? NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding) else{
        
            print("数据加载失败")
            return false
        }
        
        //执行 sql 语句
        return execSQL(sql as String)
    }
}