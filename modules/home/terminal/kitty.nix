{ ... }:

{
  # colors.conf is matugen-generated (Phase 2); shipped config omits the include.
  programs.kitty = {
    enable = true;
    settings = {
      allow_remote_control = true;
      listen_on = "unix:/tmp/kitty";
      font_size = 17;
      enable_audio_bell = false;
      window_padding_width = 14;
      hide_window_decorations = true;
      confirm_os_window_close = 0;
      cursor_blink_interval = "0.6 ease-in-out";
      cursor_stop_blinking_after = 15.0;
      cursor_beam_thickness = 1.5;
      cursor_underline_thickness = 2.0;
      cursor_trail = 1;
      cursor_trail_decay = "0.05 0.1";
      cursor_trail_start_threshold = 0;
      update_check_interval = 0;
      clipboard_control =
        "write-clipboard write-primary read-clipboard read-primary";
    };
    keybindings = {
      "ctrl+shift+h" = "send_text all \\x1b[72;5u";
      "ctrl+shift+j" = "send_text all \\x1b[74;5u";
      "ctrl+shift+k" = "send_text all \\x1b[75;5u";
      "ctrl+shift+l" = "send_text all \\x1b[76;5u";
    };
  };
}
