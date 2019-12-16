//
//  VIOButton.swift
//  VIO
//
//  Created by yuukitakada on 2019/12/14.
//  Copyright © 2019 ayafuji. All rights reserved.
//

import SwiftUI

struct VIOButton: View {
    @EnvironmentObject private var poller: Poller
    var key: String
    var background: Color
    var body: some View {
        Button(action: {
            self.poller.status[self.key] = true
        }) {
            ZStack {
                Rectangle().foregroundColor(background)
                Text(self.key)
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct VIOTouchButton: View {
    @EnvironmentObject private var poller: Poller
    var key: String
    var background: Color
    var body: some View {
        ZStack {
            Text(self.key)
                .font(.largeTitle)
                .foregroundColor(Color.white)
            Rectangle().foregroundColor(background).gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged{ value in
                    self.poller.status[self.key] = true
                }.onEnded{ _ in
                    self.poller.status[self.key] = false
                }
            )
        }
    }
}

struct VIOButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            VIOButton(key: PRINT_KEY, background: Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.5))
            VIOTouchButton(key: PRINT_KEY, background: Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.5))
        }
   }
}
