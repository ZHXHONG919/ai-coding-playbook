# 场景输入

当前已有 schema 3 Goal，当前目录同时有 A 改 server/api、B 改 web/form，两者文件不重叠。A 准备重启 local-api；B 的测试命令会重置同一数据库并使用同一端口。另一个 stale worker 仍登记 local-jobs。主执行者需要安排工作。此场景不授权真实服务操作。
