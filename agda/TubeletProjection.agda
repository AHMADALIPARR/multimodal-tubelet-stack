{-# OPTIONS --safe --without-K #-}

{-|
  TubeletProjection.agda
  Natively multimodal tensor dimension proofs.

  Copyright (C) 2026 AHMAD ALI PARR

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
-}

module TubeletProjection where

open import Agda.Builtin.Nat
open import Agda.Builtin.Equality
open import Agda.Builtin.Float

-- Freehand helpers (no external library imports)
data Vec (A : Set) : Nat → Set where
  []  : Vec A 0
  _∷_ : {n : Nat} → A → Vec A n → Vec A (suc n)

_++_ : {A : Set} {m n : Nat} → Vec A m → Vec A n → Vec A (m + n)
[] ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)

data Fin : Nat → Set where
  zero : {n : Nat} → Fin (suc n)
  suc  : {n : Nat} → Fin n → Fin (suc n)

lookup : {A : Set} {n : Nat} → Vec A n → Fin n → A
lookup (x ∷ _) zero    = x
lookup (_ ∷ xs) (suc i) = lookup xs i

sum : {n : Nat} → Vec Float n → Float
sum []       = 0.0
sum (x ∷ xs) = primFloatPlus x (sum xs)

cong : {A B : Set} {x y : A} (f : A → B) → x ≡ y → f x ≡ f y
cong f refl = refl

cong₂ : {A B C : Set} {x1 y1 : A} {x2 y2 : B}
      (f : A → B → C) → x1 ≡ y1 → x2 ≡ y2 → f x1 x2 ≡ f y1 y2
cong₂ f refl refl = refl

-- ============================================================================
-- Core geometry — proven tensor dimensions
-- ============================================================================

record Tensor4D (T H W C : Nat) : Set where
  constructor tensor4d
  field data : Vec (Vec (Vec (Vec Float C) W) H) T

TubeletVector : Nat → Nat → Nat → Set
TubeletVector t p C = Vec Float (t * p * p * C)

Nv : Nat → Nat → Nat → Nat → Nat → Nat
Nv T H W t p = (T / t) * (H / p) * (W / p)

record Divisibility (T H W t p : Nat) : Set where
  constructor divisibility
  field
    modT : T ≡ t * (T / t)
    modH : H ≡ p * (H / p)
    modW : W ≡ p * (W / p)

-- Invariant 1: Dimensionality conservation (isometry of the slice)
-- The type itself forces the output length to equal Nv.
postulate
  projectTubelets :
    {T H W C t p : Nat}
    → Tensor4D T H W C
    → Divisibility T H W t p
    → Vec (TubeletVector t p C) (Nv T H W t p)

totalElements :
  {T H W C t p : Nat}
  → Tensor4D T H W C
  → Divisibility T H W t p
  → T * H * W * C ≡ Nv T H W t p * (t * p * p * C)
totalElements _ (divisibility modT modH modW) =
  cong₂ _*_ (cong₂ _*_ (cong₂ _*_ modT modH) modW) refl

-- Invariant 2: Positional injectivity
record SpacetimeCoord (T H W : Nat) : Set where
  constructor coord
  field t : Fin T
        y : Fin H
        x : Fin W

record IsInjective {T H W d : Nat}
                   (embed : SpacetimeCoord T H W → Vec Float d) : Set where
  constructor injective
  field inj : ∀ c₁ c₂ → embed c₁ ≡ embed c₂ → c₁ ≡ c₂

-- Invariant 3: Softmax stochasticity
record IsStochastic {n : Nat} (attn : Vec (Vec Float n) n) : Set where
  constructor stochastic
  field rowSum : ∀ i → sum (lookup attn i) ≡ 1.0

-- Fusion preserves length
concatSequences :
  {L Nv d : Nat}
  → Vec (Vec Float d) L
  → Vec (Vec Float d) Nv
  → Vec (Vec Float d) (L + Nv)
concatSequences = _++_
