module Handler.UploadPic where

import           DataStructures.Shoes (Shoe)
import           Import
import           Library.PictureStore

postUploadPicR :: Handler Value
postUploadPicR = do
   toJSON <$> (storeShoe =<< (parseJsonBody_ :: Handler Shoe))
