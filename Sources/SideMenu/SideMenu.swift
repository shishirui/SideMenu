//
//  ContentView.swift
//  SideMenu
//
//  Created by Vidhyadharan Mohanram on 11/06/19.
//  Copyright © 2019 Vid. All rights reserved.
//

import SwiftUI

public struct SideMenu : View {
    
    //  MARK: Custom initializers
    
    public init<Menu: View, CenterView: View>(leftMenu: Menu,
                                              centerView: CenterView,
                                              config: SideMenuConfig = SideMenuConfig()) {
        self.leftMenu = AnyView(leftMenu)
        
        self.config = config
        self._sideMenuCenterView = State(initialValue: AnyView(centerView))
    }
    
    public init<Menu: View, CenterView: View>(rightMenu: Menu,
                                              centerView: CenterView,
                                              config: SideMenuConfig = SideMenuConfig()) {
        self.rightMenu = AnyView(rightMenu)
        
        self.config = config
        self._sideMenuCenterView = State(initialValue: AnyView(centerView))
    }
    
    public init<LMenu: View, RMenu: View, CenterView: View>(leftMenu: LMenu,
                                                            rightMenu: RMenu,
                                                            centerView: CenterView,
                                                            config: SideMenuConfig = SideMenuConfig()) {
        self.leftMenu = AnyView(leftMenu)
        self.rightMenu = AnyView(rightMenu)
        
        self.config = config
        self._sideMenuCenterView = State(initialValue: AnyView(centerView))
    }
    
    private var leftMenu: AnyView? = nil
    private var rightMenu: AnyView? = nil
        
    private var config: SideMenuConfig
    
    @State private var leftMenuBGOpacity: Double = 0
    @State private var rightMenuBGOpacity: Double = 0
    
    @State private var leftMenuOffsetX: CGFloat = 0
    @State private var rightMenuOffsetX: CGFloat = 0
    @State var isLandscape: Bool?
    
    @Environment (\.editMode) var editMode;
    
    @State private var sideMenuGestureMode: SideMenuGestureMode = SideMenuGestureMode.active;
    @State private var sideMenuLeftPanel: Bool = false
    @State private var sideMenuRightPanel: Bool = false
    @State private var sideMenuCenterView: AnyView

    private var menuAnimation: Animation {
        .easeOut(duration: self.config.animationDuration)
    }
    
    public var body: some View {
        return
            GeometryReader { geometry in
                ZStack {
                    NavigationView {
                        if (self.leftMenu != nil && self.rightMenu != nil) {
                            self.sideMenuCenterView
                                .opacity(1)
                                .transition(.opacity)
                                .navigationBarItems(
                                    leading: Button(action: {
                                        withAnimation {
                                            self.sideMenuLeftPanel.toggle()
                                        }
                                    }, label: {
                                        Image(systemName: config.leftNavigationBarItemName)
                                            .accentColor(config.leftNavigationBarItemColor)
                                            .imageScale(.large)
                                    }),
                                    trailing: Button(action: {
                                        withAnimation {
                                            self.sideMenuRightPanel.toggle()
                                        }
                                    }, label: {
                                        Image(systemName: config.rightNavigationBarItemName)
                                            .accentColor(config.rightNavigationBarItemColor)
                                            .imageScale(.large)
                                    })
                                )
                            } else if (self.leftMenu != nil) {
                                self.sideMenuCenterView
                                    .opacity(1)
                                    .transition(.opacity)
                                    .navigationBarItems(
                                        leading: Button(action: {
                                            withAnimation {
                                                self.sideMenuLeftPanel.toggle()
                                            }
                                        }, label: {
                                            Image(systemName: config.leftNavigationBarItemName)
                                                .accentColor(config.leftNavigationBarItemColor)
                                                .imageScale(.large)
                                        })
                                    )
                            } else if (self.rightMenu != nil) {
                                self.sideMenuCenterView
                                    .opacity(1)
                                    .transition(.opacity)
                                    .navigationBarItems(
                                        trailing: Button(action: {
                                            withAnimation {
                                                self.sideMenuRightPanel.toggle()
                                            }
                                        }, label: {
                                            Image(systemName: config.rightNavigationBarItemName)
                                                .accentColor(config.rightNavigationBarItemColor)
                                                .imageScale(.large)
                                        })
                                )
                            }
                    }
                if self.sideMenuLeftPanel && self.leftMenu != nil {
                    MenuBackgroundView(sideMenuLeftPanel: self.$sideMenuLeftPanel,
                                       sideMenuRightPanel: self.$sideMenuRightPanel,
                                       bgColor: self.config.menuBGColor,
                                       bgOpacity: self.leftMenuBGOpacity)
                        .zIndex(1)
                    
                    self.leftMenu!
                        .edgesIgnoringSafeArea(Edge.Set.all)
                        .frame(width: self.config.menuWidth)
                        .offset(x: self.leftMenuOffsetX, y: 0)
                        .transition(.move(edge: Edge.leading))
                        .zIndex(2)
                }
                
                if self.sideMenuRightPanel && self.rightMenu != nil {
                    MenuBackgroundView(sideMenuLeftPanel: self.$sideMenuLeftPanel,
                                       sideMenuRightPanel: self.$sideMenuRightPanel,
                                       bgColor: self.config.menuBGColor,
                                       bgOpacity: self.rightMenuBGOpacity)
                        .zIndex(3)
                    
                    self.rightMenu!
                        .edgesIgnoringSafeArea(Edge.Set.all)
                        .frame(width: self.config.menuWidth)
                        .offset(x: self.rightMenuOffsetX, y: 0)
                        .transition(.move(edge: Edge.trailing))
                        .zIndex(4)
                }
            }.gesture(self.panelDragGesture(geometry.size.width))
                .animation(self.menuAnimation)
                .onAppear {
                    self.leftMenuOffsetX = -self.menuXOffset(geometry.size.width)
                    self.rightMenuOffsetX = self.menuXOffset(geometry.size.width)
                    self.leftMenuBGOpacity = self.config.menuBGOpacity
                    self.rightMenuBGOpacity = self.config.menuBGOpacity
                }
                // Previously, the following was driven by a NotificationCenter event. But it wasn't handling rotations correctly all the time. It wasn't giving the right width on a rotation. I think it was gettig called before the GeometryReader change.
                // This is a little crude, but I wanted to have an update that occurred on any change to the view-- so I could test if the landscape/portrait orientation had changed.
                .modifier(CallOnViewUpdate({
                    let newIsLandscape = geometry.size.width > geometry.size.height
                    var update = false
                    if isLandscape == nil {
                        update = true
                    }
                    else if isLandscape != newIsLandscape {
                        update = true
                    }
                    
                    if update {
                        DispatchQueue.main.async {
                            self.isLandscape = newIsLandscape
                            self.rightMenuOffsetX = self.menuXOffset(geometry.size.width)
                            self.leftMenuOffsetX = -self.menuXOffset(geometry.size.width)
                        }
                    }
                }))
            .environment(\.sideMenuGestureModeKey, self.$sideMenuGestureMode)
            .environment(\.sideMenuCenterViewKey, self.$sideMenuCenterView)
            .environment(\.sideMenuLeftPanelKey, self.$sideMenuLeftPanel)
            .environment(\.sideMenuRightPanelKey, self.$sideMenuRightPanel)
            .environment(\.horizontalSizeClass, .compact)
        }
    }
    
    // Just a means to get some code executed when a View is updated.
    private struct CallOnViewUpdate: ViewModifier {
        init(_ closure: ()->()) {
            closure()
        }
        
        func body(content: Content) -> some View {
            content
        }
    }
    
    private func panelDragGesture(_ screenWidth: CGFloat) -> _EndedGesture<_ChangedGesture<DragGesture>>? {
        if let mode = self.editMode?.wrappedValue, mode != EditMode.inactive {
            return nil
        }
        if self.sideMenuGestureMode == SideMenuGestureMode.inactive {
            return nil
        }
        
        return DragGesture()
            .onChanged { (value) in
                self.onChangedDragGesture(value: value, screenWidth: screenWidth)
        }
            .onEnded { (value) in
            self.onEndedDragGesture(value: value, screenWidth: screenWidth)
        }
    }
    
    private func menuXOffset(_ screenWidth: CGFloat) -> CGFloat {
        return (screenWidth - (self.config.menuWidth))/2
    }
    
    //  MARK: Drag gesture methods
    
    func onChangedDragGesture(value: DragGesture.Value, screenWidth: CGFloat) {
        let startLocX = value.startLocation.x
        let translation = value.translation
        
        let translationWidth = translation.width > 0 ? translation.width : -(translation.width)
        
        let leftMenuGesturePositionX = screenWidth * 0.1
        let rightMenuGesturePositionX = screenWidth * 0.9
        
        guard translationWidth <= self.config.menuWidth else { return }
        
        if self.sideMenuLeftPanel, value.dragDirection == .left, self.leftMenu != nil {
            let newXOffset = -self.menuXOffset(screenWidth) - translationWidth
            self.leftMenuOffsetX = newXOffset
            
            let translationPercentage = (self.config.menuWidth - translationWidth) / self.config.menuWidth
            guard translationPercentage > 0 else { return }
            self.leftMenuBGOpacity = self.config.menuBGOpacity * Double(translationPercentage)
        } else if self.sideMenuRightPanel, value.dragDirection == .right, self.rightMenu != nil {
            let newXOffset = self.menuXOffset(screenWidth) + translationWidth
            self.rightMenuOffsetX = newXOffset
            
            let translationPercentage = (self.config.menuWidth - translationWidth) / self.config.menuWidth
            guard translationPercentage > 0 else { return }
            self.rightMenuBGOpacity = self.config.menuBGOpacity * Double(translationPercentage)
        } else if startLocX < leftMenuGesturePositionX, value.dragDirection == .right, self.leftMenu != nil {
            if !self.sideMenuLeftPanel {
                self.sideMenuLeftPanel.toggle()
            }
            
            let defaultOffset = -(self.menuXOffset(screenWidth) + self.config.menuWidth)
            let newXOffset = defaultOffset + translationWidth
            
            self.leftMenuOffsetX = newXOffset
            
            let translationPercentage = translationWidth / self.config.menuWidth
            
            guard translationPercentage > 0 else { return }
            self.leftMenuBGOpacity = self.config.menuBGOpacity * Double(translationPercentage)
        } else if startLocX > rightMenuGesturePositionX, value.dragDirection == .left, self.rightMenu != nil {
            if !self.sideMenuRightPanel {
                self.sideMenuRightPanel.toggle()
            }
            
            let defaultOffset = self.menuXOffset(screenWidth) + self.config.menuWidth
            let newXOffset = defaultOffset - translationWidth
            
            self.rightMenuOffsetX = newXOffset
            
            let translationPercentage = translationWidth / self.config.menuWidth
            guard translationPercentage > 0 else { return }
            self.rightMenuBGOpacity = self.config.menuBGOpacity * Double(translationPercentage)
        }
    }
    
    func onEndedDragGesture(value: DragGesture.Value, screenWidth: CGFloat) {        
        let midXPoint = (0.5 * self.config.menuWidth)
        
        if self.sideMenuRightPanel, self.rightMenu != nil {
            let rightMenuMidX = self.menuXOffset(screenWidth) + midXPoint
            
            if self.rightMenuOffsetX > rightMenuMidX {
                self.sideMenuRightPanel.toggle()
            }
            
            self.rightMenuOffsetX = self.menuXOffset(screenWidth)
            self.rightMenuBGOpacity = self.config.menuBGOpacity
        } else if self.sideMenuLeftPanel, self.leftMenu != nil {
            let leftMenuMidX = -self.menuXOffset(screenWidth) - midXPoint
            
            if self.leftMenuOffsetX < leftMenuMidX {
                self.sideMenuLeftPanel.toggle()
            }
            
            self.leftMenuOffsetX = -self.menuXOffset(screenWidth)
            self.leftMenuBGOpacity = self.config.menuBGOpacity
        }
    }
    
}

@available(iOS 14.0, *)
struct SideMenuViewProvider: LibraryContentProvider {

    @LibraryContentBuilder var views: [LibraryItem] {        
        LibraryItem(SideMenu(leftMenu: LeftMenuPanel(), centerView: CenterView()),
                    visible: true,
                    title: "SideMenu with left menu",
                    category: .control)
        
        LibraryItem(SideMenu(rightMenu: RightMenuPanel(), centerView: CenterView()),
                    visible: true,
                    title: "SideMenu with right menu",
                    category: .control)
        
        LibraryItem(SideMenu(leftMenu: LeftMenuPanel(), rightMenu: RightMenuPanel(), centerView: CenterView()),
                    visible: true,
                    title: "SideMenu with both left and right menu",
                    category: .control)
    }

}

//  MARK: Menu background view

struct MenuBackgroundView : View {
    @Binding var sideMenuLeftPanel: Bool
    @Binding var sideMenuRightPanel: Bool
    
    let bgColor: Color
    let bgOpacity: Double
    
    var body: some View {
        Rectangle()
            .background(bgColor)
            .opacity(bgOpacity)
            .transition(.opacity)
            .onTapGesture {
                withAnimation {
                    if self.sideMenuLeftPanel {
                        self.sideMenuLeftPanel.toggle()
                    }
                    
                    if self.sideMenuRightPanel {
                        self.sideMenuRightPanel.toggle()
                    }
                }
        }
        .edgesIgnoringSafeArea(Edge.Set.all)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        let leftMenu = LeftMenuPanel()
        let rightMenu = RightMenuPanel()
        
        return Group {
            SideMenu(leftMenu: leftMenu, centerView: AnyView(CenterView()))
            
            SideMenu(rightMenu: rightMenu, centerView: AnyView(CenterView()))
            
            SideMenu(leftMenu: leftMenu, rightMenu: rightMenu, centerView: AnyView(CenterView()))
        }
    }
}
#endif
