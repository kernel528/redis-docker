[![Build Status](http://drone.kernelsanders.biz:8080/api/badges/kernel528/redis-docker/status.svg?ref=refs/heads/7)](http://drone.kernelsanders.biz:8080/kernel528/redis-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/redis-docker)](https://github.com/kernel528/redis-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/redis)](https://hub.docker.com/r/kernel528/redis)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/kernel528/redis/7.2.4)](https://hub.docker.com/r/kernel528/redis)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/redis?sort=semver)](https://hub.docker.com/r/kernel528/redis)

# redis-docker

* Maintainer:  kernel528

# redis-docker

* Maintainer:  kernel528

### How to build image...
`docker image build --no-cache -t kernel528/redis-cli:7.2.4 -f Dockerfile .`

### Example usage...
`docker container run -it --rm --name redis-cli-arm64 --hostname redis-cli-arm64 kernel528/redis-cli:7.2.4-arm64 bash`
  - This just starts a bash shell in the container.  From here can launch `redis-cli`.
  - Can also launch the `redis-server` from the shell, but would need to update to expose port 6379 as well, but better to just launch like below.
```
[root@redis-cli-arm64] [/] # redis-cli --version
redis-cli 7.2.4
```

```
[root@redis-cli-arm64] [/usr/local/bin] # redis-server
21:C 07 May 2025 03:11:43.336 # WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. Being disabled, it can also cause failures without low memory condition, see https://github.com/jemalloc/jemalloc/issues/1328. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
21:C 07 May 2025 03:11:43.339 * oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
21:C 07 May 2025 03:11:43.339 * Redis version=7.2.4, bits=64, commit=00000000, modified=0, pid=21, just started
21:C 07 May 2025 03:11:43.339 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
21:M 07 May 2025 03:11:43.340 * monotonic clock: POSIX clock_gettime
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 7.2.4 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                  
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 21
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           https://redis.io       
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'

21:M 07 May 2025 03:11:43.342 * Server initialized
21:M 07 May 2025 03:11:43.342 * Ready to accept connections tcp
```

### Example Redis Server Startup...
`: docker container run -it --rm --name redis-cli-arm64 --hostname redis-cli-arm64 -p 6379:6379 kernel528/redis-cli:7.2.4-arm64 redis-server`
- This starts the redis server in the container, exposing on port 6379 from the container to the host. 
