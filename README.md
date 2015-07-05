mqtt_conn_log
====
a simple logging tool for TCP connections.

how to use
----

    
    $ sudo apt-get install tcpdump
    $ sudo gem install mqtt
    $ sudo gem install pit
    
    $ EDITOR=vi pit set mqtt_conn_log
    
        ---
        mqtt_host: mqtt.example.com
        mqtt_port: 1883
        mqtt_user: mqtt_user
        mqtt_pass: mqtt_pass
        mqtt_topic: mqtt_topic
    
    $ cd ~
    $ mkdir -p work
    $ cd work
    $ git clone https://github.com/yoggy/mqtt_conn_log.git
    $ cd mqtt_conn_log
    $ sudo tcpdump -l -i eth0 "tcp[13] & 18 == 18" 2>/dev/null | ./mqtt_conn_log.rb
    

for supervisor
----
    $ cd ~/work/mqtt_conn_log
    $ cp sudo cp mqtt_conn_log.conf.sample /etc/supervisor/conf.d/mqtt_conn_log.conf
    $ sudo vi /etc/supervisor/conf.d/mqtt_tiny_clock_pub.conf
      (fix path, etc...)
    $ sudo supervisorctl reread
    $ sudo supervisorctl add mqtt_tiny_clock_pub
    $ sudo supervisorctl status
    mqtt_tiny_clock_pub                  RUNNING    pid 8192, uptime 0:00:30

