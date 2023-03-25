//
//  SideMenuConfig.swift
//  SideMenu
//
//  Created by Vidhyadharan Mohanram on 21/06/19.
//  Copyright © 2019 Vid. All rights reserved.
//

import SwiftUI

public struct SideMenuConfig {
    public var menuBGColor: Color
    public var menuBGOpacity: Double
    
    public var leftNavigationBarItemColor: Color
    public var leftNavigationBarItemName: String
    public var rightNavigationBarItemColor: Color
    public var rightNavigationBarItemName: String

    public var menuWidth: CGFloat
    
    public var animationDuration: Double
    
    
    public init(menuBGColor: Color = .black, menuBGOpacity: Double = 0.3,
                menuWidth: CGFloat = 300, animationDuration: Double = 0.3,
                leftNavigationBarItemColor: Color = .blue, leftNavigationBarItemName: String = "sidebar.left",
                rightNavigationBarItemColor: Color = .blue, rightNavigationBarItemName: String = "sidebar.right"
    ) {
        self.menuBGColor = menuBGColor
        self.menuBGOpacity = menuBGOpacity
        self.menuWidth = menuWidth
        self.animationDuration = animationDuration
        self.leftNavigationBarItemColor = leftNavigationBarItemColor;
        self.leftNavigationBarItemName = leftNavigationBarItemName;
        self.rightNavigationBarItemColor = rightNavigationBarItemColor;
        self.rightNavigationBarItemName = rightNavigationBarItemName;
    }
}
