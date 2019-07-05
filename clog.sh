#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Created by Johnnyxsu from TencentCloud
url=$1

Http_code(){
echo "状态码分布如下:"
echo "   次数 状态码"
zcat $url|awk '{print $8}'|sort|uniq -c|sort -n
}

Http_code_to_url(){
echo && read -e -p "请输入过滤的状态码：" code
echo $code"状态码url分布"
echo "url出现次数 url"
zcat $url|awk '{if($8=='$code') {print $4}}'|sort|uniq -c|sort -nrk 1 -t' '
}

CDN_QPS_and_hit(){
QPS=`zcat $url|wc -l`
hit_num=`zcat $url|grep " hit"|wc -l`
ratio=`awk 'BEGIN{printf "%.2f%\n",('$hit_num'/'$QPS')*100}'`
echo "访问日志命中数为：" $hit_num
echo "访问日志总请求数为：" $QPS
echo "当前日志请求命中率为："$ratio
}

Http_code_to_url_noparameter(){
echo && read -e -p "请输入过滤的状态码：" code
echo $code"状态码url分布（去参）"
echo "url出现次数 url"
zcat $url|awk '{if( $8 == '$code' ) {print $4}}'|awk -F'?' '{print $1}'|sort|uniq -c|sort -nrk 1 -t' '
}

Http_code_to_Referer(){
echo && read -e -p "请输入过滤的状态码：" code
echo "  出现次数 referer"
zcat $url|awk '{if( $8 == '$code' ) {print $9}}'|sort|uniq -c|sort -nrk 1 -t' '
}

Http_code_to_IP(){
echo && read -e -p "请输入过滤的状态码：" code
echo && read -e -p "输入需要打印的行（如果为空则全部打印）：" line
if [ ! $line ] 
then
	zcat $url|awk '{if($8=='$code') {print $2}}'|sort|uniq -c|sort -nrk 1 -t' '
else
	zcat $url|awk '{if($8=='$code') {print $2}}'|sort|uniq -c|sort -nrk 1 -t' '|head -n $line
fi
}

Http_code_to_log(){
echo && read -e -p "请输入过滤的状态码：" code
echo && read -e -p "输入需要打印的行（如果为空则全部打印）：" line
if [ ! $line ]
then
	zcat $url|awk '{if($8=='$code') {print $0}}'
else
	zcat $url|awk '{if($8=='$code') {print $0}}'|head -n $line
fi
}

IP_to_log(){
echo && read -e -p "请输入需要过滤的IP：" IP
echo && read -e -p "请输入需要过滤的状态码（空则不对状态码过滤）：" code
echo && read -e -p "请输入需要过滤的url关键字（空则不对url过滤）：" ur
if [[ ! $code && ! $ur ]]
then
	zcat $url|grep $IP
elif [ ! $ur ]
then
	zcat $url|grep $IP|awk '{if( $8 == '$code' ) {print $0}}'
elif [ ! $code ]
then
	zcat $url|grep $IP|grep $ur
else
	zcat $url|grep $IP|awk '{if( $8 == '$code' ) {print $0}}'|grep $ur
fi

}

echo -e "  CDN日志分析脚本 ${Red_font_prefix}[${sh_ver}]${Font_color_suffix}

  ${Green_font_prefix}1.${Font_color_suffix} 统计日志状态码
  ${Green_font_prefix}2.${Font_color_suffix} 请求命中率
  ${Green_font_prefix}3.${Font_color_suffix} 统计特定状态码对应访问URL
  ${Green_font_prefix}4.${Font_color_suffix} 统计特定状态码对应访问URL（去除参数）
  ${Green_font_prefix}5.${Font_color_suffix} 统计特定状态码对应Referer
  ${Green_font_prefix}6.${Font_color_suffix} 统计特定状态码对应客户端IP
  ${Green_font_prefix}7.${Font_color_suffix} 统计特定状态码对应的前N行日志
  ${Green_font_prefix}8.${Font_color_suffix} 统计特定客户端IP访问日志
 "
echo && read -e -p "请输入数字 [1-15]：" num
case "$num" in
        1)
        Http_code
        ;;
        2)
        CDN_QPS_and_hit
        ;;
        3)
        Http_code_to_url
        ;;
        4)
        Http_code_to_url_noparameter
        ;;
        5)
        Http_code_to_Referer
        ;;
        6)
        Http_code_to_IP
        ;;
        7)
        Http_code_to_log
        ;;
        8)
        IP_to_log
        ;;
        *)
        echo -e "${Error} 请输入正确的数字 [1-15]"
        ;;
esac
