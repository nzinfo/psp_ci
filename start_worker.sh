docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DRONE_RPC_PROTO=http \
  -e DRONE_RPC_HOST=drone.pdev:8000 \
  -e DRONE_RPC_SECRET=drone_rpc_secret \
  -e DRONE_RUNNER_CAPACITY=2 \
  -e DRONE_RUNNER_NAME=abc \
  -e DRONE_TRACE=TRUE \
  -p 3000:3000 \
  --restart always \
  --name runner \
  drone/drone-runner-docker:1