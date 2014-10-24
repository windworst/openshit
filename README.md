OpenStack配置脚本

v0.0.1
  一键安装以下软件 (基于apt-get)
  
    依赖:
      mysql, rabbitmq, ntp

    OpenStack组建:
      KeyStone,Glance,Nova,Cinder

  一键配置OpenStack:

    OpenStack各组件配置

使用:

  第一次安装 需配置软件源 先执行
    
    sh pre_install.sh


  安装所需软件

    sh install.sh

  卸载
    sh uninstall.sh
