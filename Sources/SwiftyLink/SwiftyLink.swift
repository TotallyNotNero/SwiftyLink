//
//  SwiftyLink.swift
//  SwiftyLink
//
//  Created by TotallyNotNero on 6/19/21.
//

import Foundation
import Logging
import Discord

fileprivate let logger = Logger(label: "SwiftyNode")

/// The basic Lavalink node
open class SwiftyNode {
    
    // MARK: Properties
    
    /// The Hostname of the Lavalink Server
    let host: String

    /// The password of the Lavalink Server
    let password: String

    /// The port of the Lavalink Server
    let port: String

    /// The User ID of your Discord Bot
    let ID: String

    /// The Number of Shards your Bot is currently operating on
    let shards: String
    
    /// The underlying WebSocket connection
    var ws: URLSessionWebSocketTask?
    
    /// A collection of players, mapped by their Guild IDs
    var players = [String: Player]()
    
    /// The client responsible for this node
    let client: DiscordClient

    // MARK: Initializers
    
    ///
    /// - parameter password: Lavalink password
    /// - parameter port: Lavalink port
    /// - parameter ID: Client ID
    /// - parameter shards: Number of shards your client is operating on.
    /// - parameter password: Lavalink password
    ///
    public required init(password: String, port: String, ID: String, shards: String, host: String, client: DiscordClient) {
        self.password = password
        self.port = port
        self.shards = shards
        self.ID = ID
        self.host = host
        self.client = client
        self.ws = nil
    }
    
    // MARK: Methods
    
    ///
    /// Connects to the Lavalink server
    ///
    open func connect() {
    
        let URL = URL(string: "ws://\(host):\(port)/")!
        var Request = URLRequest(url: URL)

        Request.addValue(password, forHTTPHeaderField: "Authorization")
        Request.addValue(shards, forHTTPHeaderField: "Num-Shards")
        Request.addValue(ID, forHTTPHeaderField: "User-Id")
        Request.addValue("SwiftyLink", forHTTPHeaderField: "Client-Name")

        let Session = URLSession(configuration: .ephemeral)
        self.ws = Session.webSocketTask(with: Request)
        
        self.ws?.resume()
        
        logger.log(level: .info, .init(stringLiteral: "Successfully initiated a connection to Lavalink."))
    
    }
    
    /// Destroys the active connection to Lavalink.
    open func destroy() {
        let state = self.ws?.state
        if (state == .canceling) { return }
        
        logger.log(level: .warning, .init(stringLiteral: "Destroying the active websocket connection to Lavalink."))
        
        self.ws?.cancel()
    }
    
    /// Helper method for sending messages to Lavalink.
    /// - parameter msg: The message to send to Lavalink. MUST be a string initiated from the WebSocketTask.Message enum.
    open func sendUpdate(msg: URLSessionWebSocketTask.Message) {

        self.ws?.send(msg, completionHandler: { _ in (); logger.log(level: .info, .init(stringLiteral: "Sent the requested message to Lavalink.")) })
        
    }
    
    open func recieveMessage()  {
        self.ws!.receive { result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text message: \(text)")
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
                self.recieveMessage()
            }
        }
    }
    
    open func createPlayer(guild: String) -> Player {
        
        var player = self.players[guild]
        
        if ((player == nil)) {
            player = Player(guild: guild, node: self, client: client)
            self.players[guild] = player!
            logger.log(level: .info, .init(stringLiteral: "Created a new player"), metadata: nil)
        }
        
        return player!
        
        logger.log(level: .info, .init(stringLiteral: "Returned an existing player"), metadata: nil)
        
    }
}
