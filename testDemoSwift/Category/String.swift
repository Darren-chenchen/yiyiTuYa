//
//  String.swift
//  CloudscmSwift
//
//  Created by RexYoung on 2017/3/21.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import Foundation
import UIKit

extension String{
    
    //MARK: - 获取字符串的宽度高度
    static func getTextSize(labelStr:String,font:UIFont,maxW:CGFloat,maxH:CGFloat) -> CGSize {
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize(width: maxW, height:maxH)
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context:nil).size
        return strSize
    }
}
