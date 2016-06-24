val index_user_service :
  (unit, unit, [< Eliom_service.service_method > `Get ],
   [< Eliom_service.attached > `Attached ],
   [< Eliom_service.service_kind > `Service ], [ `WithoutSuffix ],
   unit, unit, [< Eliom_service.registrable > `Registrable ],
   [> Eliom_service.http_service ])
    Eliom_service.service

val new_user_service :
  (unit, unit, [< Eliom_service.service_method > `Get ],
   [< Eliom_service.attached > `Attached ],
   [< Eliom_service.service_kind > `Service ], [ `WithoutSuffix ],
   unit, unit, [< Eliom_service.registrable > `Registrable ],
   [> Eliom_service.http_service ])
    Eliom_service.service

val create_user_service :
  (unit, string * (string * string),
   [< Eliom_service.service_method > `Post ],
   [< Eliom_service.attached > `Attached ],
   [< `AttachedCoservice | `Service > `Service ],
   [ `WithoutSuffix ], unit,
   [ `One of string ] Eliom_parameter.param_name *
   ([ `One of string ] Eliom_parameter.param_name *
    [ `One of string ] Eliom_parameter.param_name),
   [< Eliom_service.registrable > `Registrable ],
   [> Eliom_service.http_service ])
    Eliom_service.service


module UserControllerFunctor: functor (UModel: sig
    type t = {
      id: int;
      username: string;
      email: string;
    }
    val create_user : string * (string * string) -> (unit, string) BatResult.t
    val get_users : unit -> (t array, string) BatResult.t
  end) -> sig

  val index_user_controller : unit -> unit -> Html5_types.html Eliom_content.Html5.elt Lwt.t

  val new_user_controller : unit -> unit -> Html5_types.html Eliom_content.Html5.elt Lwt.t

  val create_user_controller : unit -> string * (string * string) -> Html5_types.html Eliom_content.Html5.elt Lwt.t
end
