//
//  ].swift
//  RxSwift-threads
//
//  Created by junehee on 8/3/24.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "확인", style: .default)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(cancel)
        alert.addAction(okay)
        
        present(alert, animated: true)
    }
    
}
