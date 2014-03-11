# Licensed by AT&T under 'Software Development Kit Tools Agreement.' 2014 TERMS
# AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION:
# http://developer.att.com/sdk_agreement/ Copyright 2014 AT&T Intellectual
# Property. All rights reserved. http://developer.att.com For more information
# contact developer.support@att.com

require 'cgi'
require 'json'
require_relative '../model/aab'
require_relative '../model/simple_responses'

module Att
  module Codekit
    module Service

      #@author kh455g
      class AABService < CloudService
        SERVICE_URL = "addressBook/v1"

        def createContact(contact)
          response = self.rawCreateContact(contact)
          if response.code == 201
            Model::SuccessCreated.from_response(response)
          else
            raise(ServiceException, "Expected a 201, got: #{response.code}")
          end
        end

        def rawCreateContact(contact)
          url = "#{@fqdn}/#{SERVICE_URL}/contacts"

          begin
            self.post(url, contact.to_json)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end
        end

        def getContact(contact_id, opts={})
          if contact_id.to_s.empty?
            raise(ServiceException, "No contact id specified") 
          end

          q = opts[:quick_contact] || false

          x_fields = opts[:x_fields]

          if q
            x_fields ||= "shallow"
          end

          url = "#{@fqdn}/#{SERVICE_URL}/contacts/#{CGI.escape(contact_id)}"

          begin
            if x_fields
              response = self.get(url, {"x-fields" => x_fields})
            else
              response = self.get(url)
            end
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          r = JSON.parse(response)

          if r["quickContact"]
            Model::QuickContact.createFromParsedJson(r["quickContact"])
          else
            Model::Contact.createFromParsedJson(r["contact"])
          end
        end

        def getContacts(opts={})
          q = opts[:quick_contact] || false

          x_fields = opts[:x_fields]

          if q
            x_fields ||= "shallow" 
          end

          acceptable_params = {
            :Order => opts[:order],
            :orderBy => opts[:order_by],
            :limit => opts[:limit],
            :offset => opts[:offset],
            :formattedName => opts[:formatted_name],
            :firstName => opts[:first_name],
            :lastName => opts[:last_name],
            :nickName => opts[:nickname],
            :email => opts[:email],
            :phone => opts[:phone],
            :organization => (opts[:organization] || opts[:org]),
            :addressLine1 => opts[:address_line_1],
            :addressLine2 => opts[:address_line_2],
            :city => opts[:city],
            :zipcode => (opts[:zipcode] || opts[:zip]),
          }

          qparams = AABService.query_param_string(acceptable_params)

          url = "#{@fqdn}/#{SERVICE_URL}/contacts"
          url << "?#{qparams}" unless qparams.to_s.empty?

          begin
            if x_fields
              response = self.get(url, {"x-fields" => x_fields})
            else
              response = self.get(url)
            end
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end


          if response.code == 200
            Model::ContactsResultSet.createFromJson(response)
          else
            raise(ServiceException, "Expected a 200, got: #{response.code}")
          end
        end

        def getContactGroups(contact_id, opts={})
          if contact_id.to_s.empty?
            raise(ServiceException, "No contact id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/contacts/#{CGI.escape(contact_id)}"
          url << "/groups"

          acceptable_params = {
            :Order => opts[:order],
            :orderBy => opts[:order_by],
            :limit => opts[:limit],
            :offset => opts[:offset],
          }

          qparams = AABService.query_param_string(acceptable_params)

          url << "?#{qparams}" unless qparams.to_s.empty?

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 200
            Model::GroupsResultSet.createFromJson(response)
          else
            raise(ServiceException, "Expected a 200, got: #{response.code}")
          end
        end

        def updateContact(contact_id, contact)
          if contact_id.to_s.empty?
            raise(ServiceException, "No contact id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/contacts/#{CGI.escape(contact_id)}"

          begin
            response = self.patch(url, contact.to_json)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def deleteContact(contact_id)
          if contact_id.to_s.empty?
            raise(ServiceException, "No contact id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/contacts/#{CGI.escape(contact_id)}"

          begin
            response = self.delete(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def createGroup(group)
          url = "#{@fqdn}/#{SERVICE_URL}/groups"

          begin
            response = self.post(url, group.to_json)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 201
            Model::SuccessCreated.from_response(response)
          else
            raise(ServiceException, "Expected a 201, got: #{response.code}")
          end
        end

        def getGroups(opts={})
          url = "#{@fqdn}/#{SERVICE_URL}/groups"

          acceptable_params = {
            :Order => (opts[:order] || opts[:Order]),
            :orderBy => opts[:order_by],
            :limit => opts[:limit],
            :offset => opts[:offset],
            :groupName => (opts[:group_name] || opts[:name])
          }

          qparams = AABService.query_param_string(acceptable_params)

          url << "?#{qparams}" unless qparams.to_s.empty?

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 200
            Model::GroupsResultSet.createFromJson(response)
          else
            raise(ServiceException, "Expected a 200, got: #{response.code}")
          end
        end

        def deleteGroup(group_id)
          if group_id.to_s.empty?
            raise(ServiceException, "No group id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/groups"
          url << "/#{CGI.escape(group_id)}"

          begin
            response = self.delete(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def updateGroup(group_id, group)
          if group_id.to_s.empty?
            raise(ServiceException, "No group id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/groups"
          url << "/#{CGI.escape(group_id)}"

          begin
            response = self.patch(url, group.to_json)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def addContactToGroup(group_id, contacts)
          if group_id.to_s.empty?
            raise(ServiceException, "No group id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/groups"
          url << "/#{CGI.escape(group_id)}/contacts"

          contact_ids = CGI.escape(Array(contacts).join(","))

          url << "?contactIds=#{contact_ids}"

          begin
            response = self.post(url, "")
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def removeContactFromGroup(group_id, contacts)
          if group_id.to_s.empty?
            raise(ServiceException, "No group id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/groups"
          url << "/#{CGI.escape(group_id)}/contacts"

          contact_ids = CGI.escape(Array(contacts).join(","))

          url << "?contactIds=#{contact_ids}"

          begin
            response = self.delete(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def getGroupContacts(group_id, opts={})
          if group_id.to_s.empty?
            raise(ServiceException, "No group id specified") 
          end

          url = "#{@fqdn}/#{SERVICE_URL}/groups"
          url << "/#{CGI.escape(group_id)}/contacts"

          acceptable_params = {
            :Order => opts[:order],
            :orderBy => opts[:order_by],
            :limit => opts[:limit],
            :offset => opts[:offset],
          }

          qparams = AABService.query_param_string(acceptable_params)

          url << "?#{qparams}" unless qparams.to_s.empty?

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          ids = Array.new
          if response.code == 200
            r = JSON.parse(response)
            ids = r["contactIds"]["id"]
          else
            raise(ServiceException, "Expected a 200, got: #{response.code}")
          end
          ids
        end

        def getMyInfo
          url = "#{@fqdn}/#{SERVICE_URL}/myInfo"

          begin
            response = self.get(url)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 200
            Model::MyContactInfo.createFromJson(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

        def updateMyInfo(myinfo)
          url = "#{@fqdn}/#{SERVICE_URL}/myInfo"

          begin
            response = self.patch(url, myinfo.to_json)
          rescue RestClient::Exception => e
            raise(ServiceException, e.response, e.backtrace)
          end

          if response.code == 204
            Model::SuccessNoContent.from_response(response)
          else
            raise(ServiceException, "Expected a 204, got: #{response.code}")
          end
        end

      end # End of service

    end # module Service
  end # module Codekit
end # module Att

#  vim: set ts=8 sw=2 tw=0 et :
