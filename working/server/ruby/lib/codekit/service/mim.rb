# Licensed by AT&T under 'Software Development Kit Tools Agreement.' 2013 TERMS
# AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION:
# http://developer.att.com/sdk_agreement/ Copyright 2013 AT&T Intellectual
# Property. All rights reserved. http://developer.att.com For more information
# contact developer.support@att.com

require 'cgi'
require 'json'
require_relative '../model/mim'

module Att
  module Codekit
    module Service

      #@author kh455g
      class MIMService < CloudService
        SERVICE_URL = '/myMessages/v2/messages'
        DELTA_URL  = '/myMessages/v2/delta'
        NOTIFICATION_URL = '/myMessages/v2/notificationConnectionDetails'

        MAX_COUNT = 500

        def initialize(fqdn, token, opts = {})
          super(fqdn, token, opts[:client])
          @raw_response = opts[:raw_response]
        end
        
        # Obtain a list of messages 
        #
        # @note if the optional values are nil it will return both true/false
        #
        # @param count [Integer] the number of messages to obtain
        # @param opts [Hash] Optional parameters
        # 
        # @option :offset [Integer] Number of messages to offset from start
        #   (default: 0)
        # @option :messageIds [String, Array<String>] specify a start point by 
        #   message id
        # @option :isUnread [Boolean] filter messages by read flag
        # @option :isFavorite [Boolean] filter messages by favorite flag
        # @option :type [String, Array<String>] filter by message type 
        # @option :keyword [String] filter messages by endpoint/keyword
        # @option :isIncoming [String] filter messages by incoming
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Model::MessageList] an array of Message objects
        def getMessageList(count, opts={})
          url = "#{@fqdn}#{SERVICE_URL}"

          #acceptable optional values
          optional = {
            :offset => (opts[:offset] || 0).to_i,
            :messageIds => opts[:messageIds],
            :isUnread => opts[:isUnread],
            :isFavorite => opts[:isFavorite],
            :type => opts[:type],
            :keyword => opts[:keyword],
            :isIncoming => opts[:isIncoming],
          }

          count = MAX_COUNT if count.to_i > MAX_COUNT
          url << "?limit=#{count.to_i}"

          optional.each do |key, value|
            # append to url, convert our values to a comma separated list if an array
            url << %(&#{key}=#{CGI.escape(Array(value).join(","))}) unless value.nil?
          end
          
          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          return response if @raw_response
          Model::MessageList.createFromJson(response)
        end

        # Obtain a message by id
        #
        # @param id [String] the message to get by id
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Model::Message] A single message object
        def getMessage(id)
          url = "#{@fqdn}#{SERVICE_URL}/#{CGI.escape(id.to_s)}"

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          return response if @raw_response
          Model::Message.createFromJson(response)
        end

        # Return the content of a message (only available to mms messages)
        #
        # @param message_id [#to_s] the id of the message header
        # @param part_number [#to_i] the index of the content to retrieve 
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Model::MessageContent] Message content object
        def getMessageContent(message_id, part_number)
          url = "#{@fqdn}#{SERVICE_URL}"
          url << "/#{CGI.escape(message_id.to_s)}/parts/#{part_number.to_i}"

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          Model::MessageContent.createFromResponse(response)
        end

        # Get the delta information related to state
        #
        # @param state [#to_s] a representation of the state to get deltas against
        #
        # @return [Model::DeltaResponse] object that contains the deltas
        def getDelta(state)
          url = "#{@fqdn}#{DELTA_URL}"
          url << "?state=#{CGI.escape(state.to_s)}"

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          return response if @raw_response
          Model::DeltaResponse.createFromJson(response)
        end

        # Update a message or list of messages
        #
        # @param messages [Array<Model::MessageMetadata>, 
        #   Model::MessageMetadata] message object(s) that reflect the desired 
        #   state
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Integer] The http response code
        def updateMessages(messages)
          url = "#{@fqdn}#{SERVICE_URL}"

          list = Array.new
          Array(messages).each do |msg|
            list << item = { 
              "messageId" => msg.id.to_s,
              "isUnread" => msg.unread?.to_s,
              "isFavorite" => msg.favorite?.to_s
            }
          end
          payload = { "messages" => list }.to_json

          begin
            response = self.put(url, payload)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          response.code
        end

        # Update a single message 
        #
        # @param messageId [#to_s] id of message to update
        # @param unread [Boolean] true sets the message id(s) to unread
        # @param favorite [Boolean] set favorite message
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Integer] The http response code
        def updateMessage(messageId, unread=nil, favorite=nil)
          url = "#{@fqdn}#{SERVICE_URL}/#{CGI.escape(messageId.to_s.strip)}"

          item = Hash.new
          item["isUnread"] = unread unless unread.nil?
          item["isFavorite"] = favorite unless favorite.nil?

          payload = item.to_json

          begin
            response = self.put(url, payload)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          response.code
        end

        # Delete a message or list of messages
        #
        # @param message_id [#to_s, Array<#to_s>] the id of message to delete
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Integer] The http response code
        def deleteMessage(message_id)
          url = "#{@fqdn}#{SERVICE_URL}"

          ids = Array(message_id).map{|msg| msg.strip}.join(",")
          url << "?messageIds=#{CGI.escape(ids.to_s)}"

          begin
            response = self.delete(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          response.code
        end

        # Obtain info about the index associated with account
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Model::MessageIndexInfo] information about the index
        def getIndexInfo
          url = "#{@fqdn}#{SERVICE_URL}/index/info"

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          return response if @raw_response
          Model::MessageIndexInfo.createFromJson(response)
        end

        # Tell the api to create/update message index
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Integer] The http response code
        def createIndex
          url = "#{@fqdn}#{SERVICE_URL}/index"

          begin
            response = self.post(url, "")
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          response.code
        end
        alias_method :updateIndex, :createIndex
        alias_method :updateMessageIndex, :createIndex
        alias_method :createMessageIndex, :createIndex

        # Get the details associated with notifications
        #
        # @param queues [#to_s, Array<#to_s>] the resource(s) to subscribe
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return [Model::NotificationDetails] the notification details object
        def getNotificationDetails(queues)
          queues = Array(queues).map{|q| q.upcase}.join(",")

          url = "#{@fqdn}#{NOTIFICATION_URL}"
          url << "?queues=#{CGI.escape(queues.to_s)}"

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response || e.message, e.backtrace)
          end
          Model::NotificationDetails.createFromJson(response)
        end

        # Mark a message or list of messages to new unread status 
        #
        # @param message_id [#to_s, Array<#to_s>] the message id(s) to 
        #   update 
        # @param unread [Boolean] true sets the message id(s) to unread
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return (see #updateMessages)
        def updateReadFlag(message_id, unread)
          list = Array.new
          Array(message_id).each do |id|
            list << Model::MessageMetadata.new(id, unread)
          end
          updateMessages(list)
        end

        # Mark a message or list of messages as read
        #
        # @param message_id [#to_s, Array<#to_s>] the message id(s) to 
        #   update as read
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return (see #updateMessages)
        def markRead(message_id)
          updateReadFlag(message_id, false)
        end

        # Mark a message or list of messages as unread
        #
        # @param message_id [#to_s, Array<#to_s>] the message id(s) to 
        #   update as unread
        #
        # @raise [ServiceException] contains the api response in case of failure
        # @return (see #updateMessages)
        def markUnread(message_id)
          updateReadFlag(message_id, true)
        end

      end
    end
  end
end
