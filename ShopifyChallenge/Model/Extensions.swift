//
//  Extensions.swift
//  ShopifyChallenge
//
//  Created by Philip Tam on 2019-01-20.
//  Copyright © 2019 Philip Tam. All rights reserved.
//

import Foundation

extension String {
    func getStringRemoving(r: String) -> String {
        var st = "";
        for s in self.components(separatedBy: " ").filter({$0 != r}){
            st.append(s + " ")
        }
        return st.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

