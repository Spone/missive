module Missive
  # Stamp is a thin layer over Postmark's official library,
  # that improves it for Missive's needs.
  #
  # Main features:
  # - implementation of the [Bulk API](https://postmarkapp.com/developer/api/bulk-email)
  module Stamp
    class ApiClient < ::Postmark::ApiClient
      # client.deliver_in_bulk(
      #   from: "david@example.com",
      #   subject: "Hey, you!",
      #   html_body: "<p>Hello, {{name}}!</p>",
      #   text_body: "Hello, {{name}}!",
      #   messages: [
      #     {
      #       to: "jane.doe@example.com",
      #       template_model: { name: "Jane" }
      #     },
      #     {
      #       to: "john.doe@example.com",
      #       template_model: { name: "John" }
      #     }
      #   ]
      # )
      def deliver_in_bulk(message_hash = {})
        data = serialize(::Postmark::MessageHelper.to_postmark(message_hash))

        with_retries do
          format_response http_client.post("email/bulk", data)
        end
      end

      def get_bulk_status(id)
        format_response http_client.get("email/bulk/#{id}")
      end
    end
  end
end

# Example body
# {
#   "From": "david@example.com",
#   "ReplyTo": "staff@example.com",
#   "Subject": "This is a bulk email for {{FirstName}}",
#   "HtmlBody": "<html><body>Hi, {{FirstName}}</body></html>",
#   "TextBody": "Hi, {{FirstName}}",
#   "TemplateId": null,
#   "TemplateAlias": null,
#   "Metadata": {
#     "color": "blue",
#     "client-id": "12345"
#   },
#   "MessageStream": "broadcast",
#   "TrackOpens": true,
#   "TrackLinks": "None",
#   "Attachments": [
#     {
#       "Name": "readme.txt",
#       "Content": "dGVzdCBjb250ZW50",
#       "ContentType": "text/plain"
#     }
#   ],
#   "Headers": [
#     {
#       "Name": "CUSTOM-HEADER",
#       "Value": "value"
#     }
#   ],
#   "InlineCss": true,
#   "Tag": "Newsletter",
#   "Messages": [
#     {
#       "To": "receiver1@example.com",
#       "TemplateModel": {
#         "FirstName": "Bob"
#       },
#       "Metadata": {
#         "color": "blue",
#         "client-id": "12345"
#       },
#       "Headers": [
#         {
#           "Name": "CUSTOM-HEADER",
#           "Value": "value"
#         }
#       ]
#     },
#     {
#       "To": "receiver2@example.com",
#       "Cc": "cc@example.com",
#       "TemplateModel": {
#         "FirstName": "Frieda"
#       },
#       "Metadata": {
#         "color": "blue",
#         "client-id": "12345"
#       },
#       "Headers": [
#         {
#           "Name": "CUSTOM-HEADER",
#           "Value": "value"
#         }
#       ]
#     },
#     {
#       "To": "receiver3@example.com",
#       "Bcc": "bcc@example.com",
#       "TemplateModel": {
#         "FirstName": "Elijah"
#       },
#       "Metadata": {
#         "color": "blue",
#         "client-id": "12345"
#       },
#       "Headers": [
#         {
#           "Name": "CUSTOM-HEADER",
#           "Value": "value"
#         }
#       ]
#     }
#   ]
# }
