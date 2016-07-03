mqtt_conn_log
====
a simple logging tool for TCP connections.

how to use
----
    
    $ sudo apt-get install tcpdump
    $ sudo gem install mqtt
    $ cd ~
    $ mkdir -p work
    $ cd work
    $ git clone https://github.com/yoggy/mqtt_conn_log.git
    $ cd mqtt_conn_log
    $ cp mqtt_config.yaml.sample mqtt_config.yaml
    $ vi mqtt_config.yaml

        host:     mqtt.example.com
        port:     1883
        use_auth: true
        username: username
        password: password
        topic: publish_topic
      
    $ sudo tcpdump -l -n -i eth0 "tcp[13] & 18 == 18" 2>/dev/null | ./mqtt_conn_log.rb
    

for supervisor
----
    $ cd ~/work/mqtt_conn_log
    $ cp sudo cp mqtt_conn_log.conf.sample /etc/supervisor/conf.d/mqtt_conn_log.conf
    $ sudo vi /etc/supervisor/conf.d/mqtt_conn_log.conf
      (fix path, etc...)
    $ sudo supervisorctl reread
    $ sudo supervisorctl add mqtt_conn_log
    $ sudo supervisorctl status
    mqtt_conn_log                  RUNNING    pid 8192, uptime 0:00:30

