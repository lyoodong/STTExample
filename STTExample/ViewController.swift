//
//  ViewController.swift
//  STTExample
//
//  Created by Dongwan Ryoo on 2023/09/21.
//

import UIKit
import AVFoundation
import SnapKit
import Speech

class ViewController: UIViewController {
    
    lazy var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR"))
    
    lazy var speakButton: UIButton = {
        let view = UIButton()
        let image = UIImage(systemName: "airpodsmax")
        view.setImage(image, for: .normal)
        view.contentVerticalAlignment = .fill
        view.contentHorizontalAlignment = .fill
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.tintColor = .gray
        view.addTarget(self, action: #selector(speakButtonTapped), for: .touchUpInside)
        
        return view
    }()
    
    lazy var speakToTextLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.backgroundColor = .gray
        return view
    }()
    
    @objc
    func speakButtonTapped() {
        if let recorder = audioRecorder {
            if recorder.isRecording {
                finishRecording(success: true)
            } else {
                startRecording()
            }
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        print(audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            print("녹음 시작")
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            print("finishRecording - success")
            speakToText()
        } else {
            print("finishRecording - fail")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        audioSet()
        addSubView()
        constraints()
        requestAuth()
    }
    
    func audioSet() {
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
    
    func addSubView() {
        view.addSubview(speakButton)
        view.addSubview(speakToTextLabel)
    }
    
    func constraints() {
        speakButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(100)
        }
        
        speakToTextLabel.snp.makeConstraints { make in
            make.top.equalTo(speakButton.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func requestAuth() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .notDetermined:
                print("notDetermined")
            case .denied:
                print("denied")
            case .restricted:
                print("restricted")
            case .authorized:
                print("authorized")
            }
        }
    }
    
    func speakToText() {
        let audioUrl = audioRecorder.url
        
        if speechRecognizer!.isAvailable {
            let request = SFSpeechURLRecognitionRequest(url: audioUrl)
            speechRecognizer?.supportsOnDeviceRecognition = true
            speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
                if let error = error {
                    print(error)
                } else if let result = result {
                    print(result.bestTranscription.formattedString)
                    
                    self.speakToTextLabel.text = result.bestTranscription.formattedString
//                    let meta = result.speechRecognitionMetadata
//                    meta?.voiceAnalytics?.pitch
                    
                }
            })
        }
    }
    
    
}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}


