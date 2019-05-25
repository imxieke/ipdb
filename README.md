# ip-collect
IP 收集处理并归类

所有数据来自 `apnic afrinic arin lacnic ripencc`

包含全球 ASN IPV4 IPV6
并归类出每个国家的 ASN IPV4 IPV6

在线查询 https://mirrors.xieke.org/ip/

org/country/type/ip/segment/time

if country is null then it is reserved (保留尚未分配)

```
lists/country/CN
├── asn.txt 		# ASN 信息
├── asn_time.txt 	# ASN 及 分配时间 format asn/time
├── ipv4.txt 		# IPV4 及地址段
├── ipv4_time.txt 	# IPV4 及分配时间
├── ipv6.txt 		# IPV6 及地址段
└── ipv6_time.txt 	# IPV6 及分配时间
```
