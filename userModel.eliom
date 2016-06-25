open Postgresql

type t = {
  id: int;
  username: string;
  email: string;
}

let withConnection : connection -> (connection -> result) -> result
  = fun conn bracket -> let result =  bracket conn in conn#finish; result

let pgconn = new connection ~dbname:"testbase"


let tuple_to_user = fun user ->
  { id = Array.get user 0 |> int_of_string;
    username = Array.get user 1;
    email = Array.get user 2 }

let tuples_to_users tuples = Array.map tuple_to_user tuples

let create_user (username, (email, password)) =
  match (String.length password >= 6, EmailValidation.email_validation email) with
  | (true, true) ->  (let result = withConnection (pgconn ())
                         (fun conn -> let salt = Random.int 10000 |> string_of_int in
                           let hashed_pass = Sha512.string (password ^ salt)
                                             |> Sha512.to_hex in
                           conn#exec ~params:[|username; email; hashed_pass; salt|]
                             "INSERT INTO users (username, email, password, salt) VALUES ($1, $2, $3, $4)") in
                      match result#status with
                      | Command_ok -> BatResult.Ok ()
                      | _ -> BatResult.Bad result#error)
  | (false, false) -> BatResult.Bad "Password is too small and email must be valid"
  | (false, _) -> BatResult.Bad "Password is too small"
  | (_, false) -> BatResult.Bad "Email must be valid"

let get_users () = let result = withConnection (pgconn ())
                       (fun conn -> conn#exec "SELECT id, username, email FROM users")
  in match result#status with
  | Tuples_ok -> BatResult.Ok (tuples_to_users result#get_all)
  | _ -> BatResult.Bad result#error
