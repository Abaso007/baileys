(*  Title:      HOL/HOL.thy
    ID:         $Id: HOL.thy,v 1.94 2002/02/25 19:48:16 wenzelm Exp $
    Author:     Tobias Nipkow, Markus Wenzel, and Larry Paulson
    License:    GPL (GNU GENERAL PUBLIC LICENSE)
*)

header {* The basis of Higher-Order Logic *}

theory HOL = CPure
files ("HOL_lemmas.ML") ("cladata.ML") ("blastdata.ML") ("simpdata.ML"):


subsection {* Primitive logic *}

subsubsection {* Core syntax *}

classes type < logic
defaultsort type

global

typedecl bool

arities
  bool :: type
  fun :: (type, type) type

judgment
  Trueprop      :: "bool => prop"                   ("(_)" 5)

consts
  Not           :: "bool => bool"                   ("~ _" [40] 40)
  True          :: bool
  False         :: bool
  If            :: "[bool, 'a, 'a] => 'a"           ("(if (_)/ then (_)/ else (_))" 10)
  arbitrary     :: 'a

  The           :: "('a => bool) => 'a"
  All           :: "('a => bool) => bool"           (binder "ALL " 10)
  Ex            :: "('a => bool) => bool"           (binder "EX " 10)
  Ex1           :: "('a => bool) => bool"           (binder "EX! " 10)
  Let           :: "['a, 'a => 'b] => 'b"

  "="           :: "['a, 'a] => bool"               (infixl 50)
  &             :: "[bool, bool] => bool"           (infixr 35)
  "|"           :: "[bool, bool] => bool"           (infixr 30)
  -->           :: "[bool, bool] => bool"           (infixr 25)

local


subsubsection {* Additional concrete syntax *}

nonterminals
  letbinds  letbind
  case_syn  cases_syn

syntax
  "_not_equal"  :: "['a, 'a] => bool"                    (infixl "~=" 50)
  "_The"        :: "[pttrn, bool] => 'a"                 ("(3THE _./ _)" [0, 10] 10)

  "_bind"       :: "[pttrn, 'a] => letbind"              ("(2_ =/ _)" 10)
  ""            :: "letbind => letbinds"                 ("_")
  "_binds"      :: "[letbind, letbinds] => letbinds"     ("_;/ _")
  "_Let"        :: "[letbinds, 'a] => 'a"                ("(let (_)/ in (_))" 10)

  "_case_syntax":: "['a, cases_syn] => 'b"               ("(case _ of/ _)" 10)
  "_case1"      :: "['a, 'b] => case_syn"                ("(2_ =>/ _)" 10)
  ""            :: "case_syn => cases_syn"               ("_")
  "_case2"      :: "[case_syn, cases_syn] => cases_syn"  ("_/ | _")

translations
  "x ~= y"                == "~ (x = y)"
  "THE x. P"              == "The (%x. P)"
  "_Let (_binds b bs) e"  == "_Let b (_Let bs e)"
  "let x = a in e"        == "Let a (%x. e)"

syntax (output)
  "="           :: "['a, 'a] => bool"                    (infix 50)
  "_not_equal"  :: "['a, 'a] => bool"                    (infix "~=" 50)

syntax (xsymbols)
  Not           :: "bool => bool"                        ("\<not> _" [40] 40)
  "op &"        :: "[bool, bool] => bool"                (infixr "\<and>" 35)
  "op |"        :: "[bool, bool] => bool"                (infixr "\<or>" 30)
  "op -->"      :: "[bool, bool] => bool"                (infixr "\<longrightarrow>" 25)
  "_not_equal"  :: "['a, 'a] => bool"                    (infix "\<noteq>" 50)
  "ALL "        :: "[idts, bool] => bool"                ("(3\<forall>_./ _)" [0, 10] 10)
  "EX "         :: "[idts, bool] => bool"                ("(3\<exists>_./ _)" [0, 10] 10)
  "EX! "        :: "[idts, bool] => bool"                ("(3\<exists>!_./ _)" [0, 10] 10)
  "_case1"      :: "['a, 'b] => case_syn"                ("(2_ \<Rightarrow>/ _)" 10)
(*"_case2"      :: "[case_syn, cases_syn] => cases_syn"  ("_/ \\<orelse> _")*)

syntax (xsymbols output)
  "_not_equal"  :: "['a, 'a] => bool"                    (infix "\<noteq>" 50)

syntax (HTML output)
  Not           :: "bool => bool"                        ("\<not> _" [40] 40)

syntax (HOL)
  "ALL "        :: "[idts, bool] => bool"                ("(3! _./ _)" [0, 10] 10)
  "EX "         :: "[idts, bool] => bool"                ("(3? _./ _)" [0, 10] 10)
  "EX! "        :: "[idts, bool] => bool"                ("(3?! _./ _)" [0, 10] 10)


subsubsection {* Axioms and basic definitions *}

axioms
  eq_reflection: "(x=y) ==> (x==y)"

  refl:         "t = (t::'a)"
  subst:        "[| s = t; P(s) |] ==> P(t::'a)"

  ext:          "(!!x::'a. (f x ::'b) = g x) ==> (%x. f x) = (%x. g x)"
    -- {* Extensionality is built into the meta-logic, and this rule expresses *}
    -- {* a related property.  It is an eta-expanded version of the traditional *}
    -- {* rule, and similar to the ABS rule of HOL *}

  the_eq_trivial: "(THE x. x = a) = (a::'a)"

  impI:         "(P ==> Q) ==> P-->Q"
  mp:           "[| P-->Q;  P |] ==> Q"

defs
  True_def:     "True      == ((%x::bool. x) = (%x. x))"
  All_def:      "All(P)    == (P = (%x. True))"
  Ex_def:       "Ex(P)     == !Q. (!x. P x --> Q) --> Q"
  False_def:    "False     == (!P. P)"
  not_def:      "~ P       == P-->False"
  and_def:      "P & Q     == !R. (P-->Q-->R) --> R"
  or_def:       "P | Q     == !R. (P-->R) --> (Q-->R) --> R"
  Ex1_def:      "Ex1(P)    == ? x. P(x) & (! y. P(y) --> y=x)"

axioms
  iff:          "(P-->Q) --> (Q-->P) --> (P=Q)"
  True_or_False:  "(P=True) | (P=False)"

defs
  Let_def:      "Let s f == f(s)"
  if_def:       "If P x y == THE z::'a. (P=True --> z=x) & (P=False --> z=y)"

  arbitrary_def:  "False ==> arbitrary == (THE x. False)"
    -- {* @{term arbitrary} is completely unspecified, but is made to appear as a
    definition syntactically *}


subsubsection {* Generic algebraic operations *}

axclass zero < type
axclass one < type
axclass plus < type
axclass minus < type
axclass times < type
axclass inverse < type

global

consts
  "0"           :: "'a::zero"                       ("0")
  "1"           :: "'a::one"                        ("1")
  "+"           :: "['a::plus, 'a]  => 'a"          (infixl 65)
  -             :: "['a::minus, 'a] => 'a"          (infixl 65)
  uminus        :: "['a::minus] => 'a"              ("- _" [81] 80)
  *             :: "['a::times, 'a] => 'a"          (infixl 70)

local

typed_print_translation {*
  let
    fun tr' c = (c, fn show_sorts => fn T => fn ts =>
      if T = dummyT orelse not (! show_types) andalso can Term.dest_Type T then raise Match
      else Syntax.const Syntax.constrainC $ Syntax.const c $ Syntax.term_of_typ show_sorts T);
  in [tr' "0", tr' "1"] end;
*} -- {* show types that are presumably too general *}


consts
  abs           :: "'a::minus => 'a"
  inverse       :: "'a::inverse => 'a"
  divide        :: "['a::inverse, 'a] => 'a"        (infixl "'/" 70)

syntax (xsymbols)
  abs :: "'a::minus => 'a"    ("\<bar>_\<bar>")
syntax (HTML output)
  abs :: "'a::minus => 'a"    ("\<bar>_\<bar>")

axclass plus_ac0 < plus, zero
  commute: "x + y = y + x"
  assoc:   "(x + y) + z = x + (y + z)"
  zero:    "0 + x = x"


subsection {* Theory and package setup *}

subsubsection {* Basic lemmas *}

use "HOL_lemmas.ML"
theorems case_split = case_split_thm [case_names True False]


subsubsection {* Intuitionistic Reasoning *}

lemma impE':
  assumes 1: "P --> Q"
    and 2: "Q ==> R"
    and 3: "P --> Q ==> P"
  shows R
proof -
  from 3 and 1 have P .
  with 1 have Q by (rule impE)
  with 2 show R .
qed

lemma allE':
  assumes 1: "ALL x. P x"
    and 2: "P x ==> ALL x. P x ==> Q"
  shows Q
proof -
  from 1 have "P x" by (rule spec)
  from this and 1 show Q by (rule 2)
qed

lemma notE':
  assumes 1: "~ P"
    and 2: "~ P ==> P"
  shows R
proof -
  from 2 and 1 have P .
  with 1 show R by (rule notE)
qed

lemmas [CPure.elim!] = disjE iffE FalseE conjE exE
  and [CPure.intro!] = iffI conjI impI TrueI notI allI refl
  and [CPure.elim 2] = allE notE' impE'
  and [CPure.intro] = exI disjI2 disjI1

lemmas [trans] = trans
  and [sym] = sym not_sym
  and [CPure.elim?] = iffD1 iffD2 impE


subsubsection {* Atomizing meta-level connectives *}

lemma atomize_all [atomize]: "(!!x. P x) == Trueprop (ALL x. P x)"
proof
  assume "!!x. P x"
  show "ALL x. P x" by (rule allI)
next
  assume "ALL x. P x"
  thus "!!x. P x" by (rule allE)
qed

lemma atomize_imp [atomize]: "(A ==> B) == Trueprop (A --> B)"
proof
  assume r: "A ==> B"
  show "A --> B" by (rule impI) (rule r)
next
  assume "A --> B" and A
  thus B by (rule mp)
qed

lemma atomize_eq [atomize]: "(x == y) == Trueprop (x = y)"
proof
  assume "x == y"
  show "x = y" by (unfold prems) (rule refl)
next
  assume "x = y"
  thus "x == y" by (rule eq_reflection)
qed

lemma atomize_conj [atomize]:
  "(!!C. (A ==> B ==> PROP C) ==> PROP C) == Trueprop (A & B)"
proof
  assume "!!C. (A ==> B ==> PROP C) ==> PROP C"
  show "A & B" by (rule conjI)
next
  fix C
  assume "A & B"
  assume "A ==> B ==> PROP C"
  thus "PROP C"
  proof this
    show A by (rule conjunct1)
    show B by (rule conjunct2)
  qed
qed

lemmas [symmetric, rulify] = atomize_all atomize_imp


subsubsection {* Classical Reasoner setup *}

use "cladata.ML"
setup hypsubst_setup

ML_setup {*
  Context.>> (ContextRules.addSWrapper (fn tac => hyp_subst_tac' ORELSE' tac));
*}

setup Classical.setup
setup clasetup

lemmas [intro?] = ext
  and [elim?] = ex1_implies_ex

use "blastdata.ML"
setup Blast.setup


subsubsection {* Simplifier setup *}

lemma meta_eq_to_obj_eq: "x == y ==> x = y"
proof -
  assume r: "x == y"
  show "x = y" by (unfold r) (rule refl)
qed

lemma eta_contract_eq: "(%s. f s) = f" ..

lemma simp_thms:
  shows not_not: "(~ ~ P) = P"
  and
    "(P ~= Q) = (P = (~Q))"
    "(P | ~P) = True"    "(~P | P) = True"
    "((~P) = (~Q)) = (P=Q)"
    "(x = x) = True"
    "(~True) = False"  "(~False) = True"
    "(~P) ~= P"  "P ~= (~P)"
    "(True=P) = P"  "(P=True) = P"  "(False=P) = (~P)"  "(P=False) = (~P)"
    "(True --> P) = P"  "(False --> P) = True"
    "(P --> True) = True"  "(P --> P) = True"
    "(P --> False) = (~P)"  "(P --> ~P) = (~P)"
    "(P & True) = P"  "(True & P) = P"
    "(P & False) = False"  "(False & P) = False"
    "(P & P) = P"  "(P & (P & Q)) = (P & Q)"
    "(P & ~P) = False"    "(~P & P) = False"
    "(P | True) = True"  "(True | P) = True"
    "(P | False) = P"  "(False | P) = P"
    "(P | P) = P"  "(P | (P | Q)) = (P | Q)" and
    "(ALL x. P) = P"  "(EX x. P) = P"  "EX x. x=t"  "EX x. t=x"
    -- {* needed for the one-point-rule quantifier simplification procs *}
    -- {* essential for termination!! *} and
    "!!P. (EX x. x=t & P(x)) = P(t)"
    "!!P. (EX x. t=x & P(x)) = P(t)"
    "!!P. (ALL x. x=t --> P(x)) = P(t)"
    "!!P. (ALL x. t=x --> P(x)) = P(t)"
  by (blast, blast, blast, blast, blast, rules+)
 
lemma imp_cong: "(P = P') ==> (P' ==> (Q = Q')) ==> ((P --> Q) = (P' --> Q'))"
  by rules

lemma ex_simps:
  "!!P Q. (EX x. P x & Q)   = ((EX x. P x) & Q)"
  "!!P Q. (EX x. P & Q x)   = (P & (EX x. Q x))"
  "!!P Q. (EX x. P x | Q)   = ((EX x. P x) | Q)"
  "!!P Q. (EX x. P | Q x)   = (P | (EX x. Q x))"
  "!!P Q. (EX x. P x --> Q) = ((ALL x. P x) --> Q)"
  "!!P Q. (EX x. P --> Q x) = (P --> (EX x. Q x))"
  -- {* Miniscoping: pushing in existential quantifiers. *}
  by (rules | blast)+

lemma all_simps:
  "!!P Q. (ALL x. P x & Q)   = ((ALL x. P x) & Q)"
  "!!P Q. (ALL x. P & Q x)   = (P & (ALL x. Q x))"
  "!!P Q. (ALL x. P x | Q)   = ((ALL x. P x) | Q)"
  "!!P Q. (ALL x. P | Q x)   = (P | (ALL x. Q x))"
  "!!P Q. (ALL x. P x --> Q) = ((EX x. P x) --> Q)"
  "!!P Q. (ALL x. P --> Q x) = (P --> (ALL x. Q x))"
  -- {* Miniscoping: pushing in universal quantifiers. *}
  by (rules | blast)+

lemma eq_ac:
  shows eq_commute: "(a=b) = (b=a)"
    and eq_left_commute: "(P=(Q=R)) = (Q=(P=R))"
    and eq_assoc: "((P=Q)=R) = (P=(Q=R))" by (rules, blast+)
lemma neq_commute: "(a~=b) = (b~=a)" by rules

lemma conj_comms:
  shows conj_commute: "(P&Q) = (Q&P)"
    and conj_left_commute: "(P&(Q&R)) = (Q&(P&R))" by rules+
lemma conj_assoc: "((P&Q)&R) = (P&(Q&R))" by rules

lemma disj_comms:
  shows disj_commute: "(P|Q) = (Q|P)"
    and disj_left_commute: "(P|(Q|R)) = (Q|(P|R))" by rules+
lemma disj_assoc: "((P|Q)|R) = (P|(Q|R))" by rules

lemma conj_disj_distribL: "(P&(Q|R)) = (P&Q | P&R)" by rules
lemma conj_disj_distribR: "((P|Q)&R) = (P&R | Q&R)" by rules

lemma disj_conj_distribL: "(P|(Q&R)) = ((P|Q) & (P|R))" by rules
lemma disj_conj_distribR: "((P&Q)|R) = ((P|R) & (Q|R))" by rules

lemma imp_conjR: "(P --> (Q&R)) = ((P-->Q) & (P-->R))" by rules
lemma imp_conjL: "((P&Q) -->R)  = (P --> (Q --> R))" by rules
lemma imp_disjL: "((P|Q) --> R) = ((P-->R)&(Q-->R))" by rules

text {* These two are specialized, but @{text imp_disj_not1} is useful in @{text "Auth/Yahalom"}. *}
lemma imp_disj_not1: "(P --> Q | R) = (~Q --> P --> R)" by blast
lemma imp_disj_not2: "(P --> Q | R) = (~R --> P --> Q)" by blast

lemma imp_disj1: "((P-->Q)|R) = (P--> Q|R)" by blast
lemma imp_disj2: "(Q|(P-->R)) = (P--> Q|R)" by blast

lemma de_Morgan_disj: "(~(P | Q)) = (~P & ~Q)" by rules
lemma de_Morgan_conj: "(~(P & Q)) = (~P | ~Q)" by blast
lemma not_imp: "(~(P --> Q)) = (P & ~Q)" by blast
lemma not_iff: "(P~=Q) = (P = (~Q))" by blast
lemma disj_not1: "(~P | Q) = (P --> Q)" by blast
lemma disj_not2: "(P | ~Q) = (Q --> P)"  -- {* changes orientation :-( *}
  by blast
lemma imp_conv_disj: "(P --> Q) = ((~P) | Q)" by blast

lemma iff_conv_conj_imp: "(P = Q) = ((P --> Q) & (Q --> P))" by rules


lemma cases_simp: "((P --> Q) & (~P --> Q)) = Q"
  -- {* Avoids duplication of subgoals after @{text split_if}, when the true and false *}
  -- {* cases boil down to the same thing. *}
  by blast

lemma not_all: "(~ (! x. P(x))) = (? x.~P(x))" by blast
lemma imp_all: "((! x. P x) --> Q) = (? x. P x --> Q)" by blast
lemma not_ex: "(~ (? x. P(x))) = (! x.~P(x))" by rules
lemma imp_ex: "((? x. P x) --> Q) = (! x. P x --> Q)" by rules

lemma ex_disj_distrib: "(? x. P(x) | Q(x)) = ((? x. P(x)) | (? x. Q(x)))" by rules
lemma all_conj_distrib: "(!x. P(x) & Q(x)) = ((! x. P(x)) & (! x. Q(x)))" by rules

text {*
  \medskip The @{text "&"} congruence rule: not included by default!
  May slow rewrite proofs down by as much as 50\% *}

lemma conj_cong:
    "(P = P') ==> (P' ==> (Q = Q')) ==> ((P & Q) = (P' & Q'))"
  by rules

lemma rev_conj_cong:
    "(Q = Q') ==> (Q' ==> (P = P')) ==> ((P & Q) = (P' & Q'))"
  by rules

text {* The @{text "|"} congruence rule: not included by default! *}

lemma disj_cong:
    "(P = P') ==> (~P' ==> (Q = Q')) ==> ((P | Q) = (P' | Q'))"
  by blast

lemma eq_sym_conv: "(x = y) = (y = x)"
  by rules


text {* \medskip if-then-else rules *}

lemma if_True: "(if True then x else y) = x"
  by (unfold if_def) blast

lemma if_False: "(if False then x else y) = y"
  by (unfold if_def) blast

lemma if_P: "P ==> (if P then x else y) = x"
  by (unfold if_def) blast

lemma if_not_P: "~P ==> (if P then x else y) = y"
  by (unfold if_def) blast

lemma split_if: "P (if Q then x else y) = ((Q --> P(x)) & (~Q --> P(y)))"
  apply (rule case_split [of Q])
   apply (subst if_P)
    prefer 3 apply (subst if_not_P)
     apply blast+
  done

lemma split_if_asm: "P (if Q then x else y) = (~((Q & ~P x) | (~Q & ~P y)))"
  apply (subst split_if)
  apply blast
  done

lemmas if_splits = split_if split_if_asm

lemma if_def2: "(if Q then x else y) = ((Q --> x) & (~ Q --> y))"
  by (rule split_if)

lemma if_cancel: "(if c then x else x) = x"
  apply (subst split_if)
  apply blast
  done

lemma if_eq_cancel: "(if x = y then y else x) = x"
  apply (subst split_if)
  apply blast
  done

lemma if_bool_eq_conj: "(if P then Q else R) = ((P-->Q) & (~P-->R))"
  -- {* This form is useful for expanding @{text if}s on the RIGHT of the @{text "==>"} symbol. *}
  by (rule split_if)

lemma if_bool_eq_disj: "(if P then Q else R) = ((P&Q) | (~P&R))"
  -- {* And this form is useful for expanding @{text if}s on the LEFT. *}
  apply (subst split_if)
  apply blast
  done

lemma Eq_TrueI: "P ==> P == True" by (unfold atomize_eq) rules
lemma Eq_FalseI: "~P ==> P == False" by (unfold atomize_eq) rules

use "simpdata.ML"
setup Simplifier.setup
setup "Simplifier.method_setup Splitter.split_modifiers" setup simpsetup
setup Splitter.setup setup Clasimp.setup


subsubsection {* Generic cases and induction *}

constdefs
  induct_forall :: "('a => bool) => bool"
  "induct_forall P == \<forall>x. P x"
  induct_implies :: "bool => bool => bool"
  "induct_implies A B == A --> B"
  induct_equal :: "'a => 'a => bool"
  "induct_equal x y == x = y"
  induct_conj :: "bool => bool => bool"
  "induct_conj A B == A & B"

lemma induct_forall_eq: "(!!x. P x) == Trueprop (induct_forall (\<lambda>x. P x))"
  by (simp only: atomize_all induct_forall_def)

lemma induct_implies_eq: "(A ==> B) == Trueprop (induct_implies A B)"
  by (simp only: atomize_imp induct_implies_def)

lemma induct_equal_eq: "(x == y) == Trueprop (induct_equal x y)"
  by (simp only: atomize_eq induct_equal_def)

lemma induct_forall_conj: "induct_forall (\<lambda>x. induct_conj (A x) (B x)) =
    induct_conj (induct_forall A) (induct_forall B)"
  by (unfold induct_forall_def induct_conj_def) rules

lemma induct_implies_conj: "induct_implies C (induct_conj A B) =
    induct_conj (induct_implies C A) (induct_implies C B)"
  by (unfold induct_implies_def induct_conj_def) rules

lemma induct_conj_curry: "(induct_conj A B ==> C) == (A ==> B ==> C)"
  by (simp only: atomize_imp atomize_eq induct_conj_def) (rules intro: equal_intr_rule)

lemma induct_impliesI: "(A ==> B) ==> induct_implies A B"
  by (simp add: induct_implies_def)

lemmas induct_atomize = atomize_conj induct_forall_eq induct_implies_eq induct_equal_eq
lemmas induct_rulify1 [symmetric, standard] = induct_forall_eq induct_implies_eq induct_equal_eq
lemmas induct_rulify2 = induct_forall_def induct_implies_def induct_equal_def induct_conj_def
lemmas induct_conj = induct_forall_conj induct_implies_conj induct_conj_curry

hide const induct_forall induct_implies induct_equal induct_conj


text {* Method setup. *}

ML {*
  structure InductMethod = InductMethodFun
  (struct
    val dest_concls = HOLogic.dest_concls;
    val cases_default = thm "case_split";
    val local_impI = thm "induct_impliesI";
    val conjI = thm "conjI";
    val atomize = thms "induct_atomize";
    val rulify1 = thms "induct_rulify1";
    val rulify2 = thms "induct_rulify2";
    val localize = [Thm.symmetric (thm "induct_implies_def")];
  end);
*}

setup InductMethod.setup


subsection {* Order signatures and orders *}

axclass
  ord < type

syntax
  "op <"        :: "['a::ord, 'a] => bool"             ("op <")
  "op <="       :: "['a::ord, 'a] => bool"             ("op <=")

global

consts
  "op <"        :: "['a::ord, 'a] => bool"             ("(_/ < _)"  [50, 51] 50)
  "op <="       :: "['a::ord, 'a] => bool"             ("(_/ <= _)" [50, 51] 50)

local

syntax (xsymbols)
  "op <="       :: "['a::ord, 'a] => bool"             ("op \<le>")
  "op <="       :: "['a::ord, 'a] => bool"             ("(_/ \<le> _)"  [50, 51] 50)

(*Tell blast about overloading of < and <= to reduce the risk of
  its applying a rule for the wrong type*)
ML {*
Blast.overloaded ("op <" , domain_type);
Blast.overloaded ("op <=", domain_type);
*}


subsubsection {* Monotonicity *}

constdefs
  mono :: "['a::ord => 'b::ord] => bool"
  "mono f == ALL A B. A <= B --> f A <= f B"

lemma monoI [intro?]: "(!!A B. A <= B ==> f A <= f B) ==> mono f"
  by (unfold mono_def) rules

lemma monoD [dest?]: "mono f ==> A <= B ==> f A <= f B"
  by (unfold mono_def) rules

constdefs
  min :: "['a::ord, 'a] => 'a"
  "min a b == (if a <= b then a else b)"
  max :: "['a::ord, 'a] => 'a"
  "max a b == (if a <= b then b else a)"

lemma min_leastL: "(!!x. least <= x) ==> min least x = least"
  by (simp add: min_def)

lemma min_of_mono:
    "ALL x y. (f x <= f y) = (x <= y) ==> min (f m) (f n) = f (min m n)"
  by (simp add: min_def)

lemma max_leastL: "(!!x. least <= x) ==> max least x = x"
  by (simp add: max_def)

lemma max_of_mono:
    "ALL x y. (f x <= f y) = (x <= y) ==> max (f m) (f n) = f (max m n)"
  by (simp add: max_def)


subsubsection "Orders"

axclass order < ord
  order_refl [iff]: "x <= x"
  order_trans: "x <= y ==> y <= z ==> x <= z"
  order_antisym: "x <= y ==> y <= x ==> x = y"
  order_less_le: "(x < y) = (x <= y & x ~= y)"


text {* Reflexivity. *}

lemma order_eq_refl: "!!x::'a::order. x = y ==> x <= y"
    -- {* This form is useful with the classical reasoner. *}
  apply (erule ssubst)
  apply (rule order_refl)
  done

lemma order_less_irrefl [simp]: "~ x < (x::'a::order)"
  by (simp add: order_less_le)

lemma order_le_less: "((x::'a::order) <= y) = (x < y | x = y)"
    -- {* NOT suitable for iff, since it can cause PROOF FAILED. *}
  apply (simp add: order_less_le)
  apply blast
  done

lemmas order_le_imp_less_or_eq = order_le_less [THEN iffD1, standard]

lemma order_less_imp_le: "!!x::'a::order. x < y ==> x <= y"
  by (simp add: order_less_le)


text {* Asymmetry. *}

lemma order_less_not_sym: "(x::'a::order) < y ==> ~ (y < x)"
  by (simp add: order_less_le order_antisym)

lemma order_less_asym: "x < (y::'a::order) ==> (~P ==> y < x) ==> P"
  apply (drule order_less_not_sym)
  apply (erule contrapos_np)
  apply simp
  done


text {* Transitivity. *}

lemma order_less_trans: "!!x::'a::order. [| x < y; y < z |] ==> x < z"
  apply (simp add: order_less_le)
  apply (blast intro: order_trans order_antisym)
  done

lemma order_le_less_trans: "!!x::'a::order. [| x <= y; y < z |] ==> x < z"
  apply (simp add: order_less_le)
  apply (blast intro: order_trans order_antisym)
  done

lemma order_less_le_trans: "!!x::'a::order. [| x < y; y <= z |] ==> x < z"
  apply (simp add: order_less_le)
  apply (blast intro: order_trans order_antisym)
  done


text {* Useful for simplification, but too risky to include by default. *}

lemma order_less_imp_not_less: "(x::'a::order) < y ==>  (~ y < x) = True"
  by (blast elim: order_less_asym)

lemma order_less_imp_triv: "(x::'a::order) < y ==>  (y < x --> P) = True"
  by (blast elim: order_less_asym)

lemma order_less_imp_not_eq: "(x::'a::order) < y ==>  (x = y) = False"
  by auto

lemma order_less_imp_not_eq2: "(x::'a::order) < y ==>  (y = x) = False"
  by auto


text {* Other operators. *}

lemma min_leastR: "(!!x::'a::order. least <= x) ==> min x least = least"
  apply (simp add: min_def)
  apply (blast intro: order_antisym)
  done

lemma max_leastR: "(!!x::'a::order. least <= x) ==> max x least = x"
  apply (simp add: max_def)
  apply (blast intro: order_antisym)
  done


subsubsection {* Least value operator *}

constdefs
  Least :: "('a::ord => bool) => 'a"               (binder "LEAST " 10)
  "Least P == THE x. P x & (ALL y. P y --> x <= y)"
    -- {* We can no longer use LeastM because the latter requires Hilbert-AC. *}

lemma LeastI2:
  "[| P (x::'a::order);
      !!y. P y ==> x <= y;
      !!x. [| P x; ALL y. P y --> x \<le> y |] ==> Q x |]
   ==> Q (Least P)"
  apply (unfold Least_def)
  apply (rule theI2)
    apply (blast intro: order_antisym)+
  done

lemma Least_equality:
    "[| P (k::'a::order); !!x. P x ==> k <= x |] ==> (LEAST x. P x) = k"
  apply (simp add: Least_def)
  apply (rule the_equality)
  apply (auto intro!: order_antisym)
  done


subsubsection "Linear / total orders"

axclass linorder < order
  linorder_linear: "x <= y | y <= x"

lemma linorder_less_linear: "!!x::'a::linorder. x<y | x=y | y<x"
  apply (simp add: order_less_le)
  apply (insert linorder_linear)
  apply blast
  done

lemma linorder_cases [case_names less equal greater]:
    "((x::'a::linorder) < y ==> P) ==> (x = y ==> P) ==> (y < x ==> P) ==> P"
  apply (insert linorder_less_linear)
  apply blast
  done

lemma linorder_not_less: "!!x::'a::linorder. (~ x < y) = (y <= x)"
  apply (simp add: order_less_le)
  apply (insert linorder_linear)
  apply (blast intro: order_antisym)
  done

lemma linorder_not_le: "!!x::'a::linorder. (~ x <= y) = (y < x)"
  apply (simp add: order_less_le)
  apply (insert linorder_linear)
  apply (blast intro: order_antisym)
  done

lemma linorder_neq_iff: "!!x::'a::linorder. (x ~= y) = (x<y | y<x)"
  apply (cut_tac x = x and y = y in linorder_less_linear)
  apply auto
  done

lemma linorder_neqE: "x ~= (y::'a::linorder) ==> (x < y ==> R) ==> (y < x ==> R) ==> R"
  apply (simp add: linorder_neq_iff)
  apply blast
  done


subsubsection "Min and max on (linear) orders"

lemma min_same [simp]: "min (x::'a::order) x = x"
  by (simp add: min_def)

lemma max_same [simp]: "max (x::'a::order) x = x"
  by (simp add: max_def)

lemma le_max_iff_disj: "!!z::'a::linorder. (z <= max x y) = (z <= x | z <= y)"
  apply (simp add: max_def)
  apply (insert linorder_linear)
  apply (blast intro: order_trans)
  done

lemma le_maxI1: "(x::'a::linorder) <= max x y"
  by (simp add: le_max_iff_disj)

lemma le_maxI2: "(y::'a::linorder) <= max x y"
    -- {* CANNOT use with @{text "[intro!]"} because blast will give PROOF FAILED. *}
  by (simp add: le_max_iff_disj)

lemma less_max_iff_disj: "!!z::'a::linorder. (z < max x y) = (z < x | z < y)"
  apply (simp add: max_def order_le_less)
  apply (insert linorder_less_linear)
  apply (blast intro: order_less_trans)
  done

lemma max_le_iff_conj [simp]:
    "!!z::'a::linorder. (max x y <= z) = (x <= z & y <= z)"
  apply (simp add: max_def)
  apply (insert linorder_linear)
  apply (blast intro: order_trans)
  done

lemma max_less_iff_conj [simp]:
    "!!z::'a::linorder. (max x y < z) = (x < z & y < z)"
  apply (simp add: order_le_less max_def)
  apply (insert linorder_less_linear)
  apply (blast intro: order_less_trans)
  done

lemma le_min_iff_conj [simp]:
    "!!z::'a::linorder. (z <= min x y) = (z <= x & z <= y)"
    -- {* @{text "[iff]"} screws up a @{text blast} in MiniML *}
  apply (simp add: min_def)
  apply (insert linorder_linear)
  apply (blast intro: order_trans)
  done

lemma min_less_iff_conj [simp]:
    "!!z::'a::linorder. (z < min x y) = (z < x & z < y)"
  apply (simp add: order_le_less min_def)
  apply (insert linorder_less_linear)
  apply (blast intro: order_less_trans)
  done

lemma min_le_iff_disj: "!!z::'a::linorder. (min x y <= z) = (x <= z | y <= z)"
  apply (simp add: min_def)
  apply (insert linorder_linear)
  apply (blast intro: order_trans)
  done

lemma min_less_iff_disj: "!!z::'a::linorder. (min x y < z) = (x < z | y < z)"
  apply (simp add: min_def order_le_less)
  apply (insert linorder_less_linear)
  apply (blast intro: order_less_trans)
  done

lemma split_min:
    "P (min (i::'a::linorder) j) = ((i <= j --> P(i)) & (~ i <= j --> P(j)))"
  by (simp add: min_def)

lemma split_max:
    "P (max (i::'a::linorder) j) = ((i <= j --> P(j)) & (~ i <= j --> P(i)))"
  by (simp add: max_def)


subsubsection "Bounded quantifiers"

syntax
  "_lessAll" :: "[idt, 'a, bool] => bool"   ("(3ALL _<_./ _)"  [0, 0, 10] 10)
  "_lessEx"  :: "[idt, 'a, bool] => bool"   ("(3EX _<_./ _)"  [0, 0, 10] 10)
  "_leAll"   :: "[idt, 'a, bool] => bool"   ("(3ALL _<=_./ _)" [0, 0, 10] 10)
  "_leEx"    :: "[idt, 'a, bool] => bool"   ("(3EX _<=_./ _)" [0, 0, 10] 10)

syntax (xsymbols)
  "_lessAll" :: "[idt, 'a, bool] => bool"   ("(3\<forall>_<_./ _)"  [0, 0, 10] 10)
  "_lessEx"  :: "[idt, 'a, bool] => bool"   ("(3\<exists>_<_./ _)"  [0, 0, 10] 10)
  "_leAll"   :: "[idt, 'a, bool] => bool"   ("(3\<forall>_\<le>_./ _)" [0, 0, 10] 10)
  "_leEx"    :: "[idt, 'a, bool] => bool"   ("(3\<exists>_\<le>_./ _)" [0, 0, 10] 10)

syntax (HOL)
  "_lessAll" :: "[idt, 'a, bool] => bool"   ("(3! _<_./ _)"  [0, 0, 10] 10)
  "_lessEx"  :: "[idt, 'a, bool] => bool"   ("(3? _<_./ _)"  [0, 0, 10] 10)
  "_leAll"   :: "[idt, 'a, bool] => bool"   ("(3! _<=_./ _)" [0, 0, 10] 10)
  "_leEx"    :: "[idt, 'a, bool] => bool"   ("(3? _<=_./ _)" [0, 0, 10] 10)

translations
 "ALL x<y. P"   =>  "ALL x. x < y --> P"
 "EX x<y. P"    =>  "EX x. x < y  & P"
 "ALL x<=y. P"  =>  "ALL x. x <= y --> P"
 "EX x<=y. P"   =>  "EX x. x <= y & P"

end
