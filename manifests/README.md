To use this dev manifest:

* copy splunk-dev-example.yml to splunk-dev.yml
* Edit the IP range (10.245.0.60-10.245.0.70) and gateway and DNS to suit your environment
* Use the following option when deploying: `--vars-store=~/creds.yml` to allow creation/maintaining generated certificates and keys
* Watch out for the  `optimistic_about_file_locking: 1` flag that allows running splunk inside docker, it is only for dev