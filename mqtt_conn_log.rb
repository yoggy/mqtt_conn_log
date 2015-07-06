#!/usr/bin/ruby

require 'rubygems'
require 'mqtt'
require 'pit'
require 'json'
require 'pp'

$stdout.sync = true

$config = Pit.get("mqtt_conn_log", :require => {
	"mqtt_host"  => "mqtt.example.com",
	"mqtt_port"  => 1883,
	"mqtt_user"  => "mqtt_user",
	"mqtt_pass"  => "mqtt_pass",
	"mqtt_topic" => "mqtt_topic",
})

def split_host_port(str)
  ridx = str.rindex(".")
  host = str[0, ridx]
  port = str[ridx+1, str.size - ridx]

  [host, port]
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
    
        (src_host, src_port) = split_host_port(src_str)
        (dst_host, dst_port) = split_host_port(dst_str)
    
        h = {}
        h["timestamp"] = v[0]
        h["src_host"]  = src_host
        h["src_port"]  = src_port
        h["dst_host"]  = dst_host
        h["dst_port"]  = dst_port
    
        publish_str = JSON.generate(h)
    
    	topic = $config["mqtt_topic"]

        puts "mqtt_publish : topic=#{topic}, publish_str=#{publish_str}"
        c.publish(topic, publish_str)
    end
end
