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


struct ContentView : View {
    @EnvironmentObject private var poller: Poller
    @State private var ip_address: String = ""
    
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all).environmentObject(self.poller)

            VStack {
                ZStack {
                    if !self.poller.is_connected {
                        Rectangle().foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0))
                    } else {
                        Rectangle().foregroundColor(Color(red: 0.0, green: 1.0, blue: 0.0, opacity: 1.0))
                    }
                    
                    HStack {
                        TextField(DEFAULT_HOST, text: $ip_address)
                        Spacer()
                        Button(action: {
                            //self.poller.ip_adress = self.ip_address
                            //self.poller.set_ip_address(ip_adress: self.ip_address)
                            self.poller.connect(host: self.ip_address)
                            
                            let keyWindow = UIApplication.shared.connectedScenes
                                    .filter({$0.activationState == .foregroundActive})
                                    .map({$0 as? UIWindowScene})
                                    .compactMap({$0})
                                    .first?.windows
                                    .filter({$0.isKeyWindow}).first
                            keyWindow?.endEditing(true)
            
                        }) {
                            Text("Set IP").foregroundColor(.white)
                        }
                    }.padding()
                }.frame(height: 50)
                
                ZStack {
                    Rectangle().foregroundColor(self.poller.tracking_state_color)
                    Text(self.poller.tracking_state_str)
                        .font(Font.custom("SFProText-Bold", size: 24))
                        .foregroundColor(Color.white)
                    
                }.frame(height: 100)
                HStack {
                    VIOTouchButton(key: ERASER_KEY, background: Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.5));
                    VIOTouchButton(key: CLICK_KEY, background: Color(red: 1.0, green: 1.0, blue: 0.0, opacity: 0.5));
                }
                HStack {
                    //VIOButton(key: PRINT_KEY, background: Color(red: 0.0, green: 1.0, blue: 1.0, opacity: 0.5));
                    VIOButton(key: MERGE_KEY, background: Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.5));
                }
                Slider(value: self.$poller.volume, in: 0...100, step: 1).padding()
                
                HStack {
                    Text("1m / " + String(self.poller.ratio) + "pixels")
                        .font(.headline)
                        .foregroundColor(Color.white).padding()
                    Slider(value: self.$poller.ratio, in: 100...500, step: 1)
                }.padding()
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
