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
import ARKit

let DEFAULT_PORT: UInt16 = 32900
let DEFAULT_PORT_32: Int32 = 32900
//let DEFAULT_HOST: String = "192.168.43.128"
let DEFAULT_HOST: String = "127.0.0.1"

let CLICK_KEY = "click"
let PRINT_KEY = "print"
let MERGE_KEY = "merge"
let ERASER_KEY = "eraser"

final class Poller: ObservableObject {
    
    var connection: NWConnection?
    var arView: ARView = ARView(frame: .zero)
    
    //var udpClient = UDPClient(address: DEFAULT_HOST, port: DEFAULT_PORT_32)
    //let queue = DispatchQueue(label: "com.unifa-e.ChatClient")
    
    var transform: CMAcceleration = CMAcceleration()
    //var is_drag: Bool = false
    //var is_print: Bool = false
    
    var fps = 0
    var last_update_time: Double = 0
    
    @Published var is_connected: Bool = false
    
    var ip_adress: String = DEFAULT_HOST
    var requested_ip: String = DEFAULT_HOST
    
    var status: Dictionary = [String: Bool]()
    
    init() {
//        self.connection = NWConnection(host: NWEndpoint.Host(self.ip_adress), port: NWEndpoint.Port(integerLiteral: DEFAULT_PORT), using: .udp)
//        self.connection.start(queue: queue)
        self.last_update_time = getUnixTime()
        self.status = [
            PRINT_KEY: false,
            CLICK_KEY: false,
            MERGE_KEY: false,
            ERASER_KEY: false,
        ]
    }
    
    public func setARView(arview: ARView) {
        self.arView = arview
    }

    public func Poll() {
        NSLog("start poll")
        
        let ms: UInt32 = 1000
        let queue = DispatchQueue(label: "com.hogehoge.fuga", qos: .background)
        queue.async {
            while true {
                if self.ip_adress != self.requested_ip {
                    self.ip_adress = self.requested_ip
                    self.connection = nil
                }
                let doubled_x: Double = Double(self.arView.cameraTransform.translation.x).roundToDecimal(4)
                let doubled_y: Double = Double(self.arView.cameraTransform.translation.y).roundToDecimal(4)
                let doubled_z: Double = Double(self.arView.cameraTransform.translation.z).roundToDecimal(4)
                let clicked: String = self.status[CLICK_KEY]! ? "1" : "0"
                let printed: String = self.status[PRINT_KEY]! ? "1" : "0"
                let merge: String = self.status[MERGE_KEY]! ? "1" : "0"
                let eraser: String = self.status[ERASER_KEY]! ? "1" : "0"
                
                let results = [
                    String(doubled_x),
                    String(doubled_y),
                    String(doubled_z),
                    eraser,
                    clicked,
                    merge,
                    printed,
                ]
                if self.is_connected {
                    print(results.joined(separator: ","))
                    self.connection!.send(content: results.joined(separator: ",").data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                    })))
                }

                //NSLog("x:%@, y:%@, z:%@, clicked:%@, print: %@", String(doubled_x), String(doubled_y), String(doubled_z), clicked, printed)
                if self.status[PRINT_KEY]! {
                    self.status[PRINT_KEY] = false
                }
                
                if self.status[MERGE_KEY]! {
                    self.status[MERGE_KEY] = false
                }

                self.fps += 1
                if self.getUnixTime() - self.last_update_time > 1 {
                    NSLog("poller fps: %d", self.fps)
                    self.last_update_time = self.getUnixTime()
                    self.fps = 0
                }
                
                self.requested_ip = self.ip_adress
                
                usleep(UInt32(1000.0 / 30) * ms)
            }
        }
    }
    
    func connect(host: String) {
        self.connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: DEFAULT_PORT), using: .udp)
        self.connection?.start(queue: .global())
        self.is_connected = true
//        self.connection?.send(content: "hello".data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
//        })))
//        self.connection?.receiveMessage { (data, context, isComplete, error) in
//            if (isComplete) {
//                print(error.debugDescription)
//                self.is_connected = true
//            } else {
//                print("failed to get message from the server")
//            }
//        }
    }
    
    func getUnixTime() -> Double {
        return NSDate().timeIntervalSince1970
    }
    
    public func set_ip_address(ip_adress: String) {
        NSLog("reset ip adress %@", ip_adress)
        self.ip_adress = ip_adress
    }
    
    public func sendMessage(message: String) {
        self.connection!.send(content: message.data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
        })))
    }
}
