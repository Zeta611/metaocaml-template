{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs =
    {
      self,
      flake-utils,
      opam-nix,
      nixpkgs,
    }@inputs:
    let
      package = "metaocaml_template";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        devPackagesQuery = {
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          utop = "*";
          alcotest = "*";
          odoc = "*";
        };
        query = devPackagesQuery // {
          ocaml-variants = "5.3.0+BER";
        };
        scope = on.buildDuneProject {
          # resolveArgs.with-test = true;
          resolveArgs.env.enable-ocaml-beta-repository = true;
        } package ./. query;
        overlay = final: prev: {
          ${package} = prev.${package}.overrideAttrs (_: {
            # Prevent the ocaml dependencies from leaking into dependent environments
            doNixSupport = false;
          });
        };
        scope' = scope.overrideScope overlay;
        main = scope'.${package};
        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
      in
      {
        legacyPackages = scope';

        packages.default = main;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ main ];
          buildInputs =
            with pkgs;
            devPackages
            ++ [
              nodejs
            ];
          # BER MetaOCaml ships Codelib/Runnative as bare compilation units in
          # the compiler's stdlib dir, with no findlib package -- so dune can't
          # find a "metaocaml" library. ./findlib holds a synthetic META that
          # wraps them; put it on OCAMLPATH (prepended to the value opam-nix
          # already set) so `dune build` resolves `(libraries metaocaml)`.
          shellHook = ''
            export OCAMLPATH="$PWD/findlib''${OCAMLPATH:+:$OCAMLPATH}"
          '';
        };
      }
    );
}
