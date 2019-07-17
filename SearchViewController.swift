//
//SearchViewController.swift
// BookProject
// referenced from Bhatt, 2019

import UIKit
import Speech

class SearchViewController: UIViewController,UISearchBarDelegate,SFSpeechRecognizerDelegate {
    
    @IBOutlet var searchBar : UISearchBar!
    let voiceSoundOn = URL(fileURLWithPath: Bundle.main.path(forResource: "VoiceSoundOn", ofType: "m4a")!)
    let voiceSoundOff = URL(fileURLWithPath: Bundle.main.path(forResource: "VoiceSoundOff", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    @IBOutlet weak var voiceButton: UIButton!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var text = ""
    private let audioEngine = AVAudioEngine()
    var isFirstTime : Bool  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        // Do any additional setup after loading the view.
        
        voiceButton.isEnabled = false // 2
        speechRecognizer.delegate = self  //3
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false;
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true;
                
            case .denied:
                isButtonEnabled = false;
                print("User denied access to speech recognition");
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation(){
                self.voiceButton.isEnabled = isButtonEnabled;
                
            }
        }
        
        voiceButton.accessibilityActivate()
        voiceButton.accessibilityLabel = " Voice Recorder"
        voiceButton.accessibilityHint = "Click to start/stop recording"

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Search"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text != ""{
            
            let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
            resultVC.searchWord = searchBar.text
            self.navigationItem.title = "Search"
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: false)
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    @IBAction func voiceButtonClicked(_ sender: AnyObject) {
        if audioEngine.isRunning {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: voiceSoundOff)
                audioPlayer.prepareToPlay()
            } catch {
                print("Problem in getting File")
            }
            audioPlayer.play()
            audioEngine.stop()
            recognitionRequest?.endAudio()
            voiceButton.isEnabled = false
            searchVoiceResult()
        } else if !audioEngine.isRunning && voiceButton.isEnabled{
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: voiceSoundOn)
                audioPlayer.prepareToPlay()
            } catch {
                print("Problem in getting File")
            }
            audioPlayer.play()
            startRecording()
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(.record, mode: .default, options: .defaultToSpeaker)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false
            
            if result != nil {
                
                self.searchBar.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.voiceButton.isEnabled = true
            }
        })
        
        
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        DispatchQueue.main.async {
        }
        
    }
    func searchVoiceResult()
    {
        searchBarSearchButtonClicked(searchBar)
    }
    
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            voiceButton.isEnabled = true
        } else {
            voiceButton.isEnabled = false
        }
    }
    
    
}
