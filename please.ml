#! /usr/bin/env ocaml
 open Printf
 module List = ListLabels
 let say fmt = ksprintf (printf "Please-> %s\n%!") fmt
 let cmdf fmt =
   ksprintf (fun s -> ignore (Sys.command s)) fmt
 let chain l =
   List.iter l ~f:(fun cmd ->
       printf "! %s\n%!" cmd;
       if  Sys.command cmd = 0
       then ()
       else ksprintf failwith "%S failed." cmd
     )
 let args = Array.to_list Sys.argv
 let in_build_directory f =
   cmdf "mkdir -p _build/";
   Sys.chdir "_build/";
   begin try
     f ();
   with
     e ->
     Sys.chdir "../";
     raise e
   end;
   Sys.chdir "../";
   ()


let build () =
  in_build_directory (fun () ->
      chain [
        "pwd";
        "cp ../nonstd.ml .";
        "ocamlfind ocamlc  -c nonstd.ml -o nonstd.cmo";
        "ocamlfind ocamlopt  -c nonstd.ml  -annot -bin-annot -o nonstd.cmx";
        "ocamlc nonstd.cmo -a -o nonstd.cma";
        "ocamlopt nonstd.cmx -a -o nonstd.cmxa";
        "ocamlopt nonstd.cmxa nonstd.a -shared -o nonstd.cmxs";
      ];
    )


let install () =
    in_build_directory (fun () ->
        chain [
          "ocamlfind install nonstd ../META nonstd.cmx nonstd.cmo nonstd.cma nonstd.cmi nonstd.cmxa nonstd.cmxs nonstd.a nonstd.o"
        ])


let merlinize () =
    chain [
      "echo 'S .' > .merlin";
      "echo 'B _build' >> .merlin";
      
     ]


let build_doc () =
    in_build_directory (fun () ->
        chain [
          "mkdir -p doc";
                       sprintf "ocamlfind ocamldoc  -charset UTF-8 -keep-code -colorize-code -html nonstd.ml -d doc/";
        ])


let name = "nonstd"

let () =
  match args with
  | _ :: "build" :: [] ->
    say "Building.";
    build ();
    say "Done."
  | _ :: "build_doc" :: [] ->
    say "Building the documentation.";
    build_doc ()
  | _ :: "install" :: [] ->
    say "Installing";
    install ();
  | _ :: "uninstall" :: [] ->
    chain [
      sprintf "ocamlfind remove %s" name
    ]
  | _ :: "merlinize" :: [] -> merlinize ()
  | _ :: "clean" :: []
  | _ :: "C" :: [] ->
    cmdf "rm -fr _build"
  | _ :: "help" :: [] ->
    say "usage: ocaml %s [build|build_doc|install|uninstall|clean|merlinize]" Sys.argv.(0);
  | _ ->
    say "usage: ocaml %s [build|build_doc|install|uninstall|clean|merlinize]" Sys.argv.(0);
    exit 1
    

