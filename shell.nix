{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, attoparsec, base, base-compat, bytestring
      , containers, lattices, MemoTrie, QuickCheck, range-set-list
      , regex-applicative, semigroupoids, stdenv, step-function, text
      , transformers
      }:
      mkDerivation {
        pname = "kleene";
        version = "0.1";
        src = ./.;
        revision = "1";
        editedCabalFile = "0cirgqhbwz849szrzmyvs47pzja9wnmz5rc2ccylgdikkv4mg3bb";
        libraryHaskellDepends = [
          attoparsec base base-compat bytestring containers lattices MemoTrie
          QuickCheck range-set-list regex-applicative semigroupoids
          step-function text transformers
        ];
        homepage = "https://github.com/phadej/kleene";
        description = "Kleene algebra";
        license = stdenv.lib.licenses.bsd3;
      };

  packages = if compiler == "default"
           then pkgs.haskellPackages
           else pkgs.haskell.packages.${compiler};

  repos = {
    integer-logarithms = pkgs.fetchFromGitHub {
      owner  = "Bodigrim";
      repo   = "integer-logarithms";
      rev    = "ee7ceecc0ce1d74e61694ff1badca6a7d2e507ce";
      sha256 = "1rsx2mjb393mb300ka5dn3qhy3z7fdbxi2qhj53lddx3vna8yjdk";
    };
    lattices = pkgs.fetchFromGitHub {
      owner  = "phadej";
      repo   = "lattices";
      rev    = "2143ba5c5bcc8c5a4a0d42228994d45706376193";
      sha256 = "0jh19pyqizh5zay62kjjy0zwn69iz9r1m2x5fqswpxaahnj7gr5r";
    };
    range-set-list = pkgs.fetchFromGitHub {
      owner  = "phadej";
      repo   = "range-set-list";
      rev    = "cf6664c099d1bdf7ac96309d5bfc948106eaf63a";
      sha256 = "0086gwfs69kpz92721i4s96shhnnasb4ql5qv7cr16lgd17yflv1";
    };
    universe = pkgs.fetchFromGitHub {
      owner  = "dmwit";
      repo   = "universe";
      rev    = "a0ef0ec6fd0750725a7e63734829b44f54cfcbe2";
      sha256 = "10cdjh42k9kzbwdvvl7hv9v1mnlx06swhl8y8zsqjd0rpnabfpm2";
    };
  };

  overlay = pkgs.lib.foldr pkgs.lib.composeExtensions (_: _: {}) [
    (self: super: with pkgs.haskell.lib; {
      integer-logarithms = self.callCabal2nix "integer-logarithms" repos.integer-logarithms {};
      lattices = dontCheck (self.callCabal2nix "lattices" repos.lattices {});
      range-set-list = dontCheck (self.callCabal2nix "range-set-list" repos.range-set-list {});
      universe-base = self.callCabal2nixWithOptions "universe-base" repos.universe "--subpath universe-base" {};
      universe-reverse-instances = self.callCabal2nixWithOptions "universe-reverse-instances" repos.universe "--subpath universe-reverse-instances" {};
    })];

  overrideHaskellPackages = orig: {
    buildHaskellPackages =
      orig.buildHaskellPackages.override overrideHaskellPackages;
    overrides = if orig ? overrides
      then pkgs.lib.composeExtensions orig.overrides overlay
      else overlay;
  };

  haskellPackages = packages.override overrideHaskellPackages;

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
