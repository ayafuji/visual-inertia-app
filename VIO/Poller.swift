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
let DEFAULT_HOST: String = "192.168.43.128"

let CLICK_KEY = "click"
let PRINT_KEY = "print"
let MERGE_KEY = "merge"
let ERASER_KEY = "eraser"
let UP_KEY = "up"
let DOWN_KEY   = "down"

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

final class Poller: ObservableObject {
    var connection: NWConnection?
    var arView: ARView = ARView(frame: .zero)
    var transform: CMAcceleration = CMAcceleration()
    var fps = 0
    var last_update_time: Double = 0
    var ip_adress: String = DEFAULT_HOST
    var requested_ip: String = DEFAULT_HOST
    var status: Dictionary = [String: Bool]()
    
    @Published var is_connected: Bool = true
    
    init() {
        self.last_update_time = getUnixTime()
        self.status = [
            PRINT_KEY: false,
            CLICK_KEY: false,
            MERGE_KEY: false,
            ERASER_KEY: false,
            UP_KEY: false,
            DOWN_KEY: false,
        ]
        self.connection = NWConnection(host: NWEndpoint.Host(DEFAULT_HOST), port: NWEndpoint.Port(integerLiteral: DEFAULT_PORT), using: .udp)
        self.connection?.start(queue: .global())
        self.is_connected = true
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
                let up: String = self.status[UP_KEY]! ? "1" : "0"
                let down: String = self.status[DOWN_KEY]! ? "1" : "0"
                
                let results = [
                    String(Date().timeIntervalSince1970*1000),
                    String(doubled_x),
                    String(doubled_y),
                    String(doubled_z),
                    eraser,
                    clicked,
                    merge,
                    printed,
                    up,
                    down,
                ]
                if self.is_connected {
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
                
                if self.status[UP_KEY]! {
                    self.status[UP_KEY] = false
                }
                
                if self.status[DOWN_KEY]! {
                    self.status[DOWN_KEY] = false
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
