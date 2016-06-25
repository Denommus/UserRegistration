open Eliom_lib
open Eliom_content
open Html5.D
open BatResult

let index_user_service =
  Eliom_service.Http.service ~path:[""]
    ~get_params:Eliom_parameter.unit ()


let new_user_service =
  Eliom_service.Http.service ~path:["new"]
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
    end
]

[%%client
    open Eliom_content.Html5
    open EmailValidation
    let exists p arr = let i = ref 0 in
      let result = ref false in
      let len = Array.length arr in
      while !i < len do
        if Array.get arr !i |> p
        then begin
          i := len; result := true
        end;
        i := !i+1;
      done; !result
    let password_signal, set_password = React.S.create ""
    let password_len = React.S.map String.length password_signal
    let password_valid = React.S.map (fun x -> x>=6) password_len

    let username_signal, set_username = React.S.create ""
    let users_signal, set_users = React.S.create [||]
    let username_valid = React.S.l2
        (fun u us -> not (exists (fun x -> x=u) us))
        username_signal users_signal

    let email_signal, set_email = React.S.create ""
    let email_valid = React.S.map email_validation email_signal

    let all_valid = React.S.l3 (fun x y z -> x && y && z)
        password_valid
        username_valid
        email_valid

    let username_valid_text_sig = React.S.map
        (fun x -> if x then "" else "Username must be unique") username_valid
                              |> R.pcdata
    let password_valid_text_sig = React.S.map
        (fun x -> if x then "" else "Password length must be >6") password_valid
                              |> R.pcdata

    let email_valid_text_sig = React.S.map
        (fun x -> if x then "" else "Email must be a valid email") email_valid
                               |> R.pcdata

    let button_style_sig = React.S.map
        (fun x -> if x then "" else "display: none") all_valid
                       |> R.a_style
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

  let create_user_form users =
    Eliom_content.Html5.D.Form.
      (post_form ~service:create_user_service
         (fun (u, (e, p)) ->
            let username = input ~input_type:`Text ~name:u string in
            let email = input ~input_type:`Email ~name:e string in
            let password = input ~input_type:`Password ~name:p string in
            let _ = [%client
               (set_users ~%users : unit)
            ] in
            let _ = [%client
               (Lwt_js_events.(async Eliom_content.Html5.(fun () ->
                 let un = To_dom.of_input ~%username in
                 inputs un (fun _ _ -> let v = Js.to_string (un##.value) in
                             set_username v;
                             Lwt.return ())
               )) : unit)
            ] in
            let _ = [%client
              (Lwt_js_events.(async Eliom_content.Html5.(fun () ->
                 let pass = To_dom.of_input ~%password in
                 inputs pass (fun _ _ -> let v = Js.to_string (pass##.value) in
                               set_password v;
                               Lwt.return ())
               )) : unit)
            ] in
            let _ = [%client
              (Lwt_js_events.(async Eliom_content.Html5.(fun () ->
                 let em = To_dom.of_input ~%email in
                 inputs em (fun _ _ -> let v = Js.to_string (em##.value) in
                             set_email v;
                             Lwt.return ())
               )) : unit)
            ] in
            let username_valid_text () = [%client username_valid_text_sig] in
            let password_valid_text () = [%client password_valid_text_sig] in
            let email_valid_text () = [%client email_valid_text_sig] in
            let button_style () = [%client button_style_sig] in
            let open Eliom_content.Html5 in

            [fieldset
               [label [pcdata "login: "];
                username;
                C.node (username_valid_text ());
                br ();
                label [pcdata "email: "];
                email;
                C.node (email_valid_text ());
                br ();
                label [pcdata "password: "];
                password;
                C.node (password_valid_text ());
                br ();
                input ~a:[C.attr (button_style ())]
                  ~input_type:`Submit ~value:"Sign Up" string;
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
                  | Ok _ -> [ h2 [pcdata "User created"];
                              a index_user_service [pcdata "List"] ()]
                  | Bad err -> [ h2 [pcdata ("Error: " ^ err)];
                                 a new_user_service [pcdata "Back"] () ]))

  let default_error_view err = Eliom_tools.F.html
      ~title:"Error!"
      Html5.F.(body [
        h2 [pcdata ("Error: " ^ err)]
      ])
end



module UserControllerFunctor(UModel: sig
    include USER_MODEL
    val create_user : string * (string * string) -> (unit, string) BatResult.t
    val get_users : unit -> (t array, string) BatResult.t
  end) = struct
  module UserView = UserViewFunctor(UModel)
  open UModel
  open UserView

  let index_user_controller = fun () () -> Lwt.return (match get_users () with
    | Ok users -> index_user_view users
    | Bad err -> default_error_view err)

  let create_user_controller = fun () user -> create_user user
                                              |> create_user_view
                                              |> Lwt.return

  let new_user_controller = fun () () ->
    let users = BatResult.default [||] (get_users ()) in
    Lwt.return (new_user_view (Array.map (fun x -> x.username) users))
end
