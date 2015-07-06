#!/usr/bin/ruby

require 'rubygems'
require 'mqtt'
require 'pit'
require 'json'
require 'resolv'
require 'pp'

$stdout.sync = true

$config = Pit.get("mqtt_conn_log", :require => {
    "mqtt_host"  => "mqtt.example.com",
    "mqtt_port"  => 1883,
    "mqtt_user"  => "mqtt_user",
    "mqtt_pass"  => "mqtt_pass",
    "mqtt_topic" => "mqtt_topic",
})

def split_ip_port(str)
    ridx = str.rindex(".")
    ip   = str[0, ridx]
    port = str[ridx+1, str.size - ridx]
    
    [ip, port]
end

def gethostbyname(ip_str)
    host = ip_str
    
    begin
        host = Resolv.getname(ip_str)
    rescue Exception => e
    end
    
    host
end

MQTT::Client.connect(
    :remote_host => $config['mqtt_host'],
    :remote_port => $config['mqtt_port'].to_i,
    :username    => $config['mqtt_user'],
    :password    => $config['mqtt_pass']
) do |c|
    while l = STDIN.gets
        l.chomp!
        v = l.split(/\s/)
    
        #
        # src_host   dst_host
        #   |          |
        #   |  syn     |
        #   |--------->|
        #   |          |
        #   | syn+ack  |
        #   |<---------|
        #   |          |
        #   |  ack     |
        #   |--------->|
        #   |          |
        #        .
        #        .
        #        .
        # syn+ack 
        #   21:01:02.899447 IP dst_host_ip.http > src_host_ip.12345: Flags [S.], seq ??????????, ack ?????????,....
        #
    
        src_str = v[4][0, v[4].size-1]  # remove colon
        dst_str = v[2]
    
        (src_ip, src_port) = split_ip_port(src_str)
        (dst_ip, dst_port) = split_ip_port(dst_str)

        src_host = gethostbyname(src_ip)
        dst_host = gethostbyname(dst_ip)
    
        h = {}
        h["timestamp"] = v[0]
        h["src_ip"]    = src_ip
        h["src_host"]  = src_host
        h["src_port"]  = src_port
        h["dst_ip"]    = dst_ip
        h["dst_host"]  = dst_host
        h["dst_port"]  = dst_port
    
        publish_str = JSON.generate(h)
    
    	topic = $config["mqtt_topic"]

        puts "mqtt_publish : topic=#{topic}, publish_str=#{publish_str}"
        c.publish(topic, publish_str)
    end
end
