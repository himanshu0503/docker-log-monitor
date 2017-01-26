FROM shipimg/microbase:master.727

ADD . /home/docker-log-monitor

CMD ["node",  "/home/docker-log-monitor/loopScript.js"]