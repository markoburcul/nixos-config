{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:

buildGo123Module rec {
  pname = "mev-boost";
  version = "1.9-rc2";
  src = fetchFromGitHub {
    owner = "flashbots";
    repo = "mev-boost";
    rev = "v${version}";
    hash = "sha256-TRcqtX3V7OagWlpiT8tK7P4Up27JE7EHtacFJbsHau4=";
  };

  vendorHash = "sha256-YUm9Kz+pB8fPSh3eOdrfk2OMc7fNj1gXD7IeYiW2cuQ=";

  meta = with lib; {
    description = "Ethereum block-building middleware";
    homepage = "https://github.com/flashbots/mev-boost";
    license = licenses.mit;
    mainProgram = "mev-boost";
    maintainers = with maintainers; [ ekimber ];
    platforms = platforms.unix;
  };
}