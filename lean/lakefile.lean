-- Lean 4 library of the Agda invariants as lemmas (zero sorry)
-- Copyright (C) 2026 AHMAD ALI PARR
-- Licensed under the GNU Affero General Public License v3.0 or later.
-- See LICENSE for the full text.

import Lake
open Lake DSL

package «multimodal-tubelets» where
  -- no external dependencies

@[default_target]
lean_lib Multimodal where
  srcDir := "Multimodal"
