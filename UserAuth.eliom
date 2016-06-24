{shared{
open Eliom_lib
open Eliom_content
open Html5.D
}}

open UserView

module UserAuth_app =
  Eliom_registration.App (
  struct
    let application_name = "UserAuth"
  end)

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  UserAuth_app.register
    ~service:main_service
    (fun () () ->
       Lwt.return
         (Eliom_tools.F.html
            ~title:"UserAuth"
            ~css:[["css";"UserAuth.css"]]
            Html5.F.(body [
              h2 [pcdata "Welcome from Eliom's distillery!"];
            ])));
  UserAuth_app.register
    ~service:new_user_service
    new_user_view;
  UserAuth_app.register
    ~service:create_user_service
    create_user_view
