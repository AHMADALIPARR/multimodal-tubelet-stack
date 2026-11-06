-- Lean 4 library of the Agda invariants as lemmas (zero sorry)
-- Copyright (C) 2026 AHMAD ALI PARR
-- AGPLv3+

import Lake
open Lake DSL

package «multimodal-tubelets» where

@[default_target]
lean_lib Multimodal where
  roots := #[`Multimodal.Tubelets]
  srcDir := "."
