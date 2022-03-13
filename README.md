# Personal CI 

适用于个体或小团队软件过程。

1. 内置 git 版本控制服务（gitea）
2. 内置 持续构建 drone 
3. 支持 target 到 Ubuntu Linux | Window 8 以上 
4. 支持 的 开发语言为 Rust 和 C++.
5. 默认 使用本地的 虚拟机， 也可使用 阿里云 的 ECS 作为构建。

    - 当使用远程主机 构建时，为按需初始化。如果持续 1 hr 没新的构建任务，会自动删除自己。
    Ref: https://hujingnb.com/archives/663