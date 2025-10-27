module Missive
  # Stamp is a thin layer over Postmark's official library,
  # that improves it for Missive's needs.
  #
  # Main features:
  # - implementation of the [Bulk API](https://postmarkapp.com/developer/api/bulk-email)
  module Stamp
    class ApiClient < ::Postmark::ApiClient
      # Send bulk emails, passing a hash
      # https://postmarkapp.com/developer/api/bulk-email#send-bulk-emails
      def deliver_in_bulk(message_hash)
        data = serialize(::Postmark::MessageHelper.to_postmark(message_hash))

        with_retries do
          format_response http_client.post("email/bulk", data)
        end
      end

      # Send bulk emails, passing a message and its recipients
      # https://postmarkapp.com/developer/api/bulk-email#send-bulk-emails
      def deliver_message_in_bulk(message, recipients = [])
        data = serialize(message.to_postmark_hash.merge(messages: recipients))

        with_retries do
          response, error = take_response_of { http_client.post("email/bulk", data) }
          update_message(message, response)
          raise error if error

          format_response(response, compatible: true)
        end
      end

      # Get the status/details of a bulk API request
      # https://postmarkapp.com/developer/api/bulk-email#get-a-bulk-send-status
      def get_bulk_status(id)
        format_response http_client.get("email/bulk/#{id}")
      end
    end
  end
end
