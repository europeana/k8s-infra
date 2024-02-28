This folder contains a copy of the current fluentd configuration, but then tailored to be run in a local environment
There is no need to setup a kubernetes cluster or ELK, simply open a terminal, go to this folder, run
`fluentd -c local.conf` and see the results being written to files in the result folder. To retry delete the generated
.log and .pos files and restart fluentd.