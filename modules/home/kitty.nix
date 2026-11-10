{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    shellIntegration.enableZshIntegration = true;
    settings = {
      background_opacity = "0.92";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 10000;
      copy_on_select = "clipboard";
    };
  };
}
