# Party Starter
Run up a minecraft server, backed by S3 on Digital ocean.

## How it works

Add terraform vars for:

    aws_access_key          # for s3 data persistance
    aws_secret_key          #
    s3_path                 # eg: s3://my-bucket/server1

    do_token                # to run nodes

    key_file                # private key so you can ssh into nodes


Start the party:

    ./party start

Stop it

    ./party stop

