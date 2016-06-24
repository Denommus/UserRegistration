open Eliom_lib
open Eliom_content
open Html5.D
open Result


let new_user_service =
  Eliom_service.Http.service ~path:["user";""]
    ~get_params:Eliom_parameter.unit ()

let create_user_service =
  Eliom_service.Http.post_service
    ~fallback:new_user_service
    ~post_params:Eliom_parameter.(string "username" ** string "email" ** string "password") ()


let create_user_form () =
  Eliom_content.Html5.D.Form.
    (post_form ~service:create_user_service
       (fun (username, (email, password)) ->
          [fieldset
             [label [pcdata "login: "];
              input ~input_type:`Text ~name:username string;
              br ();
              label [pcdata "email: "];
              input ~input_type:`Email ~name:email string;
              br ();
              label [pcdata "password: "];
              input ~input_type:`Password ~name:password string;
              br ();
              input ~input_type:`Submit ~value:"Sign Up" string;
             ]
          ]) ())


let new_user_view () = Eliom_tools.F.html
    ~title:"Register user"
    Html5.F.(body [
      h2 [pcdata "Register user"];
      create_user_form ();
    ])

let create_user_view = function
  | Ok user -> Eliom_tools.F.html
              ~title:"Register user"
              Html5.F.(body [
                h2 [pcdata "User registered"];
              ])
  | Error err -> Eliom_tools.F.html
                   ~title:"Register user"
                   Html5.F.(body [
                     h2 [pcdata ("Error on the creation of the user: " ^ err)];
                   ])



module UserControllerFunctor(UModel: sig
    type t = {
      id: int;
      username: string;
      email: string;
    }
    val create_user : string * (string * string) -> (unit, string) Result.result
    val get_users : unit -> (t array, string) Result.result
  end) = struct
  open UModel

  let create_user_controller = fun () user -> create_user user
                                              |> create_user_view
                                              |> Lwt.return

  let new_user_controller = fun () () -> Lwt.return (new_user_view ())
end
