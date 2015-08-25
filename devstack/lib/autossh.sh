#!/bin/bash

cmd=$1

expect <<EOD
spawn $cmd
expect {
    "(yes/no)?" {send "yes\n"}
    -re . { exp_continue }
}
EOD
