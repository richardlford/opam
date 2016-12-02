(**************************************************************************)
(*                                                                        *)
(*    Copyright 2012-2015 OCamlPro                                        *)
(*    Copyright 2012 INRIA                                                *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

(** Operations on repositories (update, fetch...) based on the different
    backends implemented in separate modules *)

open OpamTypes

(** Get the list of packages *)
val packages: repository -> package_set

(** Get the list of packages (and their possible prefix) *)
val packages_with_prefixes: repository -> string option package_map

(** {2 Repository backends} *)

(** Initialize {i $opam/repo/$repo} *)
val init: dirname -> repository_name -> unit OpamProcess.job

(** Update {i $opam/repo/$repo}. Raises [Failure] in case the update couldn't be
    achieved. *)
val update: repository -> unit OpamProcess.job

(** Fetch an URL into a directory: if a single file, it will be put in that
    directory, otherwise the given directory is synchronised with the remote
    one. Several mirrors can be provided, in which case they will be tried in
    order, in case of an error.
    All provided hashes are checked in case of a single file; if the hash list
    is non-empty, and a directory is obtained, an error message is printed and
    Not_available returned.
    The first argument, [label] is only for status message printing. *)
val pull_url:
  string ->
  ?cache_dir:dirname -> ?cache_urls:url list ->
  ?silent_hits:bool -> ?working_dir:bool ->
  dirname -> OpamHash.t list -> url list ->
  generic_file download OpamProcess.job

(** Same as [pull_url], but for fetching a single file. *)
val pull_file:
  string -> ?cache_dir:dirname -> ?cache_urls:url list -> ?silent_hits:bool ->
  filename -> OpamHash.t list -> url list ->
  unit download OpamProcess.job

(** Same as [pull_file], but without a destination file: just ensures the file
    is present in the cache. *)
val pull_file_to_cache:
  string -> cache_dir:dirname -> ?cache_urls:url list ->
  OpamHash.t list -> url list -> unit download OpamProcess.job

(** As [pull_url], but doesn't check hashes, and instead patches the given url
    file to match the actual file hashes, as downloaded *)
val pull_url_and_fix_digest:
  string -> dirname -> OpamHash.t list -> OpamFile.URL.t OpamFile.t -> url list ->
  generic_file download OpamProcess.job

(** Get the optional revision associated to a backend (git hash, etc.). *)
val revision: dirname -> url -> version option OpamProcess.job

(** Get the version-control branch for that url. Only applicable for local,
    version controlled URLs. Returns [None] in other cases. *)
val get_branch: url -> string option OpamProcess.job

(** Returns true if the url points to a local, version-controlled directory that
    has uncommitted changes *)
val is_dirty: url -> bool OpamProcess.job

(** Find a backend *)
val find_backend: repository -> (module OpamRepositoryBackend.S)
val find_backend_by_kind: OpamUrl.backend -> (module OpamRepositoryBackend.S)
