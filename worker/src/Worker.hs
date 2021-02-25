{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module Worker where

import Control.Concurrent
import Control.Concurrent.Async
import qualified Data.ByteString.Lazy.Char8 as BL
import Network.AMQP
import Network.AMQP.Generated
import Network.AMQP.Internal
import Network.AMQP.Protocol
import Network.AMQP.Types

worker :: IO ()
worker = do
  putStrLn "starting worker."
  conn <- openConnection "127.0.0.1" "/" "guest" "guest"
  chan <- openChannel conn

  -- declare a queue, exchange and binding
  declareQueue chan newQueue {queueName = "myQueue"}
  declareExchange chan newExchange {exchangeName = "myExchange", exchangeType = "direct"}
  bindQueue chan "myQueue" "myExchange" "myKey"

  closedVar <- newEmptyMVar
  addConnectionClosedHandler conn True (putMVar closedVar ())

  -- subscribe to the queue
  let myCallback (message, envelope) = do
        putStrLn $ "received message: " ++ (BL.unpack $ msgBody message)
        ackEnv envelope -- acknowledge receiving the message
  consumeMsgs chan "myQueue" Ack myCallback

  putStrLn "worker listening."

  let putDangerousMessageOnOwnQueue = do
        writeChan
          (inQueue chan)
          HeartbeatPayload

  concurrently_
    putDangerousMessageOnOwnQueue
    (takeMVar closedVar)

  closeConnection conn
  putStrLn "worker done."
