module Handler.ListShoes where

import           Import

getListShoesR :: Handler Html
getListShoesR = do
   pics <- runDB $ selectList [] [Desc ShoeDescId]
   defaultLayout $ $(widgetFile "list_shoes")
