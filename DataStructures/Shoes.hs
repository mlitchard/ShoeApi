module DataStructures.Shoes
   (Color
   ,Photo64 (..)
   ,Shoe (..)
   ,StoreError (..)
   ,StoreResult (..)) where

import           Data.Aeson
import qualified Data.Text           as T
import           Data.Word
import           Database.Persist.TH (derivePersistField)
import           GHC.Generics
import           Prelude
data Color = Red
           | Orange
           | Yellow
           | Green
           | Blue
           | Indigo
           | Violet
              deriving (Read,Show,Generic)

derivePersistField "Color"

data PostError = PostFailed String deriving (Show,Generic)
data Shoe = Shoe
   {description_ :: T.Text
   ,color_       :: Color
   ,size_        :: T.Text
   ,photo_       :: Photo64}
      deriving (Generic,Show)

newtype Photo64 = Photo64 [Word8] deriving (Generic,Show)

data StoreError = CouldNotWriteToDB
                | CouldNotDecodeJPG
                   deriving (Show,Generic)
data StoreResult = StoredShoeSuccess deriving (Show,Generic)


instance ToJSON Shoe
instance FromJSON Shoe

instance FromJSON Photo64
instance ToJSON Photo64

instance FromJSON Color
instance ToJSON Color

instance FromJSON PostError
instance ToJSON PostError

instance FromJSON StoreError
instance ToJSON StoreError

instance FromJSON StoreResult
instance ToJSON StoreResult
