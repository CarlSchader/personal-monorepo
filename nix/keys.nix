rec {
  carl = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN/sQiWl/z33QQMN70MenMKDj3enVgpEVoFVus+PaHWNAAAABHNzaDo= yubikey-carl" # yubikey personal
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMIssaCueh863XJ1p8wVWNScHOehySTPmrZPjyK9PDJAAAAABHNzaDo= carls-yubikey-2"
  ];
  
  connor = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE8N1WCZEQv43tuIvndSbtSPa3uYxFUfGh6LN0BFbnyt connorjones@MacBookPro" # connor
  ];

  jav = [];

  saronic = [];

  shared = carl ++ connor ++ jav;
}
