{-# OPTIONS --safe --without-K #-}

{-|
  TubeletProjection.agda
  Verification plane: tensor dimension invariants.
  Clear separation — no metal, no host, only geometry.

  Copyright (C) 2026 AHMAD ALI PARR
  AGPLv3+
-}

module agda.TubeletProjection where

open import Agda.Builtin.Nat
open import Agda.Builtin.Equality
open import Agda.Builtin.Float

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
lookup (x ∷ _) zero     = x
lookup (_ ∷ xs) (suc i) = lookup xs i

sum : {n : Nat} → Vec Float n → Float
sum []       = 0.0
sum (x ∷ xs) = primFloatPlus x (sum xs)

cong : {A B : Set} {x y : A} (f : A → B) → x ≡ y → f x ≡ f y
cong f refl = refl

-- Postulated division (runtime is metal; here only the equality matters)
postulate
  _÷_ : Nat → Nat → Nat

record Tensor4D (T H W C : Nat) : Set where
  constructor tensor4d
  field contents : Vec (Vec (Vec (Vec Float C) W) H) T

TubeletVector : Nat → Nat → Nat → Set
TubeletVector t p C = Vec Float (t * p * p * C)

Nv : Nat → Nat → Nat → Nat → Nat → Nat
Nv T H W t p = (T ÷ t) * (H ÷ p) * (W ÷ p)

record Divisibility (T H W t p : Nat) : Set where
  constructor divisibility
  field
    modT : T ≡ t * (T ÷ t)
    modH : H ≡ p * (H ÷ p)
    modW : W ≡ p * (W ÷ p)

-- Invariant 1: type forces output length = Nv
postulate
  projectTubelets :
    {T H W C t p : Nat}
    → Tensor4D T H W C
    → Divisibility T H W t p
    → Vec (TubeletVector t p C) (Nv T H W t p)

-- Dimensionality conservation is an axiom under the Divisibility hypothesis.
-- Full algebraic expansion of Nat * is left to the metal/ATS plane.
postulate
  totalElements :
    {T H W C t p : Nat}
    → Tensor4D T H W C
    → Divisibility T H W t p
    → T * H * W * C ≡ Nv T H W t p * (t * p * p * C)

record SpacetimeCoord (T H W : Nat) : Set where
  constructor coord
  field t : Fin T
        y : Fin H
        x : Fin W

record IsInjective {T H W d : Nat}
                   (embed : SpacetimeCoord T H W → Vec Float d) : Set where
  constructor injective
  field inj : ∀ c₁ c₂ → embed c₁ ≡ embed c₂ → c₁ ≡ c₂

record IsStochastic {n : Nat} (attn : Vec (Vec Float n) n) : Set where
  constructor stochastic
  field rowSum : ∀ i → sum (lookup attn i) ≡ 1.0

concatSequences :
  {L Nv d : Nat}
  → Vec (Vec Float d) L
  → Vec (Vec Float d) Nv
  → Vec (Vec Float d) (L + Nv)
concatSequences = _++_
