/-
Copyright (c) 2020 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot, Eric Wieser
Ported by: Jon Eugster

! This file was ported from Lean 3 source module data.pi.algebra
! leanprover-community/mathlib commit 70d50ecfd4900dd6d328da39ab7ebd516abe4025
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Algebra.Group.Defs
import Mathlib.Data.Prod.Basic
import Mathlib.Logic.Unique
import Mathlib.Data.Sum.Basic
import Mathlib.Tactic.Classical

/-!
# Instances and theorems on pi types

This file provides basic definitions and notation instances for Pi types.

Instances of more sophisticated classes are defined in `Pi.lean` files elsewhere.
-/

open Function

universe u v₁ v₂ v₃

variable {I : Type u}

-- The indexing type
variable {α β γ : Type _}

-- The families of types already equipped with instances
variable {f : I → Type v₁} {g : I → Type v₂} {h : I → Type v₃}

variable (x y : ∀ i, f i) (i : I)

namespace Pi

/-! `1`, `0`, `+`, `*`, `+ᵥ`, `•`, `^`, `-`, `⁻¹`, and `/` are defined pointwise. -/

@[to_additive]
instance instOne [∀ i, One <| f i] : One (∀ i : I, f i) :=
  ⟨fun _ => 1⟩

#align pi.has_one Pi.instOne
#align pi.has_zero Pi.instZero

@[to_additive (attr := simp)]
theorem one_apply [∀ i, One <| f i] : (1 : ∀ i, f i) i = 1 :=
  rfl

@[to_additive]
theorem one_def [∀ i, One <| f i] : (1 : ∀ i, f i) = fun _ => 1 :=
  rfl

@[to_additive (attr := simp)]
theorem const_one [One β] : const α (1 : β) = 1 :=
  rfl

@[to_additive (attr := simp)]
theorem one_comp [One γ] (x : α → β) : (1 : β → γ) ∘ x = 1 :=
  rfl

@[to_additive (attr := simp)]
theorem comp_one [One β] (x : β → γ) : x ∘ (1 : α → β) = const α (x 1) :=
  rfl

@[to_additive]
instance instMul [∀ i, Mul <| f i] : Mul (∀ i : I, f i) :=
  ⟨fun f g i => f i * g i⟩

#align pi.has_mul Pi.instMul
#align pi.has_add Pi.instAdd

@[to_additive (attr := simp)]
theorem mul_apply [∀ i, Mul <| f i] : (x * y) i = x i * y i :=
  rfl

@[to_additive]
theorem mul_def [∀ i, Mul <| f i] : x * y = fun i => x i * y i :=
  rfl

@[to_additive (attr := simp)]
theorem const_mul [Mul β] (a b : β) : const α a * const α b = const α (a * b) :=
  rfl

@[to_additive]
theorem mul_comp [Mul γ] (x y : β → γ) (z : α → β) : (x * y) ∘ z = x ∘ z * y ∘ z :=
  rfl

@[to_additive]
instance instSMul [∀ i, SMul α <| f i] : SMul α (∀ i : I, f i) :=
  ⟨fun s x => fun i => s • x i⟩

#align pi.has_smul Pi.instSMul
#align pi.has_vadd Pi.instVAdd

@[to_additive]
instance instPow [∀ i, Pow (f i) β] : Pow (∀ i, f i) β :=
  ⟨fun x b i => x i ^ b⟩

@[to_additive (attr := simp) (reorder := 5)]
theorem pow_apply [∀ i, Pow (f i) β] (x : ∀ i, f i) (b : β) (i : I) : (x ^ b) i = x i ^ b :=
  rfl

@[to_additive (reorder := 5)]
theorem pow_def [∀ i, Pow (f i) β] (x : ∀ i, f i) (b : β) : x ^ b = fun i => x i ^ b :=
  rfl

-- `to_additive` generates bad output if we take `Pow α β`.
@[to_additive (attr := simp) (reorder := 5) smul_const]
theorem const_pow [Pow β α] (b : β) (a : α) : const I b ^ a = const I (b ^ a) :=
  rfl

@[to_additive (reorder := 6)]
theorem pow_comp [Pow γ α] (x : β → γ) (a : α) (y : I → β) : (x ^ a) ∘ y = x ∘ y ^ a :=
  rfl

attribute [to_additive] smul_apply smul_def smul_const smul_comp

/-!
Porting note: `bit0` and `bit1` are deprecated. This section can be removed entirely
(without replacement?).
-/
section deprecated

set_option linter.deprecated false

@[simp, deprecated]
theorem bit0_apply [∀ i, Add <| f i] : (bit0 x) i = bit0 (x i) :=
  rfl

@[simp, deprecated]
theorem bit1_apply [∀ i, Add <| f i] [∀ i, One <| f i] : (bit1 x) i = bit1 (x i) :=
  rfl

end deprecated

@[to_additive]
instance instInv [∀ i, Inv <| f i] : Inv (∀ i : I, f i) :=
  ⟨fun f i => (f i)⁻¹⟩

#align pi.has_inv Pi.instInv
#align pi.has_neg Pi.instNeg

@[to_additive (attr := simp)]
theorem inv_apply [∀ i, Inv <| f i] : x⁻¹ i = (x i)⁻¹ :=
  rfl

@[to_additive]
theorem inv_def [∀ i, Inv <| f i] : x⁻¹ = fun i => (x i)⁻¹ :=
  rfl

@[to_additive]
theorem const_inv [Inv β] (a : β) : (const α a)⁻¹ = const α a⁻¹ :=
  rfl

@[to_additive]
theorem inv_comp [Inv γ] (x : β → γ) (y : α → β) : x⁻¹ ∘ y = (x ∘ y)⁻¹ :=
  rfl

@[to_additive]
instance instDiv [∀ i, Div <| f i] : Div (∀ i : I, f i) :=
  ⟨fun f g i => f i / g i⟩

#align pi.has_div Pi.instDiv
#align pi.has_sub Pi.instSub

@[to_additive (attr := simp)]
theorem div_apply [∀ i, Div <| f i] : (x / y) i = x i / y i :=
  rfl

@[to_additive]
theorem div_def [∀ i, Div <| f i] : x / y = fun i => x i / y i :=
  rfl

@[to_additive]
theorem div_comp [Div γ] (x y : β → γ) (z : α → β) : (x / y) ∘ z = x ∘ z / y ∘ z :=
  rfl

@[to_additive (attr := simp)]
theorem const_div [Div β] (a b : β) : const α a / const α b = const α (a / b) :=
  rfl

section

variable [DecidableEq I]

variable [∀ i, One (f i)] [∀ i, One (g i)] [∀ i, One (h i)]

/-- The function supported at `i`, with value `x` there, and `1` elsewhere. -/
@[to_additive "The function supported at `i`, with value `x` there, and `0` elsewhere."]
def mulSingle (i : I) (x : f i) : ∀ (j : I), f j :=
  Function.update 1 i x

#align pi.mul_single Pi.mulSingle
#align pi.single Pi.single

@[to_additive (attr := simp)]
theorem mulSingle_eq_same (i : I) (x : f i) : mulSingle i x i = x :=
  Function.update_same i x _

#align pi.mul_single_eq_same Pi.mulSingle_eq_same
#align pi.single_eq_same Pi.single_eq_same

@[to_additive (attr := simp)]
theorem mulSingle_eq_of_ne {i i' : I} (h : i' ≠ i) (x : f i) : mulSingle i x i' = 1 :=
  Function.update_noteq h x _

#align pi.mul_single_eq_of_ne Pi.mulSingle_eq_of_ne
#align pi.single_eq_of_ne Pi.single_eq_of_ne

/-- Abbreviation for `mulSingle_eq_of_ne h.symm`, for ease of use by `simp`. -/
@[to_additive (attr := simp)
  "Abbreviation for `single_eq_of_ne h.symm`, for ease of use by `simp`."]
theorem mulSingle_eq_of_ne' {i i' : I} (h : i ≠ i') (x : f i) : mulSingle i x i' = 1 :=
  mulSingle_eq_of_ne h.symm x

#align pi.mul_single_eq_of_ne' Pi.mulSingle_eq_of_ne'
#align pi.single_eq_of_ne' Pi.single_eq_of_ne'

@[to_additive (attr := simp)]
theorem mulSingle_one (i : I) : mulSingle i (1 : f i) = 1 :=
  Function.update_eq_self _ _

#align pi.mul_single_one Pi.mulSingle_one
#align pi.single_zero Pi.single_zero

-- Porting notes:
-- 1) Why do I have to specify the type of `mulSingle i x` explicitly?
-- 2) Why do I have to specify the type of `(1 : I → β)`?
-- 3) Removed `{β : Sort _}` as `[One β]` converts it to a type anyways.
/-- On non-dependent functions, `Pi.mulSingle` can be expressed as an `ite` -/
@[to_additive "On non-dependent functions, `Pi.single` can be expressed as an `ite`"]
theorem mulSingle_apply [One β] (i : I) (x : β) (i' : I) :
    (mulSingle i x : I → β) i' = if i' = i then x else 1 :=
  Function.update_apply (1 : I → β) i x i'

#align pi.mul_single_apply Pi.mulSingle_apply
#align pi.single_apply Pi.single_apply

-- Porting notes : Same as above.
/-- On non-dependent functions, `Pi.mulSingle` is symmetric in the two indices. -/
@[to_additive "On non-dependent functions, `Pi.single` is symmetric in the two indices."]
theorem mulSingle_comm [One β] (i : I) (x : β) (i' : I) :
    (mulSingle i x : I → β) i' = (mulSingle i' x : I → β) i := by
  simp [mulSingle_apply, eq_comm]

#align pi.mul_single_comm Pi.mulSingle_comm
#align pi.single_comm Pi.single_comm

@[to_additive]
theorem apply_mulSingle (f' : ∀ i, f i → g i) (hf' : ∀ i, f' i 1 = 1) (i : I) (x : f i) (j : I) :
    f' j (mulSingle i x j) = mulSingle i (f' i x) j := by
  simpa only [Pi.one_apply, hf', mulSingle] using Function.apply_update f' 1 i x j

#align pi.apply_mul_single Pi.apply_mulSingle
#align pi.apply_single Pi.apply_single

@[to_additive apply_single₂]
theorem apply_mulSingle₂ (f' : ∀ i, f i → g i → h i) (hf' : ∀ i, f' i 1 1 = 1) (i : I)
    (x : f i) (y : g i) (j : I) :
    f' j (mulSingle i x j) (mulSingle i y j) = mulSingle i (f' i x y) j := by
  by_cases h : j = i
  · subst h
    simp only [mulSingle_eq_same]
  · simp only [mulSingle_eq_of_ne h, hf']

#align pi.apply_mul_single₂ Pi.apply_mulSingle₂
#align pi.apply_single₂ Pi.apply_single₂

@[to_additive]
theorem mulSingle_op {g : I → Type _} [∀ i, One (g i)] (op : ∀ i, f i → g i)
    (h : ∀ i, op i 1 = 1) (i : I) (x : f i) :
    mulSingle i (op i x) = fun j => op j (mulSingle i x j) :=
  Eq.symm <| funext <| apply_mulSingle op h i x

#align pi.mul_single_op Pi.mulSingle_op
#align pi.single_op Pi.single_op

@[to_additive]
theorem mulSingle_op₂ {g₁ g₂ : I → Type _} [∀ i, One (g₁ i)] [∀ i, One (g₂ i)]
    (op : ∀ i, g₁ i → g₂ i → f i) (h : ∀ i, op i 1 1 = 1) (i : I) (x₁ : g₁ i) (x₂ : g₂ i) :
    mulSingle i (op i x₁ x₂) = fun j => op j (mulSingle i x₁ j) (mulSingle i x₂ j) :=
  Eq.symm <| funext <| apply_mulSingle₂ op h i x₁ x₂

#align pi.mul_single_op₂ Pi.mulSingle_op₂
#align pi.single_op₂ Pi.single_op₂

variable (f)

@[to_additive]
theorem mulSingle_injective (i : I) : Function.Injective (mulSingle i : f i → ∀ i, f i) :=
  Function.update_injective _ i

#align pi.mul_single_injective Pi.mulSingle_injective
#align pi.single_injective Pi.single_injective

@[to_additive (attr := simp)]
theorem mulSingle_inj (i : I) {x y : f i} : mulSingle i x = mulSingle i y ↔ x = y :=
  (Pi.mulSingle_injective _ _).eq_iff

#align pi.mul_single_inj Pi.mulSingle_inj
#align pi.single_inj Pi.single_inj

end

/-- The mapping into a product type built from maps into each component. -/
@[simp]
protected def prod (f' : ∀ i, f i) (g' : ∀ i, g i) (i : I) : f i × g i :=
  (f' i, g' i)

-- Porting note : simp now unfolds the lhs, so we are not marking these as simp.
-- @[simp]
theorem prod_fst_snd : Pi.prod (Prod.fst : α × β → α) (Prod.snd : α × β → β) = id :=
  funext fun _ => Prod.mk.eta

-- Porting note : simp now unfolds the lhs, so we are not marking these as simp.
-- @[simp]
theorem prod_snd_fst : Pi.prod (Prod.snd : α × β → β) (Prod.fst : α × β → α) = Prod.swap :=
  rfl

end Pi

namespace Function

section Extend

@[to_additive]
theorem extend_one [One γ] (f : α → β) : Function.extend f (1 : α → γ) (1 : β → γ) = 1 :=
  funext fun _ => by apply ite_self

@[to_additive]
theorem extend_mul [Mul γ] (f : α → β) (g₁ g₂ : α → γ) (e₁ e₂ : β → γ):
    Function.extend f (g₁ * g₂) (e₁ * e₂) = Function.extend f g₁ e₁ * Function.extend f g₂ e₂ := by
  classical
  funext x
  simp only [not_exists, extend_def, Pi.mul_apply, apply_dite₂, dite_eq_ite, ite_self]
-- Porting note: The Lean3 statement was
-- `funext $ λ _, by convert (apply_dite2 (*) _ _ _ _ _).symm`
-- which converts to
-- `funext fun _ => by convert (apply_dite₂ (· * ·) _ _ _ _ _).symm`
-- However this does not work, and we're not sure why.

@[to_additive]
theorem extend_inv [Inv γ] (f : α → β) (g : α → γ) (e : β → γ) :
    Function.extend f g⁻¹ e⁻¹ = (Function.extend f g e)⁻¹ := by
  classical
  funext x
  simp only [not_exists, extend_def, Pi.inv_apply, apply_dite Inv.inv]
-- Porting note: The Lean3 statement was
-- `funext $ λ _, by convert (apply_dite has_inv.inv _ _ _).symm`
-- which converts to
-- `funext fun _ => by convert (apply_dite Inv.inv _ _ _).symm`
-- However this does not work, and we're not sure why.

@[to_additive]
theorem extend_div [Div γ] (f : α → β) (g₁ g₂ : α → γ) (e₁ e₂ : β → γ) :
    Function.extend f (g₁ / g₂) (e₁ / e₂) = Function.extend f g₁ e₁ / Function.extend f g₂ e₂ := by
  classical
  funext x
  simp [Function.extend_def, apply_dite₂]
-- Porting note: The Lean3 statement was
-- `funext $ λ _, by convert (apply_dite2 (/) _ _ _ _ _).symm`
-- which converts to
-- `funext fun _ => by convert (apply_dite₂ (· / ·) _ _ _ _ _).symm`
-- However this does not work, and we're not sure why.

end Extend

theorem surjective_pi_map {F : ∀ i, f i → g i} (hF : ∀ i, Surjective (F i)) :
    Surjective fun x : ∀ i, f i => fun i => F i (x i) := fun y =>
  ⟨fun i => (hF i (y i)).choose, funext fun i => (hF i (y i)).choose_spec⟩

theorem injective_pi_map {F : ∀ i, f i → g i} (hF : ∀ i, Injective (F i)) :
    Injective fun x : ∀ i, f i => fun i => F i (x i) :=
  fun _ _ h => funext fun i => hF i <| (congr_fun h i : _)

theorem bijective_pi_map {F : ∀ i, f i → g i} (hF : ∀ i, Bijective (F i)) :
    Bijective fun x : ∀ i, f i => fun i => F i (x i) :=
  ⟨injective_pi_map fun i => (hF i).injective, surjective_pi_map fun i => (hF i).surjective⟩

end Function

/-- If the one function is surjective, the codomain is trivial. -/
@[to_additive "If the zero function is surjective, the codomain is trivial."]
def uniqueOfSurjectiveOne (α : Type _) {β : Type _} [One β] (h : Function.Surjective (1 : α → β)) :
    Unique β :=
  h.uniqueOfSurjectiveConst α (1 : β)

@[to_additive]
theorem Subsingleton.pi_mulSingle_eq {α : Type _} [DecidableEq I] [Subsingleton I] [One α]
    (i : I) (x : α) : Pi.mulSingle i x = fun _ => x :=
  funext fun j => by rw [Subsingleton.elim j i, Pi.mulSingle_eq_same]

#align subsingleton.pi_mul_single_eq Subsingleton.pi_mulSingle_eq
#align subsingleton.pi_single_eq Subsingleton.pi_single_eq

namespace Sum

variable (a a' : α → γ) (b b' : β → γ)

@[to_additive (attr := simp)]
theorem elim_one_one [One γ] : Sum.elim (1 : α → γ) (1 : β → γ) = 1 :=
  Sum.elim_const_const 1

@[to_additive (attr := simp)]
theorem elim_mulSingle_one [DecidableEq α] [DecidableEq β] [One γ] (i : α) (c : γ) :
    Sum.elim (Pi.mulSingle i c) (1 : β → γ) = Pi.mulSingle (Sum.inl i) c := by
  simp only [Pi.mulSingle, Sum.elim_update_left, elim_one_one]

@[to_additive (attr := simp)]
theorem elim_one_mulSingle [DecidableEq α] [DecidableEq β] [One γ] (i : β) (c : γ) :
    Sum.elim (1 : α → γ) (Pi.mulSingle i c) = Pi.mulSingle (Sum.inr i) c := by
  simp only [Pi.mulSingle, Sum.elim_update_right, elim_one_one]

#align sum.elim_mul_single_one Sum.elim_mulSingle_one
#align sum.elim_one_mul_single Sum.elim_one_mulSingle
#align sum.elim_single_zero Sum.elim_single_zero
#align sum.elim_zero_single Sum.elim_zero_single

@[to_additive]
theorem elim_inv_inv [Inv γ] : Sum.elim a⁻¹ b⁻¹ = (Sum.elim a b)⁻¹ :=
  (Sum.comp_elim Inv.inv a b).symm

@[to_additive]
theorem elim_mul_mul [Mul γ] : Sum.elim (a * a') (b * b') = Sum.elim a b * Sum.elim a' b' := by
  ext x
  cases x <;> rfl

@[to_additive]
theorem elim_div_div [Div γ] : Sum.elim (a / a') (b / b') = Sum.elim a b / Sum.elim a' b' := by
  ext x
  cases x <;> rfl

end Sum
