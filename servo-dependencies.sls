{% from 'map.jinja' import homebrew with context %}

servo-dependencies:
  pkg.installed:
    - pkgs:
      - cmake
      - git
      - ccache
      {% if grains['kernel'] == 'Darwin' %}
      - automake
      - pkg-config
      - openssl
      {% else %}
      - libglib2.0-dev
      - libgl1-mesa-dri
      - libgles2-mesa-dev
      - freeglut3-dev
      - libfreetype6-dev
      - xorg-dev
      - libssl-dev
      - libbz2-dev
      - xserver-xorg-input-void
      - xserver-xorg-video-dummy
      - xpra
      - libosmesa6-dev
      - gperf
      - autoconf2.13
      {% endif %}
  pip.installed:
    - pkgs:
      - virtualenv
      - ghp-import

{% if grains['kernel'] == 'Darwin' %}
# Workaround for https://github.com/saltstack/salt/issues/26414
servo-darwin-homebrew-versions-dependencies:
  module.run:
    - name: pkg.install
    - pkgs:
      - autoconf213
    - taps:
      - homebrew/versions

# Warning: These states that manually run brew link only check that some
# version of the Homebrew package is linked, not necessarily the version
# linked above. Whether this handles updates properly is an open question.
# These should be replaced by a custom Salt state.
homebrew-link-autoconf:
  cmd.run:
    - name: 'brew link --overwrite autoconf'
    - user: {{ homebrew.user }}
    - creates: /usr/local/Library/LinkedKegs/autoconf
    - require:
      - pkg: servo-dependencies
      - module: servo-darwin-homebrew-versions-dependencies

homebrew-link-openssl:
  cmd.run:
    - name: 'brew link --force openssl'
    - user: {{ homebrew.user }}
    - creates: /usr/local/Library/LinkedKegs/openssl
    - require:
      - pkg: servo-dependencies
{% else %}
FIX enable multiverse:
  pkgrepo.absent:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

enable multiverse:
  pkgrepo.managed:
    - name: deb http://archive.ubuntu.com/ubuntu trusty multiverse

ttf-mscorefonts-installer:
  debconf.set:
    - name: ttf-mscorefonts-installer
    - data: { 'msttcorefonts/accepted-mscorefonts-eula': { 'type': 'boolean', 'value': True } }
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer
    - requires:
      - debconf: ttf-mscorefonts-installer
{% endif %}
