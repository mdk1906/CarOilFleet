//
//  MyCommissionViewController.swift
//  CarOilFleetService
//
//  Created by mdk mdk on 2017/10/17.
//  Copyright © 2017年 mdk mdk. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class MyCommissionViewController: MDKBaseListViewController{
    var btnStr :String?
    var data = [MyCommissionModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleX?.text = "我的提成"
        self.createUI()
        self.createHeadBtn()
        self.getData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createHeadBtn()  {
        let backView:UIView = UIView()
        backView.backgroundColor = UIColor.white
        backView.frame = CGRect(x:0,y:64,width:WindowWidth,height:50)
        self.view.addSubview(backView)
        let titleArr = ["待审核","已提成"]
        for index in 0..<(titleArr.count) {
            let w = WindowWidth/2
            let btn:UIButton = UIButton()
            backView.addSubview(btn)
            btn.frame = CGRect(x:CGFloat(index)*w,y:4,width:w,height:50)
            btn.tag = index + 1000
            btn.backgroundColor = UIColor.white
            btn.setTitle(titleArr[index], for: .normal)
            btn.setTitleColor(kRGBColorFromHex(rgbValue: 0x333333), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
            let hui = UIView.init()
            hui.backgroundColor = homeColor()
            hui.frame = CGRect(x:CGFloat(index)*w+(w-92)/2,y:49,width:92,height:1)
            hui.tag = index + 2000
            backView.addSubview(hui)
            hui.isHidden = true
            if index == 0 {
                btnStr = "1"
                btn.setTitleColor(homeColor(), for: .normal)
                hui.isHidden = false
            }
        }
        let hui :UIView = UIView.init()
        hui.backgroundColor = huiColor()
        backView.addSubview(hui)
        hui.snp.makeConstraints { (make)->Void in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(50)
            make.height.equalTo(1)
        }
    }
    func createUI()  {
        cellID = "MyCommissionTableViewCell"
        tableView?.frame = CGRect(x:0,y:64+50,width:WindowWidth,height:WindowHeight-64-50)
        let nib = UINib(nibName: String(describing: MyCommissionTableViewCell.self), bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: cellID)
    }
    //MARK: - tableView代理
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    //每一块有多少行
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    //绘制cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MyCommissionTableViewCell
        cell.selectionStyle = .none
        cell.MyCommissionModel = data[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    func btnClick(btn:UIButton)  {
        if btn.tag == 1000{
            //待审核
            btnStr = "1"
            btn.setTitleColor(homeColor(), for: .normal)
            
            let btn2 :UIButton = self.view.viewWithTag(1001) as! UIButton
            
            btn2.setTitleColor(UIColor.black, for: .normal)
            let hui1 :UIView = self.view.viewWithTag(2000)!
            hui1.isHidden = false
            let hui2 :UIView = self.view.viewWithTag(2001)!
            hui2.isHidden = true
            
            
            self.getData()
        }
        else if btn.tag == 1001{
            //已审核
            btnStr = "3"
            
            btn.setTitleColor(homeColor(), for: .normal)
            
            let btn2 :UIButton = self.view.viewWithTag(1000) as! UIButton
            
            btn2.setTitleColor(UIColor.black, for: .normal)
            let hui1 :UIView = self.view.viewWithTag(2000)!
            hui1.isHidden = true
            let hui2 :UIView = self.view.viewWithTag(2001)!
            hui2.isHidden = false
            self.getData()
        }
    }
    func getData()  {
        data = [MyCommissionModel]()
        let url = BASE_URL + k_accountHistory
        let params:Dictionary = ["custId":custId,"status":btnStr]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append((value?.data(using: String.Encoding.utf8)!)!, withName: key)
            }
        }, to:url,headers :["devType":"1","token":token])
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                })
                upload.responseJSON { response in
                    if let value:NSDictionary = response.result.value as! NSDictionary? {
                        let dict = JSON(value)
                        if dict["ret"].intValue == 1 {
                            loadSuccess()
                            //成功
                            print("JSON: \(value)")
                            if let items = dict["data"].arrayObject {
                                for item in items {
                                    let post = MyCommissionModel(dict: item as! [String: AnyObject])
                                    self.data.append(post)
                                }
                                self.tableView?.reloadData()
                                
                            }
                        }
                        else{
                            //失败
                            loadFailure(msg : value["msg"] as!String)
                            print("JSON: \(value)()")
                        }
                    }
                }
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                print(encodingError)
            }
            
        }
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
