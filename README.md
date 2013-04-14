# Example Plupload + S3 application

Everything is pretty much explained [here](https://github.com/moxiecode/plupload/wiki/Upload-to-Amazon-S3-using-HTML5-runtime).
This is a demo application, **do not bindly copy-paste to your app**, there
are some dangerous things in here.

## Dependencies

You need Ruby and Sinatra for this app to run.

    # Once you have ruby and rubygems installed :
    $ gem install sinatra # sudo may be required, depending on your setup

## Running the app

Make sure you configure the global : `$ACL`, `$BUCKET`, `$AWS_SECRET`. Then :

    ruby app.rb