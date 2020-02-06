(* --- Basic Types --- *)

let epsilon = '~'  (* used for representing the empty transitions *)

(* defining a state and a set of states *)
type state = string

module State = struct
  type t = state
  let compare = compare
end

module States = Set.Make(State)

(* defining input symbols and alphabet *)
type symbol = char

module Symbol = struct
  type t = symbol
  let compare = compare
end

module Alphabet = Set.Make(Symbol)

(* defining word and sequence of words as a set *)
type word = symbol list

module Word = struct
  type t = word
  let compare = compare
end

module Language = Set.Make(Word)

(* defining a transition and a set of transitions *)
type transition = state * symbol * state

module Transition = struct
  type t = transition
  let compare = compare
end

module Transitions = Set.Make(Transition)


(* --- Regular Expression --- *)
type regex =
    Empty
  | Eps
  | Symb of symbol
  | Seq of regex * regex 
  | Plus of regex * regex
  | Star of regex

(*let rec concatLang e f =*)
  

let rec regexLang = function
  | Empty -> Language.empty
  | Eps -> Language.singleton [epsilon]
  | Symb a -> Language.singleton [a]
  | _ -> assert false


(* --- Finite Automaton --- *)
type automaton = {
  states: States.t;
  alphabet: Alphabet.t;
  start: state;
  transitions: Transitions.t;
  finalStates: States.t;
};;

(* --- Compile automaton --- *)
let gensym =
  let c = ref 0 in
    fun () -> let x = !c in incr c; string_of_int x

let rec compile = function
  | Empty -> let i = gensym() in
              { states = States.singleton i; alphabet = Alphabet.empty; start = i; transitions = Transitions.empty; finalStates = States.empty }
  | Eps -> let start = gensym() and final = gensym () in
            let states = States.singleton start in
              let states = States.add final states in
                { states; alphabet = Alphabet.empty; start; transitions = Transitions.singleton (start, epsilon, final); finalStates = States.singleton final }
  | Symb a -> let start = gensym() and final = gensym () in
                let states = States.singleton start in
                  let states = States.add final states in
                    { states; alphabet = Alphabet.singleton a; start; transitions = Transitions.singleton (start, a, final); finalStates = States.singleton final }
  | Seq (e, f) -> let a = compile e and b = compile f in
                    let finalToStart = States.fold ( fun f -> Transitions.add (f, epsilon, b.start)) a.finalStates Transitions.empty in
                      let transitions = Transitions.union a.transitions b.transitions in
                        let transitions = Transitions.union transitions finalToStart in
                          { states = States.union a.states b.states; alphabet = Alphabet.union a.alphabet b.alphabet; start = a.start; transitions; finalStates = b.finalStates }
  | Plus (e, f) -> let a = compile e and b = compile f in
                    let start = gensym() in
                      let startToStart = List.fold_right Transitions.add [(start, epsilon, a.start); (start, epsilon, b.start)] Transitions.empty in
                        let transitions = Transitions.union a.transitions b.transitions in
                          let transitions = Transitions.union transitions startToStart in
                            { states = States.add start (States.union a.states b.states); alphabet = Alphabet.union a.alphabet b.alphabet; start; transitions; finalStates = States.union a.finalStates b.finalStates }  
  | Star e -> let a = compile e in
                let i = gensym() in
                  let startToStart = Transitions.singleton (i, epsilon, a.start) in
                    let finalToStart = States.fold ( fun f -> Transitions.add (f, epsilon, i)) a.finalStates Transitions.empty in
                      let newTrans = Transitions.union startToStart finalToStart in
                        let transitions = Transitions.union a.transitions newTrans in
                        { states = States.add i a.states; alphabet = a.alphabet; start = i; transitions; finalStates = States.singleton i } 


(* --- Operations over finite automatons --- *)
let rec fold t s =
  if Transitions.is_empty t then s
  else let elem = Transitions.choose t in
       let (a,_,_) = elem in
       fold (Transitions.remove elem t) (States.add a s)

(* get starting state, symbol, and/or end state of all transitions in set  *)
let delta_get_1st t = 
  fold t States.empty

(* get starting state, symbol, and/or end state of all transitions in set  *)
let delta_get_1st trans = 
  Transitions.fold ( fun (a,_,_) -> States.add a ) trans States.empty

let delta_get_2nd trans =
  Transitions.fold ( fun (_,b,_) -> Alphabet.add b ) trans Alphabet.empty

let delta_get_3rd trans = 
  Transitions.fold ( fun (_,_,c) -> States.add c ) trans States.empty

(* let delta_get_2nd3 trans = Transitions.map (fun(_,b,c) -> (b,c)) trans *)

(* returns the set of state s and all its states reachable by an epsilon transition, given s and an automaton *)
let next_eps s t =
  let trans = Transitions.filter (fun (a,b,c) -> s = a && b = epsilon) t in
    let nextStates = delta_get_3rd trans in	
      States.add s nextStates

let rec close_empty sts t = 
  let ns = States.fold (fun st -> States.union (next_eps st t) ) sts States.empty in
    if (States.subset ns sts) then ns else close_empty (States.union sts ns) t 

let eclose s a =
  close_empty (States.singleton s) a

(*let nextEps2 s t =
  let trans = Transitions.filter (fun (a,b,c) -> s = a && b = epsilon) t in
    delta_get_3rd trans

let rec eclose2 s a =
  let nextStates = States.filter (fun q -> s <> q) (nextEps2 s a) in
    let ec = States.fold (fun q -> States.union (eclose2 q a) ) nextStates States.empty in
      States.add s ec*)


(* returns states reachable from s through symbol w *)
let delta s w a =			
  let n = Transitions.filter (fun (a,b,c) -> s = a && w = b) a in
    delta_get_3rd n

(* extended transition function *)
let rec delta_ext s w a =
  match w with
  | [] | ['~'] -> eclose s a
  | x::xs -> 
      let rs = (delta_ext s xs a) in 
        let qs = States.fold (fun r -> States.union (delta r x a) ) rs States.empty in
          States.fold (fun q -> States.union (eclose q a) ) qs States.empty


let print_states s = States.iter (fun q -> Printf.printf "%s;" q) s;;
let print_alphabet a = Alphabet.iter (fun s -> Printf.printf "%c;" s) a;;
let print_transitions t = Transitions.iter (fun (a,b,c) -> Printf.printf "(%s, %c, %s);" a b c) t;;

let print_automaton a =
  print_string "States: "; print_states a.states;
  print_string "\n";
  print_string "Alphabet: "; print_alphabet a.alphabet;
  print_string "\n";
  print_string "Start state: "; print_endline a.start;
  print_string "Transitions: "; print_transitions a.transitions;
  print_string "\n";
  print_string "Final states: "; print_states a.finalStates;
  print_string "\n"

let ex0 = List.fold_right Transitions.add [ ("1", epsilon, "2"); ("1", epsilon, "4"); ("2", epsilon, "3"); ("3", epsilon, "6"); ("4", 'a', "5"); ("5", epsilon, "7"); ("5", 'b', "6"); ("3", epsilon, "2") ] Transitions.empty

let ex1 = List.fold_right Transitions.add [ ("1", epsilon, "3"); ("2", epsilon, "4"); ("2", epsilon, "5"); ("3", epsilon, "6"); ("3", epsilon, "7"); ("6", epsilon, "2"); ("7", epsilon, "1") ] Transitions.empty

let () = print_states (eclose "1" ex1); print_newline ()