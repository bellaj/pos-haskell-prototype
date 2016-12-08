-- | Genesis values related to GodTossing SSC.

module Pos.Ssc.GodTossing.Genesis
       ( genesisVssKeyPairs
       , genesisVssPublicKeys
       , genesisCertificates
       ) where

import qualified Data.HashMap.Strict           as HM
import qualified Data.Text                     as T
import           Formatting                    (int, sformat, (%))
import           Universum

import           Pos.Binary.Class              (serialize)
import           Pos.Constants                 (genesisN)
import           Pos.Crypto                    (VssKeyPair, VssPublicKey,
                                                deterministicVssKeyGen, toVssPublicKey)
import           Pos.Genesis                   (genesisKeyPairs)
import           Pos.Ssc.GodTossing.Types.Base (VssCertificatesMap, mkVssCertificate)
import           Pos.Types                     (makePubKeyAddress)

-- | List of 'VssKeyPair' in genesis.
genesisVssKeyPairs :: [VssKeyPair]
genesisVssKeyPairs = map gen [0 .. genesisN - 1]
  where
    gen :: Int -> VssKeyPair
    gen =
        deterministicVssKeyGen .
        encodeUtf8 .
        T.take 32 .
        sformat ("My awesome 32-byte seed :) #" %int % "             ")

-- | List of 'VssPublicKey' in genesis.
genesisVssPublicKeys :: [VssPublicKey]
genesisVssPublicKeys = map toVssPublicKey genesisVssKeyPairs

-- | Certificates in genesis represented as 'VssCertificatesMap'.
genesisCertificates :: VssCertificatesMap
genesisCertificates =
    HM.fromList $
    zipWith
        (\(pk, sk) vssPk -> (makePubKeyAddress pk, mkVssCertificate sk $ serialize vssPk))
        genesisKeyPairs
        genesisVssPublicKeys
