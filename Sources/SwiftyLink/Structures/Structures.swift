//
//  Structures.swift
//  SwiftyLink
//
//  Created by TotallyNotNero on 9/1/21.
//

import Foundation

/// Represents the Lavalink REST response
public struct lavalinkREST: Decodable {
    /// The type of payload recieved
    public let loadType: String
    /// The tracks resolved from the REST API
    public let tracks: [trackResponse]
}

/// Represents a track resolved from Lavalink
public struct trackResponse: Decodable {
    /// The base64 lavalink track string
    public let track: String
    /// The track's info
    public let info: infoResponse
}

/// Represents the info from the track selected
public struct infoResponse: Decodable {
    /// The track's identifier
    public let identifier: String
    /// If this track is seekable
    public let isSeekable: Bool
    /// The author listed for the resolved track
    public let author: String
    /// The length of the track
    public let length: Int
    /// If this track is a stream
    public let isStream: Bool
    /// The position in the queue
    public let position: Int
    /// The title of the resolved track
    public let title: String
    /// The URL of the track
    public let uri: String
}

/// Represents the play object Lavalink uses to queue a track
public struct trackPlay: Encodable {
    /// The op-code of the JSON
    public let op: String
    /// The base64 string of the track
    public let track: String
    /// The Guild ID the player is connected on
    public let guildId: String
}

/// Represents a stop object to stop the player
public struct stopPlayer: Encodable {
    /// The op-code of the JSON
    public let op: String
    /// The guild ID of the player
    public let guildId: String
}

/// Represents an object to pause or resume the player
public struct musicControls: Encodable {
    /// The op code of the JSON
    public let op: String
    /// The guild ID of the player
    public let guildId: String
    /// Whether the player is paused or not
    public let pause: Bool
}

/// Represents an object to seek the player
public struct seekPlayer: Decodable {
    /// The op code of the JSON
    public let op: String
    /// The Guild ID of the player
    public let guildId: String
    /// The position to seek to
    public let position: String
}

public struct statResponse: Decodable {
    public let playingPlayers: Int
    public let op: String
    public let memory: memoryResponse
    public let players: Int
    public let cpu: cpuResponse
    public let uptime: Int
}

public struct memoryResponse: Decodable {
    public let reservable: Int
    public let used: Int
    public let free: Int
    public let allocated: Int
}

public struct cpuResponse: Decodable {
    public let cores: Int
    public let systemLoad: Int
    public let lavalinkLoad: Int
}

public struct trackEndEvent: Decodable {
    public let op: String
    public let reason: String
    public let type: String
    public let track: String
    public let guildId: String
}

extension Dictionary {
    /// Fetches a value for the given key
    public func get(i: Key) -> Value {
        return self[i]!
    }
    
}

public func handleStatResponse(d: Data) ->  statResponse {
    
    let rest: statResponse = try! JSONDecoder().decode(statResponse.self, from: d)
    
    return rest
    
}

public func handleEndResponse(d: [String : String]) ->  trackEndEvent {
    
    let data = try! JSONSerialization.data(withJSONObject: d)
    
    let rest: trackEndEvent = try! JSONDecoder().decode(trackEndEvent.self, from: data)
    
    return rest
    
}

public func handleEvent(d: Data) -> trackEndEvent? {
    
    var rest: basicEvent = try! JSONDecoder().decode(basicEvent.self, from: d)
    
    let op = rest.op
    
    // Commented out the other events for now... I will properly handle them later
    if (op == "stats") { return nil }
    if (op == "playerUpdate") { return nil }
    if (rest.type == "TrackStartEvent") { return nil }
    if (rest.reason == "Disconnected.") { return nil }
    
    let response: trackEndEvent = try! JSONDecoder().decode(trackEndEvent.self, from: d)
    
    return response
    
}

struct basicEvent: Decodable {
    public let op: String
    public let type: String?
    public let reason: String?
}
