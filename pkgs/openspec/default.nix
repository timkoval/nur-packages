{ pkgs ? import <nixpkgs> {} }:

pkgs.buildNpmPackage rec {
  pname = "openspec";
  version = "0.13.0";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@fission-ai/openspec/-/openspec-${version}.tgz";
    sha256 = "sha256-JdGPo8MSQz3QsCOFCQWi5rY184aVYL5ugVKMKNICLvA=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/node_modules/@fission-ai
    cp -r . $out/lib/node_modules/@fission-ai/openspec
    ln -s $out/lib/node_modules/@fission-ai/openspec/bin/openspec $out/bin/openspec
    wrapProgram $out/bin/openspec --set NODE_PATH $out/lib/node_modules
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Spec-driven development for AI coding assistants";
    homepage = "https://github.com/Fission-AI/OpenSpec";
    license = licenses.mit;
    maintainers = [ "timkoval" ];
    mainProgram = "openspec";
    platforms = platforms.unix;
  };
}
