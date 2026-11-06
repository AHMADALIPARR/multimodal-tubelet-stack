-- Lean 4 library of the Agda invariants as lemmas (zero sorry)
import Lake
open Lake DSL

package «multimodal-tubelets» where
  -- no external dependencies

@[default_target]
lean_lib Multimodal where
  srcDir := "Multimodal"
