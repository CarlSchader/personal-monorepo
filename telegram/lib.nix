{ self, ... }:
{
  lib.make-echo-remind-service = 
  # tag: A simple tagged added to the end of the service name to make it uniqure.
  # - this is required because each service needs a unique name.
  # message: The actual message that is sent
  { tag, message, calendar-rules ? [], bot-token ? "" }: 
  { pkgs, ... }:
  {
    config = {
      systemd.timers."telegram-echo-remind-${tag}" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = calendar-rules;
          Persistent = true;
          Unit = "telegram-echo-remind-${tag}.service";
        };
      };

      systemd.services."telegram-echo-remind-${tag}" = {
        enable = true; 
        script = "${self.packages."${pkgs.system}".telegram}/bin/echo-remind -b \"${bot-token}\" ${message}"; # change this to somewhere in /etc in the future
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };
}
