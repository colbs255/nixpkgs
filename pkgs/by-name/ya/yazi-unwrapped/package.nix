{ rustPlatform
, fetchFromGitHub
, lib

, installShellFiles
, stdenv
, Foundation

, nix-update-script
, imagemagick
}:

rustPlatform.buildRustPackage rec {
  pname = "yazi";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "sxyazi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-c8fWWCOVBqQVdQch9BniCaJPrVEOCv35lLH8/hMIbvE=";
  };

  cargoHash = "sha256-VeDyO+KCD3Axse4iPIoRxIvoAn3L33e2ObBZFV/REeg=";

  env.YAZI_GEN_COMPLETIONS = true;

  nativeBuildInputs = [ installShellFiles imagemagick ];
  buildInputs = lib.optionals stdenv.isDarwin [ Foundation ];

  postInstall = ''
    installShellCompletion --cmd yazi \
      --bash ./yazi-boot/completions/yazi.bash \
      --fish ./yazi-boot/completions/yazi.fish \
      --zsh  ./yazi-boot/completions/_yazi

    # Resize logo
    for RES in 16 24 32 48 64 128 256; do
      mkdir -p $out/share/icons/hicolor/"$RES"x"$RES"/apps
      convert assets/logo.png -resize "$RES"x"$RES" $out/share/icons/hicolor/"$RES"x"$RES"/apps/yazi.png
    done

    mkdir -p $out/share/applications
    install -m644 assets/yazi.desktop $out/share/applications/
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon matthiasbeyer ];
    mainProgram = "yazi";
  };
}
