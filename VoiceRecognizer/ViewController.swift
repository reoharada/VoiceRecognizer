//
//  ViewController.swift
//  VoiceRecognizer
//
//  Created by REO HARADA on 2019/12/01.
//  Copyright © 2019 reo harada. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var recognizeTextView: UITextView!
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    var recognitionTask: SFSpeechRecognitionTask!
    let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        SFSpeechRecognizer.requestAuthorization { (status) in
            print(status)
        }
    }

    @IBAction func tapStartButton(_ sender: UIButton) {
        sender.isHidden = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .defaultToSpeaker)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            print(error)
            if let result = result {
                print(result.bestTranscription.formattedString)
                self.recognizeTextView.text = result.bestTranscription.formattedString
            }
        })
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
}

