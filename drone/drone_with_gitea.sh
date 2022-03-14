#!/bin/bash

DATA_PATH=/vagrant_data/data
GIT_SERVER="http://gitea.pdev:8080"     # 暂时直接访问端口，nginx 的反向代理稍后。
CI_SERVER="http://drone.pdev:8000"

CI_OAUTH_APP="drone"

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

# 需要在 docker 的宿主机执行，假设 数据 在 
ACCESS_TOKEN_CMD="head -1 ${TOKEN_FILE} | sed 's/.*... //'"
ACCESS_TOKEN=`sh -c "${ACCESS_TOKEN_CMD}"`

# 调试 access token 的
# echo $ACCESS_TOKEN

# 查询 : 判断 APP名称 是否相同 ， 如是 返回 对应的 id 否则是 -1
DRONE_APP_ID_CMD="curl -X GET \"${GIT_SERVER}/api/v1/user/applications/oauth2\" \
    -H \"accept: application/json\" \
    -H \"Authorization: token ${ACCESS_TOKEN}\" \
    -H \"Content-Type: application/json\" 2>/dev/null | jq '.[] | select(.name == \"${CI_OAUTH_APP}\") | .id ' "

DRONE_APP_ID=`bash -c "${DRONE_APP_ID_CMD}" `
# | grep ${CI_OAUTH_APP}
# echo $DRONE_APP_ID_CMD
# echo $DRONE_APP_ID

# -n checking if a variable has a string value or not.
if [[ -n $DRONE_APP_ID ]];
then
    echo "drone ci is already set"
    # 无法获取 client 的 client_secret 信息
    # DRONE_APP_RESP=`bash -c "curl -X GET \"${GIT_SERVER}/api/v1/user/applications/oauth2/${DRONE_APP_ID}\" \
    # -H \"accept: application/json\" \
    # -H \"Authorization: token ${ACCESS_TOKEN}\" \
    # -H \"Content-Type: application/json\" 2>/dev/null " `
    
    # `echo $DRONE_APP_RESP | jq -r '.client_id' `
else
    # create oauth app , save secret for later use.
    PAYLOAD_CREATE_DRONE_APP="{ \"name\": \"${CI_OAUTH_APP}\", \"redirect_uris\": [ \"${CI_SERVER}/login\" ] }"

    # echo "variable a is not set"
    DRONE_APP_RESP=`bash -c "curl -sS -X POST \"${GIT_SERVER}/api/v1/user/applications/oauth2\" \
        -H \"accept: application/json\" \
        -H \"Authorization: token ${ACCESS_TOKEN}\" \
        -H \"Content-Type: application/json\" \
        -d ${PAYLOAD_CREATE_DRONE_APP@Q} " `

    # example resp: 
    # {"id":8,"name":"drone","client_id":"12fe3bf6-2f0a-44fa-a89e-a1c4ea1c1553","client_secret":"lSAX9niPKJ7kpXY6IQVZxXM3Z26RJBhzpNbfpV3rbyDy","redirect_uris":["http://gitea.pdev:8080/login"],"created":"2022-03-14T14:21:38+08:00"}
    # save it 
    echo $DRONE_APP_RESP | jq '{client_id: .client_id, client_secret: .client_secret}' > ${DATA_PATH}/drone/oauth_secret.json
fi

# 从配置文件中读取 oauth 相关的信息，启动 drone.
# ...