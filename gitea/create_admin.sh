#!/bin/bash
# 需要在 gitea 的容器里，使用 用户 git 执行

GIT_SERVER="http://gitea.pdev:8080"     # 暂时直接访问端口，nginx 的反向代理稍后。

TOKEN_FILE=${DATA_PATH}/gitea/gitea_admin_resp.txt

# 检查文件是否存在
if [[ ! -f $TOKEN_FILE ]]; then
    sleep 15       # 等待 初始化 admin 账号
fi

GIT_STATUS=`bash -c "curl -I \"${GIT_SERVER}\"  2>&1 | grep -w \"200\|301\" " `

TRY_MAX_CNT=5
# 等待 git 服务器启动
while [[ ! -n $GIT_STATUS && $snum -lt $TRY_MAX_CNT ]];  
do  
    echo "Git server is down, wait it startup. $GIT_STATUS"
    sleep 5
    # echo $snum  
    ((snum++))  
    GIT_STATUS=`bash -c "curl -I \"${GIT_SERVER}\"  2>&1 | grep -w \"200\|301\" " `
done  

GIT_STATUS=`bash -c "curl -I \"${GIT_SERVER}\"  2>&1 | grep -w \"200\|301\" " `

if [[ -n $GIT_STATUS ]];
then
    # 只处理服务器启动的情况
    CREATE_GITEA_ADMIN_CMD="gitea admin user create --username \"${GITEA_ADMIN}\" \
            --password \"${GITEA_ADMIN_PASSWD}\" --email \"${GITEA_ADMIN_EMAIL}\" \
            --admin --access-token >>/data/gitea_admin_resp.log \
            && cat /data/gitea_admin_resp.log | grep \"Access token was successfully created\" | sed 's/.*... /\\n/g' | sed -n '2p' >>/data/gitea_admin_resp.txt" 
    bash -c "${CREATE_GITEA_ADMIN_CMD}"
fi 