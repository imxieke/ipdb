#!/usr/bin/env bash
# Collect and Process IP

# 移动 联通 电信 电信通 长城宽带 鹏博士 铁通(移动) 网通(联通) 卫通 歌华 方正 华数
# 电信通 AS 已与中移铁通互联 
# 铁通 合并至移动 (中移铁通) 网通 合并至联通

# 获取全球 IPV4 IPV6 ASN 信息
# 获取全球所有 IP 分配国家 缩写

# 将所有信息细分到国家

# 获取所有 ASN IPV4 IPV6 进行排序
# 获取 ASN 信息
# 获取 IP 所归属的运营商

# cidr 无类别域间路由，Classless Inter-Domain Routing 

# chinatelecom 	中国电信		chinanet 中国公用计算机互联网
# chinaunicom 	中国联通		uninet
# cmcc 			中国移动 		cmnet 	China mobile Communications  
# cttt 			中国铁通 		China Tietong Telecom
# cernet 		中国教育网 	China Education and Research Network 中国教育和科研计算机网
# gwbn 			长城宽带 		Great Wall Broadband Network  中国长城互联网 CGWNET
# drpeng 		鹏博士
# cstnet 		中国科技网
# chinagbn 		中国金桥信息网 (已并入网通)
# cncnet 		中国网通公用互联网
# csnet 		中国卫星集团互联网
# cietnet 		中国国际经济贸易互联网

# SP名称对应关键字
# 教育网 MAINT-CERNET-AP 
# 网通 MAINT-CNCGROUP
# 网通 MAINT-CNCGROUP-RRMAINT-CNCGROUP-BJ MAINT-CN-UNICOM
# 电信 MAINT-CHINANET
# 铁通 MAINT-CN-CRTC 
# CNNIC MAINT-CNNIC-AP
# 金桥信息网 MAINT-CHINAGBN-AP
# 普天 MAINT-CN-PUTIAN
# 格式 登记机构|获得该IP段的国家/组织|资源类型|起始IP|IP段长度|分配日期|分配状态
SAVETO=$(pwd)/'lists'
BASE=$(pwd)/'lists/base'

# 管理机构
ORG="apnic afrinic arin lacnic ripencc"

ASN_URL='http://bgp.potaroo.net/as1221/asnames.txt'
APNIC_IP_URL='http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'

BASE_IP_FILE=${BASE}/ip.txt
ASN_FILE=${SAVETO}/asn.txt
APNIC_IP_FILE=${SAVETO}/apnic-$(date +%Y%m%d).txt
CN_IPV4_FILE=${SAVETO}/cn-ipv4-$(date +%Y%m%d).txt
CN_IPV6_FILE=${SAVETO}/cn-ipv6-$(date +%Y%m%d).txt
CN_ASN_FILE=${SAVETO}/cn-asn-$(date +%Y%m%d).txt
CIDR_FILE=${SAVETO}/cidr-$(date +%Y%m%d).txt # All IP Segment

COUNTRY_FILE=${BASE}/country-$(date +%Y%m%d).txt
COUNTRY_PATH=${SAVETO}/country

ASN_FILE=${BASE}/asn-$(date +%Y%m%d).txt
CIDR_FILE=${BASE}/cidr-$(date +%Y%m%d).txt
IPV4_FILE=${BASE}/ipv4-$(date +%Y%m%d).txt
IPV6_FILE=${BASE}/ipv6-$(date +%Y%m%d).txt

function update_ip()
{
	curl -sSLo ${BASE}/afrinic.txt https://mirrors.xieke.org/ip/afrinic-latest.txt
	curl -sSLo ${BASE}/apnic.txt https://mirrors.xieke.org/ip/apnic-latest.txt
	curl -sSLo ${BASE}/arin.txt https://mirrors.xieke.org/ip/arin-latest.txt
	curl -sSLo ${BASE}/lacnic.txt https://mirrors.xieke.org/ip/lacnic-latest.txt
	curl -sSLo ${BASE}/ripe.txt https://mirrors.xieke.org/ip/ripe-latest.txt
	curl -sSLo ${BASE}/asn.txt https://mirrors.xieke.org/ip/asn-latest.txt
}

function get_global_ip()
{
	echo "=> Generate total ip"
	cat ${BASE}/apnic.txt | grep -v summary | grep '^apnic|' | awk -F '|' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' > ${BASE_IP_FILE}
	cat ${BASE}/afrinic.txt | grep -v summary | grep '^afrinic|' | awk -F '|' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' >> ${BASE_IP_FILE}
	cat ${BASE}/arin.txt | grep -v summary | grep '^arin|' | awk -F '|' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' >> ${BASE_IP_FILE}
	cat ${BASE}/lacnic.txt | grep -v summary | grep '^lacnic|' | awk -F '|' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' >> ${BASE_IP_FILE}
	cat ${BASE}/ripencc.txt | grep -v summary | grep '^ripencc|' | awk -F '|' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' >> ${BASE_IP_FILE}

	echo "=> Generate ASN"
	cat ${BASE_IP_FILE} | grep 'asn' > ${ASN_FILE}

	echo "=> Generate IPV4"
	cat ${BASE_IP_FILE} | grep 'ipv4' > ${IPV4_FILE}

	echo "=> Generate IPV6"
	cat ${BASE_IP_FILE} | grep 'ipv6' > ${IPV6_FILE}

	echo "=> Start Convert IP Segment "
	process_ip_address_segment
}

function process_ip_address_segment()
{
	SEG1="256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304"
	SEG2=(24 23 22 21 20 19 18 17 16 15 14 13 12 11 10)
	if [[ $(uname -s) == 'Darwin' ]]; then
		SED="sed -i .bak "
	else
		SED="sed -i"
	fi
	TIMES=0
	echo "Convert IPV4 Segment"
	for seg1 in ${SEG1}; do
		${SED} "s/\/${seg1}\//\/${SEG2[$TIMES]}\//g" ${IPV4_FILE}
		((TIMES = TIMES + 1))
	done
	echo "Convert Complete"

	# macOS version sed backup file
	if [[ -f ${IPV4_FILE}.bak ]]; then
		rm -fr ${IPV4_FILE}.bak
	fi
}

function get_all_asn()
{
	curl -sSLo ${ASN_FILE} ${ASN_URL}
}

function get_all_country()
{
	echo "=> get All Country"
	# cat ${APNIC_IP_FILE} | grep -v summary |  grep -v '|apnic|' | grep 'apnic|' | awk -F '|' '{print $2}' | sort  | uniq > ${COUNTRY_FILE}
	cat ${BASE_IP_FILE} | awk -F '/' '{print $2}' | sort | uniq > ${COUNTRY_FILE}
}

function cn_ip()
{
	get_apnic_ip_list
	grep 'apnic|CN|ipv4' ${APNIC_IP_FILE} | awk -F '|' '{print $4"/"$5"/"$6}' > ${CN_IPV4_FILE}
	grep 'apnic|CN|ipv4' ${APNIC_IP_FILE} | awk -F '|' '{print $4"/"$5"/"$6}' > ${CN_IPV4_FILE}
	grep 'apnic|CN|ipv6' ${APNIC_IP_FILE} | awk -F '|' '{print $4"/"$5"/"$6}' > ${CN_IPV6_FILE}
	grep 'apnic|CN|asn' ${APNIC_IP_FILE} | awk -F '|' '{print $4}' > ${CN_ASN_FILE}
	cat ${APNIC_IP_FILE} | grep -v summary | grep ipv4 | awk -F '|' '{print $4"/"$5"/"$6}' > ${CIDR_FILE}
}

function gen_country_ip()
{
	if [[ ! -d ${COUNTRY_PATH} ]]; then
		mkdir ${COUNTRY_PATH}
	fi

	DEST=${COUNTRY_PATH}/$1

	if [[ ! -d ${DEST} ]]; then
		mkdir -p ${DEST}
	fi

	echo "=> Generate $1 ASN"
	cat ${ASN_FILE} | grep $1 | awk -F '/' '{print $4"/"$5}' > ${COUNTRY_PATH}/$1/asn.txt
	cat ${ASN_FILE} | grep $1 | awk -F '/' '{print $4"/"$6}' > ${COUNTRY_PATH}/$1/asn_time.txt

	echo "=> Generate $1 IPV4"
	cat ${IPV4_FILE} | grep $1 | awk -F '/' '{print $4"/"$5}' | sort -t"." -k1,1n -k2,2n -k3,3n -k4,4n > ${COUNTRY_PATH}/$1/ipv4.txt
	cat ${IPV4_FILE} | grep $1 | awk -F '/' '{print $4"/"$6}' | sort -t"." -k1,1n -k2,2n -k3,3n -k4,4n > ${COUNTRY_PATH}/$1/ipv4_time.txt

	echo "=> Generate $1 IPV6"
	cat ${IPV6_FILE} | grep $1 | awk -F '/' '{print $4"/"$5}' > ${COUNTRY_PATH}/$1/ipv6.txt
	cat ${IPV6_FILE} | grep $1 | awk -F '/' '{print $4"/"$6}' > ${COUNTRY_PATH}/$1/ipv6_time.txt
}


function gen_total()
{
	cat ${ASN_FILE} | awk -F '/' '{print $4"/"$5}' | sort -n > ${SAVETO}/asn-$(date +%Y%m%d).txt
	cat ${IPV4_FILE} | awk -F '/' '{print $4"/"$5}' | sort -t"." -k1,1n -k2,2n -k3,3n -k4,4n > ${SAVETO}/ipv4-$(date +%Y%m%d).txt
	cat ${IPV6_FILE}| awk -F '/' '{print $4"/"$5}' | sort > ${SAVETO}/ipv6-$(date +%Y%m%d).txt
}

function start()
{
	update_ip 		# 获取最新 IP
	get_global_ip 	# 合并 IP 生成全球 IP 列表 并分离 ASN IPV4 IPV6
	get_all_country # 获取所有国家名称缩写

	# 分离所有国家的 ASN IPV4 IPV6 
	COUNTRYS=$(cat ${COUNTRY_FILE})
	for country in ${COUNTRYS}; do
		gen_country_ip ${country}
	done

	# get_all_asn 
}

# start
gen_total
