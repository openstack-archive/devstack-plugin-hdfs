#!/bin/bash

cmd=$1

expect <<EOD
spawn $cmd
expect {
    "(yes/no)?" {send "yes\n"; exp_continue}
}
EOD
