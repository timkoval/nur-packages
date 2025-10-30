# default.nix — Your NUR repo's entrypoint
{ pkgs ? import <nixpkgs> {} }:

let
  openspec = pkgs.buildNpmPackage rec {
    pname = "openspec";
    version = "0.13.0";  # bump for updates

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@fission-ai/openspec/-/openspec-${version}.tgz";
      sha256 = "sha256-1w1f0b92i32jh5pbwq4mhvrkbdp6l82hk193n383shqjqfiqzl95";  # ← Run `nix-prefetch-url --unpack` to get real hash
    };

    npmDepsHash = "sha256-1w1f0b92i32jh5pbwq4mhvrkbdp6l82hk193n383shqjqfiqzl95";

    dontNpmBuild = true;  # Pure CLI, no build needed

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib/node_modules/@fission-ai
      cp -r . $out/lib/node_modules/@fission-ai/openspec
      ln -s $out/lib/node_modules/@fission-ai/openspec/bin/openspec $out/bin/openspec
      wrapProgram $out/bin/openspec \
        --set NODE_PATH $out/lib/node_modules
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Spec-driven development for AI coding assistants";
      homepage = "https://github.com/Fission-AI/OpenSpec";
      license = licenses.mit;
      maintainers = [ "timkoval" ];  # Add your GitHub username
      mainProgram = "openspec";
      platforms = platforms.unix;
    };
  };
in
{
  openspec = openspec;  # Export for NUR
}
