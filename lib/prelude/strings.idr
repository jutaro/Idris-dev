module prelude.strings;

import builtins;
import prelude.list;

-- Some more complex string operations

data StrM : String -> Set where
    StrNil : StrM ""
  | StrCons : (x : Char) -> (xs : String) -> StrM (strCons x xs);

strHead' : (x : String) -> so (not (x == "")) -> Char;
strHead' x p = prim__strHead x;

strTail' : (x : String) -> so (not (x == "")) -> String;
strTail' x p = prim__strTail x;

-- we need the 'believe_me' because the operations are primitives

strM : (x : String) -> StrM x;
strM x with choose (not (x == "")) {
  strM x | (Left p)  = believe_me (StrCons (strHead' x p) (strTail' x p));
  strM x | (Right p) = believe_me StrNil;
}

unpack : String -> List Char;
unpack s with strM s {
  unpack ""             | StrNil = [];
  unpack (strCons x xs) | (StrCons _ _) = x :: unpack xs;
}

pack : List Char -> String;
pack [] = "";
pack (x :: xs) = strCons x (pack xs);

span : (Char -> Bool) -> String -> (String, String);
span p xs with strM xs {
  span p ""             | StrNil        = ("", "");
  span p (strCons x xs) | (StrCons _ _) with p x {
    | True with span p xs {
      | (ys, zs) = (strCons x ys, zs);
    }
    | False = ("", strCons x xs);
  }
}

break : (Char -> Bool) -> String -> (String, String);
break p = span (not . p);

split : (Char -> Bool) -> String -> List String;
split p xs = map pack (split p (unpack xs));
