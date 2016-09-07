//
//  AccountDetailEditingViewController.swift
//  TiMiRecording
//
//  Created by 潘元荣(外包) on 16/9/2.
//  Copyright © 2016年 潘元荣(外包). All rights reserved.
//

import UIKit

class AccountDetailEditingViewController: UIViewController {
    private let incomeButton = UIButton.init(type: .Custom)
    private let paidButton = UIButton.init(type: .Custom)
    private lazy var topView = MUAccountEditTopView.init(frame: CGRectZero)
    private let collectionView = MUAccountEditCollectionView.init(frame: CGRectMake(0, KAccoutTitleMarginToAmount * 1.5 + 30 + 45 * KHeightScale, KWidth, KHeight - KAccoutTitleMarginToAmount - 30 - 45 * KHeightScale - KKeyBoardHeight), collectionViewLayout: UICollectionViewFlowLayout.init())
    private var firstData = MUAccountDetailModel()
    private var thumbImageViewRect = CGRectZero
    private var thumbImageAniLayer = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.addButtons()
        self.topView = MUAccountEditTopView.init(frame: CGRectMake(0, KAccoutTitleMarginToAmount + 30, KWidth, 45 * KHeightScale))
        self.view.addSubview(topView)

      

    
        self.view.addSubview(self.collectionView)
        //self.collectionView.backgroundColor =  UIColor.greenColor()
        
        //data load
        self.loadData("MUAccountPayment")
        let itemHeightMargin = (self.collectionView.frame.size.height - 3 * KAccountItemHeight) / 2.0
        
        self.view.addSubview(self.thumbImageAniLayer)
        self.collectionView.setCollectionViewBlock { [unowned self](data, layer,row,offSize) -> Void in
            //self.view.bringSubviewToFront(self.thumbImageAniLayer)
            let animation = CABasicAnimation.init(keyPath: "transform.translation.x")
            let animationY = CABasicAnimation.init(keyPath: "transform.translation.y")
           
            
            var rect = self.thumbImageViewRect
            rect.origin.x -= CGFloat.init(row / KAccountItemNumTrue) * (KAccountItemHeight+KAccountItemWidthMargin)
            rect.origin.x -= layer.frame.origin.x
            rect.origin.x += offSize.x
        
            rect.origin.y += CGFloat.init(row % KAccountItemNumTrue) * (KAccountItemHeight+itemHeightMargin)

            
            animation.fromValue = 0.0
            animation.toValue = rect.origin.x
            animationY.fromValue = 0.0
            animationY.toValue = -rect.origin.y
            let groupAnimation = CAAnimationGroup.init()
            groupAnimation.animations = [animation,animationY]
            groupAnimation.delegate = self
            groupAnimation.duration = 0.5
            self.thumbImageAniLayer.image = UIImage.init(named: data.thumbnailName)
            var newRect = CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height)
            newRect.origin.x = -rect.origin.x
            newRect.origin.x += layer.frame.origin.x
          
            newRect.origin.y = rect.origin.y
            newRect.origin.y += self.thumbImageViewRect.origin.y
           
            self.thumbImageAniLayer.frame = newRect
            self.thumbImageAniLayer.layer.addAnimation(groupAnimation, forKey: "layer")
            self.firstData = data
            //print("move  ---x\(animation.toValue)")
            
            //print(offSize.x)
        }
    }
    //MARK: animation delegate
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.topView.loadData(self.firstData)
        self.collectionView.pagingEnabled = true
        self.thumbImageAniLayer.frame = CGRectZero
    }
    private func loadData(plistName : String) {
        
        
        dispatch_async(dispatch_get_global_queue(0, 0
            )) { () -> Void in
                self.collectionView.itemArray.removeAllObjects()
                self.collectionView.itemArray.addObjectsFromArray(MUAccountDataManager.manager.getDataFromPlist(plistName, isPayment: true))
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.firstData = self.collectionView.itemArray.firstObject as! MUAccountDetailModel
                    self.topView.loadData(self.firstData)
                    self.thumbImageViewRect = self.topView.getThumbnilImageRect();
                    //self.collectionView.addSubview(self.thumbImageAniLayer)
                    self.collectionView.reloadData()
                }
        }
        
    }
    private func addButtons() {
        let closeButton = UIButton.init(type: .Custom)
        closeButton.frame = CGRectMake(KAccoutTitleMarginToAmount * 0.5, KAccoutTitleMarginToAmount, 18 , 18)
        closeButton.setImage(UIImage.init(named: "btn_item_close_36x36_"), forState: .Normal)
        self.view.addSubview(closeButton)
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        
       
        incomeButton.setTitle("收入", forState: .Normal)
        incomeButton.titleLabel?.font = UIFont.systemFontOfSize(KBigFont)
        incomeButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        incomeButton.setTitleColor(UIColor.init(red: 253 / 255.0, green: 165/255.0, blue: 65/255.0, alpha: 1.0), forState: .Selected)
        incomeButton.frame = CGRectMake(KWidth * 0.5 - 80 - KAccoutTitleMarginToAmount * 0.5, KAccoutTitleMarginToAmount, 80, 30)
        incomeButton.addTarget(self, action: "incomeOrPaidDataLoad:", forControlEvents: .TouchUpInside)
        self.view.addSubview(incomeButton)
        
      
        paidButton.setTitle("支出", forState: .Normal)
        paidButton.titleLabel?.font = UIFont.systemFontOfSize(KBigFont)
        paidButton.frame = CGRectMake(KWidth * 0.5 + KAccoutTitleMarginToAmount * 0.5, KAccoutTitleMarginToAmount, 80, 30)
        paidButton.addTarget(self, action: "incomeOrPaidDataLoad:", forControlEvents: .TouchUpInside)
        paidButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        paidButton.setTitleColor(UIColor.init(red: 253 / 255.0, green: 165/255.0, blue: 65/255.0, alpha: 1.0), forState: .Selected)
        paidButton.selected = true
        self.view.addSubview(paidButton)
    }
    func close() {
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func incomeOrPaidDataLoad(sender : UIButton){
        if(sender == incomeButton && sender.selected == false) {
            incomeButton.selected = true
            paidButton.selected = false
            self.loadData("MUAccoutIncome")
        }else if(sender == paidButton && sender.selected == false) {
           paidButton.selected = true
           incomeButton.selected = false
           self.loadData("MUAccountPayment")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
