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
chain 
[
    "cp ../nonstd.ml .";
    "ocamlfind ocamlc  -c nonstd.ml -o nonstd.cmo";
    "ocamlfind ocamlopt  -c nonstd.ml  -annot -bin-annot -o nonstd.cmx";
    "ocamlc nonstd.cmo -a -o nonstd.cma";
    "ocamlopt nonstd.cmx -a -o nonstd.cmxa";
    "ocamlopt nonstd.cmxa nonstd.a -shared -o nonstd.cmxs";

]

)

let install () =
    in_build_directory (fun () ->
        chain [
          "ocamlfind install nonstd ../META nonstd.cmx nonstd.cmo nonstd.cma nonstd.cmi nonstd.cmxa nonstd.cmxs nonstd.a nonstd.o"
        ])


let uninstall () =
    chain [
      "ocamlfind remove nonstd"
    ]


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

let () = begin
match args with
| _ :: "build" :: [] ->(
say "Building";
build ();
say "Done."
)
| _ :: "build_doc" :: [] ->(
say "Building Documentation";
build_doc ();
say "Done."
)
| _ :: "install" :: [] ->(
say "Installing";
install ();
say "Done."
)
| _ :: "uninstall" :: [] ->(
say "Uninstalling";
uninstall ();
say "Done."
)
| _ :: "merlinize" :: [] ->(
say "Updating `.merlin` file";
merlinize ();
say "Done."
)
| _ :: "clean" :: [] ->(
say "Cleaning";
cmdf "rm -fr _build";
say "Done."
)
| _ ->(
say "usage: ocaml %s [build|install|uninstall|clean|build_doc|melinize]" Sys.argv.(0)
)

end


