//
//  Structures.swift
//  SwiftyLink
//
//  Created by TotallyNotNero on 9/1/21.
//

import Foundation

/// Represents the Lavalink REST response.
public struct lavalinkREST: Decodable {
    /// The type of payload recieved.
    public let loadType: String
    /// The tracks resolved from the REST API.
    public let tracks: [trackResponse]
}

/// Represents a track resolved from Lavalink.
public struct trackResponse: Decodable {
    /// The base64 lavalink track string.
    public let track: String
    /// The track's info.
    public let info: infoResponse
}

/// Represents the info from the track selected.
public struct infoResponse: Decodable {
    /// The track's identifier.
    public let identifier: String
    /// If this track is seekable.
    public let isSeekable: Bool
    /// The author listed for the resolved track.
    public let author: String
    /// The length of the track.
    public let length: Int
    /// If this track is a stream.
    public let isStream: Bool
    /// The position in the queue.
    public let position: Int
    /// The title of the resolved track.
    public let title: String
    /// The URL of the track.
    public let uri: String
}

/// Represents the play object Lavalink uses to queue a track.
public struct trackPlay: Encodable {
    /// The op code of the JSON.
    public let op: String
    /// The base64 string of the track.
    public let track: String
    /// The Guild ID the player is connected on.
    public let guildId: String
}

/// Represents a stop object to stop the player.
public struct stopPlayer: Encodable {
    /// The op code of the JSON.
    public let op: String
    /// The guild ID of the player.
    public let guildId: String
}

/// Represents an object to pause or resume the player.
public struct musicControls: Encodable {
    /// The op code of the JSON.
    public let op: String
    /// The guild ID of the player.
    public let guildId: String
    /// Whether the player is paused or not.
    public let pause: Bool
}

/// Represents an object to seek the player.
public struct seekPlayer: Decodable {
    /// The op code of the JSON.
    public let op: String
    /// The Guild ID of the player.
    public let guildId: String
    /// The position to seek to.
    public let position: String
}

/// Represents the stats JSON Lavalink sends
public struct statResponse: Decodable {
    /// The number of players currently deployed and playing.
    public let playingPlayers: Int
    /// The op code of the JSON.
    public let op: String
    /// The current memory statistics.
    public let memory: memoryResponse
    /// The number of players currently deployed.
    public let players: Int
    /// The current CPU statistics.
    public let cpu: cpuResponse
    /// The uptime of the connection.
    public let uptime: Int
}

/// Represents the memory statistics object.
public struct memoryResponse: Decodable {
    /// The amount of memory that can be reserved.
    public let reservable: Int
    /// The used memory.
    public let used: Int
    /// The amount of free memory.
    public let free: Int
    /// The amount of memory currently allocated to Lavalink.
    public let allocated: Int
}

/// Represents the CPU statistics object.
public struct cpuResponse: Decodable {
    /// The total cores of the CPU
    public let cores: Int
    /// The overall load of the system
    public let systemLoad: Int
    /// The load Lavalink is taking up.
    public let lavalinkLoad: Int
}

/// Represents the TrackEndEvent payload.
public struct trackEndEvent: Decodable {
    /// The op code of the JSON.
    public let op: String
    /// The reason for the stopped track.
    public let reason: String
    /// The type of event
    public let type: String
    /// The base64 track that was stopped.
    public let track: String
    /// The ID of the guild.
    public let guildId: String
}

extension Dictionary {
    /// Fetches a value for the given key
    public func get(i: Key) -> Value {
        return self[i]!
    }
    
}

/// Handles the statistics JSON data
/// - parameter d: The JSON recieved
public func handleStatResponse(d: Data) ->  statResponse {
    
    let rest: statResponse = try! JSONDecoder().decode(statResponse.self, from: d)
    
    return rest
    
}

/// Handles the trackEndEvent JSON data
/// - parameter d: The JSON recieved
public func handleEndResponse(d: [String : String]) ->  trackEndEvent {
    
    let data = try! JSONSerialization.data(withJSONObject: d)
    
    let rest: trackEndEvent = try! JSONDecoder().decode(trackEndEvent.self, from: data)
    
    return rest
    
}

/// Handles a normal JSON event
/// - parameter d: The JSON recieved
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

/// Represents the most basic event.
struct basicEvent: Decodable {
    /// The op code of the event.
    public let op: String
    /// The type of the event.
    public let type: String?
    /// The reason the event was emitted.
    public let reason: String?
}
