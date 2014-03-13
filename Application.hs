{-# OPTIONS_GHC -fno-warn-orphans #-}
module Application
    ( makeApplication
    , getApplicationDev
    , makeFoundation
    ) where

import qualified Database.Persist        as DP
import           Database.Persist.Sqlite
import           Import
import           Network.HTTP.Conduit    (conduitManagerSettings, newManager)
import           Settings                (PersistConf)
import           Yesod.Default.Config
import           Yesod.Default.Main      (defaultDevelApp)

import           Handler.DisplayShoe
import           Handler.ListShoes
import           Handler.UploadPic
import           System.Directory (createDirectoryIfMissing)
-- This line actually creates our YesodDispatch instance. It is the second half
-- of the call to mkYesodData which occurs in Foundation.hs. Please see the
-- comments there for more details.
mkYesodDispatch "App" resourcesApp

-- This function allocates resources (such as a database connection pool),
-- performs initialization and creates a WAI application. This is also the
-- place to put your migrate statements to have automatic database
-- migrations handled by Yesod.
makeApplication :: AppConfig DefaultEnv () -> IO Application
makeApplication conf =
    toWaiAppPlain =<< makeFoundation conf

-- | Loads up any necessary settings, creates your foundation datatype, and
-- performs some initialization.
makeFoundation :: AppConfig DefaultEnv () -> IO App
makeFoundation conf = do
    manager <- newManager conduitManagerSettings
    dbconf  <- withYamlEnvironment "config/sqlite.yml" (appEnv conf)
               DP.loadConfig >>=
               DP.applyEnv
    pool    <- DP.createPoolConfig (dbconf :: Settings.PersistConf)
    createDirectoryIfMissing False "data"
    runSqlPersistMPool (runMigration migrateAll) pool
    createDirectoryIfMissing False "data/pics"
    return $ App conf pool manager dbconf
          
              
-- for yesod devel
getApplicationDev :: IO (Int, Application)
getApplicationDev =
    defaultDevelApp loader makeApplication
  where
    loader = Yesod.Default.Config.loadConfig (configSettings Development)
--        { csParseExtra = parseExtra
--        }
