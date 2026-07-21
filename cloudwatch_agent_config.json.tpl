{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/ssl_access_log", 
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/ssl_error_log", 
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ]
      }
    }
  }
}
