cask "freeflow" do
  version "1.1.0"
  sha256 "eec643d2600d15d09b3de85295ffc39c822b4b7efc16a1ed14a5146417e265b1"

  url "https://github.com/zachlatta/freeflow/releases/download/v#{version}/FreeFlow.dmg"
  name "FreeFlow"
  desc "Voice dictation app, alternative to WisprFlow"
  homepage "https://github.com/zachlatta/freeflow"

  app "FreeFlow.app"
end
