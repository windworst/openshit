OpenShit, OpenStack HITter

Version 0.0.1

  support ubuntu 14.04 (server/desktop)

  Auto install package (base on apt-get), configure components.

    Dependence:
      mysql, rabbitmq, ntp

    Components:
      KeyStone,Glance,Nova,Cinder


Usage:

  Configure apt-get source for first run, execute:

    sh pre_install.sh

  Download package (no install)

    sh package.sh download

  Install package

    sh package.sh install

  Uninstall

    sh package.sh uninstall
