(*  Title:      HOL/cladata.ML
    ID:         $Id: cladata.ML,v 1.36 2001/12/04 01:01:31 wenzelm Exp $
    Author:     Tobias Nipkow
    Copyright   1996  University of Cambridge

Setting up the classical reasoner.
*)


(** Applying HypsubstFun to generate hyp_subst_tac **)
section "Classical Reasoner";

structure Hypsubst_Data =
  struct
  structure Simplifier = Simplifier
  (*Take apart an equality judgement; otherwise raise Match!*)
  fun dest_eq (Const("op =",T)  $ t $ u) = (t, u, domain_type T)
  val dest_Trueprop = HOLogic.dest_Trueprop
  val dest_imp = HOLogic.dest_imp
  val eq_reflection = eq_reflection
  val rev_eq_reflection = def_imp_eq
  val imp_intr = impI
  val rev_mp = rev_mp
  val subst = subst
  val sym = sym
  val thin_refl = prove_goal (the_context ())
		  "!!X. [|x=x; PROP W|] ==> PROP W" (K [atac 1]);
  end;

structure Hypsubst = HypsubstFun(Hypsubst_Data);
open Hypsubst;

(*prevent substitution on bool*)
fun hyp_subst_tac' i thm = if i <= Thm.nprems_of thm andalso
  Term.exists_Const (fn ("op =", Type (_, [T, _])) => T <> Type ("bool", []) | _ => false)
    (Library.nth_elem (i - 1, Thm.prems_of thm)) then hyp_subst_tac i thm else no_tac thm;



(*** Applying Make_Elim_Fun to create a classical "make_elim" rule ***)
structure Make_Elim = Make_Elim_Fun (val classical = classical);

(*we don't redeclare the original make_elim (Tactic.make_elim) for 
  compatibliity with strange things done in many existing proofs *)
val cla_make_elim = Make_Elim.make_elim;

(*** Applying ClassicalFun to create a classical prover ***)
structure Classical_Data = 
  struct
  val make_elim = cla_make_elim
  val mp        = mp
  val not_elim  = notE
  val classical = classical
  val sizef     = size_of_thm
  val hyp_subst_tacs=[hyp_subst_tac]
  end;

structure Classical = ClassicalFun(Classical_Data);

structure BasicClassical: BASIC_CLASSICAL = Classical; 
open BasicClassical;

bind_thm ("contrapos_np", inst "Pa" "?Q" swap);

(*Propositional rules*)
val prop_cs = empty_cs addSIs [refl,TrueI,conjI,disjCI,impI,notI,iffI]
                       addSEs [conjE,disjE,impCE,FalseE,iffCE];

(*Quantifier rules*)
val HOL_cs = prop_cs addSIs [allI,ex_ex1I] addIs [exI, the_equality] 
                     addSEs [exE] addEs [allE];

val clasetup = [fn thy => (claset_ref_of thy := HOL_cs; thy)];
