/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module logic.function.conjugate
! leanprover-community/mathlib commit c4658a649d216f57e99621708b09dcb3dcccbd23
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Logic.Function.Basic
import Mathlib.Tactic.Relation.Rfl

/-!
# Semiconjugate and commuting maps

We define the following predicates:

* `Function.Semiconj`: `f : α → β` semiconjugates `ga : α → α` to `gb : β → β` if `f ∘ ga = gb ∘ f`;
* `Function.Semiconj₂`: `f : α → β` semiconjugates a binary operation `ga : α → α → α`
  to `gb : β → β → β` if `f (ga x y) = gb (f x) (f y)`;
* `Function.Commute`: `f : α → α` commutes with `g : α → α` if `f ∘ g = g ∘ f`,
  or equivalently `Semiconj f g g`.
-/

namespace Function

variable {α : Type _} {β : Type _} {γ : Type _}

/--
We say that `f : α → β` semiconjugates `ga : α → α` to `gb : β → β` if `f ∘ ga = gb ∘ f`.
We use `∀ x, f (ga x) = gb (f x)` as the definition, so given `h : Function.Semiconj f ga gb` and
`a : α`, we have `h a : f (ga a) = gb (f a)` and `h.comp_eq : f ∘ ga = gb ∘ f`.
-/
def Semiconj (f : α → β) (ga : α → α) (gb : β → β) : Prop :=
  ∀ x, f (ga x) = gb (f x)

namespace Semiconj

variable {f fab : α → β} {fbc : β → γ} {ga ga' : α → α} {gb gb' : β → β} {gc gc' : γ → γ}

protected theorem comp_eq (h : Semiconj f ga gb) : f ∘ ga = gb ∘ f :=
  funext h

protected theorem eq (h : Semiconj f ga gb) (x : α) : f (ga x) = gb (f x) :=
  h x

theorem comp_right (h : Semiconj f ga gb) (h' : Semiconj f ga' gb') :
    Semiconj f (ga ∘ ga') (gb ∘ gb') :=
  fun x ↦ by simp only [comp_apply, h.eq, h'.eq]

theorem comp_left (hab : Semiconj fab ga gb) (hbc : Semiconj fbc gb gc) :
    Semiconj (fbc ∘ fab) ga gc :=
  fun x ↦ by simp only [comp_apply, hab.eq, hbc.eq]

theorem id_right : Semiconj f id id :=
  fun _ ↦ rfl

theorem id_left : Semiconj id ga ga :=
  fun _ ↦ rfl

theorem inverses_right (h : Semiconj f ga gb) (ha : RightInverse ga' ga) (hb : LeftInverse gb' gb) :
    Semiconj f ga' gb' :=
  fun x ↦ by rw [← hb (f (ga' x)), ← h.eq, ha x]

theorem option_map {f : α → β} {ga : α → α} {gb : β → β} (h : Semiconj f ga gb) :
    Semiconj (Option.map f) (Option.map ga) (Option.map gb)
  | none => rfl
  | some _ => congr_arg some <| h _

end Semiconj

/--
Two maps `f g : α → α` commute if `f (g x) = g (f x)` for all `x : α`.
Given `h : function.commute f g` and `a : α`, we have `h a : f (g a) = g (f a)` and
`h.comp_eq : f ∘ g = g ∘ f`.
-/
def Commute (f g : α → α) : Prop :=
  Semiconj f g g

theorem Semiconj.commute {f g : α → α} (h : Semiconj f g g) : Commute f g := h

namespace Commute

variable {f f' g g' : α → α}

@[refl]
theorem refl (f : α → α) : Commute f f :=
  fun _ ↦ Eq.refl _

@[symm]
theorem symm (h : Commute f g) : Commute g f :=
  fun x ↦ (h x).symm

theorem comp_right (h : Commute f g) (h' : Commute f g') : Commute f (g ∘ g') :=
  Semiconj.comp_right h h'

theorem comp_left (h : Commute f g) (h' : Commute f' g) : Commute (f ∘ f') g :=
  (h.symm.comp_right h'.symm).symm

theorem id_right : Commute f id :=
  Semiconj.id_right

theorem id_left : Commute id f :=
  Semiconj.id_left

theorem option_map {f g : α → α} : Commute f g → Commute (Option.map f) (Option.map g) :=
  Semiconj.option_map

end Commute

/--
A map `f` semiconjugates a binary operation `ga` to a binary operation `gb` if
for all `x`, `y` we have `f (ga x y) = gb (f x) (f y)`. E.g., a `MonoidHom`
semiconjugates `(*)` to `(*)`.
-/
def Semiconj₂ (f : α → β) (ga : α → α → α) (gb : β → β → β) : Prop :=
  ∀ x y, f (ga x y) = gb (f x) (f y)

namespace Semiconj₂

variable {f : α → β} {ga : α → α → α} {gb : β → β → β}

protected theorem eq (h : Semiconj₂ f ga gb) (x y : α) : f (ga x y) = gb (f x) (f y) :=
  h x y

protected theorem comp_eq (h : Semiconj₂ f ga gb) : bicompr f ga = bicompl gb f f :=
  funext fun x ↦ funext <| h x

theorem id_left (op : α → α → α) : Semiconj₂ id op op := fun _ _ ↦ rfl

theorem comp {f' : β → γ} {gc : γ → γ → γ} (hf' : Semiconj₂ f' gb gc) (hf : Semiconj₂ f ga gb) :
    Semiconj₂ (f' ∘ f) ga gc := fun x y ↦ by simp only [hf'.eq, hf.eq, comp_apply]

theorem isAssociative_right [IsAssociative α ga] (h : Semiconj₂ f ga gb) (h_surj : Surjective f) :
    IsAssociative β gb :=
  ⟨h_surj.forall₃.2 fun x₁ x₂ x₃ ↦ by simp only [← h.eq, @IsAssociative.assoc _ ga]⟩
#align function.semiconj₂.is_associative_right Function.Semiconj₂.isAssociative_right

theorem isAssociative_left [IsAssociative β gb] (h : Semiconj₂ f ga gb) (h_inj : Injective f) :
    IsAssociative α ga :=
  ⟨fun x₁ x₂ x₃ ↦ h_inj <| by simp only [h.eq, @IsAssociative.assoc _ gb]⟩
#align function.semiconj₂.is_associative_left Function.Semiconj₂.isAssociative_left

theorem isIdempotent_right [IsIdempotent α ga] (h : Semiconj₂ f ga gb) (h_surj : Surjective f) :
    IsIdempotent β gb :=
  ⟨h_surj.forall.2 fun x ↦ by simp only [← h.eq, @IsIdempotent.idempotent _ ga]⟩
#align function.semiconj₂.is_idempotent_right Function.Semiconj₂.isIdempotent_right

theorem isIdempotent_left [IsIdempotent β gb] (h : Semiconj₂ f ga gb) (h_inj : Injective f) :
    IsIdempotent α ga :=
  ⟨fun x ↦ h_inj <| by rw [h.eq, @IsIdempotent.idempotent _ gb]⟩
#align function.semiconj₂.is_idempotent_left Function.Semiconj₂.isIdempotent_left

end Semiconj₂

end Function
