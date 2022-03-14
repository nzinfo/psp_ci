# Personal CI 

适用于个体或小团队软件过程。

1. 内置 git 版本控制服务（gitea）
2. 内置 持续构建 drone 
3. 支持 target 到 Ubuntu Linux | Window 8 以上 
4. 支持 的 开发语言为 Rust 和 C++.
5. 默认 使用本地的 虚拟机， 也可使用 阿里云 的 ECS 作为构建。

    - 当使用远程主机 构建时，为按需初始化。如果持续 1 hr 没新的构建任务，会自动删除自己。
    Ref: https://hujingnb.com/archives/663


## 安装

依赖

- virtualbox + virtualbox ext
- vagrant
- `vagrant plugin install vagrant-hostmanager`


## 开发说明

1. gitea 在关闭 web 初始化之后，只能通过命令行初始化管理员账号。使用了 依赖的 ，只执行一次的 service 创建。
    
    - 因为无法创建同名账号，此操作是幂等的。

2. 与 drone.io 绑定时，需要使用 OAuth 机制同步信息。而 OAuth 机制绑定到个体用户上