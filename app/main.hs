import Prelude              (IO)
import Yesod.Default.Config (fromArgs,loadDevelopmentConfig)
import Yesod.Default.Main   (defaultMain)
import Application          (makeApplication)

main :: IO ()
main = defaultMain loadDevelopmentConfig makeApplication
