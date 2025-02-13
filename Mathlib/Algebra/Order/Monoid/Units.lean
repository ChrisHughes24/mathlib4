/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.monoid.units
! leanprover-community/mathlib commit f1a2caaf51ef593799107fe9a8d5e411599f3996
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Order.Hom.Basic
import Mathlib.Order.MinMax
import Mathlib.Algebra.Group.Units

/-!
# Units in ordered monoids
-/


namespace Units

@[to_additive]
instance [Monoid α] [Preorder α] : Preorder αˣ :=
  Preorder.lift val

@[to_additive (attr := simp, norm_cast)]
theorem val_le_val [Monoid α] [Preorder α] {a b : αˣ} : (a : α) ≤ b ↔ a ≤ b :=
  Iff.rfl
#align units.coe_le_coe Units.val_le_val

@[to_additive (attr := simp, norm_cast)]
theorem val_lt_val [Monoid α] [Preorder α] {a b : αˣ} : (a : α) < b ↔ a < b :=
  Iff.rfl
#align units.coe_lt_coe Units.val_lt_val

@[to_additive]
instance [Monoid α] [PartialOrder α] : PartialOrder αˣ :=
  PartialOrder.lift val Units.ext
#align units.partial_order Units.instPartialOrderUnits
#align add_units.partial_order AddUnits.instPartialOrderAddUnits

@[to_additive]
instance [Monoid α] [LinearOrder α] : LinearOrder αˣ :=
  LinearOrder.lift' val Units.ext

/-- `val : αˣ → α` as an order embedding. -/
@[to_additive "`val : add_units α → α` as an order embedding.",
  simps (config := { fullyApplied := false })]
def orderEmbeddingVal [Monoid α] [LinearOrder α] : αˣ ↪o α :=
  ⟨⟨val, ext⟩, Iff.rfl⟩
#align units.order_embedding_coe Units.orderEmbeddingVal
#align add_units.order_embedding_coe AddUnits.orderEmbeddingVal

@[to_additive (attr := simp, norm_cast)]
theorem max_val [Monoid α] [LinearOrder α] {a b : αˣ} : (max a b).val = max a.val b.val :=
  Monotone.map_max orderEmbeddingVal.monotone
#align units.max_coe Units.max_val

@[to_additive (attr := simp, norm_cast)]
theorem min_val [Monoid α] [LinearOrder α] {a b : αˣ} : (min a b).val = min a.val b.val :=
  Monotone.map_min orderEmbeddingVal.monotone
#align units.min_coe Units.min_val

end Units
