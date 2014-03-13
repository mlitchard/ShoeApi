{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
import           Control.Applicative
import           Control.Monad
import           Control.Monad.IO.Class    (liftIO)
import           Data.Aeson                (FromJSON, Result, ToJSON,
                                            Value (Object, String), encode,
                                            fromJSON, object, toJSON, (.=))
import qualified Data.ByteString           as B
import qualified Data.ByteString.Base64    as B64
import           Data.Functor
import qualified Data.Text                 as T
import           Data.Word
import           GHC.Generics
import           Prelude

import           Data.Aeson.Parser         (json)
import qualified Data.ByteString.Char8     as C
import           Data.Conduit              (($$+-))
import           Data.Conduit.Attoparsec   (sinkParser)
import           Network.HTTP.Conduit      (Request,
                                            RequestBody (RequestBodyLBS),
                                            Response (..), http, method,
                                            parseUrl, requestBody,
                                            requestHeaders, withManager)
import           Network.HTTP.Types.Header (ResponseHeaders, hContentType)

data Color = Red
           | Orange
           | Yellow
           | Green
           | Blue
           | Indigo
           | Violet
              deriving (Show,Generic)

data Shoe = Shoe
   {description_ :: T.Text
   ,color_       :: Color
   ,size_        :: T.Text
   ,photo_       :: Photo64}
      deriving (Show,Generic)

newtype Photo64 = Photo64 [Word8] deriving (Show,Generic)

data StoreError = CouldnotWrite deriving (Show,Generic)
data StoreResult = StoredShoeSuccess deriving (Show,Generic)

instance ToJSON Shoe
instance FromJSON Shoe

instance FromJSON Photo64
instance ToJSON Photo64

instance FromJSON Color
instance ToJSON Color


instance FromJSON StoreError

instance FromJSON StoreResult

main :: IO ()
main = withManager $ \manager -> do
    shoe_pics <- liftIO $ mapM B.readFile shoe_pics
    req'      <- liftIO $ parseUrl "http://localhost:3000/UploadPic"
    result <- mapM ((`http` manager)  .
              makeRequest req'        .
              encode                  .
              toJSON                  .
              makeShoeRecord)         $
              zip shoe_meta shoe_pics
    mapM_ printResult result
    return ()
    where
       shoe_pics = ["shoe_1.jpg","shoe_2.jpg","shoe_3.jpg"]
       shoe_meta = [Shoe {description_ = "This is a very nice shoe."
                         ,color_       = Red
                         ,size_        = "8"
                         ,photo_       = undefined}
                   ,Shoe {description_ = "This shoe has super powers"
                         ,color_       = Yellow
                         ,size_        = "7"
                         ,photo_       = undefined}
                   ,Shoe {description_ = "This shoe is google-rific"
                         ,color_       = Indigo
                         ,size_        = "6"
                         ,photo_       = undefined}
                   ]
printResult result = do
   resValue <- responseBody result $$+- sinkParser json
   let test = fromJSON resValue :: Result (Either StoreError StoreResult)
   liftIO $ print test
   return ()

makeShoeRecord :: (Shoe,B.ByteString) -> Shoe
makeShoeRecord (shoe_d,pic) = shoe_d {photo_ = e_pic}
   where
      e_pic = Photo64 $ B.unpack $ B64.encode pic

makeRequest req' valueBS =
   req' { method = "POST"
        , requestBody = RequestBodyLBS valueBS
        , requestHeaders = jsonHeaders }
   where
      jsonHeaders = [(hContentType, C.pack "application/json")]

handleResponse :: Value -> IO ()
handleResponse = print
