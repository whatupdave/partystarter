# Party Starter
Run up a minecraft server, backed by S3 on Digital ocean.

By default this runs up a 1GB node on Digital Ocean which currently costs $0.015 / hour. Or $10 if you leave it running for the whole month.

When you start it, it pulls the world down from S3 and puts it back when you stop the server.

## Start the party!

First make sure you have [Terraform](http://www.terraform.io/) installed.

Then create a `terraform.tfvars` file:

    cp terraform.tfvars.sample terraform.tfvars

Then edit the file and add your credentials:

    aws_access_key          # for s3 data persistance
    aws_secret_key          #
    s3_path                 # eg: s3://my-bucket/server1

    do_token                # to run nodes

    key_file                # private key so you can ssh into nodes

Now you should be ready to start the party:

    $ ./party start
    digitalocean_droplet.node: Creating...
      image:      "" => "docker"
      name:       "" => "node"
      region:     "" => "sfo1"
      size:       "" => "1gb"
      ssh_keys.#: "" => "1"
      ssh_keys.0: "" => "..."
    digitalocean_droplet.node: Provisioning with 'remote-exec'...
    digitalocean_droplet.node: Creation complete

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

    Outputs:

      server = 192.241.210.173

    [21:08:36] [Server thread/INFO]: Starting minecraft server version 1.7.10
    [21:08:36] [Server thread/INFO]: Loading properties
    [21:08:36] [Server thread/INFO]: Default game type: SURVIVAL
    [21:08:36] [Server thread/INFO]: Generating keypair
    [21:08:37] [Server thread/INFO]: Starting Minecraft server on *:25565
    [21:08:37] [Server thread/INFO]: Preparing level "world"
    [21:08:37] [Server thread/INFO]: Preparing start region for level 0
    [21:08:38] [Server thread/INFO]: Done (1.129s)! For help, type "help" or "?"

At this point you can interact with the Minecraft console, or you know, just play the game. Connect to the server address in the Outputs section.

When you're all done:

    ./party stop

This will stop Minecraft, save the data back up to S3 and clean up the mess.
