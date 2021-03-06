fun same_string(s1 : string, s2 : string) = s1 = s2


(* 1 *)
(* a *)

fun aeo_helper_opt (NONE, clean_strings, pat) = NONE
  | aeo_helper_opt (SOME(dirty_string::dirty_strings), clean_strings, pat) =
		if (same_string(dirty_string, pat)) then
			SOME(clean_strings @ dirty_strings)
		else
			aeo_helper_opt(SOME(dirty_strings), dirty_string::clean_strings, pat)
  | aeo_helper_opt (SOME([]), clean_strings, pat) = NONE

  
fun all_except_option (str, strings) = 
	aeo_helper_opt (SOME strings, [], str)
		
		
	
(* b *)

fun get_substitutions1 ([], patt) = []
  | get_substitutions1 (alist :: lists, patt) =
		let 
			val opt = all_except_option(patt, alist)
		in 
			case opt of
				SOME i => i @ get_substitutions1(lists, patt)
				| NONE => get_substitutions1(lists, patt)
		end 

		
		
(* c *)
fun get_substitutions2 ([], patt) = []
  | get_substitutions2 (alist :: lists, patt) =
		let 
			val opt = all_except_option(patt, alist)
		in 
			case opt of
				SOME i => i @ get_substitutions2(lists, patt)
				| NONE => get_substitutions2(lists, patt)
		end 



(* d *)

type fullname = {first:string, last:string, middle:string}

fun i_similar_names ([], fullname) = []
  | i_similar_names (name::names, {first=f, middle=m, last=l}) = 
		{first=name, middle=m, last=l} :: i_similar_names(names, {first=f, middle=m, last=l})

fun similar_names ([], name) = [name]
  |	similar_names (substs: string list list, {first=f, middle=m, last=l}) =
	{first=f, middle=m, last=l} :: i_similar_names (get_substitutions1 (substs, f), {first=f, middle=m, last=l})
  
  
  

datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int



type card = suit * rank




datatype color = Red | Black
datatype move = Discard of card | Draw


exception IllegalMove



(* a *)
fun card_color(a_suit, a_rank) =
	case a_suit of
		Hearts   => Red
	  | Diamonds => Red
	  | _        => Black


(* b *)	  
fun card_value(a_suit, a_rank) = 
	case a_rank of 
		Num n => n
	  | Ace   => 11
	  | _     => 10


	  


(* c *)
fun rc_helper ([], clean_cards, pat) = clean_cards
  | rc_helper (dirty_card::dirty_cards, clean_cards, pat) =
		if (dirty_card = pat) then
			clean_cards @ dirty_cards
		else
			rc_helper(dirty_cards, dirty_card::clean_cards, pat)

			
fun remove_card (cards, c, exc ) = 
	let 
		val clean_cards = rc_helper(cards, [], c)
		val len_cards = length(cards)
		val len_clean = length(clean_cards)
	in 
		if (len_clean = len_cards) then
			raise exc
		else
			clean_cards
	end
 
 
(* d *)
fun all_same_color([]) = true
  | all_same_color(fst::[]) = true
  | all_same_color(fst::snd::cards) =
		if (card_color(fst) = card_color(snd)) then
			all_same_color(snd::cards)
		else
			false
			
			
 (* e *)
 
fun sum_cards_helper([], sum) = sum
  | sum_cards_helper(c::cards, sum) = sum_cards_helper(cards, sum + card_value c)

fun sum_cards(cards) = sum_cards_helper(cards, 0)

(* f *)

fun score ([], goal) = goal div 2
  | score (cards, goal) = 
	let 
		val sum = sum_cards(cards)
		val preliminary_score = 
			if (sum > goal) then
				(sum - goal) * 3
			else 
				goal - sum
		
		val final_score = 
			if (all_same_color(cards)) then
				preliminary_score div 2
			else 
				preliminary_score

	
	in 
		final_score
	end



(* g *)



fun helper_officiate(cards, hand, [], goal) = hand
  | helper_officiate([], hand, moves, goal) = hand
  | helper_officiate(c::cards, hand, m::moves, goal) = 
 		if (goal < 0) then
			hand
		else 
			case m of 
				Draw => helper_officiate(cards, c::hand, moves, goal - card_value (c))
			  | Discard dc => helper_officiate(c::cards, remove_card(hand, dc, IllegalMove), moves, goal + card_value(dc)) 
 

fun officiate(cards, moves, goal) = 
	score(helper_officiate(cards, [], moves, goal), goal)

	
	
 
(** 3 **)
(*  a  *)

(* 
realizing that i could use the functions i have written above as helper functions, that would lead to 
very innefficient altorithms, that's why i decided to calculate the sum of the cards, the number of
aces and black cards, i.e. if the latter is 0, we can divide the score by two.
*)

fun sum_cards_ch([], sum, aces, black) = (sum, aces, black)
  | sum_cards_ch((suit, rank)::cards, sum, aces, black) = 
  		let
  			val black' = 
  				if (card_color(suit, rank) = Black) then
  					black + 1
  				else 
  					black
  			val aces' = 
  				if (rank = Ace) then
  					aces + 1
  				else 
  					aces
  		in 
			sum_cards_ch(cards, card_value(suit, rank) + sum, aces', black')
  		end 
  		
  		

fun score_challenge(cards, goal) = 
	let
		val (sum, aces, black) = sum_cards_ch(cards, 0, 0, 0)
		val num_of_aces_required = Int.abs(goal - sum) div 10
		val prelim_score = 
			if (num_of_aces_required > aces) then
				sum - aces * 10
			else 
				sum - num_of_aces_required * 10
	in
		if (black = 0 orelse black = length(cards)) then
			prelim_score div 2
		else
			prelim_score
	end
 
 
