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
public struct seekPlayer: Encodable {
    /// The op code of the JSON
    public let op: String
    /// The Guild ID of the player
    public let guildId: String
    /// The position to seek to
    public let position: String
}
