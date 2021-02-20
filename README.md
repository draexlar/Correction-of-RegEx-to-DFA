
# A Mechanized Proof of Kleene's Theorem in Why3

This reposotory contains the OCaml and WhyML files developed during the course of the poof of correction of the translation from Regular Expressions to Finite Automata, developed in the scope of the Master Thesis "**A Mechanized Proof of Kleene's Theorem in Why3**" by André Trindade, in December of 2020.

The submitted dissertation document is made available in this repository in **[Master_Thesis_ATrindade.pdf](https://github.com/draexlar/Correction-of-RegEx-to-FA/blob/master/Master_Thesis_ATrindade.pdf)**, as well as its presentation, **[Presentation.pdf](https://github.com/draexlar/Correction-of-RegEx-to-FA/blob/master/Presentation.pdf)**.

## Files & Folders
This development resultude in three types of files: **.ml**, **.mlw** and **.bak**. These, respectively, stand for OCaml files, WhyML files and Why3 backup files.

The folders contain the Why3 sessions. This is, they containe the developments of the verification conditions and proof for each of the WhyML files, hence the same names.

### [re2dfa.ml](https://github.com/draexlar/Correction-of-RegEx-to-FA/blob/master/re2dfa.ml)
This file contains an initial OCaml draft implementing the conversion from regular expression to finite automaton, including the definition of types for automaton and regular expression, as well as initial tests to assess the algorithm behaved as expected.

### [re2dfa_inductive.mlw](https://github.com/draexlar/Correction-of-RegEx-to-FA/blob/master/re2dfa_inductive.mlw)
The WhyML code was implemented based on the OCaml code, with the necessary adaptations to types, functions and predicates when required due to limitations of the WhyML language. Obviously, these include lemmas, and annotations in order to proof the concepts we have implemented

The main file is **[re2dfa_inductive.mlw](https://github.com/draexlar/Correction-of-RegEx-to-FA/blob/master/re2dfa_inductive.mlw)**, which contains the final development with the complete proof of correction of the algorithm, presented in the document of the dissertation. 

All other files are auxliary, including tests that led to the final result or test for next steps, and are *not* necessary in case the user wants to replicate our results.

## Replication
It is possible, if desired, to replicate the results presented in the dissertation. The readed must only have Why3 installed and clone the file re2dfa_inductive.mlw and the folder with the same name.

We point, however, to a bug in the Why3 system that might reorder the VC proofs, which might make it seem some VCs are not proven. In case of this behavior, it is necessary to look in each of non-proven VC and reorder the proof according to what is necessary. It can be a hard and cumbersome task, but one that we can not avoid.
