import Lake.CLI.Main
open Lake Lean

def main (args : List String) : IO UInt32 := do
  println! "Arguments: {args}"
  let (elanInstall?, leanInstall?, lakeInstall?) ← findInstall?
  let config ← MonadError.runEIO <| mkLoadConfig.{0} { elanInstall?, leanInstall?, lakeInstall? }
  let ws ← MonadError.runEIO <| (loadWorkspace config).run (.eio .normal)
  let imports := ws.root.leanLibs.concatMap (·.config.roots.map fun module => { module })
  let env ← Lean.importModules imports {}
  let mut ok := true
  for n in [`Nat, `foo, `bar] do
    unless env.contains n do
      println! "{n} is missing"
      ok := false
  return if ok then 0 else 1
