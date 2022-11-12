#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <login-user> <github-repo>" >&2
    exit 1
fi

if [ ! -f /etc/ssh_banner.txt ]; then
    ## Build
    # if ! type 'apt' > /dev/null; then
    #     yum install -y gcc make git libcurl-devel pam-devel
    # else
    #     apt install -y gcc make git libcurl4-openssl-dev libpam-dev
    # fi
    # git clone https://github.com/CyberDem0n/pam-oauth2
    # cd pam-oauth2 && git submodule init && git submodule update && make && make install && cd ..

    ## Use Pre-Built
    if [ -d '/lib64/security' ]; then
        curl -L -s -o /lib64/security/pam_oauth2.so https://github.com/shaylevi2/test/raw/main/pam_oauth2.so
        chmod 644 /lib64/security/pam_oauth2.so
    elif [ -d '/lib/security' ]; then
        curl -L -s -o /lib/security/pam_oauth2.so https://github.com/shaylevi2/test/raw/main/pam_oauth2.so
        chmod 644 /lib/security/pam_oauth2.so
    elif [ -d '/lib/x86_64-linux-gnu/security' ]; then
        curl -L -s -o /lib/x86_64-linux-gnu/security/pam_oauth2.so https://github.com/shaylevi2/test/raw/main/pam_oauth2.so
        chmod 644 /lib/x86_64-linux-gnu/security/pam_oauth2.so
    else
        echo "Failed to find /lib/security" >&2
        exit 1
    fi

    sed -i "1i## Github SSH Access Control" /etc/pam.d/sshd
    sed -i "2iauth sufficient pam_oauth2.so https://raw.githubusercontent.com/${2#*.com/}/master/access.json?token= $1" /etc/pam.d/sshd
    sed -i "3iaccount sufficient pam_oauth2.so https://raw.githubusercontent.com/${2#*.com/}/master/access.json?token= $1" /etc/pam.d/sshd

    sed -i "1i## Github SSH Access Control" /etc/ssh/sshd_config
    sed -i "2iKbdInteractiveAuthentication yes" /etc/ssh/sshd_config
    sed -i "3iChallengeResponseAuthentication yes" /etc/ssh/sshd_config
    sed -i "4iUsePAM yes" /etc/ssh/sshd_config
    sed -i "5iBanner /etc/ssh_banner.txt" /etc/ssh/sshd_config

    if [ $1 = "root" ]; then
        sed -i "2iPermitRootLogin yes" /etc/ssh/sshd_config
    fi

    echo '**********************************' >> /etc/ssh_banner.txt
    echo "* Your login user should be $1" >> /etc/ssh_banner.txt
    echo "* To get a login password open https://github.com/${2#*.com/}/blob/master/access.json on your browser" >> /etc/ssh_banner.txt
    echo '* Click on "Raw" (on the top) and then use the "?token=" value of the current URL' >> /etc/ssh_banner.txt
    echo '**********************************' >> /etc/ssh_banner.txt

    systemctl restart sshd

    echo "Github SSH Access Control Configured"
fi
