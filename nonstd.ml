
module List = struct

  include ListLabels

  let hd_exn = hd
  let hd = function o :: _ -> Some o | [] -> None

end
