//
//  ContentView.swift
//  VIO
//
//  Created by yuukitakada on 2019/12/04.
//  Copyright © 2019 ayafuji. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import CoreMotion
import Network


extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

struct ContentView : View {
    @EnvironmentObject private var poller: Poller
    
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all).environmentObject(self.poller)
            VStack {
                ZStack {
                    Text("Left Click")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                    Rectangle().foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.5)).gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global).onChanged{ value in
                            self.poller.is_drag = true
                        }.onEnded{ _ in
                            self.poller.is_drag = false
                        }
                    )
                }

                Button(action: {
                    self.poller.is_print = true
                }) {
                    ZStack {
                        Rectangle().foregroundColor(Color(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.5))
                        Text("Print")
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                    }
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject private var poller: Poller
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.poller.setARView(arview: arView)
        self.poller.Poll()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
