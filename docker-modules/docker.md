# 快速入门

## 常用命令

### docker network ls

未指定network的容器默认连接到bridge上，so，处于同一个网段下的容器可以通过ip进行通信，但是不能使用容器名称，我们当然希望可以使用容器名称进行通信，so，我们需要自己创建network，加入相同的network，通过容器名称互联。

下面我们创建一个network，然后启动elasticsearch、kibana，连接到自己创建的network上。

```bash
docker network create elk
docker create --name elasticsearch -p 9200:9200 -p 9300:9300 --network elk elasticsearch:7.7.0
docker create --name kibana -p 5601:5601 --network elk kibana:7.7.0
docker start elasticsearch 
docker start kibana
docker exec kibana ping elasticsearch
```

可以看到容器之间网络已经打通，Docker内置的dns解析维护了容器名称和容器ip的对应关系。

`docker network connect elk kibana`

也可以使用network connect命令将已经运行的容器连接到自定义的网络上。
