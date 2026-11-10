# Shared team policy. Keep personal credentials and machine-specific settings out.
{
  userName = "robotics";
  fullName = "Robotics Team";
  timeZone = "America/Detroit";
  locale = "en_US.UTF-8";

  # Optional precomputed password hash for initial provisioning.
  # Generate locally with: mkpasswd -m yescrypt
  # Prefer setting a password from the installer/live environment instead.
  initialHashedPassword = null;

  # Public keys only. Never commit private keys.
  sshAuthorizedKeys = [
    # "ssh-ed25519 AAAA... team-member@device"
  ];

  enableDocker = true;
  enablePrinting = true;

  # Keep this equal to the release used for the machine's first installation.
  stateVersion = "26.05";
}
