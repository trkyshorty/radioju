//
//  RadioPlayer.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import Foundation
import MediaPlayer
import AVKit


class RadioPlayer: NSObject, ObservableObject {
    
    static let instance = RadioPlayer()
    
    @Published var isMuted: Bool = false
    @Published var isStopped: Bool = true
    
    @Published var previousStation: StationModel?
    @Published var currentStation: StationModel?
    @Published var nowPlayingInfoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    @Published var stationService: StationService = StationService()
    @Published var genreService: GenreService = GenreService()
    @Published var countryService: CountryService = CountryService()
    @Published var locationService: LocationService = LocationService()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var commandCenter: MPRemoteCommandCenter?
    private var artwork: MPMediaItemArtwork?
    private var volumeLevel: Float = 0.75
    
    override init () {
        super.init()
        initRemoteCommandCenter()
    }
    
    func initPlayer(_ station: StationModel) {
        currentStation = station
        
        guard let url = URL(string: currentStation?.url ?? "") else { return }
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentStation!.title as String,
        ]
        
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty), options:[.new, .initial], context: nil)
        
        player?.volume = volumeLevel
        
        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        
        playerItem?.add(metadataOutput)
        
        getImageFromURL(from: URL(string: "image/station/" + currentStation!.id + ".png", relativeTo: Configuration.cdnUrl)!) { [weak self] image in
            guard let self = self,
                  let downloadedImage = image else {
                return
            }
            let artwork = MPMediaItemArtwork.init(boundsSize: downloadedImage.size, requestHandler: { _ -> UIImage in
                return downloadedImage
            })
            self.updateNowPlayingInfoArtwork(artwork)
        }
        
        nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    }
    
    func getImageFromURL(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data {
                completion(UIImage(data:data))
            }
        }).resume()
    }
    
    func updateNowPlayingInfoArtwork(_ artwork: MPMediaItemArtwork) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is AVPlayer {
            switch keyPath {
                
            case #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty):
                let _: Bool
                if let newStatusNumber = change?[NSKeyValueChangeKey.newKey] as? Bool {
                    if newStatusNumber {
                        print("Player: Stalling")
                    }
                }
                
            case #keyPath(AVPlayer.currentItem.status):
                let newStatus: AVPlayerItem.Status
                if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                } else {
                    newStatus = .unknown
                }
                
                if newStatus == .readyToPlay {
                    print("Player: Ready to play")
                    
                    if MPNowPlayingInfoCenter.default().playbackState != .playing {
                        changePlaybackState(.playing)
                        play()
                        print("Player: Playing")
                    }
                }
                
                if newStatus == .failed {
                    changePlaybackState(.interrupted)
                    print("Player: Failed")
                }
                
                if newStatus == .unknown {
                   changePlaybackState(.unknown)
                }
            case #keyPath(AVPlayer.status):
                print()
            default:
                if keyPath != nil {
                    print("Player: Unhandled keyPath " + keyPath!)
                }
            }
        }
    }
    
    private func initRemoteCommandCenter () {
        do {
            commandCenter = MPRemoteCommandCenter.shared()
            
            commandCenter?.togglePlayPauseCommand.isEnabled = false
            commandCenter?.playCommand.isEnabled = true
            commandCenter?.pauseCommand.isEnabled = true
            commandCenter?.nextTrackCommand.isEnabled = true
            commandCenter?.previousTrackCommand.isEnabled = true
            commandCenter?.changePlaybackRateCommand.isEnabled = false
            commandCenter?.skipForwardCommand.isEnabled = false
            commandCenter?.skipBackwardCommand.isEnabled = false
            commandCenter?.ratingCommand.isEnabled = true
            commandCenter?.likeCommand.isEnabled = false
            commandCenter?.dislikeCommand.isEnabled = false
            commandCenter?.bookmarkCommand.isEnabled = true
            commandCenter?.changeRepeatModeCommand.isEnabled = false
            commandCenter?.changeShuffleModeCommand.isEnabled = false
            
            // only available in iOS 9
            if #available(iOS 9.0, *) {
                commandCenter?.enableLanguageOptionCommand.isEnabled = false
                commandCenter?.disableLanguageOptionCommand.isEnabled = false
            }
            
            commandCenter?.playCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
                self.play()
                return .success
            }
            
            commandCenter?.pauseCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
                self.pause()
                return .success
            }
            
            commandCenter?.stopCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
                self.stop()
                return .success
            }
            
            commandCenter?.previousTrackCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
                self.prevStation()
                return .success
            }
            
            commandCenter?.nextTrackCommand.addTarget { (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
                self.nextStation()
                return .success
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetoothA2DP])
                try audioSession.overrideOutputAudioPort(.speaker)
                try audioSession.setActive(true)
            }
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
        } catch {
            print("Player: Something went wrong! \(error)")
        }
    }
    
    func getVolumeLevel() -> Float {
        return volumeLevel
    }
    
    func volume(_ volume: Float) {
        volumeLevel = volume
        player?.volume = volumeLevel
    }
    
    func play() {
        if(MPNowPlayingInfoCenter.default().playbackState == .stopped ||
           MPNowPlayingInfoCenter.default().playbackState == .paused ) {
            changePlaybackState(.playing)
        }
        isStopped = false
        player?.play()
    }
    
    func pause(){
        player?.pause()
        changePlaybackState(.paused)
    }
    
    func stop() {
        player?.pause() //how to destroy??
        isStopped = true
        changePlaybackState(.stopped)
    }
    
    func changePlaybackState(_ playbackState: MPNowPlayingPlaybackState) {
        MPNowPlayingInfoCenter.default().playbackState = playbackState
        nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    }
    
    func prevStation() {
        if(previousStation != nil && previousStation?.id != currentStation?.id) {
            initPlayer(previousStation!)
            play()
        } else {
            print("Player: Previous station not exist, skipped")
        }
    }
    
    func nextStation() {
        let currentStationGenreIds = currentStation?.genres.map { $0.id }
        let searchAvailableStation = stationService.data
            .filter({
                $0.genres
                    .contains(where: {
                        currentStationGenreIds!.contains($0.id)
                    })
            })
            .filter({
                $0.id != currentStation?.id && $0.id != previousStation?.id
            })
            .randomElement()
        
        if(searchAvailableStation != nil) {
            previousStation = currentStation
            initPlayer(searchAvailableStation!)
            play()
        } else {
            print("Player: Next station not exist, skipped")
        }
    }
}

extension RadioPlayer: AVPlayerItemMetadataOutputPushDelegate {
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        if let item = groups.first?.items.first // make this an AVMetadata item
        {
            item.value(forKeyPath: "value")
            let song: String? = (item.value(forKeyPath: "value")!) as? String
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtist] = song;
            self.nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        }
    }
}


