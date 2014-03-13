-- | Settings are centralized, as much as possible, into this file. This
-- includes database connection settings, static file locations, etc.
-- In addition, you can configure a number of different aspects of Yesod
-- by overriding methods in the Yesod typeclass. That instance is
-- declared in the Foundation.hs file.
module Settings where

import Prelude
import Language.Haskell.TH.Syntax (Q,Exp)
import Database.Persist.Sqlite (SqliteConf)
import Yesod.Default.Util (WidgetFileSettings
                          ,widgetFileReload
                          ,widgetFileNoReload)
import Settings.Development
import Data.Default (def)

-- | Which Persistent backend this site is using.
type PersistConf = SqliteConf

widgetFileSettings :: WidgetFileSettings
widgetFileSettings = def

widgetFile :: String -> Q Exp
widgetFile = (if development then widgetFileReload
                             else widgetFileNoReload)
              widgetFileSettings

