chef_usage_per_org
===============

Research on hacking to get usage per org

# list of orgs

## pull down the pivotal user pem from the Chef Server

Example:

    ssh -i "/path/to/your.pem" ubuntu@host
    cd ~
    sudo cp /etc/opscode/pivotal.pem .
    sudo chown ubuntu:ubuntu pivotal.pem
    ll ~
    exit
    cd ~/.chef
    scp -i "/path/to/your.pem" ubuntu@host:/home/ubuntu/pivotal.pem 
    # be careful, but clean up the copy
    # ssh -i "/path/to/your.pem" ubuntu@host
    # rm -rf pivotal.pem


## Install knife-opc

See: https://github.com/chef/knife-opc

Update your knife.rb to have:

    node_name                'pivotal'
    client_key               '~/.chef/pivotal.pem'

run 

    knife opc org list -a


## On Chef Server

    sudo chef-server-ctl org-list

## On knife workstation

With pivotal user may be able to use:

    knife exec -E 'p api.get("/organizations" )' -s https://chef.yourorg.com

If you are not the pivotal user 

    ERROR: You authenticated successfully to https://chef.yourorg.com as <username> but you are not authorized for this action
    Response:  missing create permission

# count of nodes per organization

Iterate through a file created from the above `list of orgs`

## From knife workstation:

    while read p; do                                                                           
    echo $p
    echo "knife exec -E 'p api.get(\"/organizations/$p/nodes\").size' -s https://chef.yourorg.com" | bash
    done <org_list

or simply run:

    ./org_usage.sh 

if you want to send to slack then:

    ./org_usage.sh "https://hooks.slack.com/services/<your token>" "https://chef.yourorg.com" "channel" "username"
