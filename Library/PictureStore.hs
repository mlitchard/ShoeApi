module Library.PictureStore
   (storeShoe) where

import qualified Data.ByteString        as B
import qualified Data.ByteString.Base64 as B64
import qualified Data.Text              as T
import           DataStructures.Shoes
import           Import

storeShoe :: Shoe -> Handler (Either StoreError StoreResult)
storeShoe (Shoe desc color size (Photo64 photo)) =
   case (tryDecode) of
           Left _        -> return $ Left CouldNotDecodeJPG
           Right picture -> write_files (desc,color,size) picture
   where
      tryDecode = B64.decode $ B.pack photo

write_files :: (Text,Color,Text) ->
               B.ByteString      ->
               Handler (Either StoreError StoreResult)
write_files (desc,color,size) pict  = do
   s_key@(Key val) <- runDB $ insert shoe_data
   case (fromPersistValueText val) of
      (Left _)  ->
         return $ Left CouldNotWriteToDB
      (Right p_key) ->
         (return $ Right StoredShoeSuccess)    <*
         (liftIO $ B.writeFile file_path pict) <*
         (runDB $ insert shoe_file_path)
         where
            shoe_file_path = ShoeFilePath s_key file_path
            file_path      = "data/pics/" ++ f_name
            f_name         = (T.unpack p_key) ++ ".jpg"
   where
      shoe_data = ShoeDesc desc color size
