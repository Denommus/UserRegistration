open Eliom_lib
open Eliom_content
open Html5.D


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

let new_user_view = fun () () -> Lwt.return
    (Eliom_tools.F.html
       ~title:"Register user"
       Html5.F.(body [
         h2 [pcdata "Register user"];
         create_user_form ();
       ]))

let create_user_view = fun () _ -> Lwt.return
    (Eliom_tools.F.html
       ~title:"Register user"
       Html5.F.(body [
         h2 [pcdata "User registered"];
       ]))

