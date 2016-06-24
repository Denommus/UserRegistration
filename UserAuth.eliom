[%%shared
open Eliom_lib
open Eliom_content
open Html5.D
]

module UserController = UserService.UserControllerFunctor(UserModel)
open UserController
open UserService

module UserAuth_app =
  Eliom_registration.App (
  struct
    let application_name = "UserAuth"
  end)

let () =
  UserAuth_app.register
    ~service:index_user_service
    index_user_controller;
  UserAuth_app.register
    ~service:new_user_service
    new_user_controller;
  UserAuth_app.register
    ~service:create_user_service
    create_user_controller
