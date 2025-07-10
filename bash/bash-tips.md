# Tips

## 脚本执行权限

[root@www data]# sudo ./cache_nvd_data.sh
sudo: ./cache_nvd_data.sh: command not found

原因，无执行权限：

`chmod +x cache_nvd_data.sh`
