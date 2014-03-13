module Foundation where

import           Prelude
import           Yesod
import           Model
import           Yesod.Default.Config
import           Network.HTTP.Conduit (Manager)
import qualified Settings
import qualified Database.Persist
import           Database.Persist.Sql (SqlPersistT)

-- | The site argument for your application. This can be a good place to
-- keep settings and values requiring initialization before your application
-- starts running, such as database connections. Every handler will have
-- access to the data present here.
data App = App
   { settings :: AppConfig DefaultEnv () 
   , connPool :: Database.Persist.PersistConfigPool Settings.PersistConf 
   , httpManager :: Manager
   , persistConfig :: Settings.PersistConf}

-- Set up i18n messages. See the message folder.
mkMessage "App" "messages" "en"

-- This is where we define all of the routes in our application. For a full
-- explanation of the syntax, please see:
-- http://www.yesodweb.com/book/routing-and-handlers
--
-- Note that this is really half the story; in Application.hs, mkYesodDispatch
-- generates the rest of the code. Please see the linked documentation for an
-- explanation for this split.
mkYesodData "App" $(parseRoutesFile "config/routes")


-- Please see the documentation for the Yesod typeclass. There are a number
-- of settings which can be configured by overriding methods here.
instance Yesod App where
    approot = ApprootMaster $ appRoot . settings


-- How to run database actions.
instance YesodPersist App where
    type YesodPersistBackend App = SqlPersistT
    runDB = defaultRunDB persistConfig connPool
instance YesodPersistRunner App where
    getDBRunner = defaultGetDBRunner connPool


-- This instance is required to use forms. You can modify renderMessage to
-- achieve customized and internationalized form validation messages.
instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage
