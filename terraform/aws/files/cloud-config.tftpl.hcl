%{ if length(ssh_authorized_keys) > 0 ~}
ssh_authorized_keys:
%{ for _ in ssh_authorized_keys ~}
  - ${_}
%{ endfor ~}
%{ endif ~}