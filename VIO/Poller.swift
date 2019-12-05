//
//  Poller.swift
//  VIO
//
//  Created by yuukitakada on 2019/12/04.
//  Copyright © 2019 ayafuji. All rights reserved.
//

import SwiftUI
import Network
import CoreMotion
import RealityKit

let DEFAULT_PORT: UInt16 = 32900
let DEFAULT_HOST: String = "192.168.43.66"

final class Poller: ObservableObject {
    
    var connection: NWConnection
    var arView: ARView = ARView(frame: .zero)
    let queue = DispatchQueue(label: "com.unifa-e.ChatClient")
    
    var transform: CMAcceleration = CMAcceleration()
    var is_drag: Bool = false
    var is_print: Bool = false
    
    var fps = 0
    var last_update_time: Double = 0
    
    init() {
        self.connection = NWConnection(host: NWEndpoint.Host(DEFAULT_HOST), port: NWEndpoint.Port(integerLiteral: DEFAULT_PORT), using: .udp)
        self.connection.stateUpdateHandler = { (newState) in
            switch newState {
            case .ready:
                NSLog("Ready to send")
            case .waiting(let error):
                NSLog("\(#function), \(error)")
            case .failed(let error):
                NSLog("\(#function), \(error)")
            case .setup: break
            case .cancelled: break
            case .preparing: break
            }
        }
        self.connection.start(queue: queue)
        
        self.last_update_time = getUnixTime()
    }
    
    public func setARView(arview: ARView) {
        self.arView = arview
    }
    
    public func Poll() {
        NSLog("start poll")
        let queue = DispatchQueue(label: "com.hogehoge.fuga", qos: .background)
        let ms: UInt32 = 1000
        queue.async {
            while true {
                let doubled_x: Double = Double(self.arView.cameraTransform.translation.x).roundToDecimal(4)
                let doubled_y: Double = Double(self.arView.cameraTransform.translation.y).roundToDecimal(4)
                let doubled_z: Double = Double(self.arView.cameraTransform.translation.z).roundToDecimal(4)
                let clicked: String = self.is_drag ? "1" : "0"
                let printed: String = self.is_print ? "1" : "0"
                
                let message: String = String(doubled_x) + "," + String(doubled_y) + "," + String(doubled_z) + "," + clicked + "," + printed
                self.connection.send(content: message.data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                })))
                
                //NSLog("x:%@, y:%@, z:%@, clicked:%@, print: %@", String(doubled_x), String(doubled_y), String(doubled_z), clicked, printed)
                if self.is_print {
                    self.is_print = false
                }
                
                self.fps += 1
                if self.getUnixTime() - self.last_update_time > 1 {
                    NSLog("poller fps: %d", self.fps)
                    self.last_update_time = self.getUnixTime()
                    self.fps = 0
                }
                
                usleep(UInt32(1000.0 / 30) * ms)
            }
        }
    }
    
    func getUnixTime() -> Double {
        return NSDate().timeIntervalSince1970
    }
    
    public func connect(host: String) {
        NSLog("trying to connect %s:%d", host, DEFAULT_PORT)
        self.connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: DEFAULT_PORT), using: .udp)
        self.connection.stateUpdateHandler = { (newState) in
            switch newState {
            case .ready:
                NSLog("Ready to send")
            case .waiting(let error):
                NSLog("\(#function), \(error)")
            case .failed(let error):
                NSLog("\(#function), \(error)")
            case .setup: break
            case .cancelled: break
            case .preparing: break
            }
        }
        self.connection.start(queue: queue)
    }
    
    public func sendMessage(message: String) {
        self.connection.send(content: message.data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
        })))
    }
    
}
