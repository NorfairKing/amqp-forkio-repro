{-# LANGUAGE OverloadedStrings #-}

module Sender where

import Control.Concurrent
import qualified Data.ByteString.Lazy.Char8 as BL
import Network.AMQP
import Network.AMQP.Generated
import Network.AMQP.Internal
import Network.AMQP.Types

sender :: IO ()
sender = do
  putStrLn "starting sender."
  conn <- openConnection "127.0.0.1" "/" "guest" "guest"
  chan <- openChannel conn

  -- declare a queue, exchange and binding
  declareQueue chan newQueue {queueName = "myQueue"}
  declareExchange chan newExchange {exchangeName = "myExchange", exchangeType = "direct"}
  bindQueue chan "myQueue" "myExchange" "myKey"

  putStrLn "Sending two test messages"

  publishMsg
    chan
    "myExchange"
    "myKey"
    newMsg
      { msgBody = (BL.pack "test message 1"),
        msgDeliveryMode = Just Persistent
      }

  publishMsg
    chan
    "myExchange"
    "myKey"
    newMsg
      { msgBody = (BL.pack "test message 2"),
        msgDeliveryMode = Just Persistent
      }
  closeConnection conn
  putStrLn "sender done."
