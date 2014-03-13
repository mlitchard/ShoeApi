module Handler.DisplayShoe where

import           Import

getDisplayShoeR :: ShoeDescId -> Handler Html
getDisplayShoeR sm_id = do
   (Entity _ sfp) <- runDB $ getBy404 $ UniqueShoeId sm_id
   (Just meta)    <- runDB $ get sm_id
   defaultLayout $ $(widgetFile "display_shoe")
