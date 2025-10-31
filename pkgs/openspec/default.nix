{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "openspec";
  version = "0.13.0";

  src = pkgs.fetchurl {
    url = "https://github.com/Fission-AI/OpenSpec/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-gGUoUaya8tW9t6fGDpBvH223zRZQZot9qKQJ5NzZR80=";
  };

  nativeBuildInputs = [ pkgs.nodejs pkgs.pnpm pkgs.cacert pkgs.makeWrapper ];

  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  unpackPhase = ''
    tar -xzf $src
    cd OpenSpec-${version}
  '';

  postPatch = ''
    cat > pnpm-workspace.yaml <<EOF
    packages:
      - .
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    pnpm install --frozen-lockfile --ignore-scripts
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/node_modules/@fission-ai/openspec
    cp -r . $out/lib/node_modules/@fission-ai/openspec

    # Create wrapper script
    cat > $out/bin/openspec <<EOF
    #!${pkgs.bash}/bin/bash
    exec ${pkgs.nodejs}/bin/node $out/lib/node_modules/@fission-ai/openspec/bin/openspec.js "\$@"
    EOF
    chmod +x $out/bin/openspec

    wrapProgram $out/bin/openspec \
      --set NODE_PATH $out/lib/node_modules

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
