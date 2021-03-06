https://github.com/servo/homu:
  git.latest:
    - rev: e07f74e7a3a185768e71639d6a328ef8ea234f92
    - target: /home/servo/homu
    - user: servo
    - require_in:
      - pip: install_homu

/home/servo/homu/cfg.toml:
  file.managed:
    - source: salt://homu/cfg.toml
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644
    - watch_in:
      - service: homu

/home/servo/homu/_venv:
  virtualenv.managed:
    - venv_bin: virtualenv-3.4
    - system_site_packages: False
    - require_in:
      - pip: install_homu

install_homu:
  pip.installed:
    - bin_env: /home/servo/homu/_venv
    - editable: /home/servo/homu

homu:
  service.running:
    - enable: True
    - require:
      - pip: install_homu

/etc/init/homu.conf:
  file.managed:
    - source: salt://homu/homu.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: homu
