type t = {
  id: int;
  username: string;
  email: string;
}

val create_user : string * (string * string) -> (unit, string) BatResult.t

val get_users : unit -> (t array, string) BatResult.t
