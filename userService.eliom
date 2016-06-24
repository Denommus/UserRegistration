open Eliom_lib
open Eliom_content
open Html5.D
[%%shared
open BatResult
]

let index_user_service =
  Eliom_service.Http.service ~path:["users"; ""]
    ~get_params:Eliom_parameter.unit ()


let new_user_service =
  Eliom_service.Http.service ~path:["users"; "new"]
    ~get_params:Eliom_parameter.unit ()

let create_user_service =
  Eliom_service.Http.post_service
    ~fallback:new_user_service
    ~post_params:Eliom_parameter.(string "username" ** string "email" ** string "password") ()

[%%shared
module type USER_MODEL = sig
  type t = {
    id: int;
    username: string;
    email: string;
  }
  val create_user : string * (string * string) -> (unit, string) BatResult.t
  val get_users : unit -> (t array, string) BatResult.t
end
]

module UserViewFunctor(UModel: USER_MODEL) = struct
  open UModel

  let user_record user = tr [ td [pcdata (string_of_int user.id)];
                              td [pcdata user.username];
                              td [pcdata user.email]; ]

  let index_user_view users = Eliom_tools.F.html
      ~title: "Users registered"
      Html5.F.(body [
        h2 [pcdata "Users registered"];
        table ([
          tr [th [pcdata "id"]; th [pcdata "username"]; th [pcdata "email"]]
        ] @ Array.to_list (Array.map user_record users));
        br ();
        a new_user_service [pcdata "New user"] ();
      ])

  let create_user_form users =Eliom_content.Html5.D.Form.
      (post_form ~service:create_user_service
         (fun (username, (email, password)) ->
            let username = input ~input_type:`Text ~name:username string in
            let password = input ~input_type:`Password ~name:password string in
            [fieldset
               [label [pcdata "login: "];
                username;
                br ();
                label [pcdata "email: "];
                input ~input_type:`Email ~name:email string;
                br ();
                label [pcdata "password: "];
                password;
                br ();
                input ~input_type:`Submit ~value:"Sign Up" string;
               ]
            ]) ())


  let new_user_view users = Eliom_tools.F.html
      ~title:"Register user"
      Html5.F.(body [
        h2 [pcdata "Register user"];
        create_user_form users;
        a index_user_service [pcdata "Main page"] ();
      ])

  let create_user_view user = Eliom_tools.F.html
      ~title:"Register user"
      Html5.F.(body 
        (match user with
         | Ok _ -> [ h2 [pcdata "User created"] ]
         | Bad err -> [ h2 [pcdata ("Error: " ^ err)];
           a new_user_service [pcdata "Back"] () ]))

  let default_error_view err = Eliom_tools.F.html
      ~title:"Error!"
      Html5.F.(body [
        h2 [pcdata ("Error: " ^ err)]
      ])
end



module UserControllerFunctor(UModel: USER_MODEL) = struct
  module UserView = UserViewFunctor(UModel)
  open UModel
  open UserView

  let index_user_controller = fun () () -> Lwt.return (match get_users () with
    | Ok users -> index_user_view users
    | Bad err -> default_error_view err)

  let create_user_controller = fun () user -> create_user user
                                              |> create_user_view
                                              |> Lwt.return

  let new_user_controller = fun () () -> Lwt.return (new_user_view ())
end
