require 'sinatra'
require 'erb'
require 'base64'
require 'json'
require 'digest/sha1'

$ACL = 'public-read' # Change this according to your needs
$BUCKET = 'YOUR_BUCKET'
$AWS_SECRET = 'YOUR_SECRET'

def policy
  conditions = [
    ["starts-with", "$utf8", ""],
    # Change this path if you need, but adjust the javascript config
    ["starts-with", "$key", "uploads"],
    ["starts-with", "$filename", ""],
    { "bucket" => $BUCKET },
    { "acl" => $ACL }
  ]

  policy = {
    # Valid for 3 hours. Change according to your needs
    'expiration' => (Time.now.utc + 3600 * 3).iso8601,
    'conditions' => conditions
  }

  Base64.encode64(JSON.dump(policy)).gsub("\n","")
end

def signature
  Base64.encode64(
    OpenSSL::HMAC.digest(
      OpenSSL::Digest::Digest.new('sha1'),
      $AWS_SECRET, policy
    )
  ).gsub("\n","")
end

get '/' do
  erb :page, :layout => false
end

__END__

@@ page
<!doctype html>
<html>
  <head>
  <title>Pluload S3 demo</title>

  <style type="text/css">@import url(/plupload/src/jquery.plupload.queue/css/jquery.plupload.queue.css);</style>
  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>

  <!-- Load plupload and all it's runtimes and finally the jQuery queue widget -->
  <script type="text/javascript" src="/plupload/src/moxie/bin/js/moxie.js"></script>
  <script type="text/javascript" src="/plupload/src/plupload.js"></script>
  <script type="text/javascript" src="/plupload/src/jquery.plupload.queue/jquery.plupload.queue.js"></script>

  <script>
    $(function() {
      $("#uploader").pluploadQueue({
        // General settings
        runtimes : 'flash,html5',

        // Flash settings
        flash_swf_url : '/plupload/src/moxie/bin/flash/Moxie.swf',

        // S3 specific settings
        url : "https://<%= $BUCKET %>.s3.amazonaws.com:443/",
        file_name_name: false, // Custom option to our fork to remove file_name_name
        multipart: true,
        multipart_params : {
          // Dummy filename to ensure the field is sent in HTML just like Flash
          // This allow to have a consistent AWS policy for both HTML and Flash
          filename: 'filename',
          utf8: true,

          AWSAccessKeyId: "YOUR_AWS_ACCESS_KEY_ID",
          acl: "public-read", // See http://docs.aws.amazon.com/AmazonS3/latest/dev/ACLOverview.html#CannedACL
          // See Generating a policy and a signature
          policy: "<%= policy %>",
          signature: "<%= signature %>",

          // This is basically the resulting location of the file on S3.
          // See http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPOST.html#RESTObjectPOST-requests-form-fields
          //
          // WARNING : Change this to suite your needs.
          // You need to insert some sort of unique identifier to avoid
          // overriding files if they share the same filename.
          key: "uploads/${filename}",
        }
      });
    });
  </script>
  </head>

  <body>
    <form>
      <div id="uploader"></div>
    </form>
  </body>
</html>