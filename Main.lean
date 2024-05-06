import Lake.CLI.Main
open Lake Lean

def main (args : List String) : IO UInt32 := do
  unless args.length == 1 do
    println! "This commands takes exactly one argument: the path to a file containing a list of declarations to check."
    return 1
  let filename : System.FilePath := args[0]!
  unless ← filename.pathExists do
    println! "Could not find declaration list {filename}."
    return 1
  let (elanInstall?, leanInstall?, lakeInstall?) ← findInstall?
  let config ← MonadError.runEIO <| mkLoadConfig { elanInstall?, leanInstall?, lakeInstall? }
  let (ws?, log) ← (loadWorkspace config).captureLog
  log.replay (logger := .stderr)
  let some ws := ws? | return 1
  let imports := ws.root.leanLibs.concatMap (·.config.roots.map fun module => { module })
  let env ← Lean.importModules imports {}
  let mut ok := true
  for line in ← IO.FS.lines filename do
    unless env.contains line.toName do
      println! "{line} is missing"
      ok := false
  return if ok then 0 else 1
