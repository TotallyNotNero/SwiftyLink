//
//  SwiftyPlayer.swift
//  SwiftyLink
//
//  Created by TotallyNotNero on 9/1/21.
//

import Foundation
import Discord
import Logging

fileprivate let logger = Logger(label: "SwiftyPlayer")

/// Represents a music player.
open class Player {
    
    // MARK: Properties
    
    /// The Guild ID this player is responsible for
    private let guildID: String
    
    /// The node this player is managed by
    public let node: SwiftyNode
    
    /// The client this player is attached to
    public let client: DiscordClient
    
    /// The currently playing track, sourced from the REST response
    public var song: lavalinkREST?
    
    // MARK: Initializers
    
    /// Initializes the player
    /// - parameter guild: The Guild ID this player is responsible for
    /// - parameter node: The node this player is managed by
    /// - parameter client: The client this player is attached to
    public required init(guild: String, node: SwiftyNode, client: DiscordClient) {
        self.guildID = guild
        self.node = node
        self.client = client
    }
    
    /// Connects to the specified voice channel.
    /// - parameter channel: The voice channel
    /// - parameter deaf: Whether the bot should be deafened or not
    /// - parameter mute: Whether the bot should be muted or not
    open func connect(channel: String, deaf: Bool, mute: Bool) {
        
        let payload = DiscordGatewayPayload(code: DiscordGatewayCode.gateway(DiscordNormalGatewayCode.voiceStatusUpdate), payload: DiscordGatewayPayloadData.object(["guild_id": "\(self.guildID)", "channel_id": "\(channel)", "self_mute": mute, "self_deaf": deaf]), sequenceNumber: nil, name: nil)
        
        client.shardManager.sendPayload(payload, onShard: 0)
        
        logger.log(level: .info, .init(stringLiteral: "Successfully connected to the voice channel."))
        
    }
    
    /// Searches a song on Lavalink
    open func search(query: String, songHandler: @escaping (lavalinkREST?, Error?) -> Void) {
        let url = URL(string: "http://\(self.node.host):\(self.node.port)/loadtracks?identifier=\(query)")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Authorization": "\(self.node.password)"
        ]
        
        var res: lavalinkREST?

        URLSession.shared.dataTask(with: request) { (data, response, error) in
          guard error == nil else { return }
          guard let data = data, let response = response else { return }

            let rest: lavalinkREST = try! JSONDecoder().decode(lavalinkREST.self, from: data)
            
            if rest.loadType == "NO_MATCHES" { return }
             
            print(rest.loadType)
            print(rest.tracks[0].info.title)
            
            res = rest
            
            songHandler(res, nil)
    
        }.resume()
    }
    
    /// Plays a song on Lavalink
    /// - parameter track: The base64 track to play
    open func play(track: String) {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let object = trackPlay(op: "play", track: track, guildId: guildID)
        
        let JSON = try? encoder.encode(object)
        
        let response = String(data: JSON!, encoding: .utf8)!
        
        let message = URLSessionWebSocketTask.Message.string(response)
        
        self.node.sendUpdate(msg: message)
        
    }
    
    /// Stops the player
    open func stop() {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let object = stopPlayer(op: "stop", guildId: guildID)
        
        let JSON = try? encoder.encode(object)
        
        let response = String(data: JSON!, encoding: .utf8)!
        
        let message = URLSessionWebSocketTask.Message.string(response)
        
        self.node.sendUpdate(msg: message)
        
    }
    
    /// Pauses or resumes a song currently playing
    open func pause(status: Bool) {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let object = musicControls(op: "pause", guildId: self.guildID, pause: status)
        
        let JSON = try? encoder.encode(object)
        
        let response = String(data: JSON!, encoding: .utf8)!
        
        let message = URLSessionWebSocketTask.Message.string(response)
        
        self.node.sendUpdate(msg: message)
        
        if (status == true) {
            logger.log(level: .info, .init(stringLiteral: "Playback paused on Guild \(self.guildID)"))
        } else if (status == false){
            logger.log(level: .info, .init(stringLiteral: "Playback resumed on Guild \(self.guildID)"))
        }
        
    }
    
    /// Sends the Voice Server Update payload to Lavalink
    open func handleVoiceServer(msg: URLSessionWebSocketTask.Message) {
        
        self.node.ws?.send(msg, completionHandler: { _ in (); logger.log(level: .info, .init(stringLiteral: "Sent the voice server update to Lavalink.")) })
        
    }
    
    /// Sends the Voice State Update payload to Lavalink
    open func handleVoiceState(msg: URLSessionWebSocketTask.Message) {
        
        self.node.ws?.send(msg, completionHandler: { _ in (); logger.log(level: .info, .init(stringLiteral: "Sent the voice state update to Lavalink.")) })
        
    }
}

