# 阿里云OSS

## mb（创建存储空间）

存储空间（Bucket）是用于存储对象（Object）的容器。在上传任意类型的Object前，您需要先创建Bucket。本文介绍如何通过mb命令创建Bucket。

注意事项

- 要创建Bucket，您必须具有oss:PutBucket权限。具体操作，请参见为RAM用户授权自定义的权限策略。
- 从ossutil 1.6.16版本开始，命令行中Binary名称支持直接使用ossutil，您无需根据系统刷新Binary名称。如果您的ossutil版本低于1.6.16，则需要根据系统刷新Binary名称。

以命令中指定选项的形式创建Bucket

```bash
ossutil mb oss://bucketname 
[--acl <value>]
[--storage-class <value>]
[--redundancy-type <value>]
```

| 参数                | 说明                                                                                                                 |
|-------------------|--------------------------------------------------------------------------------------------------------------------|
| bucketname        | 创建的Bucket名称。Bucket名称在OSS范围内必须全局唯一，一旦创建完成则无法修改。                                                                     |
| --acl             | Bucket的读写权限ACL。取值如下：                                                                                               |
|                   | private（默认值）：只有该Bucket的拥有者可以对该Bucket内的文件进行读写操作，其他人无法访问该Bucket内的文件。                                                 |
|                   | public-read：只有Bucket拥有者可以对该Bucket内的文件进行写操作，其他用户（包括匿名访问者）都可以对该Bucket中的文件进行读操作。这有可能造成您数据的外泄以及费用激增，请谨慎操作。             |
|                   | public-read-write：任何人（包括匿名访问者）都可以对该Bucket内文件进行读写操作。这有可能造成您数据的外泄以及费用激增，若被人恶意写入违法信息还可能会侵害您的合法权益。除特殊场景外，不建议您配置公共读写权限。 |
| --storage-class   | Bucket的存储类型。取值如下：                                                                                                  |
|                   | Standard（默认值）：支持频繁的数据访问。                                                                                           |
|                   | IA：适用于较低访问频率（平均每月访问频率1到2次）的业务场景，有最低存储时间（30天）和最小计量单位（64 KB）要求。支持数据实时访问，访问数据时会产生数据取回费用。                              |
|                   | Archive：适用于数据长期保存的业务场景，有最低存储时间（60天）和最小计量单位（64 KB）要求。数据需解冻（约1分钟）后访问，解冻会产生数据取回费用。                                    |
|                   | ColdArchive：适用于需要超长时间存放的极冷数据，有最低存储时间（180天）和最小计量单位（64 KB）要求。数据需解冻后访问，解冻时间根据数据大小和选择的解冻模式决定，解冻会产生数据取回费用。              |
| --redundancy-type | Bucket的数据容灾类型。取值如下：                                                                                                |
|                   | LRS（默认值）：本地冗余LRS将您的数据冗余存储在同一个可用区的不同存储设备上，可支持两个存储设备并发损坏时，仍维持数据不丢失，可正常访问。                                            |
|                   | ZRS：同城冗余ZRS采用多可用区（AZ）内的数据冗余存储机制，将用户的数据冗余存储在同一地域（Region）的多个可用区。当某个可用区不可用时，仍然能够保障数据的正常访问。                            |

### 使用示例

仅创建examplebucket。

`ossutil mb oss://examplebucket`

如果创建Bucket时未指定Bucket所在地域，则默认在ossutil配置文件中Endpoint指向的地域创建Bucket。例如配置文件中的Endpoint为<https://oss-cn-hangzhou.aliyuncs.com>，则表示在华东1（杭州）地域创建了Bucket。

创建examplebucket，并指定读写权限ACL为私有、存储类型为低频访问以及数据容灾类型为同城冗余ZRS。

`ossutil mb oss://examplebucket --acl private --storage-class IA --redundancy-type ZRS`

以下输出结果表明已成功创建符合指定条件的Bucket。

0.335189(s) elapsed

通用选项

当您需要通过命令行工具ossutil切换至另一个地域的Bucket时，可以通过-e选项指定该Bucket所属的Endpoint。当您需要通过命令行工具ossutil切换至另一个阿里云账号下的Bucket时，可以通过-i选项指定该账号的AccessKey ID，并通过-k选项指定该账号的AccessKey Secret。

例如您需要为另一个阿里云账号下，华东2（上海）地域创建名为examplebucket的存储空间，命令如下：

`ossutil mb oss://examplebucket -e oss-cn-shanghai.aliyuncs.com -i LTAI4Fw2NbDUCV8zYUzA****  -k 67DLVBkH7EamOjy2W5RVAHUY9H****`

## 设置Bucket ACL

本文中含有需要您注意的重要提示信息，忽略该信息可能对您的业务造成影响，请务必仔细阅读。

当您希望粗粒度地控制某个Bucket的读写权限，即Bucket内的所有Object均为统一的读写权限时，您可以选择使用Bucket ACL的方式。Bucket ACL包含公共读、公共读写和私有。您可以在创建Bucket时设置Bucket ACL，也可以在创建Bucket后根据自身的业务需求修改Bucket ACL。

注意事项

- 仅Bucket拥有者可以执行修改Bucket ACL的操作。
- 修改Bucket ACL会影响Bucket内所有ACL为继承Bucket的文件。
- 如果您在上传文件（Object）时未指定文件的ACL，则文件的ACL均默认继承Bucket ACL。

Bucket包含以下三种读写权限：

| 权限值               | 权限描述                                                                                                        |
|-------------------|-------------------------------------------------------------------------------------------------------------|
| public-read-write | 公共读写：任何人（包括匿名访问者）都可以对该Bucket内文件进行读写操作。                                                                      |
|                   | 互联网上任何用户都可以对该Bucket内的文件进行访问，并且向该Bucket写入数据。这有可能造成您数据的外泄以及费用激增，如果被人恶意写入违法信息还可能会侵害您的合法权益。除特殊场景外，不建议您配置公共读写权限。 |
| public-read       | 公共读：只有该Bucket的拥有者可以对该Bucket内的文件进行写操作，任何人（包括匿名访问者）都可以对该Bucket中的文件进行读操作。                                      |
|                   | 互联网上任何用户都可以对该Bucket内文件进行访问，这有可能造成您数据的外泄以及费用激增，请谨慎操作。                                                        |
| private（默认值）      | 私有：只有Bucket的拥有者可以对该Bucket内的文件进行读写操作，其他人无法访问该Bucket内的文件。                                                     |

### 设置或修改Bucket ACL

ACL是授予存储空间（Bucket）和文件（Object）访问权限的访问策略。您可以在创建Bucket或上传Object时设置ACL，也可以在创建Bucket或上传Object后的任意时间内修改ACL。set-acl命令用于设置或修改Bucket或Object的访问权限ACL。

命令格式

`ossutil set-acl oss://examplebucket private -b`

注意事项

- 要设置或修改Bucket ACL，您必须具有oss:PutBucketAcl权限；要设置或修改Object ACL，您必须具有oss:PutObjectAcl权限；要批量修改Object ACL，您必须具有oss:PutObjectAcl和oss:ListObjects权限。
- 从ossutil 1.6.16版本开始，命令行中Binary名称支持直接使用ossutil，您无需根据系统刷新Binary名称。如果您的ossutil版本低于1.6.16，则需要根据系统刷新Binary名称。

### 授权或限制用户访问OSS的常见Bucket Policy示例

Bucket Policy是OSS提供的一种针对存储空间（Bucket）的授权策略，使您可以精细化地授权或限制有身份的访问者（阿里云账号、RAM用户、RAM角色）或匿名访问者对指定OSS资源的访问。例如，您可以为其他阿里云账号的RAM用户授予指定OSS资源的只读权限。

通用说明

与RAM Policy不同的是，Bucket Policy还包含了用于指定允许或拒绝访问资源的主体元素Principal。使用Principal，您可以精细化地授权或限制不同访问者对指定OSS资源的访问。在不需要对访问者做个性化区分的情况下，通过一种集中式的方式管理权限，避免重复对每个访问者进行授权或限制。例如，通过在Principal输入多个RAM用户的UID，来匹配指定的RAM用户；通过在Principal中输入通配符星号（*），来匹配所有访问者。

注意事项：

- 在Bucket Policy的策略语句中，如果Principal为通配符星号（*），且包含Condition，则策略语句会对包含Bucket Owner在内的所有访问者生效。即使是默认拥有所有访问权限的Bucket Owner，如果触发拒绝策略，其访问请求也会被拒绝。
- 在Bucket Policy的策略语句中，如果Principal为通配符星号（*），但不包含Condition，则策略语句只会对除Bucket Owner以外的所有访问者生效。对于默认拥有所有访问权限的Bucket Owner，不会触发拒绝策略，其访问请求不会被拒绝。

1. 示例一：授予指定RAM用户读写权限

    当您希望允许自己团队的指定成员或合作方的指定成员上传、下载、管理存储空间中的文件时，您可以通过Bucket Policy在存储空间级别直接为这些成员对应的RAM用户授予权限，而无需为每个RAM用户单独设置访问策略。以下示例用于授予指定RAM用户（UID为27737962156157xxxx和20214760404935xxxx）对目标存储空间（examplebucket）的读写权限。

    > 重要
    以下允许策略语句中，由于没有授予指定RAM用户列举存储空间的权限，因此指定RAM用户无法在阿里云控制台的Bucket列表页面查看所有的存储空间，找到目标的存储空间，然后点击进入。指定RAM用户可以通过添加收藏路径来访问目标存储空间，而无需拥有列举存储空间的权限。具体操作，请参见访问路径。

    ```json
    {
        "Version":"1",
        "Statement":[
            {
                "Effect":"Allow",
                "Action":[
                    "oss:GetObject",
                    "oss:PutObject",
                    "oss:GetObjectAcl",
                    "oss:PutObjectAcl",
                    "oss:AbortMultipartUpload",
                    "oss:ListParts",
                    "oss:RestoreObject",
                    "oss:GetVodPlaylist",
                    "oss:PostVodPlaylist",
                    "oss:PublishRtmpStream",
                    "oss:ListObjectVersions",
                    "oss:GetObjectVersion",
                    "oss:GetObjectVersionAcl",
                    "oss:RestoreObjectVersion"
                ],
                "Principal":[
                    "27737962156157xxxx",
                    "20214760404935xxxx"
                ],
                "Resource":[
                    "acs:oss:*:174649585760xxxx:examplebucket/*"
                ]
            },
            {
                "Effect":"Allow",
                "Action":[
                    "oss:ListObjects"
                ],
                "Principal":[
                    "27737962156157xxxx",
                    "20214760404935xxxx"
                ],
                "Resource":[
                    "acs:oss:*:174649585760xxxx:examplebucket"
                ],
                "Condition":{
                    "StringLike":{
                        "oss:Prefix":[
                            "*"
                        ]
                    }
                }
            }
        ]
    }
    ```

2. 示例四：授予指定RAM用户查看存储空间并列举文件的权限
    当您希望允许自己团队的指定成员或合作方的指定成员查看存储空间的所有信息并列举其中的文件时，您可以通过Bucket Policy在存储空间级别直接为这些成员对应的RAM用户授予权限，而无需为每个RAM用户单独设置访问策略。以下示例用于授予指定RAM用户查看目标存储空间（examplebucket）的所有信息并列举其中的文件的权限。

    ```json
    {
        "Version":"1",
        "Statement":[
            {
                "Action":[
                    "oss:Get*",
                    "oss:ListObjects",
                    "oss:ListObjectVersions"
                ],
                "Effect":"Allow",
                "Principal":[
                    "20214760404935xxxx"
                ],
                "Resource":[
                    "acs:oss:*:174649585760xxxx:examplebucket"
                ]
            }
        ]
    }
    ```

3. 示例八：限制只能从指定VPC的指定IP地址网段访问

    当您的存储空间需要限制只能从指定VPC的指定IP地址访问时，您可以创建两条拒绝策略语句：

    使用acs:SourceVpc条件关键字创建一条拒绝策略语句，用于阻止来自其他VPC或公网的请求。对于来自其他VPC的请求，会被识别为不符合指定VPC ID条件，触发策略中的拒绝规则。对于来自公网的请求，由于公网访问不包含VPC信息，因此也会被识别为不符合指定VPC ID条件，触发策略中的拒绝规则。

    使用acs:SourceIp条件关键字和acs:SourceVpc条件关键字创建一条拒绝策略语句，用于阻止指定VPC网段之外的请求。

    将以上两条拒绝策略语句添加到Bucket Policy后，两者之间的逻辑关系为或，即满足任一条件就会触发拒绝。以下示例用于拒绝除指定VPC（ID为t4nlw426y44rd3iq4xxxx）的指定IP地址网段（IP地址网段为192.168.0.0/16）以外的所有访问者对目标存储空间（examplebucket）进行读取文件操作。

    重要

    - 以下拒绝策略语句中，由于Principal为通配符星号（*），且包含Condition，因此该拒绝策略语句会对包含Bucket Owner在内的所有访问者生效。添加以下拒绝策略语句后，即使是默认拥有所有访问权限的Bucket Owner，如果不是从指定VPC的指定IP地址网段访问，其访问请求也会被拒绝。
    - 以下拒绝策略语句仅用于限制访问，而不会授予任何访问权限。如果授权主体没有被授予过访问权限，您可以添加一条允许策略语句来授予其访问权限。

    ```json
    {
        "Version":"1",
        "Statement":[
            {
                "Effect":"Deny",
                "Action":[
                    "oss:GetObject"
                ],
                "Principal":[
                    "*"
                ],
                "Resource":[
                    "acs:oss:*:174649585760xxxx:examplebucket/*"
                ],
                "Condition":{
                    "StringNotEquals":{
                        "acs:SourceVpc":[
                            "vpc-t4nlw426y44rd3iq4xxxx"
                        ]
                    }
                }
            },
            {
                "Effect":"Deny",
                "Action":[
                    "oss:GetObject"
                ],
                "Principal":[
                    "*"
                ],
                "Resource":[
                    "acs:oss:*:174649585760xxxx:examplebucket/*"
                ],
                "Condition":{
                    "StringEquals":{
                        "acs:SourceVpc":[
                            "vpc-t4nlw426y44rd3iq4xxxx"
                        ]
                    },
                    "NotIpAddress":{
                        "acs:SourceIp":[
                            "192.168.0.0/16"
                        ]
                    }
                }
            }
        ]
    }
    ```
