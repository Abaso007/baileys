(*  Title:      HOL/Numeral.thy
    ID:         $Id: Numeral.thy,v 1.12 2002/01/13 20:13:59 wenzelm Exp $
    Author:     Larry Paulson and Markus Wenzel

Generic numerals represented as twos-complement bit strings.
*)

theory Numeral = Datatype
files "Tools/numeral_syntax.ML":

datatype
  bin = Pls
      | Min
      | Bit bin bool    (infixl "BIT" 90)

axclass
  number < type  -- {* for numeric types: nat, int, real, \dots *}

consts
  number_of :: "bin => 'a::number"

syntax
  "_Numeral" :: "num_const => 'a"    ("_")
  Numeral0 :: 'a
  Numeral1 :: 'a

translations
  "Numeral0" == "number_of Pls"
  "Numeral1" == "number_of (Pls BIT True)"


setup NumeralSyntax.setup

syntax (xsymbols)
  "_square" :: "'a => 'a"  ("(_\<twosuperior>)" [1000] 999)
syntax (HTML output)
  "_square" :: "'a => 'a"  ("(_\<twosuperior>)" [1000] 999)
syntax (output)
  "_square" :: "'a => 'a"  ("(_ ^/ 2)" [81] 80)
translations
  "x\<twosuperior>" == "x^2"
  "x\<twosuperior>" <= "x^(2::nat)"


lemma Let_number_of [simp]: "Let (number_of v) f == f (number_of v)"
  -- {* Unfold all @{text let}s involving constants *}
  by (simp add: Let_def)

lemma Let_0 [simp]: "Let 0 f == f 0"
  by (simp add: Let_def)

lemma Let_1 [simp]: "Let 1 f == f 1"
  by (simp add: Let_def)

end
