{-# LANGUAGE ScopedTypeVariables #-}

-- | Command line options of pos-node.

module NodeOptions
       ( Args (..)
       , argsParser
       ) where

import           Control.TimeWarp.Logging   (Severity (Debug, Info))
import           Data.Monoid                ((<>))
import           Options.Applicative.Simple (Parser, auto, help, long, many, metavar,
                                             option, showDefault, strOption, switch,
                                             value)
import           Serokell.Util.OptParse     (fromParsec)
import           Universum                  hiding ((<>))

import           Pos.CLI                    (dhtKeyParser, dhtNodeParser)
import           Pos.DHT                    (DHTKey, DHTNode)

data Args = Args
    { dbPath             :: !FilePath
    , rebuildDB          :: !Bool
    , spendingGenesisI   :: !(Maybe Int)
    , vssGenesisI        :: !(Maybe Int)
    , spendingSecretPath :: !(Maybe FilePath)
    , vssSecretPath      :: !(Maybe FilePath)
    , port               :: !Word16
    , pettyUtxo          :: !Bool
    , flatDistr          :: !(Maybe (Int, Int))
    , bitcoinDistr       :: !(Maybe (Int, Int))
    , dhtPeers           :: ![DHTNode]
    , supporterNode      :: !Bool
    , dhtKey             :: !(Maybe DHTKey)
    , mainLogSeverity    :: !Severity
    , dhtLogSeverity     :: !Severity
    , commLogSeverity    :: !(Maybe Severity)
    , serverLogSeverity  :: !(Maybe Severity)
    , timeLord           :: !Bool
    , dhtExplicitInitial :: !Bool
    , enableStats        :: !Bool
    }
  deriving Show

argsParser :: Parser Args
argsParser =
    Args <$>
    strOption
        (long "db-path" <> metavar "FILEPATH" <> value "node-db" <>
         help "Path to the node database") <*>
    switch
        (long "rebuild-db" <>
         help
             "If we DB already exist, discard it's contents and create new one from scratch") <*>
    optional
        (option
             auto
             (long "spending-genesis" <> metavar "INT" <>
              help "Use genesis spending #i")) <*>
    optional
        (option
             auto
             (long "vss-genesis" <> metavar "INT" <> help "Use genesis vss #i")) <*>
    optional
        (strOption
             (long "spending-sk" <> metavar "FILEPATH" <>
              help "Path to spending secret key")) <*>
    optional
        (strOption
             (long "vss-sk" <> metavar "FILEPATH" <>
              help "Path to VSS secret key")) <*>
    option
        auto
        (long "port" <> metavar "INTEGER" <> value 3000 <> showDefault <>
         help "Port to work on") <*>
    switch
        (long "petty-utxo" <>
         help "Petty utxo (1 coin per transaction, many txs)") <*>
    optional
        (option auto $
         mconcat
             [ long "flat-distr"
             , metavar "(INT,INT)"
             , help
                   "Use flat stake distribution with given parameters (nodes, coins)"
             ]) <*>
    optional
        (option auto $
         mconcat
             [ long "bitcoin-distr"
             , metavar "(INT,INT)"
             , help
                   "Use bitcoin stake distribution with given parameters (nodes, coins)"
             ]) <*>
    many
        (option (fromParsec dhtNodeParser) $
         long "peer" <> metavar "HOST:PORT/HOST_ID" <> help peerHelpMsg) <*>
    switch
        (long "supporter" <> help "Launch DHT supporter instead of full node") <*>
    optional
        (option (fromParsec dhtKeyParser) $
         long "dht-key" <> metavar "HOST_ID" <> help "DHT key in base64-url") <*>
    option
        auto
        (long "main-log" <> metavar "SEVERITY" <> value Debug <> showDefault <>
         help "Main log severity, one of Info, Debug, Warning, Error") <*>
    option
        auto
        (long "dht-log" <> metavar "SEVERITY" <> value Info <> showDefault <>
         help "DHT log severity, one of Info, Debug, Warning, Error") <*>
    optional
        (option auto $
         mconcat
             [ long "comm-log"
             , metavar "SEVERITY"
             , help "Comm (time-warp) log severity"
             ]) <*>
    optional
        (option auto $
         mconcat
             [long "server-log", metavar "SEVERITY", help "Server log severity"]) <*>
    switch
        (long "time-lord" <>
         help
             "Peer is time lord, i.e. one responsible for system start time decision & propagation (used only in development)") <*>
    switch
        (long "explicit-initial" <>
         help
             "Explicitely contact to initial peers as to neighbors (even if they appeared offline once)") <*>
    switch (long "stats" <> help "Enable stats logging")
  where
    peerHelpMsg =
        "Peer to connect to for initial peer discovery. Format example: \"localhost:1234/MHdtsP-oPf7UWly7QuXnLK5RDB8=\""