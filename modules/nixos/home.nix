{ inputs, team, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs team; };
    users.${team.userName} = import ../home;
  };
}
