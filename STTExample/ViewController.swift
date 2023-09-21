//
//  ViewController.swift
//  STTExample
//
//  Created by Dongwan Ryoo on 2023/09/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    lazy var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { permission in
                if permission {
                    print("음성 녹음 허용")
                } else {
                    print("음성 녹음 불허")
                }
            }
            
        } catch {
            print("음성 녹음 실패")
        }
        
        
    }
}

