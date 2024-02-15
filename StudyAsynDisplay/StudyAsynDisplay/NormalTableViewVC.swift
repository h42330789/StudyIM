//
//  NormalTableViewVC.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 2/14/24.
//

import UIKit
import SnapKit
import Kingfisher

class NormalTableViewVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    lazy var tableView: UITableView = {
        let v = UITableView(frame: self.view.bounds, style: .plain)
        v.register(NormalTableCell.self, forCellReuseIdentifier: "Cell")
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    var dataList: [NormalDataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.reloadData()
   
        let newList = Array(0...9999).map{ NormalDataModel(avator: "https://h42330789.github.io/assets/img/lonelyflow.jpg", title: "title\($0)", status: "status\($0)", date: "date\($0)") }
        self.updateData(newList: newList)
    }

    func updateData(newList: [NormalDataModel], isShowReverse: Bool = false) {
        self.dataList = isShowReverse ? newList.reversed() : newList
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NormalTableCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NormalTableCell
        let model = dataList[indexPath.row]
        cell.avatar.kf.setImage(with: URL(string: model.avator))
        cell.titleLabel.text = model.title
        cell.statusLabel.text = model.status
        cell.dateLabel.text = model.date
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("\(indexPath.row)")
    }
}

class NormalTableCell: UITableViewCell {
    lazy var avatar: UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 20
        v.backgroundColor = .lightGray
        return v
    }()
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .black
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    lazy var statusLabel: UILabel = {
        let v = UILabel()
        v.textColor = .gray
        v.font = UIFont.systemFont(ofSize: 12)
        return v
    }()
    lazy var dateLabel: UILabel = {
        let v = UILabel()
        v.textColor = .gray
        v.font = UIFont.systemFont(ofSize: 12)
        return v
    }()
    lazy var infoBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(named: "InfoIcon"), for: .normal)
        v.addTarget(self, action: #selector(self.infoPressed), for: .touchUpInside)
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSelf() {
        self.contentView.addSubview(avatar)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(statusLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(infoBtn)
        
        avatar.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.top.equalTo(avatar.snp.top)
        }
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.bottom.equalTo(avatar.snp.bottom)
        }
        infoBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
            make.width.height.equalTo(40)
        }
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatar)
            make.right.equalTo(infoBtn.snp.left).offset(-10)
        }
    }
    
    // MARK: - 按钮点击
    @objc func infoPressed() {
        print("infoPressed")
    }
}
